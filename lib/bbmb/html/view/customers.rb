#!/usr/bin/env ruby
# Html::View::Customers -- bbmb.ch -- 18.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/template'
require 'htmlgrid/button'
require 'htmlgrid/divform'
require 'htmlgrid/list'
require 'htmlgrid/urllink'

module BBMB
  module Html
    module View
class Filter < HtmlGrid::DivForm
  COMPONENTS = {
    [0,0]		=>	:filter,
    [1,0]		=>	:filter_button,
    [2,0]		=>	:filter_reset,
  }
  FORM_NAME = 'filter'
  def event
    @session.state.direct_event
  end
  def filter(model)
    filter = HtmlGrid::InputText.new(:filter, model, @session, self)
    filter.value = @session.event_bound_user_input(:filter)
    filter
  end
  def filter_button(model)
    button = HtmlGrid::Button.new(:filter_button, model, @session, self)
    url = @lookandfeel._event_url(event, :filter => nil)
		script = "document.location.href='#{url}' + encodeURIComponent(document.#{formname}.filter.value); return false;"
    self.onsubmit = button.onclick = script
    #button.set_attribute('value', @lookandfeel.lookup(:filter))
    button
  end
  def filter_reset(model)
    button = HtmlGrid::Button.new(:reset, model, @session, self)
    url = @lookandfeel._event_url(event, :filter => "*")
    button.onclick = "document.location.href='#{url}'"
    button
  end
end
class CustomersList < HtmlGrid::List
  BACKGROUND_ROW = 'bg'
  BACKGROUND_SUFFIX = ''
  COMPONENTS = {
    [0,0] =>	:customer_id,
    [1,0]	=>	:organisation,
    [2,0] =>  :plz,
    [3,0]	=>	:city,
    [4,0]	=>	:email,
    [5,0]	=>	:communication,
    [6,0]	=>	:valid,
    [7,0]	=>	:last_login,
  }
  CSS_CLASS = 'list'
  CSS_MAP = {
    [1,0]		=>	'big',
  }
  SORT_DEFAULT = nil
  SYMBOL_MAP = {
    :email  => HtmlGrid::MailLink,
  }
  def organisation(model)
    link = HtmlGrid::Link.new(:organisation, model, @session, self)
    link.value = model.organisation
    link.href = @lookandfeel._event_url(:customer, 
                                        {:customer_id => model.customer_id})
    link
  end
=begin
  def email(model)
    if(mail = model.email)
      link = HtmlGrid::Link.new(:email, model, @session, self)
      link.value = mail
      link.href = sprintf("mailto:%s", mail)
      link
    end
  end
  def email(model)
    EmailValue.new(model, @session, self)
  end
  def last_login(model)
    DateTimeView.new(:last_login, model, @session, self)
  end
  def active(model)
    model.value(:active)
  end
=end 
  def last_login(model)
    @session.user.last_login(model.email)
  end
  def valid(model)
    @lookandfeel.lookup(@session.user.entity_valid?(model.email).to_s)
  end
  private
  def sort_link(header_key, matrix, component)
    link = HtmlGrid::Link.new(header_key, @model, @session, self)
    args = {
      :sortvalue	=>	component.to_s,
    }
    link.attributes['href'] = @lookandfeel._event_url(:customers, args)
    link
  end
end
class CustomersComposite < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0]	=>	Filter,
    [0,1]	=>	:pager,
    [0,2]	=>	:customers,
  }
  CSS_ID_MAP = ['filter', 'pager']
  def customers(model)
    CustomersList.new(model.customers, @session, self)
  end
  def pager(model)
    pager = []
    if(model.index > 0)
      pager.push(_pager_link(:previous, model.index - model.step))
    end
    pager.push(@lookandfeel.lookup(:pager_index, model.first, model.last))
    if(model.last < model.total)
      pager.push(_pager_link(:next, model.index + model.step))
    end
    pager.push(@lookandfeel.lookup(:pager_total, model.total))
  end
  def _pager_link(key, index)
    link = HtmlGrid::Link.new(key, @model, @session, self)
    link.href = @lookandfeel._event_url(:customers, :index => index)
    link
  end
end
class Customers < Template
  CONTENT = CustomersComposite
end
    end
  end
end
