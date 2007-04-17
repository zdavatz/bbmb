#!/usr/bin/env ruby
# Util::Updater -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb'
require 'bbmb/util/polling_manager'

module BBMB
  module Util
module Updater
  def Updater.run
    PollingManager.new.poll_sources { |filename, io|
      if(importer = BBMB.config.importers[filename])
        import(importer, io)
      end
    }
  end
  def Updater.import(importer, io)
    klass = Util.const_get(importer)
    count = klass.new.import(io)
    BBMB.logger.debug('updater') { 
      sprintf("%s imported %i entities", importer, imported) }
  end
end
  end
end
