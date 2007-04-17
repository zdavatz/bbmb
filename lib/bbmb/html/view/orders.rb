#!/usr/bin/env ruby
# Html::View::Orders -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/template'

module BBMB
  module Html
    module View
class OrdersComposite < HtmlGrid::List
  BACKGROUND_ROW = 'bg'
  BACKGROUND_SUFFIX = ''
  COMPONENTS = {
    #[0,0] => :order_id,
    [0,0] => :commit_time,
    [1,0] => :size,
    [2,0] => :item_count,
    [3,0] => :total,
  }
  CSS_CLASS = 'list'
  CSS_HEAD_MAP = {
    [1,0] => 'right',
    [2,0] => 'right',
    [3,0] => 'right',
  }
  CSS_MAP = {
    [1,0,2] => 'right',
    [3,0]   => 'total',
  }
  LOOKANDFEEL_MAP = {
    :total => :order_total,
  }
  SORT_DEFAULT = :commit_time
  SORT_REVERSE = true
  def commit_time(model)
    link = HtmlGrid::Link.new(:commit_time, model, @session, self)
    link.value = model.commit_time.strftime("%d.%m.%Y %H:%M")
    link.href = @lookandfeel._event_url(:order, :order_id => model.order_id)
    link.css_class = 'commit-time'
    link
  end
  def items(model)
    model.positions.inject(0) { |memo, pos| memo + pos.quantity }
  end
end
class Orders < Template
  CONTENT = OrdersComposite
end
    end
  end
end
