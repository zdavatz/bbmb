#!/usr/bin/env ruby
# Html::Util::Session -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
require 'bbmb/html/util/known_user'
require 'bbmb/html/state/login'
require 'sbsm/session'
require 'sbsm/redirector'

module BBMB
  module Html
    module Util
class Session < SBSM::Session
  include SBSM::Redirector
  DEFAULT_LANGUAGE = 'de'
  DEFAULT_STATE = State::Login
  EXPIRES = BBMB.config.session_timeout
  PERSISTENT_COOKIE_NAME = "bbmb-barcodereader"
  def login
    @user = @app.login(user_input(:email), user_input(:pass))
    @user.session = self if(@user.respond_to?(:session=))
    @user
  end
  def logout
    @app.logout(@user.auth_session) if(@user.respond_to?(:auth_session))
    super
  end
  def lookandfeel
    if(@lookandfeel.nil? \
      || (@lookandfeel.language != persistent_user_input(:language)))
      require 'bbmb/html/util/lookandfeel'
      @lookandfeel = Lookandfeel.new(self) # dtsttcpw
    end
    @lookandfeel
  end
  def process(request)
    begin 
      if(@user.is_a?(KnownUser) && @user.auth_session.expired?)
        logout
      end
    rescue DRb::DRbError, RangeError, NoMethodError
      logout
    end
    super
  end
  def validate(key, value)
    @validator.validate(key, value)
  end
end
    end
  end
end
