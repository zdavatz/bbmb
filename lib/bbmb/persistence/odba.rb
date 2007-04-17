#!/usr/bin/env ruby
# Persistence::ODBA -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
require 'odba'
require 'odba/connection_pool'
require 'odba/drbwrapper'
require 'bbmb/persistence/odba/model/customer'
require 'bbmb/persistence/odba/model/order'
require 'bbmb/persistence/odba/model/product'
require 'bbmb/persistence/odba/model/quota'

module BBMB
  module Persistence
    module ODBA
      def ODBA.all(klass)
        klass.odba_extent
      end
      def ODBA.save(*objs)
        objs.each { |obj| obj.odba_store }
      end
      def ODBA.delete(*objs)
        objs.each { |obj| obj.odba_delete }
      end
    end
  end
  ODBA.storage.dbi = ODBA::ConnectionPool.new("DBI:pg:#{@config.db_name}",
                                             @config.db_user, @config.db_auth)
  ODBA.cache.setup
  ODBA.cache.prefetch
end
