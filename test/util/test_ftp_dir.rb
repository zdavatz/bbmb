#!/usr/bin/env ruby
# Util::TestFtpDir -- bbmb -- 19.04.2007 -- hwyss@ywesee.com


$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/util/ftp_dir'
require 'flexmock'
require 'fileutils'

module BBMB
  module Util
class TestFtpDir < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_send_order
    BBMB.config = config = flexmock('config')
    dir = File.expand_path('../data/destination', File.dirname(__FILE__))
    FileUtils.mkdir_p(dir)
    config.should_receive(:order_destinations).and_return([dir])
    config.should_receive(:tmpfile_basename).and_return('bbmb')
    order = flexmock('order')
    order.should_receive(:to_i2).and_return('data')
    order.should_receive(:filename).and_return('order.csv')
    flexstub(Net::FTP).should_receive(:open)\
      .and_return { |host, user, pass, block|
      fsession = flexmock('ftp')
      fsession.should_receive(:put).and_return { |local, remote|
        assert_equal(File.join(dir, 'order.csv'), remote)
      }
      block.call(fsession)
    }

    FtpDir.send_order(order)
    path = File.join(dir, 'order.csv')
    assert File.exists?(path)
    assert_equal("data\n", File.read(path))
  end
end
  end
end
