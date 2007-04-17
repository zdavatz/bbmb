#!/usr/bin/env ruby
# Html::View::Customer -- bbmb.ch -- 19.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/template'
require 'htmlgrid/errormessage'
require 'htmlgrid/form'
require 'htmlgrid/popuplink'
require 'htmlgrid/select'

module BBMB
  module Html
    module View
class CustomerForm < HtmlGrid::Form
  include HtmlGrid::ErrorMessage
  COMPONENTS = {
    [0,0]   =>  :organisation,
    [2,0]   =>  :customer_id,
    [0,1]   =>  :ean13,
    [2,1,0] =>  :turnaround,
    [3,1,0] =>  ' - ', 
    [3,1,1] =>  :history, 
    [0,2]   =>  'contact',
    [0,3]   =>  :title,
    [2,3]   =>  :drtitle,
    [0,4]   =>  :lastname,
    [2,4]   =>  :firstname,
    [0,5]   =>  :address1,
    [0,6]   =>  :address2,
    [0,7]   =>  :address3,
    [0,8,0] =>  :plz,
    [0,8,1] =>  '/',
    [0,8,2] =>  :city,
    [2,8]   =>  :canton,
    [0,9]   =>  :email,
    [0,10]  =>  :phone_business,
    [2,10]  =>  :phone_private,
    [0,11]  =>  :phone_mobile,
    [2,11]  =>  :fax,
    [0,12]  =>  :pass,
    [1,12,3]=>  :change_pass, # in UserView#change_pass, the third 
                              # number here is used as the value of 
                              # the colspan attribute
    [1,12,4]=>  '&nbsp;',
    [1,12,5]=>  :generate_pass,
    [2,12]  =>  :confirm_pass,
    [1,13]  =>  :submit,
  }
  CSS_ID_MAP = {
    [0,8,0] => 'plz',
    [0,8,2] => 'city',
  }
  CSS_MAP = {
    [0,2,4] => 'contact',
  }
  DEFAULT_CLASS = HtmlGrid::InputText
  EVENT = "save"
  FORM_NAME = 'hospital'
  LABELS = true
  SYMBOL_MAP = {
    :canton => HtmlGrid::Select,
    :title  => HtmlGrid::Select,
  }
  def init
    super
    error_message
  end
  def change_pass(model)
    unless(set_pass?)
      button = HtmlGrid::Button.new(:change_password, model, @session, self)
      form = "document.#{formname}"
      button.onclick = "#{form}.event.value='change_pass';#{form}.submit();"
      button.value = @lookandfeel.lookup("change_password")
      matrix = components.index(:change_pass)
      @grid.set_colspan(*matrix)
      button
    end
  end
  def confirm_pass(model)
    _pass(:confirm_pass, model)
  end
  def generate_pass(model)
    unless(set_pass?)
      if(@session.state.cleartext)
				link = HtmlGrid::Link.new(:show_pass, model, @session, self)
        link.href = 'javascript:' << popup(@lookandfeel._event_url(:show_pass), 
                                           'password')
        link
      else
        button = HtmlGrid::Button.new(:generate_pass, model, @session, self)
        form = "document.#{formname}"
        button.onclick = "#{form}.event.value='generate_pass';#{form}.submit();"
        matrix = components.index(:change_pass)
        @grid.set_colspan(*matrix)
        button
      end
    end
  end
  def history(model)
    link = HtmlGrid::Link.new(:history, model, @session, self)
    link.href = @lookandfeel._event_url(:history, 
                                        :customer_id => model.customer_id)
    link
  end
  def pass(model)
    _pass(:pass, model)
  end
  def _pass(key, model)
    if(set_pass?)
      HtmlGrid::Pass.new(key, model, @session, self)
    end
  end
  def popup(url, name='popup')
    script = "window.open('#{url}','#{name}','resizable=yes,menubar=no,height=350,width=500').focus();" 
    if(self.respond_to?(:onload=))
      self.onload = script
    end
    script
  end
  def set_pass?
    @session.event == :change_pass \
      || @session.error(:pass) || @session.error(:confirm_pass)
  end
  def turnaround(model)
    link = HtmlGrid::Link.new(:turnaround, model, @session, self)
    args = { :customer_id => model.customer_id }
    link.href = @lookandfeel._event_url(:orders, args)
    link.value = sprintf(@lookandfeel.lookup(:currency_format), model.turnaround)
    link.label = true
    link
  end
end
class CustomerComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => '&nbsp;',
    [0,1] => CustomerForm,
  }
  CSS_ID_MAP = [ 'divider' ]
end
class Customer < Template
  CONTENT = CustomerComposite
end
    end
  end
end
