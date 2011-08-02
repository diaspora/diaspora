# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
# 
# This file contains lazy enumerators.

module I18n
  module Inflector

    if RUBY_VERSION.gsub(/\D/,'')[0..1].to_i < 19
      require 'enumerator' rescue nil

      class LazyEnumerator < Object.const_defined?(:Enumerator) ? Enumerator : Enumerable::Enumerator

        # This class allows to initialize the Enumerator with a block
        class Yielder
          def initialize(&block)
            @main_block = block
          end

          def each(&block)
            @final_block = block
            @main_block.call(self)
          end

          if Proc.method_defined?(:yield)
            def yield(*arg)
              @final_block.yield(*arg)
            end
          else
            def yield(*arg)
              @final_block.call(*arg)
            end
          end

          if method_defined?(:yield) and not method_defined?(:"<<")
            alias_method :"<<", :yield
          end

        end

        unless (self.new{} rescue false)
          def initialize(*args, &block)
            args.empty? ? super(Yielder.new(&block)) : super(*args, &nil) 
          end
        end

        if method_defined?(:with_object) and not method_defined?(:each_with_object)
          alias_method :each_with_object, :with_object
        end

      end # class LazyEnumerator for ruby18

    else # if RUBY_VERSION >= 1.9.0

      class LazyEnumerator < Enumerator
      end

    end

    # This class adds some lazy operations for collections
    class LazyEnumerator

      # Addition operator for collections
      # @return [I18n::Inflector::LazyEnumerator] the enumerator
      def +(other)
        self.class.new do |yielder|
          each do |v|
            yielder << v
          end
          other.each do |v|
            yielder << v
          end
        end
      end

      # Insertion operator for collections
      # @return [I18n::Inflector::LazyEnumerator] the enumerator
      def insert(value)
        self.class.new do |yielder|
          yielder << value
          each do |v|
            yielder << v
          end
        end
      end

      # Appending operator for collections
      # @return [I18n::Inflector::LazyEnumerator] the enumerator
      def append(value)
        self.class.new do |yielder|
          each do |v|
            yielder << v
          end
          yielder << value
        end
      end

      # Mapping enumerator
      # @return [I18n::Inflector::LazyEnumerator] the enumerator
      def map(&block)
        self.class.new do |yielder|
          each do |v|
            yielder << block[v]
          end
        end
      end

      # Selecting enumerator
      # @return [I18n::Inflector::LazyEnumerator] the enumerator
      def select(&block)
        self.class.new do |yielder|
          each do |v|
            yielder << v if block[v]
          end
        end
      end

      # Rejecting enumerator
      # @return [I18n::Inflector::LazyEnumerator] the enumerator
      def reject(&block)
        self.class.new do |yielder|
          each do |v|
            yielder << v unless block[v]
          end
        end
      end

    end

    # This class implements simple enumerators for arrays
    # that allow to do lazy operations on them.
    class LazyArrayEnumerator < LazyEnumerator

    end

    # This class implements simple enumerators for hashes
    # that allow to do lazy operations on them.
    class LazyHashEnumerator < LazyEnumerator

      # Creates a Hash kind of object by collecting all
      # data from enumerated collection.
      # @return [Hash] the resulting hash
      def to_h
        h = Hash.new
        each{|k,v| h[k]=v }
        h
      end

      # Insertion operator for Hash enumerators
      # @return [I18n::Inflector::LazyHashEnumerator] the enumerator
      def insert(key, value)
        self.class.new do |yielder|
          yielder.yield(key, value)
          each do |k,v|
            yielder.yield(k,v)
          end
        end
      end

      # Appending operator for Hash enumerators
      # @return [I18n::Inflector::LazyHashEnumerator] the enumerator
      def append(key, value)
        self.class.new do |yielder|
          each do |k,v|
            yielder.yield(k,v)
          end
          yielder.yield(key, value)
        end
      end

      # Hash mapping enumerator
      # @return [I18n::Inflector::LazyHashEnumerator] the enumerator
      def map(&block)
        LazyHashEnumerator.new do |yielder|
          each do |k,v|
            yielder.yield(k,block[k,v])
          end
        end
      end

      # Hash to Array mapping enumerator
      # @return [I18n::Inflector::LazyHashEnumerator] the enumerator
      def ary_map(&block)
        LazyHashEnumerator.new do |yielder|
          each do |value|
            yielder << block[value]
          end
        end
      end

      # This method converts resulting keys
      # to an array.
      def keys
        ary = []
        each{ |k,v| ary << k }
        return ary
      end

      # This method converts resulting values
      # to an array.
      def values
        ary = []
        each{ |k,v| ary << v }
        return ary
      end

      # Keys enumerator
      # @return [I18n::Inflector::LazyArrayEnumerator.new] the enumerator
      def each_key(&block)
        LazyArrayEnumerator.new do |yielder|
          each do |k,v|
            yielder << k
          end
        end
      end

      # Values enumerator
      # @return [I18n::Inflector::LazyArrayEnumerator.new] the enumerator
      def each_value(&block)
        LazyArrayEnumerator.new do |yielder|
          each do |k,v|
            yielder << v
          end
        end
      end

      # Hash selecting enumerator
      # @return [I18n::Inflector::LazyHashEnumerator] the enumerator
      def select(&block)
        self.class.new do |yielder|
          each do |k,v|
            yielder.yield(k,v) if block[k,v]
          end
        end
      end

      # Hash rejecting enumerator
      # @return [I18n::Inflector::LazyHashEnumerator] the enumerator
      def reject(&block)
        self.class.new do |yielder|
          each do |k,v|
            yielder.yield(k,v) unless block[k,v]
          end
        end
      end

    end # class LazyHashEnumerator

  end
end
