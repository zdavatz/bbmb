#!/usr/bin/env ruby
# Html::View::Result -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/result'

module BBMB
  module Html
    module View
class FavoritesProducts < Products
  EVENT = :favorite_product
  FORM_NAME = 'products'
  CSS_ID = 'favorites'
end
class FavoritesResultComposite < ResultComposite
  COMPONENTS = {
    [0,0] => Search,
    [1,0] => :product_count,
    [0,1] => FavoritesProducts,
  }
end
class FavoritesResult < Template
  CONTENT = FavoritesResultComposite
end
    end
  end
end
