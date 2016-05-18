#!/usr/bin/env ruby
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com 

here = File.expand_path(File.dirname(__FILE__))
$: << here

require 'find'

failures =  []
okay =  []
Find.find(here) do |file|
  if /test_.*\.rb$/o.match(file)
    short =  File.basename(file, '.rb')
    if false # Run them all as a simple
      require file
    else
      log = short + '.log'
      cmd = "bash -c 'bundle exec #{file} --seed 62766  2>&1 | tee #{log}; ( exit ${PIPESTATUS[0]} )'"
      puts cmd
      res = system(cmd)
      if res
        puts "No problem executing #{short}"
        okay << short
        FileUtils.rm_f(log)
      else
        failures << short
      end
    end
  end
end
puts
puts "The following tests showed no problems #{okay}"
puts
puts "The following tests had problems #{failures}"
# --seed 33839 hangs
# --seed 62766 passed
exit(failures.size)