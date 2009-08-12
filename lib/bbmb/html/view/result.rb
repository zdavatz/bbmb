#!/usr/bin/env ruby
# Html::View::Result -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/backorder'
require 'bbmb/html/view/list_prices'
require 'bbmb/html/view/multilingual'
require 'bbmb/html/view/search'
require 'bbmb/html/view/template'
require 'htmlgrid/errormessage'
require 'htmlgrid/formlist'

module BBMB
  module Html
    module View
class Products < HtmlGrid::FormList
  include Backorder
  include ListPrices
  include Multilingual
  include HtmlGrid::ErrorMessage
  CSS_CLASS = 'list'
  if BBMB.config.enable_price_levels
    COMPONENTS = {
      [0,0]	=>	:quantity,
      [1,0]	=>	:description,
      [2,0]	=>	:backorder,
      [3,0] =>  :price,
      [4,0] =>  :price_levels,
      [5,0] =>  :price2,
      [6,0] =>  :price3,
      [4,1] =>  :price4,
      [5,1] =>  :price5,
      [6,1] =>  :price6
    }
    CSS_HEAD_MAP = {
      [3,0] => 'right',
      [4,0] => 'right',
    }
    CSS_MAP = {
      [0,0]     => 'tiny',
      [1,0]     => 'description',
      [3,0,4,2] => 'right'
    }
    OFFSET_STEP = [0,2]
    HEAD_OFFSET_STEP = [0,1]
  else
    COMPONENTS = {
      [0,0]	=>	:quantity,
      [1,0]	=>	:description,
      [2,0]	=>	:backorder,
      [3,0] =>  :price,
    }
    CSS_HEAD_MAP = {
      [3,0] => 'right',
    }
    CSS_MAP = {
      [0,0] => 'tiny',
      [1,0] => 'description',
      [3,0] => 'right'
    }
    OFFSET_STEP = [0,1]
  end
  EVENT = :order_product
  FORM_NAME = 'products'
  SORT_DEFAULT = :description
  def init
    super
    error_message
  end
  def compose_footer(matrix)
    super unless(@model.empty?)
  end
  def quantity(product)
    name = "quantity[#{product.article_number}]"
    input = HtmlGrid::InputText.new(name, product, @session, self)
    input.value = @model.ordered_quantity(product)
    input.css_class = 'tiny'
    script = "if(this.value == '0') this.value = '';"
    input.set_attribute('onFocus', script)
    script = "if(this.value == '') this.value = '0';"
    input.set_attribute('onBlur', script)
    input
  end
end
class ResultComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => Search,
    [1,0] => :product_count,
    [0,1] => Products,
  }
  CSS_ID_MAP = ['toolbar']
  def product_count(model)
    span = HtmlGrid::Span.new(model, @session, self)
    span.value = if(model.size == 1)
      @lookandfeel.lookup(:product_found)
    else
      @lookandfeel.lookup(:products_found, model.size)
    end
    span.css_class = 'guide'
    span
  end
end
class Result < Template
  CONTENT = ResultComposite
end
    end
  end
end
