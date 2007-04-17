#!/usr/bin/env ruby
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com 

here = File.dirname(__FILE__)
$: << here

require 'find'
Find.find(here) { |file|
	if /test_.*\.rb$/o.match(file)
    require file
	end
}
