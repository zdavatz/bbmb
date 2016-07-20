require 'pathname'

root_dir = Pathname.new(__FILE__).realpath.parent.parent
lib_dir  = root_dir.join('lib')
test_dir = root_dir.join('test')

$:.unshift(root_dir) unless $:.include?(root_dir)
$:.unshift(lib_dir)  unless $:.include?(lib_dir)
$:.unshift(test_dir) unless $:.include?(test_dir)

require 'minitest/autorun'
require 'flexmock/test_unit'

require 'bbmb/config'

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }
