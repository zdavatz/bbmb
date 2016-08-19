require 'test_helper'
require 'bbmb/model/product'
require 'bbmb/model/promotion'

module BBMB
  module Model
class TestProduct < Minitest::Test
  def setup
    @product = Product.new("article_number")
  end
  def test_int_accessors
    [:l1_qty, :l2_qty, :l3_qty, :l4_qty, :l5_qty, :l6_qty ].each { |key|
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
      :l6_price, :vat ].each { |key|
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
    refute_equal(@product, 'article_number')
    other = Product.new("article_number")
    assert_equal(@product, other)
    other = Product.new("foobar")
    refute_equal(@product, other)
  end
  def test_price
    assert_equal(nil, @product.price)
    assert_equal(0, @product.price_effective)
    assert_equal(nil, @product.price(1))
    assert_equal(0, @product.price_effective(1))
    @product.l1_price = 11.50
    assert_equal(11.50, @product.price)
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

  def test_to_info
    info = @product.to_info
    assert_instance_of(ProductInfo, info)
    assert_equal('article_number', info.article_number)
    assert_equal(info, info.to_info)
  end

  def test_to_product
    product = @product.to_info.to_product
    assert_instance_of(Product, product)
    assert_equal('article_number', product.article_number)
    assert_equal(product, product.to_product)
    %w{
      backorder_date catalogue1 catalogue2 catalogue3
      description ean13 expiry_date partner_index pcode status
    }.map do |attr|
      assert_equal(@product.send(attr), product.send(attr))
    end
    assert_equal(@product.promotion, product.promotion)
    assert_equal(@product.sale, product.sale)
  end

  def test_price_levels__no_promo
    @product.l1_qty = 1
    @product.l1_price = 10
    assert_equal(10, @product.price_qty(1))
    assert_equal(10, @product.price_qty(6))
    @product.l2_qty = 6
    @product.l2_price = 8
    assert_equal(10, @product.price_qty(1))
    assert_equal(8, @product.price_qty(6))
    assert_equal(8, @product.price_qty(12))
    @product.l3_qty = 12
    @product.l3_price = 6
    assert_equal(10, @product.price_qty(1))
    assert_equal(8, @product.price_qty(6))
    assert_equal(6, @product.price_qty(12))
  end
  def test_price_levels__with_old_promo
    @product.promotion = promo = Promotion.new
    promo.start_date = Date.today - 2
    promo.end_date = Date.today - 1
    promo.l1_qty = 1
    promo.l1_price = 8
    promo.l2_qty = 12
    promo.l2_price = 6
    @product.l1_qty = 1
    @product.l1_price = 10
    assert_equal(10, @product.price_qty(1))
    assert_equal(10, @product.price_qty(6))
    @product.l2_qty = 6
    @product.l2_price = 8
    assert_equal(10, @product.price_qty(1))
    assert_equal(8, @product.price_qty(6))
    assert_equal(8, @product.price_qty(12))
    @product.l3_qty = 12
    @product.l3_price = 6
    assert_equal(10, @product.price_qty(1))
    assert_equal(8, @product.price_qty(6))
    assert_equal(6, @product.price_qty(12))
  end
  def test_price_levels__with_current_promo
    @product.promotion = promo = Promotion.new
    promo.start_date = Date.today - 1
    promo.end_date = Date.today + 1
    promo.l1_qty = 1
    promo.l1_price = 8
    promo.l2_qty = 12
    promo.l2_price = 5
    @product.l1_qty = 1
    @product.l1_price = 10
    @product.l2_qty = 6
    @product.l2_price = 8
    @product.l3_qty = 12
    @product.l3_price = 6
    assert_equal(8, @product.price_qty(1))
    assert_equal(8, @product.price_qty(6))
    assert_equal(5, @product.price_qty(12))
  end
  def test_price_levels__with_promo_override
    @product.promotion = promo = Promotion.new
    promo.start_date = Date.today - 1
    promo.end_date = Date.today + 1
    promo.l1_qty = 6
    promo.l1_price = 10
    promo.l2_qty = 12
    promo.l2_price = 5
    @product.l1_qty = 1
    @product.l1_price = 9
    @product.l2_qty = 6
    @product.l2_price = 8
    @product.l3_qty = 12
    @product.l3_price = 6
    assert_equal(10, @product.price_qty(1))
    assert_equal(10, @product.price_qty(6))
    assert_equal(5, @product.price_qty(12))
  end
  def test_freebies__no_promo
    assert_equal(nil, @product.freebies(1))
  end
  def test_freebies__with_old_promo
    @product.promotion = promo = Promotion.new
    promo.start_date = Date.today - 2
    promo.end_date = Date.today - 1
    promo.l1_qty = 6
    promo.l1_price = 8
    promo.l1_free = 1
    promo.l2_qty = 12
    promo.l2_price = 7
    promo.l2_free = 3
    assert_equal(nil, @product.freebies(5))
    assert_equal(nil, @product.freebies(6))
  end
  def test_freebies__with_current_promo
    @product.promotion = promo = Promotion.new
    promo.start_date = Date.today - 1
    promo.end_date = Date.today + 1
    promo.l1_qty = 6
    promo.l1_price = 8
    promo.l1_free = 1
    promo.l2_qty = 12
    promo.l2_price = 7
    promo.l2_free = 3
    assert_equal(nil, @product.freebies(5))
    assert_equal(1, @product.freebies(6))
    assert_equal(1, @product.freebies(11))
    assert_equal(3, @product.freebies(12))
  end
  def test_discount__use_normal_price_levels
    @product.l1_qty = 1
    @product.l1_price = 99.50
    @product.l2_qty = 3
    @product.l2_price = 94.50
    @product.l3_qty = 6
    @product.l3_price = 88.50
    @product.sale = promo = Promotion.new
    promo.start_date = Date.today - 1
    promo.end_date = Date.today + 1
    promo.l1_qty = 1
    promo.l1_discount = 50
    promo.l1_price = 0
    promo.l1_free = 0
    assert_equal(99.50, @product.price_qty(1))
    assert_equal(99.50, @product.price_qty(2))
    assert_equal(94.50, @product.price_qty(3))
    assert_equal(94.50, @product.price_qty(5))
    assert_equal(88.50, @product.price_qty(6))
    assert_equal(49.75, @product.price_effective(1))
  end
  def test_qty_level__promo
    @product.l1_qty = 1
    @product.l2_qty = 10
    @product.promotion = promo = Promotion.new
    promo.start_date = Date.today - 1
    promo.end_date = Date.today + 1
    assert_equal(1, @product.qty_level(1))
    assert_equal(10, @product.qty_level(2))
    promo.l1_qty = 5
    assert_equal(1, @product.qty_level(1))
    assert_equal(10, @product.qty_level(2))
    promo.l1_price = 2
    assert_equal(5, @product.qty_level(1))
    assert_equal(nil, @product.qty_level(2))
  end
end
  end
end
