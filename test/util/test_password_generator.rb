#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test_helper'
require 'bbmb/util/password_generator'

module BBMB
  module Util
class TestPasswordGenerator < Minitest::Test
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
