#!/usr/bin/env ruby
# Util::PollingManager -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb'
require 'bbmb/util/mail'
require 'fileutils'
require 'uri'
require 'yaml'
require 'net/pop'

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
