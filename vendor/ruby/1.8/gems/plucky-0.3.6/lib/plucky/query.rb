# encoding: UTF-8
require 'forwardable'
module Plucky
  class Query
    include Enumerable
    extend  Forwardable

    OptionKeys = [
      :select, :offset, :order,                                              # MM
      :fields, :skip, :limit, :sort, :hint, :snapshot, :batch_size, :timeout # Ruby Driver
    ]

    attr_reader    :criteria, :options, :collection
    def_delegator  :criteria, :simple?
    def_delegator  :options,  :fields?
    def_delegators :to_a, :each, :include?

    def initialize(collection, opts={})
      @collection, @options, @criteria = collection, OptionsHash.new, CriteriaHash.new
      opts.each { |key, value| self[key] = value }
    end

    def initialize_copy(source)
      super
      @criteria = @criteria.dup
      @options  = @options.dup
    end

    def object_ids(*keys)
      return criteria.object_ids if keys.empty?
      criteria.object_ids = *keys
      self
    end

    def per_page(limit=nil)
      return @per_page || 25 if limit.nil?
      @per_page = limit
      self
    end

    def paginate(opts={})
      page          = opts.delete(:page)
      limit         = opts.delete(:per_page) || per_page
      query         = clone.update(opts)
      total         = query.count
      paginator     = Pagination::Paginator.new(total, page, limit)
      query[:limit] = paginator.limit
      query[:skip]  = paginator.skip
      query.all.tap do |docs|
        docs.extend(Pagination::Decorator)
        docs.paginator(paginator)
      end
    end

    def find_each(opts={})
      query = clone.update(opts)
      query.collection.find(query.criteria.to_hash, query.options.to_hash)
    end

    def find_one(opts={})
      query = clone.update(opts)
      query.collection.find_one(query.criteria.to_hash, query.options.to_hash)
    end

    def find(*ids)
      return nil if ids.empty?
      if ids.size == 1 && !ids[0].is_a?(Array)
        first(:_id => ids[0])
      else
        all(:_id => ids.flatten)
      end
    end

    def all(opts={})
      find_each(opts).to_a
    end

    def first(opts={})
      find_one(opts)
    end

    def last(opts={})
      clone.update(opts).reverse.find_one
    end

    def remove(opts={})
      query = clone.update(opts)
      query.collection.remove(query.criteria.to_hash)
    end

    def count(opts={})
      find_each(opts).count
    end

    def size
      count
    end

    def update(opts={})
      opts.each { |key, value| self[key] = value }
      self
    end

    def fields(*args)
      clone.tap { |query| query.options[:fields] = *args }
    end
    
    def ignore(*args)
      set_fields(args,0)
    end
    
    def only(*args)
      set_fields(args,1)
    end    

    def limit(count=nil)
      clone.tap { |query| query.options[:limit] = count }
    end

    def reverse
      clone.tap do |query|
        query[:sort].map! do |s|
          [s[0], -s[1]]
        end unless query.options[:sort].nil?
      end
    end

    def skip(count=nil)
      clone.tap { |query| query.options[:skip] = count }
    end
    alias offset skip

    def sort(*args)
      clone.tap { |query| query.options[:sort] = *args }
    end
    alias order sort

    def where(hash={})
      clone.tap do |query|
        query.criteria.merge!(CriteriaHash.new(hash))
      end
    end

    def empty?
      count.zero?
    end

    def exists?(options={})
      !count(options).zero?
    end
    alias :exist? :exists?

    def to_a
      all
    end

    def [](key)
      key = key.to_sym if key.respond_to?(:to_sym)
      if OptionKeys.include?(key)
        @options[key]
      else
        @criteria[key]
      end
    end

    def []=(key, value)
      key = key.to_sym if key.respond_to?(:to_sym)
      if OptionKeys.include?(key)
        @options[key] = value
      else
        @criteria[key] = value
      end
    end

    def merge(other)
      merged_criteria = criteria.merge(other.criteria).to_hash
      merged_options  = options.merge(other.options).to_hash
      clone.update(merged_criteria).update(merged_options)
    end

    def to_hash
      criteria.to_hash.merge(options.to_hash)
    end

    def explain
      collection.find(criteria.to_hash, options.to_hash).explain
    end

    def inspect
      as_nice_string = to_hash.collect do |key, value|
        " #{key}: #{value.inspect}"
      end.sort.join(",")
      "#<#{self.class}#{as_nice_string}>"
    end
    
    private
    
    def set_fields(field_list, value)
      the_fields = {}
      field_list.each {|field| the_fields[field.to_sym] = value}
      clone.tap { |query| query.options[:fields] =  the_fields}
    end
    
  end
end