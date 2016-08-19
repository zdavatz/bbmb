#!/usr/bin/env ruby
# Model::Product -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/model/subject'
require 'bbmb/util/numbers'
require 'date'

module BBMB
  module Model
class ProductInfo < Subject
  include Util::Numbers
  attr_reader :article_number, :backorder
  attr_accessor :backorder_date, :commit_date, :ean13, :expiry_date,
    :partner_index, :pcode, :promotion, :sale, :status
  multilingual :description, :catalogue1, :catalogue2, :catalogue3
  int_accessor :l1_qty, :l2_qty, :l3_qty, :l4_qty, :l5_qty, :l6_qty
  money_accessor :price, :l1_price, :l2_price, :l3_price, :l4_price, 
    :l5_price, :l6_price, :vat
  def initialize(article_number)
    @article_number = article_number
    @backorder = false
  end
  def current_promo
    [@sale, @promotion].find { |promo| promo }
  end
  def freebies(level)
    (promo = current_promo) && promo.freebies(level)
  end
  def price(qty=nil)
    qty ||= 1
    res = @price
    (1..6).each { |num|
      if(res.nil? || ((tmp = instance_variable_get("@l#{num}_qty")) \
                      && qty >= tmp))
        res = instance_variable_get("@l#{num}_price") || res
      end
    }
    if((pr = current_promo) && (((price = pr.price_qty(qty)) && price > res) \
       || ((price = pr.l1_price) && price > res)))
      res = price
    end
    res
  end
  def price_base
    price(1)
  end
  def price_effective(qty=nil)
    price = price_qty(qty)
    if((promo = current_promo) && (discount = promo.discount(qty)))
      price *= (100.0 - discount) / 100.0
    end
    price || Util::Money.new(0)
  end
  def price_qty(qty=nil)
    ((promo = current_promo) && promo.price_qty(qty)) \
      || price(qty)
  end
  def qty_level(level=nil)
    if((promo = current_promo) && promo.has_price_qty?)
      promo.qty_level(level)
    else
      instance_variable_get("@l#{level}_qty")
    end
  end

  def ==(other)
    other.is_a?(ProductInfo) && @article_number == other.article_number
  end

  def to_info
    self
  end

  def to_product
    convert_to(Product)
  end

  private

  # Converts as new instance
  #
  # @param [Class] klass New class {Product|ProductInfo}
  # @return [Array(Product,ProductInfo)] new instance
  def convert_to(klass)
    base_keys = %i{
      backorder_date catalogue1 catalogue2 catalogue3
      description ean13 expiry_date partner_index pcode status
    }
    keys = case klass.to_s
           when 'BBMB::Model::Product'
             base_keys
           when 'BBMB::Model::ProductInfo'
             base_keys += %i{
               vat price
               l1_qty l2_qty l3_qty l4_qty l5_qty l6_qty
               l1_price l2_price l3_price l4_price l5_price l6_price
             }
           else
             raise "Unknown class #{klass}"
           end
    obj = klass.new(@article_number)
    keys.each { |key| obj.send("#{key}=", self.send(key)) }
    obj.promotion = @promotion.dup if (@promotion && @promotion.current?)
    obj.sale      = @sale.dup      if (@sale && @sale.current?)
    obj
  end
end
class Product < ProductInfo
  def backorder=(value)
    case value
    when true, 1, /^(ja?|y(es)?|1)$/i
      @backorder = true
    else
      @backorder = false
    end
  end
  def current_promo
    [@sale, @promotion].find { |promo| promo && promo.current? }
  end

  def to_product
    self
  end

  def to_info
    convert_to(ProductInfo)
  end
end
  end
end
