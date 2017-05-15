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
  def initialize(session)
    puts "BBMB::Html::Util::KnownUser.new object_id is #{self.object_id} SBSM::Session ? #{self.is_a? SBSM::Session} auth_session is #{session.class}"
    @auth_session = session.auth_session
    # puts "backtrace #{caller.join("\n")}"
    # @auth_session.auth.allowed?('edit', 'yus.entities')
  end
  def allowed?(action, key=nil)
    if @auth_session
      return @auth_session.allowed?(action, key)
    end
  rescue => error
    puts error
    puts error.backtrace.join("\n")
  end
  def entity_valid?(email)
    !!(@auth_session.allowed?('edit', 'yus.entities') \
      && (entity = @auth_session.find_entity(email)) && entity.valid?)
  end
  def navigation
    puts "BBMB::Html::Util::KnownUser navigation returning  [ :logout ]"
    [ :logout ]
  end
  def get_preference(key)
    @auth_session.get_preference(key.to_s)
  end
  def remote_call(method, *args, &block)
    SBSM.debug("remote_call #{method} args #{args} block.nil? #{block.nil?}")
    if defined?(@auth_session) && @auth_session.is_a?(DRb::DRbObject)
      return @auth_session.send(method, *args, &block)
    else
      return false
    end
  rescue RangeError, DRb::DRbError => e
    SBSM.info('auth') { e }
  rescue error
    puts error
  end
  # alias :method_missing :remote_call
end
    end
  end
end
