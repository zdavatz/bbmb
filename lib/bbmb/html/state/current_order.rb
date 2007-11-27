#!/usr/bin/env ruby
# Html::State::CurrentOrder -- bbmb.ch -- 20.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/state/info'
require 'bbmb/html/state/json'
require 'bbmb/html/view/current_order'
require 'bbmb/util/mail'
require 'bbmb/util/target_dir'
require 'bbmb/util/transfer_dat'

module BBMB
  module Html
    module State
class CurrentOrder < Global
  DIRECT_EVENT = :current_order
  VIEW = View::CurrentOrder
  def init
    @model = _customer.current_order
    @model.calculate_effective_prices
  end
  def ajax
    do_update
    data = {}
    [ :reference, :comment, :priority, :total ].each { |key|
      data.store key, @model.send(key).to_s
    }
    State::Json.new(@session, data)
  end
  def commit
    ## update most recent values and ensure @model = _customer.current_order
    do_update 
    _customer.commit_order!
    BBMB::Util::Mail.send_order(@model)
    BBMB::Util::TargetDir.send_order(@model)
    @model = _customer.current_order
    Info.new(@session, :message => :order_sent, 
             :event => :current_order)
  rescue StandardError => err
    BBMB::Util::Mail.notify_error(err)
    Info.new(@session, :message => :order_problem, 
             :event => :current_order)
  end
  def do_update
    @model = _customer.current_order
    keys = [ :comment, :priority, :reference ]
    input = user_input(keys)
    unless(error?)
      input.each { |key, value|
        @model.send("#{key}=", value)
      }
      case @model.priority
      when 40
        @model.shipping = 80
      when 41
        @model.shipping = 50
      else
        @model.shipping = 0
      end
      BBMB.persistence.save(@model)
    end
  end
end
    end
  end
end
