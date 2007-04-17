#!/usr/bin/env ruby
# Model::Product -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/model/product'

module BBMB
  module Model
    class Product
      include ODBA::Persistable
      odba_index :article_number
      odba_index :ean13
      odba_index :description
      odba_index :pcode
      odba_index :catalogue1
      odba_index :catalogue2
    end
  end
end
