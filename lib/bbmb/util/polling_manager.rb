#!/usr/bin/env ruby
# Util::PollingManager -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb'
require 'bbmb/util/mail'
require 'fileutils'
require 'net/ftp'
require 'net/pop'
require 'tmpdir'
require 'uri'
require 'yaml'

module BBMB
  module Util
class FileMission
  attr_accessor :backup_dir, :delete, :directory, :glob_pattern
  def file_paths
    path = File.expand_path(@glob_pattern || '*', @directory)
    Dir.glob(path).collect { |entry|
      File.expand_path(entry, @directory)
    }.compact
  end
  def poll(&block)
    @directory = File.expand_path(@directory, BBMB.config.bbmb_dir)
    file_paths.each { |path|
      poll_path(path, &block)
    }
  end
  def poll_path(path, &block)
    File.open(path) { |io|
      block.call(File.basename(path), io)
    }
  rescue StandardError => err
    BBMB::Util::Mail.notify_error(err)
  ensure
    if(@backup_dir)
      dir = File.expand_path(@backup_dir, BBMB.config.bbmb_dir)
      FileUtils.mkdir_p(dir)
      FileUtils.mv(path, dir)
    elsif(@delete)
      FileUtils.rm(path)
    end
  end
end
class PopMission 
  attr_accessor :host, :port, :user, :pass, :delete
  @@ptrn = /name=(?:(?:(?<quote>['"])(?:=\?.+?\?[QB]\?)?(?<file>.*?)(\?=)?(?<!\\)\k<quote>)|(?:(?<file>.+?)(?:;|$)))/i
  def poll(&block)
    Net::POP3.start(@host, @port || 110, @user, @pass) { |pop|
      pop.each_mail { |mail|
        poll_mail(mail, &block)
      }
    }
  end
  def poll_mail(mail, &block)
    source = mail.pop
    ## work around a bug in RMail::Parser that cannot deal with
    ## RFC-2822-compliant CRLF..
    source.gsub!(/\r\n/, "\n")
    poll_message(RMail::Parser.read(source), &block)
    mail.delete if(@delete)
  rescue StandardError => err
    BBMB::Util::Mail.notify_error(err)
  end
  def poll_message(message, &block)
    if(message.multipart?)
      message.each_part { |part|
        poll_message(part, &block)
      }
    elsif(match = @@ptrn.match(message.header["Content-Type"]))
      block.call(match["file"], message.decode)
    end
  end
end
class FtpMission
  attr_accessor :backup_dir, :delete, :pattern, :directory
  def initialize(*args)
    super
    @regexp = Regexp.new('.*')
  end
  def poll(&block)
    @backup_dir ||= Dir.tmpdir
    FileUtils.mkdir_p(@backup_dir)
    @regexp = Regexp.new(@pattern || '.*')
    uri = URI.parse(@directory)
    locals = []
    Net::FTP.open(uri.host) do |ftp|
      ftp.login uri.user, uri.password
      ftp.chdir uri.path
      ftp.nlst.each do |file|
        if(local = poll_remote ftp, file)
          locals.push local
        end
      end
    end
    locals.each do |path|
      poll_file path, &block
    end
  end
  def poll_file(path, &block)
    File.open(path) { |io|
      block.call(File.basename(path), io)
    }
  rescue StandardError => err
    BBMB::Util::Mail.notify_error(err)
  end
  def poll_remote(ftp, file)
    if(@regexp.match file)
      local = File.join(@backup_dir, file)
      ftp.get file, local
      ftp.delete file if @delete
      local
    end
  end
  def regexp
  end
end
class PollingManager
  def load_sources(&block)
    file = File.open(BBMB.config.polling_file)
    YAML.load_documents(file) { |mission|
      block.call(mission)
    }
  ensure
    file.close if(file)
  end
  def poll_sources(&block)
    load_sources { |source|
      source.poll(&block)
    }
  end
end
  end
end
