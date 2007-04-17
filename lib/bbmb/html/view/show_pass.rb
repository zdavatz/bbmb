#!/usr/bin/env ruby
# Html::View::ShowPass -- bbmb.ch -- 19.10.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/template'
require 'htmlgrid/div'

module BBMB
  module Html
    module View
class ShowPassInnerComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :email,
    [0,1] => :cleartext,
  }
  DEFAULT_CLASS = HtmlGrid::Value
  LABELS = true
end
class Address < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :to_str 
  }
end
class ShowPassComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => :admin_address,
    [0,1] => :customer_address,
    [0,2] => "&nbsp;",
    [0,3] => ShowPassInnerComposite,
  }
  CSS_ID_MAP = {
    0 => 'admin-address',
    2 => 'divider',
  }
  CSS_MAP = ['address', 'address']
  def admin_address(model)
    #div = HtmlGrid::Div.new(model, @session, self)
    #div.css_id = 'admin-address'
    #div.value = 
    BBMB.config.admin_address.gsub("\n", "<br>")
  end
  def customer_address(model)
    model.address_lines.join('<br>')
  end
end
class ShowPass < Template
  COMPONENTS = {
    [0,0]	 =>	:logo,
    [0,1]	 =>	ShowPassComposite,
  }
  SYMBOL_MAP = {
    :logo => HtmlGrid::Image, 
  }
  def init
    super
    self.onload = 'window.opener.location.reload();'
  end
end
    end
  end
end
