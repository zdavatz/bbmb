#!/usr/bin/env ruby
# Util::Mail -- bbmb.ch -- 19.11.2012 -- yasaka@ywesee.com
# Util::Mail -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com

require 'mail'
require 'bbmb/config'
require 'pp'

module BBMB
  module Util
module Mail
  def Mail.notify_confirmation_error(order)
    config = BBMB.config
    if to = config.confirm_error_to
      customer = order.customer
      from = config.confirm_error_from
      cc = config.confirm_error_cc
      subject = config.confirm_error_subject % customer.customer_id
      body = config.confirm_error_body % customer.customer_id
      Mail.sendmail body, subject, from, to, cc
    end
  end
  def Mail.notify_debug(subject, body)
    config = BBMB.config
    from = config.mail_order_from
    to = config.error_recipients
    subject = sprintf "%s: %s", BBMB.config.name, subject
    Mail.sendmail(body, subject, from, to)
  end
  def Mail.notify_error(error)
    config = BBMB.config
    from = config.mail_order_from
    to = config.error_recipients
    subject = sprintf "%s: %s", BBMB.config.name, error.message
    body = [ error.class, error.message,
    error.backtrace ].flatten.join("\n")
    Mail.sendmail(body, subject, from, to)
  end
  def Mail.notify_inject_error(order, opts={})
    config = BBMB.config
    if to = config.inject_error_to
      customer = order.customer
      from = config.inject_error_from
      cc = config.inject_error_cc
      subject = config.inject_error_subject % [
        order.order_id,
        opts[:customer_name] || customer.customer_id,
      ]
      body = config.inject_error_body % [
        opts[:customer_name] || customer.customer_id,
        order.commit_time.strftime('%d.%m.%Y %H:%M:%S'),
        customer.customer_id,
      ]
      Mail.sendmail body, subject, from, to, cc
    end
  end
  def Mail.sendmail(my_body, my_subject, from_addr, to_addr, cc_addrs=[], my_reply_to = nil)
    config = BBMB.config
    config.mail_suppress_sending = true if  defined?(::MiniTest)
    if config.mail_suppress_sending
      msg = [ "#{__FILE__}:#{__LINE__} Suppress sending mail with subject: #{my_subject}",
              "    from #{from_addr} to: #{to_addr} cc: #{cc_addrs} reply_to: #{my_reply_to}",
              my_body.to_s[0..10240]
            ]
      puts msg unless defined?(::MiniTest)
      ::Mail.defaults do  delivery_method :test end
    else
      puts "Mail.sendmail #{config.smtp_server} #{config.smtp_port} #{config.smtp_helo} smtp_user: #{ config.smtp_user}  #{ config.smtp_pass}  #{ config.smtp_authtype}"
      puts "Mail.sendmail from #{from_addr} to #{to_addr} cc #{cc_addrs} message: #{my_body.class}"
      return if to_addr == nil
      ::Mail.defaults do
      options = { :address              => config.smtp_server,
                  :port                 => config.smtp_port,
                  :domain               => config.smtp_domain,
                  :user_name            => config.smtp_user,
                  :password             => config.smtp_pass,
                  :authentication       => 'plain',
                  :enable_starttls_auto => true  }
        delivery_method :smtp, options
      end
    end
    ::Mail.deliver do
      from from_addr
      to to_addr
      cc cc_addrs
      reply_to (my_reply_to ? my_reply_to : from_addr)
      subject my_subject
      body my_body
    end
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
        sprintf(line, pos.quantity.to_i,
                pos.description, pos.price_qty.to_f, pos.total.to_f)
      end
      parts.push date, content.join("\n"), order.total
      if vtotal = order.total_incl_vat
        parts.push vtotal
      end
    end

    from = config.mail_confirm_from
    subject = config.mail_confirm_subject % order.order_id
    body = sprintf *parts

    Mail.sendmail(body, subject, from, to, config.mail_confirm_cc, reply_to)
  end
  def Mail.send_order(order)
    config = BBMB.config
    from = config.mail_order_from
    to = config.mail_order_to
    cc = config.mail_order_cc
    subject = config.mail_order_subject % order.order_id
    body = order.to_target_format
    Mail.sendmail(body, subject, from, to, cc)
  end
  def Mail.send_request(email, organisation, body)
    config = BBMB.config
    from = config.mail_request_from
    to = config.mail_request_to
    cc = config.mail_request_cc
    subject = config.mail_request_subject % organisation
    Mail.sendmail("", subject, from, to, cc, email)
  end
end
  end
end
