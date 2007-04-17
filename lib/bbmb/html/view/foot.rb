#!/usr/bin/env ruby
# Html::View::Foot -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/copyleft'
require 'bbmb/html/view/navigation'
require 'htmlgrid/divcomposite'

module BBMB
  module Html
    module View
class Foot < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] =>  Navigation,
    [0,1] =>  CopyLeft, 
  }
  CSS_ID = 'head'
  CSS_ID_MAP = ['navigation']
end
    end
  end
end
