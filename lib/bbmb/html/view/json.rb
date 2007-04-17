#!/usr/bin/env ruby
# Html::View::Json -- bbmb.ch -- 26.09.2006 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'json/objects'

module BBMB
  module Html
    module View
class Json < HtmlGrid::Component
  HTTP_HEADERS = {
    'Content-Type'  =>  'text/javascript; charset=UTF-8',
  }
  def to_html(context)
    @model.to_json
  end
end
    end
  end
end
