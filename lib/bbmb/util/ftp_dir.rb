#!/usr/bin/env ruby
# Util::FtpDir -- bbmb -- 17.04.2007 -- hwyss@ywesee.com

require 'bbmb/config'
require 'net/ftp'
require 'tempfile'

module BBMB
  module Util
module FtpDir
  def FtpDir.send_order(order)
    content = order.to_i2
    basename = BBMB.config.tmpfile_basename
    BBMB.config.order_destinations.each { |destination|
      uri = URI.parse(File.join(destination, order.filename))
      Tempfile.open(basename) { |tmp|
        tmp.puts(content)
        tmp.flush
        Net::FTP.open(uri.host, uri.user, uri.password) { |ftp|
          ftp.put(tmp.path, uri.path)
        }
      }
    }
  end
end
  end
end
