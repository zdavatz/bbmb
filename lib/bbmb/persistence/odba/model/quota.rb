#!/usr/bin/env ruby
# Model::Quota -- bbmb -- 11.04.2007 -- hwyss@ywesee.com

require 'bbmb/model/quota'

module BBMB
  module Model
    class Quota
      include ODBA::Persistable
    end
  end
end
