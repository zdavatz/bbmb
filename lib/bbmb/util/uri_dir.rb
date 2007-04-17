#!/usr/bin/env ruby
# Util::UriDir -- bbmb -- 17.04.2007 -- hwyss@ywesee.com

require 'bbmb/config'
require 'open-uri'
require 'pp'

module BBMB
  module Util
module UriDir
  def UriDir.send_order(order)
    content = order.to_i2
    BBMB.config.order_destinations.each { |destination|
      uri = File.join(destination, order.filename)
      open(uri, 'w') { |fh| fh.write(content) }
    }
  end
end
  end
end
