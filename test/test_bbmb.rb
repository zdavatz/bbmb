require 'test_helper'

module BBMB
  class TestBbmb < Minitest::Test
    def test_global_readers
      assert_respond_to(BBMB, :config)
      assert_respond_to(BBMB, :persistence)
      assert_respond_to(BBMB, :logger)
      assert_respond_to(BBMB, :server)
    end
  end
end
