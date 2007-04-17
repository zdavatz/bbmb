#!/usr/bin/env ruby
# Html::State::Favorites -- bbmb.ch -- 28.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/view/favorites'

module BBMB
  module Html
    module State
class Favorites < Global
  DIRECT_EVENT = :favorites
  VIEW = View::Favorites
  def init
    @model = _customer.favorites
  end
end
    end
  end
end
