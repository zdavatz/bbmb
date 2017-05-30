#!/usr/bin/env ruby
# Util::Updater -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb'
require 'sbsm/logger'
require 'bbmb/util/polling_manager'

module BBMB
  module Util
module Updater
  def Updater.run
    SBSM.info "Updated.run started at #{Time.now}"
    PollingManager.new.poll_sources do |filename, io|
      importer, *args = BBMB.config.importers[filename]
      SBSM.info "Updated.run filename #{File.expand_path(filename)} importer #{importer.class}"
      if(importer)
        import(importer, args, io)
      end
    end
  end
  def Updater.import(importer, args, io)
    klass = Util.const_get(importer)
    SBSM.info("Updater.import using klass #{klass}")
    count = klass.new(*args).import(io)
    SBSM.info("updater #{importer.class} imported #{count.is_a?(Integer) ? count : 0} entities")
  end
end
  end
end
