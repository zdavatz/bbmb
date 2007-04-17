#!/usr/bin/env ruby
# Html::View::Info -- bbmb.ch -- 30.11.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/template'

module BBMB
  module Html
    module View
class InfoComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => '&nbsp;',
    [0,1] => :message,
  }
  CSS_ID_MAP = ['divider']
  CSS_MAP = {
    1 => 'info', 
  }
  def message(model)
    @lookandfeel.lookup(model.message)
  end
end
class Info < Template
  CONTENT = InfoComposite
  def http_headers
    headers = super
    headers.store('Refresh', 
      "5; URL=#{@lookandfeel._event_url(@model.event)}")
    headers
  end
end
    end
  end
end
