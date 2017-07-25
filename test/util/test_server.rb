#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'
require 'sbsm/logger'
require 'bbmb/util/rack_interface'
require 'bbmb/util/app'

module BBMB
  module Util

class TestServer < Minitest::Test
  def setup
    require 'bbmb/util/server'
    super
    BBMB.config = $default_config.clone
    BBMB.config.persistence = 'none'
    @rack_app = BBMB::Util::App.new
    @server = BBMB::Util::Server.new('none', @rack_app)
    Model::Customer.instances.clear
    Model::Product.instances.clear
  end
  def teardown
    BBMB.config = $default_config.clone
    super
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
    customer = flexmock('customer')
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
    customer_mock = flexmock("find_by_customer_id",  Model::Customer)
    customer_mock.should_receive(:find_by_customer_id).and_return(customer).once
    product_mock = flexmock("product_mock",  Model::Product)
    product_mock.should_receive(:odba_store).at_least.once
    product_mock.should_receive(:new).with('1234567').and_return(pr1)
    product_mock.should_receive(:new).with('1234567890123').and_return(pr2)
    product_mock.should_receive(:new).with('2345678901234').and_return(pr3)
    description = flexmock('description')
    description.should_receive(:de=).and_return('description_de')
    description.should_receive(:de).and_return('description_de')
    product_mock.should_receive(:description).at_least.once.and_return(description)
    product_mock.should_receive(:article_number).at_least.once.and_return('article_number')
    product_mock.should_receive(:price_effective).at_least.once.and_return(33)
    product_mock.should_receive(:backorder).at_least.once
    quota = Model::Quota.new(product_mock)
    customer.should_receive(:quota).and_return(quota).at_least.once
    order_mock = flexmock("order_mock",  Model::Order)
    order_mock.should_receive(:add).once
    skip('Too much time to fix test_inject_order')
    @server.inject_order('12345', prods, infos)
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
    flexmock(customer).should_receive(:inject_order).once.and_return { |order|
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
    flexmock(BBMB::Util::Mail).should_receive(:send_order).with(BBMB::Model::Order)
    BBMB.config.mail_confirm_reply_to = 'replyto@test.org'
    BBMB.config.error_recipients = 'to@test.org'
    skip('Too much time to fix test_inject_order__customer_by_ean13')
    res = @server.inject_order('1234567890123', prods, infos, :deliver => true)
    assert_equal("12345-", res[:order_id])
    assert_equal(3, res[:products].size)
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
    @server.rename_user('cutomer_id', nil, 'test@bbmb.ch')
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
    @server.rename_user('cutomer_id',   'old@bbmb.ch', 'test@bbmb.ch')
  end
  def test_rename_user__same
    @server.rename_user('cutomer_id', 'test@bbmb.ch', 'test@bbmb.ch')
  end
  def test_run_invoicer
    error_mock = flexmock(RuntimeError.new, 'error')
    flexstub(Mail).should_receive(:notify_error).at_least.once.and_return { |error|
      assert_instance_of(RuntimeError, error_mock)
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
