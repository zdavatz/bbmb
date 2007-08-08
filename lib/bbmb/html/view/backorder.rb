#!/usr/bin/env ruby
# Html::View::Backorder -- bbmb.ch -- 06.10.2006 -- hwyss@ywesee.com

module BBMB
  module Html
    module View
module Backorder
  def backorder(model)
    value = if(date = model.backorder_date)
              date.strftime(@lookandfeel.lookup(:backorder_date))
            elsif(model.backorder)
              @lookandfeel.lookup(:backorder)
            end
    if(value)
      div = HtmlGrid::Div.new(model, @session, self)
      div.css_class = 'limited'
      div.value = value
      div
    end
  end
end
    end
  end
end
