#!/usr/bin/env ruby
# Html::State::Orders -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/view/orders'

module BBMB
  module Html
    module State
class Orders < Global
  DIRECT_EVENT = :orders
  VIEW = View::Orders
  def init
    @model = _customer.orders
  end
end
    end
  end
end
