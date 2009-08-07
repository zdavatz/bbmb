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
        config = BBMB.config
        config.error_recipients = ['to.test@bbmb.ch']
        config.mail_order_from = 'from.test@bbmb.ch'
        config.mail_order_to = 'to.test@bbmb.ch'
        config.mail_order_cc = 'cc.test@bbmb.ch'
        config.mail_order_subject = 'order %s'
        config.mail_request_from = 'from.request.test@bbmb.ch'
        config.mail_request_to = 'to.request.test@bbmb.ch'
        config.mail_request_cc = 'cc.request.test@bbmb.ch'
        config.mail_request_subject = 'Request %s'
        config.name = 'Application/User Agent'
        config.smtp_authtype = :plain
        config.smtp_helo = 'helo.domain'
        config.smtp_pass = 'secret'
        config.smtp_port = 25
        config.smtp_server = 'mail.test.com'
        config.smtp_user = 'user'
        config.mail_confirm_reply_to = 'replyto-test@bbmb.ch'
        config.mail_confirm_from = 'from-test@bbmb.ch'
        config.mail_confirm_cc = []
        config.mail_confirm_subject = 'Confirmation %s'
        config.mail_confirm_body = <<-EOS
Sie haben am %s folgende Artikel bestellt:

%s
------------------------------------------------------------------------
Bestelltotal exkl. Mwst. %10.2f
Bestelltotal inkl. Mwst. %10.2f
====================================

En date du %s vous avez commandé les articles suivants

%s
------------------------------------------------------------------------
Commande excl. Tva.      %10.2f
Commande incl. Tva.      %10.2f
====================================

In data del %s Lei ha ordinato i seguenti prodotti.

%s
------------------------------------------------------------------------
Totale dell'ordine escl. %10.2f
Totale dell'ordine incl. %10.2f
====================================
        EOS
        config.mail_confirm_lines = [
          "%3i x %-36s à %7.2f, total  %10.2f",
          "%3i x %-36s à %7.2f, total  %10.2f",
          "%3i x %-36s a %7.2f, totale %10.2f",
        ]
        config.inject_error_to = 'to.test@bbmb.ch'
        config.confirm_error_to = 'to.test@bbmb.ch'
        config
      end
      def test_inject_error
        config = setup_config
        customer = flexmock('customer')
        customer.should_receive(:customer_id).and_return('12345678')
        order = flexmock('order')
        order.should_receive(:customer).and_return(customer)
        order.should_receive(:order_id).and_return('12345678-90')
        order.should_receive(:commit_time).and_return Time.local(2009, 8, 7, 11, 14, 4)
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
Mime-Version: 1.0
User-Agent: Application/User Agent
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
From: errors.test@bbmb.ch
To: to.test@bbmb.ch
Cc: 
Subject: Order 12345678-90 with missing customer: Pharmacy Health
        EOS
        body = <<-EOS
The order Pharmacy Health, committed on 07.08.2009 11:14:04, assigned to the unknown customer: 12345678
        EOS
        smtp.should_receive(:sendmail).and_return { |message, from, recipients|
          assert(message.include?(headers),
                 "missing headers:\n#{headers}\nin message:\n#{message}")
          assert(message.include?(body),
                 "missing body:\n#{body}\nin message:\n#{message}")
          assert_equal('errors.test@bbmb.ch', from)
          assert_equal(['to.test@bbmb.ch'], recipients)
        }
        Mail.notify_inject_error(order, :customer_name => 'Pharmacy Health')
      end
      def test_confirm_error
        config = setup_config
        customer = flexmock('customer')
        customer.should_receive(:customer_id).and_return('12345678')
        order = flexmock('order')
        order.should_receive(:customer).and_return(customer)
        order.should_receive(:order_id).and_return('12345678-90')
        order.should_receive(:commit_time).and_return Time.local(2009, 8, 7, 11, 14, 4)
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
Mime-Version: 1.0
User-Agent: Application/User Agent
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
From: errors.test@bbmb.ch
To: to.test@bbmb.ch
Cc: 
Subject: Customer 12345678 without email address
        EOS
        body = <<-EOS
Customer 12345678 does not have an email address configured
        EOS
        smtp.should_receive(:sendmail).and_return { |message, from, recipients|
          assert(message.include?(headers),
                 "missing headers:\n#{headers}\nin message:\n#{message}")
          assert(message.include?(body),
                 "missing body:\n#{body}\nin message:\n#{message}")
          assert_equal('errors.test@bbmb.ch', from)
          assert_equal(['to.test@bbmb.ch'], recipients)
        }
        Mail.notify_confirmation_error(order)
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
Mime-Version: 1.0
User-Agent: Application/User Agent
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
From: from.test@bbmb.ch
To: to.test@bbmb.ch
Subject: Application/User Agent: error-message
        EOS
        body = <<-EOS
RuntimeError
error-message
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
        order.should_receive(:to_target_format).and_return('i2-data')
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
Mime-Version: 1.0
User-Agent: Application/User Agent
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
From: from.test@bbmb.ch
To: to.test@bbmb.ch
Cc: cc.test@bbmb.ch
Subject: order order-id
Message-ID: <order-id@from.test.bbmb.ch>
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
      def test_send_request
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
Mime-Version: 1.0
User-Agent: Application/User Agent
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
From: from.request.test@bbmb.ch
To: to.request.test@bbmb.ch
Cc: cc.request.test@bbmb.ch
Subject: Request Organisation
Reply-To: sender@email.com
        EOS
        body = <<-EOS
request body
        EOS
        smtp.should_receive(:sendmail).and_return { |message, from, recipients|
          assert(message.include?(headers), 
                 "missing headers:\n#{headers}\nin message:\n#{message}")
          assert(message.include?(body), 
                 "missing body:\n#{body}\nin message:\n#{message}")
          assert_equal('from.request.test@bbmb.ch', from)
          assert_equal(['to.request.test@bbmb.ch', 'cc.request.test@bbmb.ch'], 
                       recipients)
        }
        Mail.send_request('sender@email.com', 'Organisation', 'request body')
      end
      def test_send_confirmation
        pos1 = flexmock('position')
        pos1.should_receive(:quantity).and_return(2)
        pos1.should_receive(:description).and_return('Product1')
        pos1.should_receive(:price_qty).and_return(10.0)
        pos1.should_receive(:price).and_return(20.0)
        pos2 = flexmock('position')
        pos2.should_receive(:quantity).and_return(3)
        pos2.should_receive(:description).and_return('Product2')
        pos2.should_receive(:price_qty).and_return(5.0)
        pos2.should_receive(:price).and_return(15.0)
        customer = flexmock('customer')
        customer.should_receive(:email).and_return('customer@bbmb.ch')
        order = flexmock('order')
        order.should_receive(:to_target_format).and_return('i2-data')
        order.should_receive(:order_id).and_return('order-id')
        order.should_receive(:filename).and_return('filename')
        order.should_receive(:customer).and_return(customer)
        order.should_receive(:commit_time).and_return(Time.local(2009,8,6,11,55))
        order.should_receive(:collect).and_return do |block|
          [pos1, pos2].collect(&block)
        end
        order.should_receive(:total).and_return 25.0
        order.should_receive(:total_incl_vat).and_return 25.6
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
Mime-Version: 1.0
User-Agent: Application/User Agent
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
From: from-test@bbmb.ch
To: customer@bbmb.ch
Subject: Confirmation order-id
Message-ID: <order-id@from-test.bbmb.ch>
Reply-To: replyto-test@bbmb.ch
        EOS
        body = <<-EOS
Sie haben am 06.08.2009 folgende Artikel bestellt:

  2 x Product1                             à   10.00, total       20.00
  3 x Product2                             à    5.00, total       15.00
------------------------------------------------------------------------
Bestelltotal exkl. Mwst.      25.00
Bestelltotal inkl. Mwst.      25.60
====================================

En date du 06.08.2009 vous avez commandé les articles suivants

  2 x Product1                             à   10.00, total       20.00
  3 x Product2                             à    5.00, total       15.00
------------------------------------------------------------------------
Commande excl. Tva.           25.00
Commande incl. Tva.           25.60
====================================

In data del 06.08.2009 Lei ha ordinato i seguenti prodotti.

  2 x Product1                             a   10.00, totale      20.00
  3 x Product2                             a    5.00, totale      15.00
------------------------------------------------------------------------
Totale dell'ordine escl.      25.00
Totale dell'ordine incl.      25.60
====================================
        EOS
        smtp.should_receive(:sendmail).and_return { |message, from, recipients|
          assert(message.include?(headers),
                 "missing headers:\n#{headers}\nin message:\n#{message}")
          assert(message.include?(body),
                 "missing body:\n#{body}\nin message:\n#{message}")
          assert_equal('from-test@bbmb.ch', from)
          assert_equal(['customer@bbmb.ch'], recipients)
        }
        Mail.send_confirmation(order)
      end
    end
  end
end
