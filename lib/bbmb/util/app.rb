#!/usr/bin/env ruby
# Util::Server -- de.bbmb.org -- 01.09.2006 -- hwyss@ywesee.com
require 'bbmb/config'
require 'ydim/invoice'
require 'bbmb/html/util/known_user'
require 'bbmb/html/util/session'
require 'bbmb/html/util/validator'
require 'bbmb/util/invoicer'
require 'bbmb/util/invoicer'
require 'bbmb/util/mail'
require 'bbmb/util/updater'
require 'bbmb/model/order' # needed to be enable to invoice later
require 'bbmb/model/customer'
require 'date'
require 'sbsm/app'
case BBMB.config.persistence
when 'odba'
  require 'bbmb/persistence/odba'
else
  require 'bbmb/persistence/none'
end
require 'bbmb/model/customer'
require 'bbmb/model/quota'
require 'bbmb/model/product'
require 'bbmb/model/promotion'
require 'bbmb/util/server'

module BBMB
  def self.persistence
    @@persistence ||= BBMB::Persistence::ODBA
  end
  module Util
    class App < SBSM::App
      attr_accessor :db_manager, :yus_server
      def start_service
        case BBMB.config.persistence
        when 'odba'
          DRb.install_id_conv ODBA::DRbIdConv.new
        end
        BBMB.persistence = BBMB::Persistence::ODBA
        BBMB.auth = DRb::DRbObject.new(nil, BBMB.config.auth_url)
        BBMB.server = BBMB::Util::Server.new(BBMB.persistence, self)
        BBMB.server.extend(DRbUndumped)
        BBMB.server = BBMB.server
        if(BBMB.config.update?)
          BBMB.server.run_updater
        end
        if(BBMB.config.invoice?)
          BBMB.server.run_invoicer
        end
        url = BBMB.config.server_url
        url.untaint
        DRb.start_service(url, BBMB.server)
        $SAFE = 1
        $0 = BBMB.config.name
        SBSM.logger.info("started bbmb-server on #{url}")
        DRb.thread.join
        SBSM.logger.info('finished') { sprintf("starting bbmb-server on %s", url) }
      rescue Exception => error
        SBSM.logger.error('fatal')
        raise
      end
      def initialize
          super
          SBSM.logger.info "Starting Rack-Service #{self.class} and service #{BBMB.config.server_url}"
          Thread.new {
              start_service
          }
      end
      def send_order order, customer
        SBSM.logger.info "send_order #{order.order_id} and customer #{customer.customer_id}"
        begin
          Timeout.timeout(300) {
            BBMB::Util::TargetDir.send_order(order)
          }
        rescue StandardError => err
          err.message << " (Email: #{customer.email} - Customer-Id: #{customer.customer_id})"
          BBMB::Util::Mail.notify_error(err)
        end
        begin
          Timeout.timeout(300) {
            BBMB::Util::Mail.send_order(order)
          }
        rescue StandardError => err
          err.message << " (Email: #{customer.email} - Customer-Id: #{customer.customer_id})"
          BBMB::Util::Mail.notify_error(err)
        end
        begin
          Timeout.timeout(300) {
            BBMB::Util::Mail.send_confirmation(order)
          }
        rescue StandardError => err
          err.message << " (Email: #{customer.email} - Customer-Id: #{customer.customer_id})"
          BBMB::Util::Mail.notify_error(err)
        end
      end
    end
  end
end
