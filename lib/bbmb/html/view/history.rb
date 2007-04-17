#!/usr/bin/env ruby
# Html::View::History -- bbmb.ch -- 03.10.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/template'

module BBMB
  module Html
    module View
class HistoryProducts < HtmlGrid::List
  BACKGROUND_ROW = 'bg'
  BACKGROUND_SUFFIX = ''
  COMPONENTS = {
    [0,0]  =>  :order_count,
    [1,0]  =>  :quantity,
    [2,0]  =>  :description,
    [3,0]  =>  :price,
    [4,0]  =>  :total,
  }
  CSS_CLASS = 'list'
  CSS_MAP = {
    [0,0,2]=>  'tiny right',
    [2,0]  =>  'description',
    [3,0]  =>  'right',
    [4,0]  =>  'total',
  }
  CSS_HEAD_MAP = {
    [0,0] => 'right', 
    [1,0] => 'right', 
    [3,0] => 'right', 
    [4,0] => 'right', 
  }
  SORT_DEFAULT = :description
  def price(model)
    min, max = model.price_extremes
    if(min == max)
      min
    else
      @lookandfeel.lookup(:price_range, min, max)
    end
  end
end
class HistoryComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0]  =>  HistoryProducts,
    [0,1]  =>  :turnaround,
  }
  CSS_MAP = { 1 => 'right' }
  CSS_ID_MAP = { 1 => 'order-total' }
  def turnaround(model)
    @lookandfeel.lookup(:history_turnaround, model.turnaround)
  end
end
class History < Template
  CONTENT = HistoryComposite
end
    end
  end
end
