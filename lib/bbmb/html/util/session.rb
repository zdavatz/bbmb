#!/usr/bin/env ruby
# encoding: utf-8

require 'uri'
require 'bbmb/config'
require 'sbsm/session'
require 'bbmb/html/state/global'
require 'bbmb/html/util/known_user'


module BBMB
  module Html
    module Util
class Session < SBSM::Session
  DEFAULT_LANGUAGE = 'de'
  DEFAULT_FLAVOR = 'bbmb'
  DEFAULT_STATE = State::Login
  EXPIRES = BBMB.config.session_timeout
  PERSISTENT_COOKIE_NAME = "bbmb-barcodereader"
  if uri = URI.parse(BBMB.config.http_server)
    SERVER_NAME = uri.host
  end
  attr_reader :email, :pass, :auth_session
  def initialize(app:,  cookie_name:, trans_handler:, validator:, unknown_user:)
    super
    # @user = BBMB::Html::Util::KnownUser.new(self)
  end
  def login
    @email = user_input(:email)
    @password = user_input(:pass)
    @user.session = self if(@user.respond_to?(:session=))
    # Before rack: @user = @app.login(user_input(:email), user_input(:pass))
    #      gets now  NoMethodError: undefined method `login' for nil:NilClass

    # undefined
    # @user = @app.auth.login(user_input(:email), user_input(:pass))
    #  ArgumentError: wrong number of arguments (given 2, expected 3)
    # from (druby://virbac.bbmb.ngiger.ch:12003) /usr/local/ruby-2.4.0/lib/ruby/gems/2.4.0/gems/yus-1.0.4/lib/yus/server.rb:24:in `login'
    puts "session= defined? #{@user.respond_to?(:session=)}"
    # @auth_session = @app.auth.login(user_input(:email), user_input(:pass), BBMB.config.auth_domain)
    @auth_session = @app.auth.login(user_input(:email), user_input(:pass), BBMB.config.auth_domain) # logs in claude meier without problem, but not admin
    if @auth_session.valid?
      @user = BBMB::Html::Util::KnownUser.new(self) # TODO:Should we set it already in the initialize method?
    else
      @user = SBSM::UnknownUser
    end
    SBSM.info "BBMB::Html::Util::Session login #{user_input(:email)} #{user_input(:pass)}  #{@user.class} auth_session #{@auth_session.class}"
    #unless @user.is_a?(BBMB::Html::Util::KnownUser)
    @user
  end
  def logout
    SBSM.info "BBMB::Html::Util::Session logout @auth_session #{@auth_session.class}"
    $stdout.sync = true
    @app.logout(@user.auth_session) if(@user.respond_to?(:auth_session))
    super
  end

  def lookandfeel
    if(@lookandfeel.nil? \
      || (@lookandfeel.language != persistent_user_input(:language)))
      require 'bbmb/html/util/lookandfeel'
      @lookandfeel = Lookandfeel.new(self)
    end
    @lookandfeel
  end
  def process(request)
    SBSM.info "BBMB::Html::Util::Session process"
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
  def remote_call(method, *args, &block)
    @yus_user.send(method, *args, &block)
  rescue RangeError, DRb::DRbError => e
    BBMB.logger.error('auth') { e }
  end
end
    end
  end
end
