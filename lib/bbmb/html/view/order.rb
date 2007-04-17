#!/usr/bin/env ruby
# Html::View::Order -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/template'
require 'htmlgrid/labeltext'

module BBMB
  module Html
    module View
class AdditionalInformation < HtmlGrid::Composite
  COMPONENTS = {}
  CSS_CLASS = 'list'
  LABELS = true
  VERTICAL = true
  DEFAULT_CLASS = HtmlGrid::Value
  SYMBOL_MAP = {
    :order_total => HtmlGrid::LabelText, 
  }
  def init
    idx = 0
    [:reference, :comment, :priority].each { |key|
      if(@model.send(key))
        components.store([0,idx], key)
        css_map.store([0,idx,1,2], 'additional-info')
        idx += 2
      end
    }
    components.update([0,idx,0] => :order_total, [0,idx,1] => :total)
    css_map.store([0,idx], 'order-total')
    super
  end
  def priority(model)
    item = HtmlGrid::Value.new(:priority, model, @session, self)
    item.value = @lookandfeel.lookup("priority_#{model.priority}")
    item
  end
  def total(model)
    span = HtmlGrid::Span.new(model, @session, self)
    span.css_id = 'total'
    span.value = model.total
    span
  end
end
module PositionMethods
  def delete_position(model, event)
    link = HtmlGrid::Link.new(:delete, model, @session, self)
    url = @lookandfeel.base_url
    id = model.article_number
    link.href = "javascript:delete_position('#{url}', '#{event}', '#{id}');"
    link
  end
  def position_modifier(model, name, event)
    link = HtmlGrid::Link.new(name, model, @session, self)
    args = {
      'query'  =>  model.description.to_s[/^[^\s]+/]
    }
    link.href = @lookandfeel._event_url(event, args)
    link.value = model.send(name)
    link
  end
end
class Positions < HtmlGrid::List
  include ListPrices
  CSS_CLASS = 'list'
  COMPONENTS = {
    [0,0]  =>  :quantity,
    [1,0]  =>  :description,
    [2,0]  =>  :price_base,
    [3,0]  =>  :price_levels,
    [4,0]  =>  :price2,
    [5,0]  =>  :price3,
    [3,1]  =>  :price4,
    [4,1]  =>  :price5,
    [5,1]  =>  :price6,
    [6,0]  =>  :total,
  }
  CSS_MAP = {
    [0,0]     => 'tiny right',
    [1,0]     => 'description',
    [2,0,4,2] => 'right',
    [6,0]     => 'total',
  }
  CSS_HEAD_MAP = {
    [0,0] => 'right',
    [2,0] => 'right',
    [3,0] => 'right',
    [6,0] => 'right',
  }
end
class OrderComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => Positions,
    [0,1] => AdditionalInformation,
  }
end
class Order < Template
  CONTENT = OrderComposite
end
    end
  end
end
