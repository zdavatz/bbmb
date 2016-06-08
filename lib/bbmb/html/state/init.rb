#!/usr/bin/env ruby
# encoding: utf-8

require 'bbmb/html/state/customers'
require 'bbmb/html/view/login'

module BBMB
  module Html
    module State
      class Init < SBSM::State
        VIEW = Html::View::LoginForm
        def login
          if(res = @session.login)
            Customers.new(@session, nil)
          end
        end
      end
    end
  end
end
