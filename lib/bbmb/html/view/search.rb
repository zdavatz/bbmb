#!/usr/bin/env ruby
# Html::View::Search -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

require 'htmlgrid/divform'

module BBMB
  module Html
    module View
class Search < HtmlGrid::DivForm
  CSS_ID = 'search'
  COMPONENTS = {
    [0,0] => :query,
    [1,0] => :submit,
  }
  EVENT = :search
  FORM_NAME = 'search'
  SYMBOL_MAP = {
    :query => HtmlGrid::InputText
  }
  def init
    super
    url = @lookandfeel._event_url(event, :query => nil)
    self.onsubmit = "document.location.href='#{url}'+encodeURLPart(this.query.value); return false;"
  end
end
    end
  end
end
