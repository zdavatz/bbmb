require 'pathname'

root_dir = Pathname.new(__FILE__).realpath.parent.parent
lib_dir  = root_dir.join('lib')
test_dir = root_dir.join('test')

$:.unshift(root_dir) unless $:.include?(root_dir)
$:.unshift(lib_dir)  unless $:.include?(lib_dir)
$:.unshift(test_dir) unless $:.include?(test_dir)

require 'minitest/autorun'
require 'flexmock/minitest'
require 'bbmb/config'
require 'sbsm/logger'
SBSM.logger = Logger.new('test_helper.log')

# We create hier a global copy of the defautl BBMB.config as we
# must restore it after each change in BBMB.config in a test
$default_config = BBMB.config.clone
BBMB.config.persistence = 'none'

require 'mail'
::Mail.defaults do delivery_method :test end
SendRealMail = false
if SendRealMail
  TestRecipient = 'ngiger@ywesee.com'
else
  TestRecipient = 'to.test@bbmb.ch'
end
::Mail::TestMailer.deliveries.clear

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }
