#!/usr/bin/env ruby
# Html::View::Backorder -- bbmb.ch -- 06.10.2006 -- hwyss@ywesee.com

module BBMB
  module Html
    module View
module Backorder
  def backorder(model)
    if(date = model.backorder_date)
      date.strftime(@lookandfeel.lookup(:backorder_date))
    elsif(model.backorder)
      @lookandfeel.lookup(:backorder)
    end
  end
end
    end
  end
end
