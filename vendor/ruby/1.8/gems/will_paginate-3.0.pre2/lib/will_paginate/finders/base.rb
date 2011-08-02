require 'will_paginate/core_ext'

module WillPaginate
  module Finders
    # = Database-agnostic finder module
    # 
    # Out of the box, will_paginate supports hooking in several ORMs to
    # provide paginating finders based on their API. As of this writing, the
    # supported libraries are:
    #
    # * ActiveRecord
    # * DataMapper
    # * Sequel
    #
    # It's easy to write your own adapter for anything that can load data with
    # explicit limit and offset settings. DataMapper adapter is a nice and
    # compact example of writing an adapter to bring the +paginate+ method to
    # DataMapper models.
    #
    # == The importance of SQL's <tt>ORDER BY</tt>
    #
    # In most ORMs, <tt>:order</tt> parameter specifies columns for the
    # <tt>ORDER BY</tt> clause in SQL. It is important to have it, since
    # pagination only makes sense with ordered sets. Without the order clause,
    # databases aren't required to do consistent ordering when performing
    # <tt>SELECT</tt> queries.
    # 
    # Ordering by a field for which many records share the same value (e.g.
    # "status") can still result in incorrect ordering with some databases (MS
    # SQL and Postgres for instance). With these databases it's recommend that
    # you order by primary key as well. That is, instead of ordering by
    # "status DESC", use the alternative "status DESC, id DESC" and this will
    # yield consistent results.
    #
    # Therefore, make sure you are doing ordering on a column that makes the
    # most sense in the current context. Make that obvious to the user, also.
    # For perfomance reasons you will also want to add an index to that column.
    module Base
      def per_page
        @per_page ||= 30
      end
      
      def per_page=(limit)
        @per_page = limit.to_i
      end
      
      # This is the main paginating finder.
      #
      # == Special parameters for paginating finders
      # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
      # * <tt>:per_page</tt> -- defaults to <tt>CurrentModel.per_page</tt> (which is 30 if not overridden)
      # * <tt>:total_entries</tt> -- use only if you manually count total entries
      # * <tt>:count</tt> -- additional options that are passed on to +count+
      # * <tt>:finder</tt> -- name of the finder method to use (default: "find")
      #
      # All other options (+conditions+, +order+, ...) are forwarded to +find+
      # and +count+ calls.
      def paginate(*args, &block)
        options = args.pop
        page, per_page, total_entries = wp_parse_options(options)

        WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
          query_options = options.except :page, :per_page, :total_entries
          wp_query(query_options, pager, args, &block)
        end
      end

      # Iterates through all records by loading one page at a time. This is useful
      # for migrations or any other use case where you don't want to load all the
      # records in memory at once.
      #
      # It uses +paginate+ internally; therefore it accepts all of its options.
      # You can specify a starting page with <tt>:page</tt> (default is 1). Default
      # <tt>:order</tt> is <tt>"id"</tt>, override if necessary.
      #
      # {Jamis Buck describes this}[http://weblog.jamisbuck.org/2007/4/6/faking-cursors-in-activerecord]
      # and also uses a more efficient way for MySQL.
      def paginated_each(options = {}, &block)
        options = { :order => 'id', :page => 1 }.merge options
        options[:page] = options[:page].to_i
        options[:total_entries] = 0 # skip the individual count queries
        total = 0
        
        begin 
          collection = paginate(options)
          total += collection.each(&block).size
          options[:page] += 1
        end until collection.size < collection.per_page
        
        total
      end
      
      protected
        
        def wp_parse_options(options) #:nodoc:
          raise ArgumentError, 'parameter hash expected' unless Hash === options
          raise ArgumentError, ':page parameter required' unless options.key? :page
          
          if options[:count] and options[:total_entries]
            raise ArgumentError, ':count and :total_entries are mutually exclusive'
          end

          page     = options[:page] || 1
          per_page = options[:per_page] || self.per_page
          total    = options[:total_entries]
          
          return [page, per_page, total]
        end
        
    end
  end
end
