#!/usr/bin/env ruby
# Html::View::ListPrices -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

module BBMB
  module Html
    module View
module Vat
  def vat(model)
    if(vat = model.vat)
      sprintf("%.1f%%", vat.to_f)
    end
  end
end
module ListPrices
  include Vat
  BACKGROUND_ROW = 'bg'
  BACKGROUND_SUFFIX = ''
  HEAD_OFFSET_STEP = [0,1]
  OFFSET_STEP = [0,2]
  def pricex(model, pricex)
    qval = model.send("l#{pricex}_qty")
    pval = model.send("l#{pricex}_price")
    if(qval.to_i > 0 && pval.to_f > 0)
      @lookandfeel.lookup(:list_price, qval, pval)
    end
  end
  def price1(model)
    pricex(model, 1)
  end
  def price2(model)
    pricex(model, 2)
  end
  def price3(model)
    pricex(model, 3)
  end
  def price4(model)
    pricex(model, 4)
  end
  def price5(model)
    pricex(model, 5)
  end
  def price6(model)
    pricex(model, 6)
  end
  def price_base(model)
    model.product.price
  end
  def price_levels(model)
    price1(model)
  end
end
    end
  end
end
