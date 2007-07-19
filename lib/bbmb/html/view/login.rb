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
    link = HtmlGrid::Link.new(:new_customer, model, @session, self)
    link.href = @lookandfeel.lookup(:new_customer_mail)
    link.value = @lookandfeel.lookup(:new_customer_invite)
    link.label = true
    link
  end
end
class LoginComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => LoginForm,
  }
end
class Login < Template
  CONTENT = LoginComposite
end
    end
  end
end
