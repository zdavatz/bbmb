#!/usr/bin/env ruby
# Html::View::CopyLeft -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/link'

module BBMB
  module Html
    module View
class CopyLeft < HtmlGrid::DivComposite
  def CopyLeft.external_link(key, url)
    define_method(key) { |model|
      link = HtmlGrid::Link.new(key, model, @session, self)
      link.href = url
      link
    }
  end
  COMPONENTS = {
    [0,0]      =>  :lgpl,
    [1,0]      =>  ', ',
    [2,0]      =>  :current_year,
    [3,0]      =>  ' ',
    [4,0]      =>  :ywesee,
    [5,0]      =>  ' ',
    [6,0]      =>  :bbmb_version,
  }
  external_link :lgpl, 'http://www.gnu.org/copyleft/lesser.html'
  external_link :ywesee, 'http://www.ywesee.com'
  external_link :version, 'http://scm.ywesee.com/?p=vetoquinol.bbmb.ch'
  def current_year(model)
    Time.now.year.to_s
  end
  def bbmb_version(model)
    link = version(model)
    link.set_attribute('title', VERSION)
    link
  end
end
    end
  end
end
