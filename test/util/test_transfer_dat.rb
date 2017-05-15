#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test_helper'
require 'stringio'
require 'bbmb/util/transfer_dat'

module BBMB
  module Util
class TestTransferDat <  Minitest::Test
  include FlexMock::TestCase
  def setup
    super
  end
  def teardown
    super
  end
  def test_parse_line
    src = "030201899    0624427Mycolog creme tube 15 g                           000176803710902940"
    info = TransferDat.parse_line(src)
    assert_instance_of(Model::Order::Info, info)
    assert_equal '624427', info.pcode
    assert_equal 'Mycolog creme tube 15 g', info.description
    assert_equal '7680371090294', info.ean13
    assert_equal 1, info.quantity
  end
  def test_parse_line__error
    info = nil
    info = TransferDat.parse_line("")
    assert_nil(info)
  end
  def test_parse
    src = <<-EOS.strip
030201899    0624427Mycolog creme tube 15 g                           000176803710902940
030201899    1590386Risperdal cpr 20 1 mg                             000176805231601410
    EOS
    count = 0
    TransferDat.parse(StringIO.new(src)) do |info|
      assert_instance_of(Model::Order::Info, info)
      count += 1
    end
    assert_equal(2, count)
  end
end
  end
end
