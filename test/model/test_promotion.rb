#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test_helper'
require 'bbmb/model/promotion'

module BBMB
  module Model
class TestPromotion < Minitest::Test
  def setup
    super
    @promo = Promotion.new
  end
  def test_current
    assert_equal(false, @promo.current?)
    @promo.start_date = Date.today + 1
    assert_equal(false, @promo.current?)
    @promo.start_date = Date.today
    assert_equal(true, @promo.current?)
    @promo.end_date = Date.today
    assert_equal(true, @promo.current?)
    @promo.start_date = nil
    assert_equal(true, @promo.current?)
    @promo.end_date = Date.today - 1
    assert_equal(false, @promo.current?)
  end
  def test_price_qty
    assert_nil(@promo.price_qty(1))
    @promo.l1_qty = 6
    @promo.l1_price = 10
    assert_nil(@promo.price_qty(5))
    assert_equal(10, @promo.price_qty(6))
    @promo.l1_discount = 10
    assert_nil(@promo.price_qty(5))
    assert_equal(10, @promo.price_qty(6))
  end
end
  end
end
