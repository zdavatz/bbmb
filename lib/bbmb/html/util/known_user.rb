#!/usr/bin/env ruby
# Html::Util::KnownUser -- bbmb.ch -- 18.09.2006 -- hwyss@ywesee.com

require 'sbsm/user'

module BBMB
  module Html
    module Util
class KnownUser < SBSM::User
  ### Admin users need permissions for:
  # login BBMB.config.auth_domain + ".Admin"
  # edit yus.entities
  # set_password
  # grant login
  #
  ### Customers need permissions for:
  # login BBMB.config.auth_domain + ".Customer"
  attr_reader :auth_session
  PREFERENCE_KEYS = [ :home, :pagestep ]
  def initialize(session)
    @auth_session = session.auth_session
  end
  def allowed?(action, key=nil)
    if @auth_session
      return @auth_session.allowed?(action, key)
      return @auth_session.remote_call(:allowed?, action, key)
    end
    SBSM.debug('User ' + sprintf('allowed?(%s, %s)', action, key))
    return true
  rescue => error
    puts error
    puts error.backtrace.join("\n")
  end
  def entity_valid?(email)
    !!(@auth_session.allowed?('edit', 'yus.entities') \
      && (entity = @auth_session.find_entity(email)) && entity.valid?)
  end
  def navigation
    [ :logout ]
  end
  def get_preference(key)
    return @auth_session.get_preference(key.to_s)
    remote_call(:get_preference, key)
  end
  def remote_call(method, *args, &block)
    SBSM.debug("remote_call #{method} args #{args} block.nil? #{block.nil?}")
    if defined?(@auth_session) && @auth_session.is_a?(DRb::DRbObject)
      return @auth_session.send(method, *args, &block)
    else
      return false
      return super(method, *args, &block)
    end
  rescue RangeError, DRb::DRbError => e
    SBSM.info('auth') { e }
  rescue error
    puts error
    puts error.backtrace.join("\n")
  end
end
    end
  end
end
