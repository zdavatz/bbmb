#!/usr/bin/env ruby
# Util::Server -- de.bbmb.org -- 01.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
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
require 'bbmb/persistence/odba' unless BBMB.config.persistence.eql?('none')
require 'bbmb/model/customer'
require 'bbmb/model/quota'
require 'bbmb/model/product'
require 'bbmb/model/promotion'
require 'sbsm/admin_server'

module BBMB
  def self.persistence
    @@persistence ||= BBMB::Persistence::ODBA
  end
  module Util
    class Server < SBSM::AdminServer
      def initialize(persistence, app)
        @persistence = persistence
        @app = app
        super(app: app)
      end
      def invoice(range)
        SBSM.info "invoice started at #{Time.now} for #{range}"
        Invoicer.run(range)
      rescue Exception => e
        Mail.notify_error(e)
      end
      def update
        Updater.run
      rescue Exception => e
        Mail.notify_error(e)
      end
      def inject_order(customer_id, products, infos, opts={})
        @app.inject_order(customer_id, products, infos, opts)
      end
      def rename_user(customer_id, old_name, new_name)
        return if old_name.eql?(new_name)
        BBMB.auth.autosession(BBMB.config.auth_domain) do |session|
          if (old_name.nil?)
            begin
              session.create_entity(new_name)
            rescue => error
              raise error if Model::Customer.odba_extent.find {|x| x.email && x.email.index(new_name) }
              SBSM.info("Skip session.create_entity for customer #{customer_id} as we found no customer with e-mail #{new_name}")
            end
          else
            session.rename(old_name, new_name)
          end
        end
      end
      def run_invoicer
        @invoicer ||= Thread.new {
          Thread.current.abort_on_exception = true
          loop {
            today = Date.today
            day = today >> 1
            start = Time.local(today.year, today.month)
            now = Time.now
            at = Time.local(day.year, day.month)
            secs = at - now
            msg = "run_invoicer sleeping %.2f seconds (or more than %d days)" % [ secs, secs/3600/24 ]
            SBSM.debug(msg)
            sleep(secs)
            invoice(start...at)
          }
        }
      end
      def run_updater
        run_only_once_at_startup = false
        SBSM.debug("run_only_once_at_startup? #{run_only_once_at_startup} hour: #{BBMB.config.update_hour}")
        @updater ||= Thread.new {
          loop {
            day = Date.today
            now = Time.now
            if(now.hour >= BBMB.config.update_hour)
              day += 1
            end
            at = Time.local(day.year, day.month, day.day, BBMB.config.update_hour)
            secs = at - now
            SBSM.debug("updater sleeping %.2f seconds. run_only_once_at_startup #{run_only_once_at_startup}" % secs)
            if run_only_once_at_startup then puts "Skipped sleeping #{secs}" else sleep(secs) end
            SBSM.debug("update starting")
            update
            SBSM.debug("update finished")
            Thread.abort if run_only_once_at_startup
          }
        }
      end
    end
  end
end
