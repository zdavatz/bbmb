#!/usr/bin/env ruby
# Html::View::Template -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/view/head'
require 'bbmb/html/view/foot'
require 'htmlgrid/divtemplate'
require 'time'

module HtmlGrid
  class Composite
    LEGACY_INTERFACE = false
  end
end
module BBMB
  module Html
    module View
class Template < HtmlGrid::DivTemplate
  COMPONENTS = {
    [0,0]    =>  :head,
    [0,1]    =>  :content,
    [0,2]    =>  :foot,
  }
  CSS_ID_MAP = ['head', 'content', 'foot']
	CSS_FILES = ['bbmb.css']
  HEAD = Head
  HTTP_HEADERS = {
    "Content-Type"  =>  "text/html; charset=utf-8",
    "Cache-Control" =>  "private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
    "Pragma"        =>  "no-cache",
    "Expires"       =>  Time.now.httpdate,
    "P3P"           =>  "CP='OTI NID CUR OUR STP ONL UNI PRE'",
  }
  FOOT = Foot
  META_TAGS = [
    {
      "http-equiv"  =>  "robots",
      "content"     =>  "nofollow, noindex",
    },
  ]
  def http_headers(*args)
    headers = super
    headers.store('Refresh', 
      "#{BBMB.config.session_timeout}; URL=#{@lookandfeel._event_url(:logout)}")
    headers
  end
  def title(context)
    parts = [:html_title, *@session.state.direct_event].collect { |key| 
      @lookandfeel.lookup(key) }.compact
    context.title { parts.join(' | ') }
  end
end
    end
  end
end
