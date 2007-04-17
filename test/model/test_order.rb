#!/usr/bin/env ruby
# Model::TestOrder -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'bbmb/model/order'
require 'date'
require 'flexmock'
require 'test/unit'

module BBMB
  module Model
class TestOrder < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @customer = flexmock("customer")
    @order = Order.new(@customer)
  end
  def test_add
    assert_equal(true, @order.empty?)
    product = flexmock('product')
    product.should_receive(:article_number).and_return('12345')
    pos = @order.add(3, product)
    assert_equal(false, @order.empty?)
    assert_equal(1, @order.positions.size)
    position = @order.positions.first
    assert_equal(pos, position)
    assert_instance_of(Order::Position, position)
    assert_equal(product, position.product)
    assert_equal(3, position.quantity)
  end
  def test_add__0
    assert_equal(true, @order.empty?)
    product = flexmock('product')
    product.should_receive(:article_number).and_return('12345')
    pos = @order.add(0, product)
    assert_equal(true, @order.empty?)
  end
  def test_add__0__remove
    assert_equal(true, @order.empty?)
    product = flexmock('product')
    product.should_receive(:article_number).and_return('12345')
    pos = @order.add(3, product)
    assert_equal(false, @order.empty?)
    assert_equal(1, @order.positions.size)
    pos = @order.add(0, product)
    assert_equal([], @order.positions)
  end
  def test_additional_info
    assert_equal({}, @order.additional_info)
    @order.comment = 'Comment'
    assert_equal({:comment => 'Comment'}, @order.additional_info)
    @order.reference = '12345'
    assert_equal({:comment => 'Comment', :reference => '12345'}, 
                 @order.additional_info)
    @order.comment = nil
    assert_equal({:reference => '12345'}, @order.additional_info)
  end
  def test_clear
    position = flexmock('position')
    @order.positions.push(position)
    @order.clear
    assert_equal([], @order.positions)
  end
  def test_commit
    assert_equal(nil, @order.commit_time)
    assert_raises(RuntimeError) { @order.commit!('commit_id', Time.now) }
    assert_equal(nil, @order.commit_time)
    position = flexmock('position')
    @order.positions.push(position)
    position.should_receive(:commit!).times(1)
    time = Time.now
    @order.commit!('commit_id', time)
    assert_equal(time, @order.commit_time)
    assert_equal('commit_id', @order.commit_id)
  end
  def test_empty
    assert_equal(true, @order.empty?)
    position = flexmock('position')
    @order.positions.push(position)
    assert_equal(false, @order.empty?)
  end
  def test_enumerable
    assert @order.is_a?(Enumerable)
    assert @order.respond_to?(:empty?)
    assert @order.respond_to?(:each)
  end
  def test_position
    product = flexmock('product')
    assert_nil(@order.position(product))
    position = flexmock('position')
    position.should_receive(:product).and_return(product)
    @order.positions.push(position)
    pos = @order.position(product)
    assert_equal(position, pos)
  end
  def test_quantity
    product = flexmock('product')
    assert_equal(0, @order.quantity(product))
    product.should_receive(:article_number).and_return('12345')
    @order.add(17, product)
    assert_equal(17, @order.quantity(product))
  end
  def test_size
    assert_equal(0, @order.size)
    position = flexmock('position')
    @order.positions.push(position)
    assert_equal(1, @order.size)
  end
  def test_total
    pos1 = flexmock('position')
    pos2 = flexmock('position')
    @order.positions.push(pos1, pos2)
    pos1.should_receive(:total).and_return(Util::Money.new(12.80))
    pos2.should_receive(:total).and_return(Util::Money.new(17.20))
    assert_equal(30, @order.total)
    @order.shipping = 10
    assert_equal(40, @order.total)
  end
  def test_to_i2
    @customer.should_receive(:customer_id).and_return(7)
    @customer.should_receive(:organisation).and_return('Organisation')
    position = flexmock('position')
    position.should_receive(:ean13).and_return("EAN13")
    position.should_receive(:article_number).and_return("ArticleNumber")
    position.should_receive(:quantity).and_return(17)
    position.should_ignore_missing
    @order.positions.push(position)
    @order.reference = "Reference"
    @order.comment = "Comment"
    @order.commit!('8', Time.local(2006,9,27,9,50,12))
    @order.priority = 41
    expected = <<-EOS
001:7601001000681
002:ORDERX
003:220
010:7-8-20060927095012.txt
100:YWESEE
101:Reference
201:CU
202:7
201:BY
202:1075
231:Organisation
236:Comment
237:61
238:41
250:ADE
251:700008
300:4
301:20060927
500:1
501:EAN13
502:ArticleNumber
520:17
521:PCE
540:2
541:20060927
    EOS
    assert_equal(expected, @order.to_i2)
  end
end
class TestOrderPosition < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @product = flexmock('product')
    @position = Order::Position.new(3, @product)
  end
  def test_commit
    info = flexmock('info')
    @product.should_receive(:to_info).and_return(info)
    @position.commit!
    assert_equal(info, @position.product)
  end
  def test_total
    @product.should_receive(:price).with(3).and_return(12)
    assert_equal(36, @position.total)
  end
end
  end
end
