#!/usr/bin/env ruby
# Html::View::Head -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/image'

module BBMB
  module Html
    module View
class Head < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0] => :logo,
    [0,2] => 'welcome',
    [0,1] => :logged_in_as, # has float-right, needs to be before 'welcome'
  }
  CSS_ID_MAP = {2 => 'welcome', 1 => 'logged-in-as'}
  SYMBOL_MAP = {
    :logo => HtmlGrid::Image,
  }
  def logged_in_as(model)
    if(@session.logged_in?)
      @lookandfeel.lookup(:logged_in_as, @session.user.name)
    end
  end
end
    end
  end
end
