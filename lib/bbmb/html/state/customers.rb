# Html::State::Customers -- bbmb.ch -- 18.09.2006 -- hwyss@ywesee.com

require 'bbmb/html/state/global_predefine'
require 'bbmb/html/state/customer'
require 'bbmb/html/view/customers'
require 'bbmb/model/customer'
require 'ostruct'

module BBMB
  module Html
    module State
class Customers < Global
  DIRECT_EVENT = :customers
  VIEW = View::Customers
  FILTER = [ :customer_id, :organisation, :plz, :city, :email ]
  def init
    start = Time.now
    @model = BBMB.persistence.all(Model::Customer)
    @sortby = [:organisation]
    BBMB.logger.debug('State') {
      sprintf("Customers#init: loaded %i customers in %1.5fs",
              @model.size, Time.now - start)
    }
    @filter = Proc.new { |model|
      input = @session.event_bound_user_input(:filter)
      if input
        pattern = Regexp.new(input.gsub('*', '.*'), 'ui')
        model = model.select { |customer|
          FILTER.any? { |key|
            value = customer.send(key).to_s
            next if value.empty?
            begin
              pattern.match(value)
            rescue ArgumentError
              false
            end
          }
        }
      end
      get_sortby!
      model.sort! { |a, b| compare_entries(a, b) }
      @sort_reverse && model.reverse! 
      page(model)
    }
  end
  def page(model)
    page = OpenStruct.new
    index = @session.user_input(:index).to_i
    step = @session.user.pagestep || BBMB.config.pagestep
    page.index = index
    page.first = index + 1
    page.step = step
    page.total = model.size
    page.customers = model[index, step]
    page.last = index + page.customers.size
    page
  end
end
    end
  end
end
