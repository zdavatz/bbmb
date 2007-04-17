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
  PREFERENCE_KEYS.each { |key|
    define_method(key) {
      remote_call(:get_preference, key) 
    }
  }
  def initialize(session)
    @auth_session = session
  end
  def allowed?(action, key=nil)
    allowed = remote_call(:allowed?, action, key)
    BBMB.logger.debug('User') {
      sprintf('%s: allowed?(%s, %s) -> %s', name, action, key, allowed)
    }
    allowed
  end
  def entity_valid?(email)
    !!(allowed?('edit', 'yus.entities') \
      && (entity = remote_call(:find_entity, email)) && entity.valid?)
  end
  def navigation
    [ :logout ]
  end
  def remote_call(method, *args, &block)
    @auth_session.send(method, *args, &block)
  rescue RangeError, DRb::DRbError => e
    BBMB.logger.error('auth') { e }
  end
  alias :method_missing :remote_call
end
    end
  end
end
