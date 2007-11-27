#!/usr/bin/env ruby
# Model -- bbmb -- 08.08.2007 -- hwyss@ywesee.com

require 'bbmb/util/multilingual'

module BBMB
  module Model
    class Subject
      class << self
        def multilingual(*keys)
          @multilinguals ||= []
          keys.each { |key|
            @multilinguals.push key
            name = "@#{key}"
            define_method(key) {
              instance_variable_get(name) or begin
                instance_variable_set(name, Util::Multilingual.new)
              end
            }
            define_method(:to_s) { 
              self.send(key).to_s
            }
            ml = @multilinguals
            define_method(:multilinguals) { ml }
            protected
            attr_writer key
          }
        end
      end
      def migrate_to_subject
        changed = false
        multilinguals.each { |key|
          name = "@#{key}"
          if((var = instance_variable_get(name)) \
             && !var.is_a?(Util::Multilingual))
            changed = true
            ml = Util::Multilingual.new
            ml.de = var
            instance_variable_set(name, ml)
          end
        }
        changed
      end
    end
  end
end
