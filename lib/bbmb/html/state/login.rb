#!/usr/bin/env ruby
# Html::State::Login -- bbmb.ch -- 15.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/viral/admin'
require 'bbmb/html/state/viral/customer'
require 'bbmb/html/view/login'
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
