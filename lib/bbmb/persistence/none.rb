#!/usr/bin/env ruby
# Persistence::None -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/persistence/odba/model/customer'
require 'bbmb/persistence/odba/model/product'
require 'bbmb/persistence/odba/model/order'
require 'bbmb/persistence/odba/model/quota'

module BBMB
  module Persistence
    module ODBA
      def ODBA.all(klass, &block)
        []
      end
      def ODBA.save(*objs)
        objs.each { |obj| obj.odba_store }
      end
      def ODBA.delete(*objs)
        objs.each { |obj| obj.odba_delete }
      end
      def ODBA.migrate_to_subject
      end
    end
  end
end

