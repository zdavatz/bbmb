#!/usr/bin/env ruby
# Html::View::Favorites -- bbmb.ch -- 28.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/current_order'
require 'htmlgrid/formlist'

module BBMB
  module Html
    module View
class ClearFavorites < ClearOrder
  EVENT = :clear_favorites
end
class SearchFavorites < Search
  EVENT = :search_favorites
end
class FavoritesPositions < Positions
  include Backorder
  include PositionMethods
  CSS_ID = 'favorites'
  COMPONENTS = {
    [0,0]  =>  :delete_position,
    [1,0]  =>  :quantity,
    [2,0]  =>  :description,
    [3,0]  =>  :backorder,
    [4,0]  =>  :price_base,
    [5,0]  =>  :price_levels,
    [6,0]  =>  :price2,
    [7,0]  =>  :price3,
    [5,1]  =>  :price4,
    [6,1]  =>  :price5,
    [7,1]  =>  :price6,
    [8,0]  =>  :total,
  }
  CSS_MAP = {
    [0,0]     => 'delete',
    [1,0]     => 'tiny right',
    [2,0]     => 'description',
    [4,0,4,2] => 'right',
    [8,0]     => 'total',
  }
  CSS_HEAD_MAP = {
    [1,0] => 'right',
    [4,0] => 'right',
    [5,0] => 'right',
    [8,0] => 'right',
  }
  def delete_position(model)
    super(model, :favorite_product)
  end
  def description(model)
    position_modifier(model, :description, :search_favorites)
  end
  def quantity(model)
    name = "quantity[#{model.article_number}]"
    input = HtmlGrid::InputText.new(name, model, @session, self)
    input.value = model.quantity
    input.css_class = 'tiny'
    script = "if(this.value == '0') this.value = '';"
    input.set_attribute('onFocus', script)
    script = "if(this.value == '') this.value = '0';"
    input.set_attribute('onBlur', script)
    input
  end
end
class FavoritesForm < HtmlGrid::DivForm
  include UnavailableMethods
  COMPONENTS = {
    [0,0] => FavoritesPositions,
    [0,1] => :unavailables,
  }
  EVENT = :increment_order
  FORM_NAME = 'favorites'
  def init
    unless(@model.empty?)
      components.update( [1,1] => :submit, [2,1] => :nullify, [3,1] => :reset )
    end
    super
  end
  def nullify(model)
    button = HtmlGrid::Button.new(:nullify, model, @session, self)
    button.set_attribute('onClick', "zeroise(this.form);")
    button
  end
  def reset(model)
    input = HtmlGrid::Button.new(:default_values, model, @session, self)
    input.set_attribute('type', 'reset')
    input
  end
end
class FavoritesComposite < OrderComposite
  COMPONENTS = {
    [0,0] => SearchFavorites,
    [1,0] => :barcode_reader,
    [2,0] => :position_count,
    [3,0] => :favorite_transfer,
    [4,0] => :clear_favorites,
    [0,1] => FavoritesForm,
  }
  CSS_ID_MAP = [ 'toolbar' ]
  SYMBOL_MAP = {
    :favorite_transfer => TransferDat,
  }
  def barcode_reader(model)
    if(@session.client_activex?)
      BarcodeReader.new(model, @session, self)
    end
  end
  def clear_favorites(model)
    unless(model.empty?)
      ClearFavorites.new(model, @session, self)
    end
  end
  def position_count(model)
    span = HtmlGrid::Span.new(model, @session, self)
    span.value = @lookandfeel.lookup(:favorite_positions, model.size)
    span.css_class = 'guide'
    span
  end
end
class Favorites < CurrentOrder
  include HtmlGrid::DojoToolkit::DojoTemplate
  include ActiveX
  CONTENT = FavoritesComposite
  DOJO_DEBUG = BBMB.config.debug
  DOJO_PREFIX = {
    'ywesee' => '../javascript',
  }
  JAVASCRIPTS = [
    "bcreader",
    "order",
  ]

end
    end
  end
end
