#!/usr/bin/env ruby
# PasswordGenerator -- bbmb -- 11.10.2002 -- hwyss@ywesee.com 

module BBMB
  module Util
    class PasswordGenerator
      SEQUENCE = [ :char, :char, :sym, :num ]
      SIZE = {
        :char  =>  2,
        :num  =>  4,
        :sym  =>  1,
      }
      POOL = {
        :char  =>  ("A".."Z").to_a + ("a".."z").to_a,
        :num  =>  ("0".."9").to_a,
        :sym  =>  %w{! @ * ?},
      }
      class << self
        def generate(user)
          pool = POOL.dup
          char = [user.organisation, user.firstname, user.lastname].join
          if(char.length >= 12)
            pool[:char] = char.scan(/\w/)
          end
          pass = ""
          random_sequence.each { |type| 
            SIZE[type].times {
              pass << pool[type].at(rand(pool[type].size))
            }
          }
          pass
        end
        def random_sequence
          sequence = SEQUENCE.dup
          random = []
          while(sequence.length > 0)
            random.push(sequence.delete_at(rand(sequence.size)))
          end
          random
        end
      end
    end
  end
end
