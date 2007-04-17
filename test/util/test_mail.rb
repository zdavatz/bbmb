#!/usr/bin/env ruby
# Util::TestMail -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com


$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'bbmb/util/mail'
require 'flexmock'
require 'test/unit'

module BBMB
  module Util
    class TestMail < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup_config
        config = flexmock('config')
        BBMB.config = config
        config.should_receive(:error_recipients).and_return(['to.test@bbmb.ch'])
        config.should_receive(:mail_order_from).and_return('from.test@bbmb.ch')
        config.should_receive(:mail_order_to).and_return('to.test@bbmb.ch')
        config.should_receive(:mail_order_cc).and_return('cc.test@bbmb.ch')
        config.should_receive(:mail_order_subject).and_return('order %s')
        config.should_receive(:name).and_return('Application/User Agent')
        config.should_receive(:smtp_authtype).and_return(:plain)
        config.should_receive(:smtp_helo).and_return('helo.domain')
        config.should_receive(:smtp_pass).and_return('secret')
        config.should_receive(:smtp_port).and_return(25)
        config.should_receive(:smtp_server).and_return('mail.test.com')
        config.should_receive(:smtp_user).and_return('user')
        config
      end
      def test_notify_error
        config = setup_config
        smtp = flexmock('smtp')
        flexstub(Net::SMTP).should_receive(:start).and_return { 
          |srv, port, helo, user, pass, type, block|
          assert_equal('mail.test.com', srv)
          assert_equal(25, port)
          assert_equal('helo.domain', helo)
          assert_equal('user', user)
          assert_equal('secret', pass)
          assert_equal(:plain, type)
          block.call(smtp) 
        }
        headers = <<-EOS
From: from.test@bbmb.ch
To: to.test@bbmb.ch
Subject: Application/User Agent: error-message
User-Agent: Application/User Agent
        EOS
        body = <<-EOS
[RuntimeError, "error-message", nil]
        EOS
        smtp.should_receive(:sendmail).and_return { |message, from, recipients|
          assert(message.include?(headers), 
                 "missing headers:\n#{headers}\nin message:\n#{message}")
          assert(message.include?(body), 
                 "missing body:\n#{body}\nin message:\n#{message}")
          assert_equal('from.test@bbmb.ch', from)
          assert_equal(['to.test@bbmb.ch'], recipients)
        }
        Mail.notify_error(RuntimeError.new("error-message"))
      end
      def test_send_order
        order = flexmock('order')
        order.should_receive(:to_i2).and_return('i2-data')
        order.should_receive(:order_id).and_return('order-id')
        order.should_receive(:filename).and_return('filename')
        config = setup_config
        smtp = flexmock('smtp')
        flexstub(Net::SMTP).should_receive(:start).and_return { 
          |srv, port, helo, user, pass, type, block|
          assert_equal('mail.test.com', srv)
          assert_equal(25, port)
          assert_equal('helo.domain', helo)
          assert_equal('user', user)
          assert_equal('secret', pass)
          assert_equal(:plain, type)
          block.call(smtp) 
        }
        headers = <<-EOS
From: from.test@bbmb.ch
To: to.test@bbmb.ch
Cc: cc.test@bbmb.ch
Subject: order order-id
Message-ID: <order-id@from.test.bbmb.ch>
Mime-Version: 1.0
User-Agent: Application/User Agent
        EOS
        body = <<-EOS
i2-data
        EOS
        smtp.should_receive(:sendmail).and_return { |message, from, recipients|
          assert(message.include?(headers), 
                 "missing headers:\n#{headers}\nin message:\n#{message}")
          assert(message.include?(body), 
                 "missing body:\n#{body}\nin message:\n#{message}")
          #assert(message.include?(attachment), 
                 #"missing attachment:\n#{attachment}\nin message:\n#{message}")
          assert_equal('from.test@bbmb.ch', from)
          assert_equal(['to.test@bbmb.ch', 'cc.test@bbmb.ch'], recipients)
        }
        Mail.send_order(order)
      end
    end
  end
end
