#!/usr/bin/env ruby
# Html::State::Login -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/info'
require 'bbmb/html/state/viral/admin'
require 'bbmb/html/state/viral/customer'
require 'bbmb/html/view/login'
require 'bbmb/util/mail'
require 'sbsm/state'
require 'yus/session'

module BBMB
  module Html
    module State
class Login < SBSM::State
  VIEW = View::Login
  def login
    reconsider_permissions(@session.login)
    trigger(:home)
  rescue Yus::UnknownEntityError
    @errors.store(:email, create_error(:e_authentication_error, :email, nil))
    self
  rescue Yus::AuthenticationError
    @errors.store(:pass, create_error(:e_authentication_error, :pass, nil))
    self
  end
  def home
    self
  end
  def request_access
    lnf = @session.lookandfeel
    if(lnf.enabled?(:request_access, false))
      keys = [ :firstname, :lastname, :organisation, :address1, :plz, :city,
        :phone_business, :email, :customer_id, ]
      input = user_input(keys, keys)
      if(error?)
        @errors.clear
        @errors.store(:all, create_error(:e_need_all_fields, :all, nil))
        self
      else
        body = <<-EOS
Vorname:        #{input[:firstname]}
Name:           #{input[:lastname]}
Tierarztpraxis: #{input[:organisation]}
Strasse / Nr.:  #{input[:address1]}
PLZ:            #{input[:plz]}
Ort:            #{input[:city]}
Tel. Praxis:    #{input[:phone_business]}
E-Mail Adresse: #{input[:email]}
TVS/Virbac-Nr:  #{input[:customer_id]}
        EOS
        BBMB::Util::Mail.send_request(input[:email], input[:organisation], body)
        Info.new(@session, :message => :request_sent, :event => :logout)
      end
    end
  end
  private
  def reconsider_permissions(user)
    viral_modules(user) { |mod|
      self.extend(mod)
    }
  end
  def viral_modules(user)
    [
      ['.Admin', State::Viral::Admin],
      ['.Customer', State::Viral::Customer],
    ].each { |key, mod|
      if(user.allowed?("login", BBMB.config.auth_domain + key))
        yield mod
      end
    }
  end
end
    end
  end
end
