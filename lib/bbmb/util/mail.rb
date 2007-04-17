#!/usr/bin/env ruby
# Util::Mail -- bbmb.ch -- 27.09.2006 -- hwyss@ywesee.com

require 'bbmb/config'
require 'net/smtp'
require 'rmail'
require 'pp'

module BBMB
  module Util
module Mail
  def Mail.notify_error(error)
    config = BBMB.config
    message = RMail::Message.new
    header = message.header
    from = header.from = config.mail_order_from
    to = header.to = config.error_recipients
    header.subject = sprintf "%s: %s", BBMB.config.name, error.message
    header.add('User-Agent', BBMB.config.name)
    message.body = [ error.class, error.message, error.backtrace ].pretty_inspect
    Mail.sendmail(message, from, to)
  end
  def Mail.sendmail(message, from, to, cc=[])
    config = BBMB.config
    Net::SMTP.start(config.smtp_server, config.smtp_port, config.smtp_helo,
                    config.smtp_user, config.smtp_pass, 
                    config.smtp_authtype) { |smtp|
      smtp.sendmail(message.to_s, from, [to, cc].flatten.compact)
    }
  end
  def Mail.send_order(order)
    message = RMail::Message.new
    config = BBMB.config
    header = message.header
    header.add('Date', Time.now.rfc822)
    from = header.from = config.mail_order_from
    to = header.to = config.mail_order_to
    cc = header.cc = config.mail_order_cc
    header.subject = config.mail_order_subject % order.order_id
    header.add('Message-ID', sprintf('<%s@%s>', order.order_id, 
                                     from.tr('@', '.')))
    header.add('Mime-Version', '1.0')
    header.add('User-Agent', BBMB.config.name)
    header.add('Content-Type', 'text/plain', nil, 'charset' => 'utf-8')
    header.add('Content-Disposition', 'inline')
    message.body = order.to_i2

    Mail.sendmail(message, from, to, cc)
  end
end
  end
end
