#!/usr/bin/env ruby
#  -- de.oddb.org -- 09.08.2007 -- hwyss@ywesee.com

require 'bbmb/html/util/multilingual'

module BBMB
  module Html
    module View
module Multilingual
  include Util::Multilingual
  def description(model)
    _(model.description)
  end
end
    end
  end
end
