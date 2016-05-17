#!/usr/bin/env ruby
# Util::TestPasswordGenerator -- bbmb.ch -- 19.10.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require "minitest/autorun"
require 'flexmock/test_unit'
require 'bbmb/util/password_generator'

module BBMB
  module Util
class TestPasswordGenerator < Minitest::Test
  include FlexMock::TestCase
  def test_generate
    customer = flexmock('Customer')
    customer.should_receive(:organisation).and_return('abab')
    customer.should_receive(:firstname).and_return('abab')
    customer.should_receive(:lastname).and_return('abab')
    pass = PasswordGenerator.generate(customer)
    assert_equal 9, pass.length
    assert /\d{4}/.match(pass)
    assert /[!@?*]/.match(pass)
    assert /[ab]{2}/.match(pass)
  end
end
  end
end
