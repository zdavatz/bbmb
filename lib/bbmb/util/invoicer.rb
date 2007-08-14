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
      orders = orders(range)
      turnover = deduction = Util::Money.new(0)
      baseline = Util::Money.new(BBMB.config.invoice_baseline)
      total = orders.inject(turnover) { |memo, order| order.total + memo }
      if(total == 0 || baseline > 0)
        all_orders = orders(fiscal_year(range))
        turnover = all_orders.inject(turnover) { |memo, order| 
          order.total + memo }
        deduction = [deduction, baseline - turnover].max
      end
      owed = total - deduction
      if(owed > 0)
        invoice = create_invoice(range, owed, orders, date)
        send_invoice(invoice.unique_id)
      else
        body = sprintf(<<-EOS, baseline, turnover + total, total, deduction - total)
Baseline:      %10.2f
Turnover:      %10.2f
Current Month: %10.2f
-------------------------
Outstanding:   %10.2f
        EOS
        Util::Mail.notify_debug("No invoice necessary", body)
      end
    end
    def create_invoice(time_range, owed, orders, date, currency='CHF')
      time = Time.now
      ydim_connect { |client|
        ydim_inv = client.create_invoice(BBMB.config.ydim_id)
        ydim_inv.description = sprintf(BBMB.config.invoice_format, 
                                       time_range.first.strftime("%d.%m.%Y"),
                                       (time_range.last - 1).strftime("%d.%m.%Y"))
        ydim_inv.date = date
        ydim_inv.currency = currency
        ydim_inv.payment_period = 30
        item_data = {
          :price    =>  owed.to_f * BBMB.config.invoice_percentage / 100,
          :quantity =>  1,
          :text     =>  sprintf(BBMB.config.invoice_item_format, 
                                owed, orders.size),
          :time			=>	Time.local(date.year, date.month, date.day),
          :unit     =>  "%0.1f%" % BBMB.config.invoice_percentage,
        }
        client.add_items(ydim_inv.unique_id, [item_data])
        ydim_inv
      }
    end
    def fiscal_year(range)
      day, month, = BBMB.config.invoice_newyear.split('.', 3)
      time = range.first
      year = time.year
      first = Time.local(year, month, day)
      if(first > time)
        first = Time.local(year - 1, month, day)
      end
      first...time
    end
    def orders(range)
      BBMB.persistence.all(Model::Order).select { |order|
        order.commit_time && range.include?(order.commit_time)
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
