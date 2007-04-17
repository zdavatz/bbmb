#!/usr/bin/env ruby
# Html::View::Backorder -- bbmb.ch -- 06.10.2006 -- hwyss@ywesee.com

module BBMB
  module Html
    module View
module Backorder
  def backorder(model)
    if(model.backorder)
      @lookandfeel.lookup(:backorder)
    end
  end
end
    end
  end
end
