#!/usr/bin/env ruby
# Util::TestMoney -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'bbmb/util/numbers'

module BBMB
  module Util
    class TestMoney < Test::Unit::TestCase
      def test_initialize_integer
        m = Money.new(15)
        assert_equal(1500, m.credits)
        assert_equal(15.0, m.to_f)
        assert_equal("15.00", m.to_s)
      end
      def test_initialize_float
        m = Money.new(15.55)
        assert_equal(1555, m.credits)
        assert_equal(15.55, m.to_f)
        assert_equal("15.55", m.to_s)
      end
      def test_initialize_money
        n = Money.new(15.55)
        m = Money.new(n)
        assert_equal(1555, m.credits)
        assert_equal(15.55, m.to_f)
        assert_equal("15.55", m.to_s)
      end
      def test_equality
        m = Money.new(15.55)
        n = Money.new(15.55)
        o = Money.new(15.56)
        assert_equal(m, m)
        assert_equal(m, n)
        assert_not_equal(m, o)
        assert_equal(m, 15.55)
        assert_not_equal(m, 15.56)
        assert_equal(m, "15.55")
        assert_not_equal(m, "15.56")
      end
      def test_add
        m = Money.new(15.55)
        n = Money.new(12.45)
        o = m + n
        assert_instance_of(Money, o)
        assert_equal(28, o)
      end
      def test_subtract
        m = Money.new(15.55)
        n = Money.new(12.45)
        o = m - n
        assert_instance_of(Money, o)
        assert_equal(3.1, o)
      end
      def test_multiply
        m = Money.new(15.55)
        n = m * 4
        assert_instance_of(Money, n)
        assert_equal(62.20, n)
      end
      def test_divide
        m = Money.new(16.80)
        n = m / 4
        assert_instance_of(Money, n)
        assert_equal(4.20, n)
      end
    end
  end
end
