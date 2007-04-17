#!/usr/bin/env ruby
# Html::Util::Validator -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'sbsm/validator'

module BBMB
  module Html
    module Util
class Validator < SBSM::Validator
  ENUMS = {
    :canton				=>	[
      nil, "AG", "AI", "AR", "BE", "BL", "BS", "FR", "GE", "GL", "GR", "JU",
      "LU", "NE", "NW", "OW", "SG", "SH", "SO", "SZ", "TG", "TI", "UR", "VD",
      "VS", "ZG", "ZH" ],
    :title => [nil, 'title_f', 'title_m']
  }
  EVENTS = [ :ajax, :change_pass, :clear_favorites, :clear_order, :commit,
    :current_order, :customer, :customers, :delete_unavailable, :favorites,
    :favorite_product, :favorite_transfer, :generate_pass, :history, :home,
    :increment_order, :login, :logout, :order, :orders, :order_product,
    :order_transfer, :save, :scan, :show_pass, :search, :search_favorites,
    :sort ]
  FILES = [ :file_chooser ]
  NUMERIC = [ :comport, :customer_id, :EAN_13, :index, :plz, :priority,
    :quantity ]
  STRINGS = [ :address1, :address2, :address3, :city, :comment,
    :drtitle, :fax, :filter, :firstname, :lastname, :order_id,
    :organisation, :phone_business, :phone_mobile, :phone_private,
    :query, :reference, :sortvalue ]
  def ean13(value)
    return nil if(value.empty?)
    match = /\d{13}/.match(value.to_s)
    unless match
      raise SBSM::InvalidDataError.new(:e_invalid_ean13, :ean13, value) 
    end
    values = match[0].split("")
    check = values.pop
    sum = 0
    values.each_with_index { |val, index| 
      modulus = ((index%2)*2)+1	
      sum += (modulus*val.to_i)
    }
    unless (check.to_i == (10-(sum%10))%10)
      raise SBSM::InvalidDataError.new(:e_invalid_ean13, :ean13, value) 
    end
    match[0]
  end
  def perform_validation(key, value)
    super(key, u(value))
  end
end
    end
  end
end
