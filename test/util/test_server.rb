#!/usr/bin/env ruby
# Util::TestServer -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb'
require 'bbmb/util/server'
require 'stub/persistence'
require 'flexmock'

module BBMB
  module Util
class TestServer < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @server = Server.new
    Model::Customer.instances.clear
    Model::Product.instances.clear
  end
  def test_inject_order__unknown_customer
    assert_raises(RuntimeError) {
      @server.inject_order('12345', [], {})
    }
  end
  def test_inject_order
    pr1 = Model::Product.new 1
    pr1.pcode = '1234567'
    pr2 = Model::Product.new 2
    pr2.ean13 = '1234567890123'
    pr3 = Model::Product.new 3
    pr3.ean13 = '2345678901234'
    pr3.pcode = '2345678'
    customer = Model::Customer.new('12345')
    flexmock(customer).should_receive(:inject_order).times(1).and_return { |order|
      assert_instance_of(Model::Order, order)
      ps1, ps2, ps3 = order.positions
      assert_instance_of(Model::Order::Position, ps1)
      assert_instance_of(Model::Order::Position, ps2)
      assert_instance_of(Model::Order::Position, ps3)
      assert_equal(3, ps1.quantity)
      assert_equal(pr1, ps1.product)
      assert_equal(4, ps2.quantity)
      assert_equal(pr2, ps2.product)
      assert_equal(5, ps3.quantity)
      assert_equal(pr3, ps3.product)
      assert_equal('My Comment', order.comment)
      assert_equal('76543', order.reference)
    }
    prods = [
      {:quantity => 3, :pcode => '1234567'},
      {:quantity => 4, :ean13 => '1234567890123'},
      {:quantity => 5, :pcode => '2345678', :ean13 => '2345678901234'},
    ]
    infos = {
      :comment => 'My Comment',
      :reference => '76543',
    }
    assert_nothing_raised {
      @server.inject_order('12345', prods, infos)
    }
  end
  def test_inject_order__customer_by_ean13
    pr1 = Model::Product.new 1
    pr1.pcode = '1234567'
    pr2 = Model::Product.new 2
    pr2.ean13 = '1234567890123'
    pr3 = Model::Product.new 3
    pr3.ean13 = '2345678901234'
    pr3.pcode = '2345678'
    customer = Model::Customer.new('12345')
    customer.ean13 = '1234567890123'
    flexmock(customer).should_receive(:inject_order).times(1).and_return { |order|
      assert_instance_of(Model::Order, order)
      ps1, ps2, ps3 = order.positions
      assert_instance_of(Model::Order::Position, ps1)
      assert_instance_of(Model::Order::Position, ps2)
      assert_instance_of(Model::Order::Position, ps3)
      assert_equal(3, ps1.quantity)
      assert_equal(pr1, ps1.product)
      assert_equal(4, ps2.quantity)
      assert_equal(pr2, ps2.product)
      assert_equal(5, ps3.quantity)
      assert_equal(pr3, ps3.product)
      assert_equal('My Comment', order.comment)
      assert_equal('76543', order.reference)
    }
    prods = [
      {:quantity => 3, :pcode => '1234567'},
      {:quantity => 4, :ean13 => '1234567890123'},
      {:quantity => 5, :pcode => '2345678', :ean13 => '2345678901234'},
    ]
    infos = {
      :comment => 'My Comment',
      :reference => '76543',
    }
    flexmock(BBMB::Util::Mail).should_receive(:send_order)\
      .with(BBMB::Model::Order).times(1)
    flexmock(BBMB::Util::TargetDir).should_receive(:send_order)\
      .with(BBMB::Model::Order).times(1)
    assert_nothing_raised {
      @server.inject_order('1234567890123', prods, infos, :deliver => true)
    }
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
