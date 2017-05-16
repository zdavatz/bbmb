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
require 'bbmb/persistence/odba'
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
      attr_accessor :auth, :config, :persistence, :server

      def start_service
        case BBMB.config.persistence
        when 'odba'
          DRb.install_id_conv ODBA::DRbIdConv.new
          @persistence = BBMB::Persistence::ODBA
        end
        @auth = DRb::DRbObject.new(nil, BBMB.config.auth_url)
        puts "installed @auth #{@auth}"
        @server = BBMB::Util::Server.new(@persistence, self)
        @server.extend(DRbUndumped)
        BBMB.server = @server
        puts "installed BBMB.server #{BBMB.server}"
        if(BBMB.config.update?)
          @server.run_updater
        end
        if(BBMB.config.invoice?)
          @server.run_invoicer
        end
        url = BBMB.config.server_url
        url.untaint
        DRb.start_service(url, @server)
        $SAFE = 1
        $0 = BBMB.config.name
        SBSM.logger.info('start') { sprintf("starting bbmb-server on %s", url) }
        DRb.thread.join
        SBSM.logger.info('finished') { sprintf("starting bbmb-server on %s", url) }
      rescue Exception => error
        SBSM.logger.error('fatal') { error }
        raise
      end
      def initialize
          super
          puts "Starting Rack-Service #{self.class} and service #{BBMB.config.server_url}"
          Thread.new {
              start_service
          }
      end
      def login(email, pass)
        session = BBMB.auth.login(email, pass, BBMB.config.auth_domain)
        Html::Util::KnownUser.new(session)
      end
      def logout(session)
        # Here we start when logging in from the home page
        BBMB.auth.logout(session)
      rescue DRb::DRbError, RangeError, NameError
      end
    end
  end
end
