$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'fileutils'
require 'minitest/autorun'
require 'flexmock/test_unit'
require 'htmlgrid/list'
require 'bbmb/config'
require 'bbmb/model/customer'
require 'bbmb/html/state/viral/admin'
require 'bbmb/html/state/customers'

module BBMB
  module Html
    module State
      class TestCustomers < Minitest::Test
        include FlexMock::TestCase

        def setup
          super
          BBMB.config = flexmock('config')
          BBMB.logger = flexmock('logger')
          BBMB.logger.should_receive(:debug)
          BBMB.persistence = flexmock('persistence', :all => [])
          app      = flexmock('app')
          user     = flexmock('user', :pagestep => 1)
          @session = flexmock('session', :app => app, :user => user)
          @model   = flexmock('model')
        end

        def test_filter_finds_customer_by_ean13
          search_input = '7999999999999'
          valid_customer = flexmock(
            :customer_id  => '1',
            :organisation => '',
            :plz          => '',
            :city         => '',
            :email        => '',
            :ean13        => '7999999999999'
          )
          unknown_customer = flexmock(
            :customer_id  => '99',
            :organisation => '',
            :plz          => '',
            :city         => '',
            :email        => '',
            :ean13        => ''
          )
          flexmock(Customers).new_instances
            .should_receive(:page).with([valid_customer]).once
          @session.should_receive(:event_bound_user_input)
            .and_return(search_input)
          @session.should_receive(:user_input).and_return(search_input)
          state = Customers.new(@session, @model)
          state.init
          filter = state.instance_variable_get(:@filter)
          filter.call([valid_customer, unknown_customer])
        end

        def test_filter_finds_customer_by_customer_name
          search_input = 'Company'
          valid_customer = flexmock(
            :customer_id  => '1',
            :organisation => 'Test Company',
            :plz          => '',
            :city         => '',
            :email        => '',
            :ean13        => ''
          )
          unknown_customer = flexmock(
            :customer_id  => '99',
            :organisation => '',
            :plz          => '',
            :city         => '',
            :email        => '',
            :ean13        => ''
          )
          flexmock(Customers).new_instances
            .should_receive(:page).with([valid_customer]).once
          @session.should_receive(:event_bound_user_input)
            .and_return(search_input)
          @session.should_receive(:user_input).and_return(search_input)
          state = Customers.new(@session, @model)
          state.init
          filter = state.instance_variable_get(:@filter)
          filter.call([valid_customer, unknown_customer])
        end
      end
    end
  end
end
