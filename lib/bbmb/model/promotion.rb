#!/usr/bin/env ruby
# Model::Promotion -- bbmb -- 10.04.2007 -- hwyss@ywesee.com

require 'bbmb/model/subject'
require 'date'

module BBMB
  module Model
    class Promotion < Subject
      attr_accessor :end_date, :start_date
      multilingual :lines
      def current?
        (@start_date..@end_date).include? Date.today
      end
    end
  end
end
