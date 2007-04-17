#!/usr/bin/env ruby
# Html::State::Viral::Customer -- bbmb.ch -- 20.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/current_order'
require 'bbmb/html/state/favorites'
require 'bbmb/html/state/favorites_result'
require 'bbmb/html/state/order'
require 'bbmb/html/state/orders'
require 'bbmb/html/state/result'
require 'sbsm/viralstate'

module BBMB
  module Html
    module State
      module Viral
module Customer
  include SBSM::ViralState
  EVENT_MAP = {
    :current_order    =>  State::CurrentOrder,
    :favorites        =>  State::Favorites,
    :orders           =>  State::Orders,
    :search           =>  State::Result,
    :search_favorites =>  State::FavoritesResult,
  }
  def _customer
    @customer ||= Model::Customer.find_by_email(@session.user.name)
  end
  def _increment_order(order)
    quantities = user_input(:quantity)
    if(error?)
      false
    else
      quantities.each { |article_number, quantity|
        order.increment(quantity.to_i, 
                        Model::Product.find_by_article_number(article_number))
      }
      BBMB.persistence.save(order, _customer)
      true
    end
  end
  def _transfer(order)
    if(io = user_input(:file_chooser))
      BBMB::Util::TransferDat.parse(io) { |info|
        if(product = Model::Product.find_by_pcode(info.pcode) \
           || Model::Product.find_by_ean13(info.ean13))
          order.increment(info.quantity, product)
        else
          order.unavailable.push(info)
        end
      }
    end
    self
  end
  def _update_order(order)
    quantities = user_input(:quantity)
    if(error?)
      false
    else
      quantities.each { |article_number, quantity|
        order.add(quantity.to_i, 
                  Model::Product.find_by_article_number(article_number))
      }
      BBMB.persistence.save(order, _customer)
      true
    end
  end
  def clear_favorites
    _customer.favorites.clear
    self
  end
  def clear_order
    _customer.current_order.clear
    self
  end
  def delete_unavailable
    if(@model.respond_to?(:unavailable) && (ids = user_input(:quantity)))
      ids.each { |id, qty|
        @model.unavailable.delete_at(id.to_i)
      }
      BBMB.persistence.save(@model)
    end
    self
  end
  def favorite_product
    if(_update_order(_customer.favorites))
      trigger(:favorites)
    end
  end
  def favorite_transfer
    _transfer(_customer.favorites)
  end
  def home
    trigger(@session.user.home || :current_order)
  end
  def increment_order
    if(_increment_order(_customer.current_order))
      trigger(:current_order)
    end
  end
  def order
    if(order_id = @session.user_input(:order_id))
      customer_id, commit_id = order_id.split('-', 2)
      State::Order.new(@session, _customer.order(commit_id))
    end
  end
  def order_product
    if(_update_order(_customer.current_order))
      trigger(:current_order)
    end
  end
  def order_transfer
    _transfer(_customer.current_order)
  end
  def scan
    success = false
    if(port = user_input(:comport))
      @session.set_cookie_input(:comport, port)
    end
    if(@model.is_a?(Model::Order))
      user_input(:EAN_13).each { |key, quantity|
        success = true
        if(product = Model::Product.find_by_ean13(key))
          @model.increment(quantity.to_i, product)
        else
          info = Model::Order::Info.new
          info.ean13 = key
          info.quantity = quantity
          @model.unavailable.push(info)
        end
      }
      BBMB.persistence.save(@model)
    end
    State::Json.new(@session, {:success => success})
  end
  def zone_navigation
    [ :current_order, :orders, :favorites ]
  end
end
      end
    end
  end
end
