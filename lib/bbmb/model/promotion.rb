#!/usr/bin/env ruby
# Model::Promotion -- bbmb -- 10.04.2007 -- hwyss@ywesee.com

require 'bbmb/model/subject'
require 'bbmb/util/numbers'
require 'date'

module BBMB
  module Model
class Promotion < Subject
  include Util::Numbers
  attr_accessor :end_date, :start_date
  int_accessor :l1_qty, :l2_qty, :l3_qty, :l4_qty, 
    :l1_free, :l2_free, :l3_free, :l4_free, 
    :l1_discount, :l2_discount, :l3_discount, :l4_discount
  money_accessor :l1_price, :l2_price, :l3_price, :l4_price
  multilingual :lines
  def current?
    today = Date.today
    !!(@start_date || @end_date) \
      && (@start_date.nil? || today >= @start_date) \
      && (@end_date.nil? || today <= @end_date)
  end
  def discount(qty)
    data_qty(qty, "discount")
  end
  def freebies(qty)
    data_qty(qty, "free")
  end
  def price_qty(qty)
    data_qty(qty, "price")
  end
  def price_effective(qty)
    price = price_qty(qty)
    if(price && (discount = discount(qty)))
      price = price * (100.0 - discount) / 100.0
    end
    price
  end
  def qty_level(level)
    instance_variable_get("@l#{level}_qty")
  end
  private
  def data_qty(qty, key)
    return if qty.nil?
    res = nil
    (1..4).each { |num|
      if((tmp = qty_level(num)) && qty >= tmp)
        res = instance_variable_get("@l#{num}_#{key}") || res
      end
    }
    res
  end
end
  end
end
