#!/usr/bin/env ruby
# Util::TestTargetDir -- bbmb -- 19.04.2007 -- hwyss@ywesee.com


$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/util/target_dir'
require 'flexmock'
require 'fileutils'

module BBMB
  module Util
class TestTargetDir < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    super
    @dir = File.expand_path('../data/destination', 
                            File.dirname(__FILE__))
  end
  def teardown
    super
    FileUtils.rm_r(@dir) if(File.exist? @dir)
  end
  def test_send_order__ftp
    BBMB.config = config = flexmock('config')
    FileUtils.mkdir_p(@dir)
    ftp = "ftp://user:pass@test.host.com#{@dir}"
    config.should_receive(:order_destinations).and_return([ftp])
    config.should_receive(:tmpfile_basename).and_return('bbmb')
    order = flexmock('order')
    order.should_receive(:to_i2).and_return('data')
    order.should_receive(:filename).and_return('order.csv')
    flexstub(Net::FTP).should_receive(:open)\
      .and_return { |host, user, pass, block|
      assert_equal('test.host.com', host)
      assert_equal('user', user)
      assert_equal('pass', pass)
      fsession = flexmock('ftp')
      fsession.should_receive(:put).and_return { |local, remote|
        assert_equal(File.join(@dir, 'order.csv'), remote)
      }
      block.call(fsession)
    }
    TargetDir.send_order(order)
  end
  def test_send_order__local
    BBMB.config = config = flexmock('config')
    FileUtils.mkdir_p(@dir)
    config.should_receive(:order_destinations).and_return([@dir])
    config.should_receive(:tmpfile_basename).and_return('bbmb')
    order = flexmock('order')
    order.should_receive(:to_i2).and_return('data')
    order.should_receive(:filename).and_return('order.csv')
    flexstub(Net::FTP).should_receive(:open).times(0)

    TargetDir.send_order(order)
    path = File.join(@dir, 'order.csv')
    assert File.exists?(path)
    assert_equal("data\n", File.read(path))
  end
end
  end
end
