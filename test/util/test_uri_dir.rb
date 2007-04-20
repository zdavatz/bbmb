#!/usr/bin/env ruby
# Util::TestUriDir -- bbmb -- 19.04.2007 -- hwyss@ywesee.com


$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/util/uri_dir'
require 'flexmock'
require 'fileutils'

module BBMB
  module Util
class TestUriDir < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_send_order
    BBMB.config = config = flexmock('config')
    dir = File.expand_path('../data/destination', File.dirname(__FILE__))
    FileUtils.mkdir_p(dir)
    config.should_receive(:order_destinations).and_return([dir])
    order = flexmock('order')
    order.should_receive(:to_i2).and_return('data')
    order.should_receive(:filename).and_return('order.csv')
    UriDir.send_order(order)
    path = File.join(dir, 'order.csv')
    assert File.exists?(path)
    assert_equal("data\n", File.read(path))
  end
end
  end
end

