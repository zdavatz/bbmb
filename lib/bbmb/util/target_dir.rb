#!/usr/bin/env ruby
# Util::TargetDir -- bbmb -- 17.04.2007 -- hwyss@ywesee.com

require 'bbmb/config'
require 'net/ftp'
require 'tempfile'
require 'uri'

module BBMB
  module Util
module TargetDir
  def TargetDir.send_order(order)
    content = order.to_target_format
    basename = BBMB.config.tmpfile_basename
    BBMB.config.order_destinations.each { |destination|
      uri = URI.parse(File.join(destination, order.filename))
      case uri.scheme
      when "ftp"
        Tempfile.open(basename) { |tmp|
          tmp.puts(content)
          tmp.flush
          Net::FTP.open(uri.host, uri.user, uri.password) { |ftp|
            ftp.put(tmp.path, uri.path)
          }
        }
      else
        path = File.expand_path(uri.path, BBMB.config.bbmb_dir)
        File.open(path, 'w') { |fh|
          fh.puts content
        }
      end
    }
  end
end
  end
end
