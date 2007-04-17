#!/usr/bin/env ruby
# Model::TestProduct -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/model/product'

module BBMB
  module Model
class TestProduct < Test::Unit::TestCase
  def setup
    @product = Product.new("article_number")
  end
  def test_int_accessors
    [:l1_qty, :l2_qty, :l3_qty, :l4_qty, :l5_qty, :l6_qty, 
      :mwst ].each { |key|
      assert_nil(@product.send(key))
      @product.send("#{key}=", "2")
      int = @product.send(key)
      assert_instance_of(Fixnum, int)
      assert_equal(2, int)
      @product.send("#{key}=", nil)
      assert_nil(@product.send(key))
    }
  end
  def test_money_accessors
    [:price, :l1_price, :l2_price, :l3_price, :l4_price, :l5_price,
      :l6_price ].each { |key|
      assert_nil(@product.send(key))
      @product.send("#{key}=", "1.23")
      price = @product.send(key)
      assert_instance_of(Util::Money, price)
      assert_equal(1.23, price)
      @product.send("#{key}=", nil)
      assert_nil(@product.send(key))
    }
  end
  def test_backorder_accessor
    assert_equal(false, @product.backorder)
    @product.backorder = "yes"
    assert_equal(true, @product.backorder)
    @product.backorder = "no"
    assert_equal(false, @product.backorder)
    @product.backorder = 1
    assert_equal(true, @product.backorder)
    @product.backorder = "1"
    assert_equal(true, @product.backorder)
    @product.backorder = nil
    assert_equal(false, @product.backorder)
  end
  def test_equals
    assert_not_equal(@product, 'article_number')
    other = Product.new("article_number")
    assert_equal(@product, other)
    other = Product.new("foobar")
    assert_not_equal(@product, other)
  end
  def test_price
    assert_equal(nil, @product.price)
    assert_equal(0, @product.price(1))
    @product.l1_price = 11.50
    assert_equal(nil, @product.price)
    assert_equal(11.50, @product.price(1))
    @product.price = 12.50
    assert_equal(12.50, @product.price)
    @product.l1_qty = 1
    assert_equal(11.50, @product.price(1))
    @product.l1_qty = 2
    assert_equal(12.50, @product.price(1))
    @product.l2_qty = 3
    assert_equal(11.50, @product.price(3))
    @product.l2_price = 13.50
    assert_equal(13.50, @product.price(3))
    @product.l3_qty = 4
    @product.l3_price = 14.50
    assert_equal(13.50, @product.price(3))
    assert_equal(14.50, @product.price(4))
    assert_equal(14.50, @product.price(5))
    assert_equal(14.50, @product.price(6))
    @product.l6_qty = 6
    @product.l6_price = 16.50
    assert_equal(16.50, @product.price(6))
  end
  def test_info
    info = @product.to_info
    assert_instance_of(ProductInfo, info)
    assert_equal('article_number', info.article_number)
    info1 = info.to_info
    assert_equal(info, info1)
  end
end
  end
end
