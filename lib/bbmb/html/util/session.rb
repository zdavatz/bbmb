#!/usr/bin/env ruby
# encoding: utf-8

require 'bbmb/config'
require 'sbsm/session'
require 'bbmb/html/state/global'
require 'bbmb/html/util/lookandfeel'
require 'bbmb/html/util/known_user'


module BBMB
  module Html
    module Util
class Session < SBSM::Session
  DEFAULT_LANGUAGE = 'de'
  DEFAULT_FLAVOR = "sandoz"
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
