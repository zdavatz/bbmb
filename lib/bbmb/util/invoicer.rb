#!/usr/bin/env ruby
# Util::Invoicer -- bbmb.ch -- 03.10.2006 -- hwyss@ywesee.com

require 'ydim/config'
require 'ydim/client'
require 'openssl'

module BBMB
  module Util
module Invoicer
  class << self
    def run(range, date=Date.today)
      orders = BBMB.persistence.all(Model::Order).select { |order|
        order.commit_time && range.include?(order.commit_time)
      }
      invoice = create_invoice(range, orders, date)
      send_invoice(invoice.unique_id)
    end
    def create_invoice(time_range, orders, date, currency='CHF')
      time = Time.now
      ydim_connect { |client|
        ydim_inv = client.create_invoice(BBMB.config.ydim_id)
        ydim_inv.description = sprintf(BBMB.config.invoice_format, 
                                       time_range.first.strftime("%d.%m.%Y"),
                                       (time_range.last - 1).strftime("%d.%m.%Y"))
        ydim_inv.date = date
        ydim_inv.currency = currency
        ydim_inv.payment_period = 30
        total = orders.inject(0) { |memo, order| order.total + memo }
        item_data = {
          :price    =>  total.to_f * BBMB.config.invoice_percentage / 100,
          :quantity =>  1,
          :text     =>  sprintf(BBMB.config.invoice_item_format, 
                                total, orders.size),
          :time			=>	Time.local(date.year, date.month, date.day),
          :unit     =>  "%0.1f%" % BBMB.config.invoice_percentage,
        }
        client.add_items(ydim_inv.unique_id, [item_data])
        ydim_inv
      }
    end
    def send_invoice(invoice_id)
      ydim_connect { |client| client.send_invoice(invoice_id) }
    end
    def ydim_connect(&block)
      config = YDIM::Client::CONFIG
      if(path = BBMB.config.ydim_config)
        config.load(path)
      end
      server = DRbObject.new(nil, config.server_url)
      client = YDIM::Client.new(config)
      key = OpenSSL::PKey::DSA.new(File.read(config.private_key))
      client.login(server, key)
      block.call(client)
    ensure
      client.logout if(client)
    end
  end
end
  end
end
