#!/usr/bin/env ruby
# Html::Util::Multilingual -- bbmb -- 09.08.2007 -- hwyss@ywesee.com

module BBMB
  module Html
    module Util
module Multilingual
  def _(value)
    if(value.is_a?(BBMB::Util::Multilingual))
      value.send(@session.language) || value.default
    else
      value
    end
  end
end
    end
  end
end
