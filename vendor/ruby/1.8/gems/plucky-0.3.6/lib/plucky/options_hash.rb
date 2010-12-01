# encoding: UTF-8
module Plucky
  class OptionsHash
    attr_reader :source

    def initialize(hash={})
      @source = {}
      hash.each { |key, value| self[key] = value }
    end

    def initialize_copy(source)
      super
      @source = @source.dup
      each do |key, value|
        self[key] = value.clone if value.duplicable?
      end
    end

    def []=(key, value)
      key = normalized_key(key)
      source[key] = normalized_value(key, value)
    end

    def ==(other)
      source == other.source
    end

    def to_hash
      source
    end

    def fields?
      !self[:fields].nil?
    end

    def merge(other)
      self.class.new(to_hash.merge(other.to_hash))
    end

    def merge!(other)
      other.to_hash.each { |key, value| self[key] = value }
      self
    end

    private
      def method_missing(method, *args, &block)
        @source.send(method, *args, &block)
      end

      NormalizedKeys = {
        :order  => :sort,
        :select => :fields,
        :offset => :skip,
        :id     => :_id,
      }

      def normalized_key(key)
        NormalizedKeys.default = key
        NormalizedKeys[key.to_sym]
      end

      def normalized_value(key, value)
        case key
          when :fields
            normalized_fields(value)
          when :sort
            normalized_sort(value)
          when :limit, :skip
            value.nil? ? nil : value.to_i
          else
            value
        end
      end

      def normalized_fields(value)
        return nil if value.respond_to?(:empty?) && value.empty?
        case value
          when Array
            if value.size == 1 && value.first.is_a?(Hash)
              value.first
            else
              value.flatten
            end
          when Symbol
            [value]
          when String
            value.split(',').map { |v| v.strip }
          else
            value
        end
      end

      def normalized_sort(value)
        case value
          when Array
            if value.size == 1 && value[0].is_a?(String)
              normalized_sort_piece(value[0])
            else
              value.compact.map { |v| normalized_sort_piece(v).flatten }
            end
          else
            normalized_sort_piece(value)
        end
      end

      def normalized_sort_piece(value)
        case value
          when SymbolOperator
            [normalized_direction(value.field, value.operator)]
          when String
            value.split(',').map do |piece|
              normalized_direction(*piece.split(' '))
            end
          when Symbol
            [normalized_direction(value)]
          else
            value
        end
      end

      def normalized_direction(field, direction=nil)
        direction ||= 'ASC'
        direction = direction.upcase == 'ASC' ? 1 : -1
        [normalized_key(field).to_s, direction]
      end
  end
end