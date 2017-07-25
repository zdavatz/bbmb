#!/usr/bin/env ruby
# TransferDat -- bbmb -- 31.10.2002 -- hwyss@ywesee.com

require 'bbmb/model/order'

module BBMB
  module Util
module TransferDat
  def TransferDat.parse(io)
    begin
      io.rewind
      data = io.read
      lines = data.split(/[\r\n]+/)
    rescue ArgumentError => error
      raise error unless io.is_a?(File)
      lines = File.open(io, external_encoding: Encoding::ISO_8859_1).read.split(/[\r\n]+/)
    end
    lines.collect { |line|
      if(parsed = parse_line(line))
        yield parsed
      end
    }
  end
  def TransferDat.parse_line(line)
    begin
      result = Model::Order::Info.new
      result.pcode  = line[13,7].to_i.to_s
      result.description = line[20,50].strip
      result.ean13 = line[74,13]
      result.quantity = line[70,4].to_i
      result
    rescue Exception => e
      SBSM.info('transfer') {
        [e.class, e.message, e.backtrace].pretty_inspect
      }
    end
  end
end
  end
end
