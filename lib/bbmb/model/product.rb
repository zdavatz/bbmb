#!/usr/bin/env ruby
# Model::Product -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/util/numbers'

module BBMB
  module Model
class ProductInfo
  include Util::Numbers
  attr_reader :article_number
  attr_accessor :catalogue1, :catalogue2, :catalogue3, :description,
    :ean13, :expiry_date, :partner_index, :pcode, :promotion, :sale,
    :status
  int_accessor :l1_qty, :l2_qty, :l3_qty, :l4_qty, :l5_qty, :l6_qty, :mwst
  money_accessor :price, :l1_price, :l2_price, :l3_price, :l4_price, 
    :l5_price, :l6_price
  def initialize(article_number)
    @article_number = article_number
    @backorder = false
  end
  def price(level=nil)
    if(level.nil?)
      @price
    else
      res = @price
      (1..6).each { |num|
        if(res.nil? || ((qty = instance_variable_get("@l#{num}_qty")) \
                        && level >= qty))
          res = instance_variable_get("@l#{num}_price") || res
        end
      }
      res || Util::Money.new(0)
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
    when true, 1, /^(ja|yes|1)$/i
      @backorder = true
    else
      @backorder = false
    end
  end
  def to_info
    info = ProductInfo.new(@article_number)
    [ :catalogue1, :catalogue2, :catalogue3, :description, :ean13,
      :expiry_date, :partner_index, :pcode, :promotion, :sale, :status,
      :l1_qty, :l2_qty, :l3_qty, :l4_qty, :l5_qty, :l6_qty, :mwst,
      :price, :l1_price, :l2_price, :l3_price, :l4_price, :l5_price,
      :l6_price
    ].each { |key|
      info.send("#{key}=", self.send(key))
    }
    info
  end
end
  end
end
