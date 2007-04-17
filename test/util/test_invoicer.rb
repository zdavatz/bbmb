#!/usr/bin/env ruby
# Util::TestInvoicer -- bbmb.ch -- 05.10.2006 -- hwyss@ywesee.com


$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'bbmb/config'
require 'bbmb/util/invoicer'
require 'bbmb/util/numbers'
require 'flexmock'
require 'ostruct'
require 'stub/persistence'
require 'test/unit'

module BBMB
  module Util
class TestInvoicer < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    key = OpenSSL::PKey::DSA.new(512)
    keypath = File.expand_path('../data/private_key', 
                               File.dirname(__FILE__))
    File.open(keypath, 'w') { |fh| fh.puts(key) }
    YDIM::Client::CONFIG.private_key = keypath
    BBMB.config = flexmock('config')
    @ydim_server = flexmock('ydim')
    @ydim_url = 'druby://localhost:10082'
    @ydim_config = flexstub(YDIM::Client::CONFIG)
    @ydim_config.should_receive(:server_url).and_return(@ydim_url)
    @drb_server = DRb.start_service(@ydim_url, @ydim_server)
  end
  def teardown
    @drb_server.stop_service
    super
  end
  def test_create_invoice
    datadir = File.expand_path('data', File.dirname(__FILE__))
    order1 = flexmock('order1')
    order2 = flexmock('order2')
    order1.should_receive(:total).and_return(Util::Money.new(11.00))
    order2.should_receive(:total).and_return(Util::Money.new(13.00))
    path = File.join(datadir, "ydim.yml")
    FileUtils.mkdir_p(datadir)
    File.open(path, 'w') { |fh| 
      fh.puts({'server_url' => @ydim_url}.to_yaml) }
    @ydim_config.should_receive(:load).and_return { |ydim_path|
      assert_equal(path, ydim_path)
    }
    BBMB.config.should_receive(:ydim_config).and_return(path)
    BBMB.config.should_receive(:ydim_id).and_return(7)
    BBMB.config.should_receive(:invoice_percentage).and_return(1)
    BBMB.config.should_receive(:invoice_format).and_return("%s - %s")
    BBMB.config.should_receive(:invoice_item_format).and_return("%.2f -> %i")
    session = flexmock('session')
    @ydim_server.should_receive(:login).and_return(session)
    invoice = OpenStruct.new
    invoice.unique_id = 2
    session.should_receive(:create_invoice).and_return { |id|
      assert_equal(7, id)
      invoice
    }
    today = Date.new(2006,10)
    data = {
      :price    => 0.24,
      :quantity => 1,
      :text     => "24.00 -> 2",
      :time     => Time.local(2006,10),
      :unit     => "1.0%",
    }
    session.should_receive(:add_items).and_return { |id, items|
      assert_equal(2, id)
      assert_equal([data], items)
    }
    @ydim_server.should_receive(:logout).and_return { |client|
      assert_equal(session, client)
    }
    range = Time.local(2006,9)...Time.local(2006,10)
    result = Invoicer.create_invoice(range, [order1, order2], today)
    assert_equal(invoice, result)
    assert_equal("01.09.2006 - 30.09.2006", invoice.description)
    assert_equal(today, invoice.date)
    assert_equal('CHF', invoice.currency)
    assert_equal(30, invoice.payment_period)
  ensure
    FileUtils.rm_r(datadir) if(File.exist?(datadir))
  end
  def test_send_invoice
    BBMB.config.should_ignore_missing
    session = flexmock('session')
    @ydim_server.should_receive(:login).and_return(session)
    session.should_receive(:send_invoice).and_return { |id|
      assert_equal(123, id)
    }
    @ydim_server.should_receive(:logout).and_return { |client|
      assert_equal(session, client)
    }
    Invoicer.send_invoice(123)
  end
  def test_run
    order1 = flexmock('order1')
    order1.should_receive(:total).and_return(Util::Money.new(11.00))
    order1.should_receive(:commit_time).and_return(Time.local(2006,8,31,23,59,59))
    order2 = flexmock('order2')
    order2.should_receive(:total).and_return(Util::Money.new(13.00))
    order2.should_receive(:commit_time).and_return(Time.local(2006,9))
    order3 = flexmock('order1')
    order3.should_receive(:total).and_return(Util::Money.new(17.00))
    order3.should_receive(:commit_time).and_return(Time.local(2006,9,30,23,59,59))
    order4 = flexmock('order1')
    order4.should_receive(:total).and_return(Util::Money.new(19.00))
    order4.should_receive(:commit_time).and_return(Time.local(2006,10))
    BBMB.persistence = flexmock('persistence')
    BBMB.persistence.should_receive(:all).and_return { |klass|
      assert_equal(Model::Order, klass)
      [order1, order2, order3, order4]
    }
    BBMB.config.should_receive(:ydim_config)
    BBMB.config.should_receive(:ydim_id).and_return(7)
    BBMB.config.should_receive(:invoice_percentage).and_return(1)
    BBMB.config.should_receive(:invoice_format).and_return("%s - %s")
    BBMB.config.should_receive(:invoice_item_format).and_return("%.2f -> %i")
    session = flexmock('session')
    @ydim_server.should_receive(:login).and_return(session)
    invoice = OpenStruct.new
    invoice.unique_id = 39
    session.should_receive(:create_invoice).and_return { |id|
      assert_equal(7, id)
      invoice
    }
    today = Date.new(2006,10)
    data = {
      :price    => 0.30,
      :quantity => 1,
      :text     => "30.00 -> 2",
      :time     => Time.local(2006,10),
      :unit     => "1.0%",
    }
    session.should_receive(:add_items).and_return { |id, items|
      assert_equal(39, id)
      assert_equal([data], items)
    }
    @ydim_server.should_receive(:logout).and_return { |client|
      assert_equal(session, client)
    }
    range = Time.local(2006,9)...Time.local(2006,10)
    session.should_receive(:send_invoice).with(39)
    Invoicer.run(range, today)
    assert_equal("01.09.2006 - 30.09.2006", invoice.description)
    assert_equal(today, invoice.date)
    assert_equal('CHF', invoice.currency)
    assert_equal(30, invoice.payment_period)
  end
end
  end
end
