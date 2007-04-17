#!/usr/bin/env ruby
# Html::State::History -- bbmb.ch -- 03.10.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/view/history'

module BBMB
  module Html
    module State
class History < Global
  VIEW = View::History
  class PositionFacade
    attr_reader :quantity, :total
    def initialize
      @positions = []
      @quantity = 0
      @prices = []
      @total = 0
    end
    def add(position)
      @positions.push(position)
      @quantity += position.quantity
      @prices.push(position.price)
      @total = position.total + @total
    end
    def order_count
      @positions.size
    end
    def price_extremes
      [@prices.min, @prices.max]
    end
    def respond_to?(key)
      super || @positions.last.respond_to?(key)
    end
    def method_missing(key, *args, &block)
      @positions.last.send(key, *args, &block)
    end
  end
  class HistoryFacade
    include Enumerable
    attr_accessor :sorted
    def initialize
      @map = {}
      @positions = []
    end
    def add(order)
      order.each { |position|
        add_position(position)
      }
    end
    def add_position(position)
      key = position.article_number
      pos = @map.fetch(key) { 
        pos = @map.store(key, PositionFacade.new)
        @positions = @map.values
        pos
      }
      pos.add(position)
    end
    def each(&block)
      @positions.each(&block)
    end
    def empty?
      @positions.empty?
    end
    def reverse!
      @positions.reverse!
    end
    def sort!(*args, &block)
      @positions.sort!(*args, &block)
    end
    def turnaround
      @positions.inject(0) { |inj, position| 
        position.total + inj
      }
    end
  end
  def init
    @model = HistoryFacade.new
    if(@customer = _customer)
      @customer.orders.sort_by { |order| order.commit_time }.each { |order|
        @model.add(order)
      }
    end
  end
  def direct_argument_keys
    [:customer_id]
  end
  def direct_event
    [:history, {:customer_id => @customer.customer_id}]
  end
end
    end
  end
end
