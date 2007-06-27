#!/usr/bin/env ruby
# Html::View::CurrentOrder -- bbmb.ch -- 20.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/backorder'
require 'bbmb/html/view/list_prices'
require 'bbmb/html/view/order'
require 'bbmb/html/view/search'
require 'bbmb/html/view/template'
require 'htmlgrid/divform'
require 'htmlgrid/dojotoolkit'
require 'htmlgrid/inputfile'
require 'htmlgrid/inputradio'
require 'htmlgrid/inputtext'
require 'htmlgrid/javascript'
require 'htmlgrid/span'
require 'htmlgrid/spancomposite'
require 'htmlgrid/textarea'

module BBMB
  module Html
    module View
module ActiveX
  def other_html_headers(context)
    html = ''
    if @session.client_activex?
      cab = 'BbmbBarcodeReader.CAB#version=1,3,0,0'
      cid = "CLSID:1311F1ED-198B-11D6-8FF9-000103484A9A"
      if(@session.client_nt5?) 
        cab = 'BbmbBarcodeReader2.CAB#version=2,1,0,0'
      end
      props = {
        "id"			=>	"BCReader",
        "classid"	=>	cid,
        "codebase"=>	@lookandfeel.resource_global(:activex, cab),
      }
      html << context.object(props)
    end
    html << super
  end
end
module UnavailableMethods
  def unavailables(model) 
    unavailable = model.unavailable
    unless unavailable.empty?
      Unavailables.new(unavailable, @session, self) 
    end
  end
end
class BarcodeReader < HtmlGrid::SpanComposite
  include HtmlGrid::FormMethods
  COMPONENTS = {
    [0,0] => :barcode_usb,
    [1,0] => :barcode_reader,
    [2,0] => :barcode_comport,
  }
  EVENT = 'scan'
  FORM_ID = 'bcread'
  FORM_NAME = 'bcread'
  def barcode_usb(model)
    if(!@session.client_nt5?)
      link = HtmlGrid::Link.new(:barcode_usb, model, @session, self)
      link.href = "http://www.ionetworks.com/support/epdrivers.jsp#E95"
      link.target = "_blank"
      link
    end
  end
  def barcode_reader(model)
    button = HtmlGrid::Button.new(:barcode_button, model, @session, self)
    args = [
      @lookandfeel.lookup(:barcode_none),
      @lookandfeel.lookup(:barcode_empty),
    ]
    com = 'this.form.barcode_comport'
    argstr = args.join("', '")
    button.set_attribute('onclick', "bc_read(#{com}, '#{argstr}')")
    button
  end
  def barcode_comport(model)
    input = HtmlGrid::Input.new(:barcode_comport, model, @session, self)
    input.set_attribute('type', 'hidden')
    val = @session.get_cookie_input(:comport)
    if(!/[0-9]+/.match(val)) 
      val = "-1"
    end
    input.value = val
    input
  end
end
class ClearOrder < HtmlGrid::SpanComposite
  include HtmlGrid::FormMethods
  FORM_ID = 'clear'
  EVENT = :clear_order
  COMPONENTS = {
    [0,0] => :clear,
  }
  def clear(model)
    button = HtmlGrid::Button.new(event, model, @session, self)
    condition = "if(confirm('#{@lookandfeel.lookup(event.to_s << "_confirm")}'))"
    condition << "this.form.submit();"
    button.set_attribute('onclick', condition)
    button
  end
end
class CurrentAdditionalInformation < HtmlGrid::Composite
  COMPONENTS = {
    [0,0]  =>  :reference,
    [0,2]  =>  :comment,
  }
  LABELS = true
  VERTICAL = true
  def comment(model)
    input = HtmlGrid::Textarea.new(:comment, model, @session, self)
    input.set_attribute('onKeyUp', 
      'if(this.value.length > 60) this.value=this.value.substring(0,60);')
    input.value = model.comment
    input.label = true
    url = @lookandfeel._event_url(:ajax)
    input.set_attribute('onchange', "update_order('#{url}', this.form)")
    input.set_attribute('id', :comment)
    input
  end
  def reference(model)
    _input_value(:reference, model)
  end
  def _input_value(key, model)
    input = HtmlGrid::InputText.new(key, model, @session, self)
    url = @lookandfeel._event_url(:ajax)
    input.set_attribute('onchange', "update_order('#{url}', this.form)")
    input.set_attribute('id', key)
    input
  end
end
class CurrentPriorities < HtmlGrid::Composite
  COMPONENTS = {
    [0,0]		=>	:priority,
    [0,1,0]		=>	:priority_0,
    [0,1,1]	=>	'priority_0',
    [0,2,0]		=>	:priority_1,
    [0,2,1]	=>	'priority_1',
    [1,2]		=>	'priority_explain_1',
    [0,3,0]		=>	:priority_13,
    [0,3,1]	=>	'priority_13',
    [1,3]		=>	'priority_explain_13',
    [0,4,0]		=>	:priority_16,
    [0,4,1]	=>	'priority_16',
    [1,4]		=>	'priority_explain_16',
    [0,5,0]		=>	:priority_21,
    [0,5,1]	=>	'priority_21',
    [1,5]		=>	'priority_explain_21',
    [0,6,0]		=>	:priority_40,
    [0,6,1]	=>	'priority_40',
    [1,6]		=>	'priority_explain_40',
    [0,7,0]		=>	:priority_41,
    [0,7,1]	=>	'priority_41',
    [1,7]		=>	'priority_explain_41',
  }
  SYMBOL_MAP = {
    :priority => HtmlGrid::LabelText,
  }
  def priority_input(model, num)
    radio = HtmlGrid::InputRadio.new(:priority, 
      model, @session, self)
    num = num.to_i
    radio.value = num
    radio.label = false
    test = model.priority || @session.user_input(:priority)
    if(test == num)
      radio.set_attribute('checked', true)
    end
    url = @lookandfeel._event_url(:ajax)
    script = "update_order('#{url}', this.form)"
    radio.set_attribute('onclick', script)
    radio
  end
  def priority_0(model)
    priority_input(model, '')
  end
  def priority_1(model)
    priority_input(model, 1)
  end
  def priority_13(model)
    priority_input(model, 13)
  end
  def priority_16(model)
    priority_input(model, 16)
  end
  def priority_21(model)
    priority_input(model, 21)
  end
  def priority_40(model)
    priority_input(model, 40)
  end
  def priority_41(model)
    priority_input(model, 41)
  end
end
class CurrentToggleable < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => CurrentAdditionalInformation, 
    [1,0] => CurrentPriorities,
  }
end
class TransferDat < HtmlGrid::SpanComposite
  include HtmlGrid::FormMethods
  COMPONENTS = {
    [0,0] => :file_chooser,
    [1,0] => :submit,
  }
  EVENT = :transfer
  FORM_ID = 'transfer-dat'
  FORM_NAME = 'transfer_dat'
  SYMBOL_MAP = {
    :file_chooser => HtmlGrid::InputFile, 
  }
  TAG_METHOD = :multipart_form
  def initialize(event, *args)
    @event = event
    super(*args)
  end
  def event
    @event || super
  end
end
class CurrentPositions < HtmlGrid::List
  include Backorder
  include ListPrices
  include PositionMethods
  CSS_CLASS = 'list'
  COMPONENTS = {
    [0,0]  =>  :delete_position,
    [1,0]  =>  :quantity,
    [2,0]  =>  :description,
    [3,0]  =>  :backorder,
    [4,0]  =>  :price_base,
    [5,0]  =>  :price_levels,
    [6,0]  =>  :price2,
    [7,0]  =>  :price3,
    [5,1]  =>  :price4,
    [6,1]  =>  :price5,
    [7,1]  =>  :price6,
    [8,0]  =>  :total,
  }
  CSS_MAP = {
    [0,0]     => 'delete',
    [1,0]     => 'tiny right',
    [2,0]     => 'description',
    [4,0,4,2] => 'right',
    [8,0]     => 'total',
  }
  CSS_HEAD_MAP = {
    [1,0] => 'right',
    [4,0] => 'right',
    [5,0] => 'right',
    [8,0] => 'right',
  }
  SORT_DEFAULT = :description
  def delete_position(model)
    super(model, :order_product)
  end
  def description(model)
    position_modifier(model, :description, :search)
  end
end
class CurrentOrderForm < HtmlGrid::DivForm
  COMPONENTS = {
    [0,0] => :toggle,
    [0,1] => CurrentToggleable,
    [0,2] => :order_total,
    [1,2] => :total,
    [0,3] => :submit,
  }
  CSS_ID_MAP = { 1 => 'info', 2 => 'order-total' }
  EVENT = :commit
  FORM_ID = 'additional_info'
  SORT_DEFAULT = :description
  SYMBOL_MAP = {
    :order_total => HtmlGrid::LabelText, 
  }
  def toggle(model)
    ms_open = "&nbsp;+&nbsp;#{@lookandfeel.lookup(:additional_info)}"
    ms_close = "&nbsp;&minus;&nbsp;#{@lookandfeel.lookup(:additional_info)}"
    status = model.additional_info.empty? ? 'closed' : 'open'
    attrs = {
      'css_class'     => 'toggler',
      'message_open'  => ms_open, 
      'message_close' => ms_close, 
      'status'        => status,
      'togglee'       => 'info',
    }
    dojo_tag('contenttoggler', attrs)
  end
  def total(model)
    span = HtmlGrid::Span.new(model, @session, self)
    span.css_id = 'total'
    span.value = model.total
    span
  end
end
class Unavailables < HtmlGrid::List
  BACKGROUND_ROW = 'bg'
  BACKGROUND_SUFFIX = ''
  CSS_CLASS = 'list'
  COMPONENTS = {
    [0,0]  =>  :delete_position,
    [1,0]  =>  :quantity,
    [2,0]  =>  :description,
  }
  CSS_MAP = {
    [0,0] => 'delete',
    [1,0] => 'tiny right',
    [2,0] => 'description',
    [3,0] => 'right',
  }
  SORT_DEFAULT = nil
  OMIT_HEADER = true
  def delete_position(model)
    link = HtmlGrid::Link.new(:delete, model, @session, self)
    url = @lookandfeel.base_url
    id = @list_index
    event = 'delete_unavailable'
    link.href = "javascript:delete_position('#{url}', '#{event}', '#{id}');"
    link
  end
  def description(model)
    span = HtmlGrid::Span.new(model, @session, self)
    parts = [model.description].compact
    [:ean13, :pcode].each { |key|
      if(value = model.send(key))
        parts.push(sprintf("%s: %s", @lookandfeel.lookup(key), value))
      end
    }
    span.value = @lookandfeel.lookup(:unavailable, parts.join(', '))
    span
  end
end
class CurrentOrderComposite < HtmlGrid::DivComposite
  include UnavailableMethods
  COMPONENTS = {
    [0,0] => Search,
    [1,0] => :position_count,
    [2,0] => :barcode_reader,
    [3,0] => :order_transfer,
    [4,0] => :clear_order,
    [0,1] => CurrentPositions,
    [0,2] => :unavailables,
  }
  CSS_ID_MAP = [ 'toolbar' ]
  def init
    unless(@model.empty?)
      components.store([1,2], CurrentOrderForm)
    end
    super
  end
  def barcode_reader(model)
    if(@session.client_activex? && !@lookandfeel.disabled?(:barcode_reader))
      BarcodeReader.new(model, @session, self)
    end
  end
  def clear_order(model)
    unless(model.empty?)
      ClearOrder.new(model, @session, self)
    end
  end
  def order_transfer(model)
    unless(@lookandfeel.disabled?(:transfer_dat))
      TransferDat.new(:order_transfer, model, @session, self)
    end
  end
  def position_count(model)
    span = HtmlGrid::Span.new(model, @session, self)
    span.value = @lookandfeel.lookup(:positions, model.size)
    span.css_class = 'guide'
    span
  end
end
class CurrentOrder < Template
  include HtmlGrid::DojoToolkit::DojoTemplate
  include ActiveX
  CONTENT = CurrentOrderComposite
  DOJO_DEBUG = BBMB.config.debug
  DOJO_PREFIX = {
    'ywesee' => '../javascript',
  }
  DOJO_REQUIRE = [ 'dojo.widget.*', 'ywesee.widget.*', 
    'ywesee.widget.ContentToggler' ] #, 'dojo.widget.Tooltip' ]
  JAVASCRIPTS = [
    "bcreader",
    "order",
  ]
end
    end
  end
end
