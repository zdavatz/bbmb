#!/usr/bin/env ruby
# Html::State::Global -- bbmb.ch -- 18.09.2006 -- hwyss@ywesee.com
require 'sbsm/state'
require 'bbmb/html/state/global_predefine'
require 'bbmb/html/state/init'
require 'bbmb/html/state/change_password'
require 'bbmb/html/state/current_order'
require 'bbmb/html/state/customer'
require 'bbmb/html/state/customers'
require 'bbmb/html/state/favorites'
require 'bbmb/html/state/favorites_result'
require 'bbmb/html/state/history'
require 'bbmb/html/state/info'
require 'bbmb/html/state/json'
require 'bbmb/html/state/login'
require 'bbmb/html/state/order'
require 'bbmb/html/state/orders'
require 'bbmb/html/state/result'
require 'bbmb/html/state/show_pass'

module BBMB
  module Html
    module State
class Global < SBSM::State
  def initialize(first, second)
    super(first, second)
  end
  def logout
    @session.logout
    State::Login.new(@session, nil)
  end
  def direct_arguments
    if(keys = direct_argument_keys)
      keys.inject({}) { |memo, key|
        memo.store(key, @session.user_input(key))
        memo
      }
    end
  end
  def direct_argument_keys
  end
  def direct_request?(event)
    requested_event(event) == direct_event
  end
  def requested_event(event)
    if(args = direct_arguments)
      [ event, args ]
    else
      event
    end
  end
  def trigger(event)
    if(direct_request?(event))
      self
    else
      super
    end
  end
  def user_input(*args)
    data = super
    data.each { |key, val|
      if(val.is_a?(String))
        data.store(key, val.empty? ? nil : u(val))
      end
    }
    data
  end
end
    end
  end
end
