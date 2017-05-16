#!/usr/bin/env ruby
# Html::View::Navigation -- bbmb.ch -- 18.09.2006 -- hwyss@ywesee.com

module BBMB
  module Html
    module View
class NavigationLink < HtmlGrid::Link
  def init
    unless(@session.event == @name)
      self.href = @lookandfeel._event_url(@name)
    end
    super
  end
end
class Navigation < HtmlGrid::DivComposite
  COMPONENTS = {}
  DEFAULT_CLASS = NavigationLink
  def init
    build_navigation
    super
  end
  def build_navigation
    @lookandfeel.navigation.each_with_index { |event, idx|
      components.store([idx,0], event)
    }
  end
end
    end
  end
end
