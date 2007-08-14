#!/usr/bin/env ruby
# Model::Product -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/model/subject'
require 'bbmb/util/numbers'
require 'date'

module BBMB
  module Model
class ProductInfo < Subject
  include Util::Numbers
  attr_reader :article_number
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
    price
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
  def to_info
		self
  end
  def ==(other)
    other.is_a?(ProductInfo) && @article_number == other.article_number
  end
end
class Product < ProductInfo
  attr_reader :backorder
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
  def to_info
    info = ProductInfo.new(@article_number)
    [ :backorder_date, :catalogue1, :catalogue2, :catalogue3,
      :description, :ean13, :expiry_date, :partner_index, :pcode,
      :status, :l1_qty, :l2_qty, :l3_qty, :l4_qty, :l5_qty, :l6_qty, :vat,
      :price, :l1_price, :l2_price, :l3_price, :l4_price, :l5_price, :l6_price
    ].each { |key|
      info.send("#{key}=", self.send(key))
    }
    info.promotion = @promotion.dup if(@promotion && @promotion.current?)
    info.sale = @sale.dup if(@sale && @sale.current?)
    info
  end
end
  end
end
