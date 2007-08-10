#!/usr/bin/env ruby
# Util::Multilingual -- de.oddb.org -- 04.09.2006 -- hwyss@ywesee.com

module BBMB
  module Util
    class Multilingual
      include Comparable
      attr_reader :canonical
      attr_reader :synonyms
      def initialize(canonical={})
        @canonical = canonical
        @synonyms = []
      end
      def all
        @canonical.values.concat(@synonyms)
      end
      def default
        @canonical.values.sort.first
      end
      def empty?
        @canonical.empty?
      end
      def method_missing(meth, *args, &block)
        case meth.to_s
        when /^[a-z]{2}$/
          @canonical[meth]
        when /^([a-z]{2})=$/
          key = $~[1].to_sym
          if(value = args.first)
            @canonical.store(key, value)
          else
            @canonical.delete(key)
          end
        else
          super(meth, *args, &block)
        end
      end
      def to_s
        default.to_s
      end
      def ==(other)
        case other
        when String
          @canonical.values.any? { |val| val == other } \
            || @synonyms.any? { |val| val == other }
        when Multilingual
          @canonical == other.canonical && @synonyms == other.synonyms
        else
          false
        end
      end
      def <=>(other)
        all.sort <=> other.all.sort
      end
    end
  end
end
