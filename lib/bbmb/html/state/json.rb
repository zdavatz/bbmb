#!/usr/bin/env ruby
# Html::State::Json -- bbmb.ch -- 26.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/json'
require 'sbsm/state'

module BBMB
  module Html
    module State
class Json < SBSM::State
  VIEW = View::Json
  VOLATILE = true
end
    end
  end
end
