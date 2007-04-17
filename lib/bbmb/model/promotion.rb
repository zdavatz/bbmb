#!/usr/bin/env ruby
# Model::Promotion -- bbmb -- 10.04.2007 -- hwyss@ywesee.com

require 'date'

module BBMB
  module Model
    class Promotion
      attr_accessor :end_date, :lines, :start_date
      def initialize
        @lines = []
      end
      def current?
        (@start_date..@end_date).include? Date.today
      end
    end
  end
end
