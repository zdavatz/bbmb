#!/usr/bin/env ruby
# Util::Server -- de.bbmb.org -- 01.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
require 'bbmb/html/util/known_user'
require 'bbmb/html/util/session'
require 'bbmb/html/util/validator'
require 'bbmb/util/invoicer'
require 'bbmb/util/invoicer'
require 'bbmb/util/mail'
require 'bbmb/model/order' # needed to be enable to invoice later
require 'bbmb/model/customer'
require 'date'
require 'sbsm/app'
require 'bbmb/persistence/odba'
require 'bbmb/model/customer'
require 'bbmb/model/quota'
require 'bbmb/model/product'
require 'bbmb/model/promotion'

module BBMB
  module Util
    class RackInterface < SBSM::RackInterface
      ENABLE_ADMIN = true
      SESSION = Html::Util::Session
      VALIDATOR = Html::Util::Validator
      def initialize(app: BBMB::Util::App.new,
                     auth: nil,
                     validator: BBMB::Html::Util::Validator)
        [ File.join(Dir.pwd, 'etc', 'config.yml'),
        ].each do |config_file|
          if File.exist?(config_file)
            SBSM.info "BBMB.config.load from #{config_file}"
            BBMB.config.load (config_file)
            break
          end
        end
        @app = app
        super(app: app,
              session_class: BBMB::Html::Util::Session,
              unknown_user: Html::Util::KnownUser,
              validator: validator,
              cookie_name: 'virbac.bbmb'
              )
      end
    end
  end
end
