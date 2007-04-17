#!/usr/bin/env ruby
# Model::Customer -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/model/customer'

module BBMB
  module Model
    class Customer
      include ODBA::Persistable
      ODBA_PREFETCH = true
      ODBA_SERIALIZABLE = ['@protected']
      odba_index :customer_id
      odba_index :email
      alias :__old_current_order__ :current_order
      def current_order
        if(@current_order.nil?)
          __old_current_order__
          odba_store
        end
        @current_order
      end
      alias :__old_commit_order__ :commit_order!
      def commit_order!(*args)
        order = __old_commit_order__(*args)
        @archive.odba_store
        odba_store
        order
      end
      alias :__old_favorites__ :favorites
      def favorites
        if(@favorites.nil?)
          __old_favorites__
          odba_store
        end
        @favorites
      end
    end
  end
end
