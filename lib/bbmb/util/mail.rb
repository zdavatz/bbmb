#!/usr/bin/env ruby
# Util::Mail -- bbmb.ch -- 19.11.2012 -- yasaka@ywesee.com
# Util::Mail -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
require 'net/smtp'
require 'rmail'
require 'pp'
require 'bbmb/util/smtp_tls'

module BBMB
  module Util
module Mail
  def Mail.notify_confirmation_error(order)
    config = BBMB.config
    if to = config.confirm_error_to
      header, message = setup
      customer = order.customer
      from = header.from = config.confirm_error_from
      header.to = to
      cc = header.cc = config.confirm_error_cc
      header.subject = config.confirm_error_subject % customer.customer_id
      message.body = config.confirm_error_body % customer.customer_id
      Mail.sendmail message, from, to, cc
    end
  end
  def Mail.notify_debug(subject, body)
    header, message = setup
    config = BBMB.config
    from = header.from = config.mail_order_from
    to = header.to = config.error_recipients
    header.subject = sprintf "%s: %s", BBMB.config.name, subject
    message.body = body
    Mail.sendmail(message, from, to)
  end
  def Mail.notify_error(error)
    header, message = setup
    config = BBMB.config
    from = header.from = config.mail_order_from
    to = header.to = config.error_recipients
    header.subject = sprintf "%s: %s", BBMB.config.name, error.message
    message.body = [ error.class, error.message, 
      error.backtrace.pretty_inspect ].join("\n")
    Mail.sendmail(message, from, to)
  end
  def Mail.notify_inject_error(order, opts={})
    config = BBMB.config
    if to = config.inject_error_to
      customer = order.customer
      header, message = setup
      from = header.from = config.inject_error_from
      header.to = to
      cc = header.cc = config.inject_error_cc
      header.subject = config.inject_error_subject % [
        order.order_id,
        opts[:customer_name] || customer.customer_id,
      ]
      message.body = config.inject_error_body % [
        opts[:customer_name] || customer.customer_id,
        order.commit_time.strftime('%d.%m.%Y %H:%M:%S'),
        customer.customer_id,
      ]
      Mail.sendmail message, from, to, cc
    end
  end
  def Mail.sendmail(message, from, to, cc=[])
    config = BBMB.config
    Net::SMTP.start(config.smtp_server, config.smtp_port, config.smtp_helo,
                    config.smtp_user, config.smtp_pass, 
                    config.smtp_authtype) { |smtp|
      smtp.sendmail(message.to_s, from, [to, cc].flatten.compact)
    }
  end
  def Mail.send_confirmation(order)
    config = BBMB.config
    ## there are two switches that determine whether a confirmation is sent out:
    #  application-wide: mail_confirm_reply_to must be configured
    reply_to = config.mail_confirm_reply_to or return nil
    #  per-customer: order_confirmation must be checked
    order.customer.order_confirmation or return nil
    to = order.customer.email or return notify_confirmation_error(order)
    body = config.mail_confirm_body or return nil
    date = order.commit_time.strftime("%d.%m.%Y")
    parts = []
    config.mail_confirm_lines.collect do |line|
      content = order.collect do |pos|
        sprintf line, pos.quantity, pos.description, pos.price_qty, pos.total
      end
      parts.push date, content.join("\n"), order.total
      if vtotal = order.total_incl_vat
        parts.push vtotal
      end
    end

    header, message = setup
    from = header.from = config.mail_confirm_from
    header.to = to
    header.subject = config.mail_confirm_subject % order.order_id
    header.add('Message-ID', sprintf('<%s@%s>', order.order_id,
                                     from.tr('@', '.')))
    header.add('Reply-To', reply_to)
    message.body = sprintf body, *parts

    Mail.sendmail(message, from, to, config.mail_confirm_cc)
  end
  def Mail.send_order(order)
    header, message = setup
    config = BBMB.config
    from = header.from = config.mail_order_from
    to = header.to = config.mail_order_to
    cc = header.cc = config.mail_order_cc
    header.subject = config.mail_order_subject % order.order_id
    header.add('Message-ID', sprintf('<%s@%s>', order.order_id, 
                                     from.tr('@', '.')))
    message.body = order.to_target_format

    Mail.sendmail(message, from, to, cc)
  end
  def Mail.send_request(email, organisation, body)
    header, message = setup
    config = BBMB.config
    from = header.from = config.mail_request_from
    to = header.to = config.mail_request_to
    cc = header.cc = config.mail_request_cc
    header.subject = config.mail_request_subject % organisation
    header.add('Reply-To', email)
    message.body = body
    Mail.sendmail(message, from, to, cc)
  end
  def Mail.setup
    message = RMail::Message.new
    header = message.header
    header.add('Date', Time.now.rfc822)
    header.add('Mime-Version', '1.0')
    header.add('User-Agent', BBMB.config.name)
    header.add('Content-Type', 'text/plain', nil, 'charset' => 'utf-8')
    header.add('Content-Disposition', 'inline')
    [header, message]
  end
end
  end
end
