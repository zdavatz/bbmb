#!/usr/bin/env ruby
# Html::View::ChangePassword -- virbac.bbmb.ch -- 28.06.2007 -- hwyss@ywesee.com

require 'bbmb/html/view/template'
require 'htmlgrid/errormessage'
require 'htmlgrid/form'

module BBMB
  module Html
    module View
class ChangePasswordForm < HtmlGrid::Form
  include HtmlGrid::ErrorMessage
  COMPONENTS = {
    [0,0] => :email,
    [0,1] => :pass,
    [0,2] => :confirm_pass,
    [1,3] => :submit,
  }
  EVENT = :save
  LABELS = true
  SYMBOL_MAP = {
    :pass         => HtmlGrid::Pass,
    :confirm_pass => HtmlGrid::Pass,
  }
  def init
    super
    error_message
  end
end
class ChangePasswordComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => "change_pass",
    [0,1] => ChangePasswordForm,
  }
  CSS_ID_MAP = ['title']
end
class ChangePassword < Template
  CONTENT = ChangePasswordComposite
end
    end
  end
end
