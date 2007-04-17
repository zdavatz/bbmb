#!/usr/bin/env ruby
# Html::State::ShowPass -- bbmb.ch -- 18.10.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/view/show_pass'

module BBMB
  module Html
    module State
class ShowPass < Global
  VIEW = View::ShowPass
  VOLATILE = true
end
    end
  end
end
