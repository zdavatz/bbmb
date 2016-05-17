#!/usr/bin/env ruby
# TestBbmb -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('../lib', File.dirname(__FILE__))

require "minitest/autorun"
require 'bbmb'

module BBMB
  class TestBbmb < Minitest::Test
    def test_global_readers
      assert_respond_to(BBMB, :config)
      assert_respond_to(BBMB, :persistence)
      assert_respond_to(BBMB, :logger)
      assert_respond_to(BBMB, :server)
    end
  end
end
