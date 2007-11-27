#!/usr/bin/env ruby
# Model::Product -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/model/product'

module BBMB
  module Model
    class ProductInfo
      def migrate_to_subject
        changed = super
        @promotion && @promotion.migrate_to_subject && (changed = true)
        @sale && @sale.migrate_to_subject && (changed = true)
        changed
      end
    end
    class Product
      include ODBA::Persistable
      odba_index :article_number
      odba_index :ean13
      odba_index :description, 'description.all'
      odba_index :pcode
      odba_index :catalogue1, 'catalogue1.all'
      odba_index :catalogue2, 'catalogue2.all'
    end
  end
end
