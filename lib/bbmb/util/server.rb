#!/usr/bin/env ruby
# Util::Server -- de.bbmb.org -- 01.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
require 'bbmb/html/util/known_user'
require 'bbmb/html/util/session'
require 'bbmb/html/util/validator'
require 'bbmb/util/invoicer'
require 'bbmb/util/mail'
require 'bbmb/util/updater'
require 'date'
require 'sbsm/drbserver'

module BBMB
  module Util
    class Server < SBSM::DRbServer
      ENABLE_ADMIN = true 
	    SESSION = Html::Util::Session
	    VALIDATOR = Html::Util::Validator
      attr_reader :updater
      def invoice(range)
        Invoicer.run(range)
      rescue Exception => e
        Mail.notify_error(e)
      end
      def login(email, pass)
        session = BBMB.auth.login(email, pass, BBMB.config.auth_domain)
        Html::Util::KnownUser.new(session)
      end
      def logout(session)
        BBMB.auth.logout(session)
      rescue DRb::DRbError, RangeError, NameError
      end
      def rename_user(old, new)
        return if(old == new)
        BBMB.auth.autosession(BBMB.config.auth_domain) { |session|
          if(old.nil?)
            session.create_entity(new)
          else
            session.rename(old, new)
          end
        }
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
            BBMB.logger.debug("invoicer") { 
              "sleeping %.2f seconds" % secs
            }
            sleep(secs)
            invoice(start...at)
          }
        }
      end
      def run_updater
        @updater ||= Thread.new {
          loop {
            day = Date.today
            now = Time.now
            if(now.hour >= BBMB.config.update_hour)
              day += 1
            end
            at = Time.local(day.year, day.month, day.day, 
                            BBMB.config.update_hour)
            secs = at - now
            BBMB.logger.debug("updater") { 
              "sleeping %.2f seconds" % secs
            }
            sleep(secs)
            update
          }
        }
      end
      def update
        Updater.run
      rescue Exception => e
        Mail.notify_error(e)
      end
    end
  end
end
