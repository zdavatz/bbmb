#!/usr/bin/env ruby
# Bbmb -- bbmb.ch -- 17.12.2019 -- zdavatz@ywesee.com
require 'bbmb/version'

module BBMB
  class << self
    attr_accessor :auth, :config, :persistence, :server
  end
end
