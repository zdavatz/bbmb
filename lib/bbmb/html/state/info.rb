#!/usr/bin/env ruby
# Html::State::Info -- bbmb.ch -- 30.11.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global'
require 'bbmb/html/view/info'
require 'ostruct'

module BBMB
  module Html
    module State
class Info < Global
  VIEW = Html::View::Info
  def init
    model = OpenStruct.new
    model.event = @model[:event]
    model.message = @model[:message]
    @model = model
    super
  end
end
    end
  end
end
