#!/usr/bin/env ruby
# Html::State::Order -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/view/order'

module BBMB
  module Html
    module State
class Order < Global
  VIEW = View::Order
  def direct_argument_keys
    [:order_id]
  end
  def direct_event
    [:order, {:order_id => @model.order_id}]
  end
end
    end
  end
end
