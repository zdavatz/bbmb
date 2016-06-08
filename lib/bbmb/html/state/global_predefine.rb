#!/usr/bin/env ruby
# encoding: utf-8
# Html::State::Global -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'sbsm/state'
module BBMB
  module Html
    module State
      class Global < SBSM::State
        class << self
          def mandatory(*keys)
            define_method(:_mandatory) { keys }
            define_method(:mandatory) { _mandatory }
            define_method(:mandatory?) { |key| mandatory.include?(key) }
          end
        end
      end
    end
  end
end
