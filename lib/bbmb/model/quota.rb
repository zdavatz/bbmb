#!/usr/bin/env ruby
# Model::Deal -- bbmb -- 11.04.2007 -- hwyss@ywesee.com

require 'bbmb/util/numbers'

module BBMB
  module Model
class Quota
  class << self
    def delegate(*keys)
      keys.each { |key|
        define_method(key) { @product.send(key) } 
      }
    end
  end
  include Util::Numbers
  attr_reader :product
  attr_accessor :start_date, :end_date
  int_accessor :target, :actual, :difference
  money_accessor :price
  delegate :article_number, :description
  def initialize(product)
    @product = product
  end
end
  end
end
