#!/usr/bin/env ruby
# Html::View::Login -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/template'
require 'htmlgrid/dojotoolkit'
require 'htmlgrid/errormessage'
require 'htmlgrid/form'
require 'htmlgrid/pass'

module BBMB
  module Html
    module View
class NewCustomerForm < HtmlGrid::Form
  include HtmlGrid::ErrorMessage
  COMPONENTS = { 
    [0,0] => :firstname,
    [0,1] => :lastname,
    [0,2] => :organisation,
    [0,3] => :address1,
    [0,4] => :plz,
    [0,5] => :city,
    [0,6] => :phone_business,
    [0,7] => :email,
    [0,8] => :customer_id,
    [1,9] => "new_customer_thanks",
    [1,10]=> :submit,
  }
  CSS_ID = 'new-customer-form'
  EVENT = :request_access
  LABELS = true
  LOOKANDFEEL_MAP = {
    :customer_id => :customer_or_tsv_id,
  }
  def init
    super
    error_message
  end
end
class LoginForm < HtmlGrid::Form
  COMPONENTS = {
    [0,0] =>  :email,
    [0,1] =>  :pass,
    [1,2] =>  :submit,
    [0,3] =>  :new_customer,
  }
  CSS_MAP = { [0,3,2] => 'new-customer' }
  EVENT = :login
  FORM_ID = 'login'
  FORM_NAME = 'login'
  LABELS = true
  SYMBOL_MAP = {
    :pass =>  HtmlGrid::Pass, 
  }
  def new_customer(model)
    if(@lookandfeel.enabled?(:request_access, false))
      msg = @lookandfeel.lookup(:new_customer_invite).gsub("\n", '<br>')
      status = (@session.event == :request_access) ? 'open' : 'closed'
      attrs = {
        'css_class'     => 'new-customer',
        'message_open'  => msg, 
        'message_close' => msg, 
        'status'        => status,
        'togglee'       => 'new-customer',
      }
      tag = dojo_tag('contenttoggler', attrs)
      tag.label = true
      tag
    else
      link = HtmlGrid::Link.new(:new_customer, model, @session, self)
      link.href = @lookandfeel.lookup(:new_customer_mail)
      link.value = @lookandfeel.lookup(:new_customer_invite)
      link.label = true
      link
    end
  end
end
class LoginComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => LoginForm,
  }
  def init
    if(@lookandfeel.enabled?(:request_access, false))
      components.store([0,1], NewCustomerForm)
      css_id_map.store(1, 'new-customer')
    end
    super
  end
end
class Login < Template
  include HtmlGrid::DojoToolkit::DojoTemplate
  CONTENT = LoginComposite
  DOJO_DEBUG = BBMB.config.debug
  DOJO_PREFIX = {
    'ywesee' => '../javascript',
  }
  DOJO_REQUIRE = [ 'dojo.widget.*', 'ywesee.widget.*', 
    'ywesee.widget.ContentToggler' ]
end
    end
  end
end
