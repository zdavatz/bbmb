#!/usr/bin/env ruby
# Util::TestServer -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb'
require 'bbmb/util/server'
require 'flexmock'

module BBMB
  module Util
class TestServer < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @server = Server.new
  end
  def test_rename_user__new
    BBMB.config = flexmock('config')
    BBMB.config.should_receive(:auth_domain).times(1).and_return('ch.bbmb')
    BBMB.auth = flexmock('auth')
    session = flexmock('yus-session')
    BBMB.auth.should_receive(:autosession).times(1).and_return { |domain, block|
      assert_equal('ch.bbmb', domain)
      block.call(session)
    }
    session.should_receive(:create_entity).times(1).and_return { |email|
      assert_equal('test@bbmb.ch', email)
    }
    @server.rename_user(nil, 'test@bbmb.ch')
  end
  def test_rename_user__existing
    BBMB.config = flexmock('config')
    BBMB.config.should_receive(:auth_domain).times(1).and_return('ch.bbmb')
    BBMB.auth = flexmock('auth')
    session = flexmock('yus-session')
    BBMB.auth.should_receive(:autosession).times(1).and_return { |domain, block|
      assert_equal('ch.bbmb', domain)
      block.call(session)
    }
    session.should_receive(:rename).times(1).and_return { |previous, email|
      assert_equal('old@bbmb.ch', previous)
      assert_equal('test@bbmb.ch', email)
    }
    @server.rename_user('old@bbmb.ch', 'test@bbmb.ch')
  end
  def test_rename_user__same
    assert_nothing_raised { 
      @server.rename_user('test@bbmb.ch', 'test@bbmb.ch')
    }
  end
  def test_run_invoicer
    BBMB.logger = flexmock('logger')
    BBMB.logger.should_ignore_missing
    flexstub(Mail).should_receive(:notify_error).times(1).and_return { |error|
      assert_instance_of(RuntimeError, error)
    }
    flexstub(Invoicer).should_receive(:run).times(1).and_return { |range|
      assert_instance_of(Range, range)
      raise "notify an error!"
    }
    invoicer = @server.run_invoicer
    Timeout.timeout(5) { 
      until(invoicer.status == 'sleep')
        sleep 0.1
      end
    }
    invoicer.wakeup
    assert_equal('run', invoicer.status)
    until(invoicer.status == 'sleep')
      sleep 0.1
    end
    invoicer.exit
  end
  def test_run_updater
    BBMB.config = flexmock('config')
    BBMB.config.should_receive(:update_hour).and_return(0)
    BBMB.logger = flexmock('logger')
    BBMB.logger.should_ignore_missing
    flexstub(Mail).should_receive(:notify_error).times(1).and_return { |error|
      assert_instance_of(RuntimeError, error)
    }
    flexstub(Updater).should_receive(:run).times(1).and_return {
      raise "notify an error!"
    }
    updater = @server.run_updater
    Timeout.timeout(5) { 
      until(updater.status == 'sleep')
        sleep 0.1
      end
    }
    updater.wakeup
    assert_equal('run', updater.status)
    until(updater.status == 'sleep')
      sleep 0.1
    end
    updater.exit
  end
end
  end
end
