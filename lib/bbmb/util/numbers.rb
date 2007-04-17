#!/usr/bin/env ruby
# Util::Money -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

module BBMB
  module Util
module Numbers
  def Numbers.append_features(mod)
    super
    mod.module_eval {
      class << self
        def money_accessor(*keys)
          keys.each { |key|
            attr_reader key
            define_method("#{key}=") { |value|
              money = Util::Money.new(value) if(value.to_f > 0)
              instance_variable_set("@#{key}", money)
            }
          }
        end
        def int_accessor(*keys)
          keys.each { |key|
            attr_reader key
            define_method("#{key}=") { |value|
              int = value.to_i if(value)
              instance_variable_set("@#{key}", int)
            }
          }
        end
      end
    }
  end
end
class Money
  attr_reader :credits
  include Comparable
  def initialize(amount)
    @credits = (amount.to_f * 100).round
  end
  def to_f
    @credits.to_f / 100
  end
  def to_s
    sprintf("%1.2f", to_f)
  end
  def +(other)
    Money.new(to_f + other.to_f)
  end
  def -(other)
    Money.new(to_f - other.to_f)
  end
  def *(other)
    Money.new(to_f * other.to_f)
  end
  def /(other)
    Money.new(to_f / other.to_f)
  end
  def <=>(other)
    case other
    when Money
      @credits <=> other.credits
    else
      to_f <=> other.to_f
    end
  end
end
  end
end
