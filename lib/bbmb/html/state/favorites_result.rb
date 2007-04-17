#!/usr/bin/env ruby
# Html::State::Result -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/result'
require 'bbmb/html/view/favorites_result'

module BBMB
  module Html
    module State
class FavoritesResult < Result
  VIEW = View::FavoritesResult
  def direct_event
    [:search_favorites, {:query => @query}]
  end
  def _order 
    _customer.favorites
  end
end
    end
  end
end
