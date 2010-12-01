require 'will_paginate/finders/base'
require 'active_record'

module WillPaginate::Finders
  # = Paginating finders for ActiveRecord models
  # 
  # WillPaginate adds +paginate+, +per_page+ and other methods to
  # ActiveRecord::Base class methods and associations. It also hooks into
  # +method_missing+ to intercept pagination calls to dynamic finders such as
  # +paginate_by_user_id+ and translate them to ordinary finders
  # (+find_all_by_user_id+ in this case).
  # 
  # In short, paginating finders are equivalent to ActiveRecord finders; the
  # only difference is that we start with "paginate" instead of "find" and
  # that <tt>:page</tt> is required parameter:
  #
  #   @posts = Post.paginate :all, :page => params[:page], :order => 'created_at DESC'
  # 
  # In paginating finders, "all" is implicit. There is no sense in paginating
  # a single record, right? So, you can drop the <tt>:all</tt> argument:
  # 
  #   Post.paginate(...)              =>  Post.find :all
  #   Post.paginate_all_by_something  =>  Post.find_all_by_something
  #   Post.paginate_by_something      =>  Post.find_all_by_something
  #
  module ActiveRecord
    include WillPaginate::Finders::Base
    
    # In Rails, this is automatically called to mix-in pagination functionality to ActiveRecord.
    def self.enable!
      ::ActiveRecord::Base.class_eval do
        extend ActiveRecord
      end

      # support pagination on associations and scopes
      [::ActiveRecord::Relation, ::ActiveRecord::Associations::AssociationCollection].each do |klass|
        klass.send(:include, ActiveRecord)
      end
    end
    
    # Wraps +find_by_sql+ by simply adding LIMIT and OFFSET to your SQL string
    # based on the params otherwise used by paginating finds: +page+ and
    # +per_page+.
    #
    # Example:
    # 
    #   @developers = Developer.paginate_by_sql ['select * from developers where salary > ?', 80000],
    #                          :page => params[:page], :per_page => 3
    #
    # A query for counting rows will automatically be generated if you don't
    # supply <tt>:total_entries</tt>. If you experience problems with this
    # generated SQL, you might want to perform the count manually in your
    # application.
    # 
    def paginate_by_sql(sql, options)
      WillPaginate::Collection.create(*wp_parse_options(options)) do |pager|
        query = sanitize_sql(sql.dup)
        original_query = query.dup
        # add limit, offset
        query << " LIMIT #{pager.per_page} OFFSET #{pager.offset}"
        # perfom the find
        pager.replace find_by_sql(query)
        
        unless pager.total_entries
          count_query = original_query.sub /\bORDER\s+BY\s+[\w`,\s]+$/mi, ''
          count_query = "SELECT COUNT(*) FROM (#{count_query})"
          
          unless ['oracle', 'oci'].include?(self.connection.adapter_name.downcase)
            count_query << ' AS count_table'
          end
          # perform the count query
          pager.total_entries = count_by_sql(count_query)
        end
      end
    end

  protected

    def wp_query(options, pager, args, &block) #:nodoc:
      finder = (options.delete(:finder) || 'find').to_s
      find_options = options.except(:count).update(:offset => pager.offset, :limit => pager.per_page) 

      if finder == 'find'
        if Array === args.first and !pager.total_entries
          pager.total_entries = args.first.size
        end
        args << :all if args.empty?
      end
      
      args << find_options
      pager.replace send(finder, *args, &block)
      
      unless pager.total_entries
        # magic counting
        pager.total_entries = wp_count(options, args, finder) 
      end
    end

    # Does the not-so-trivial job of finding out the total number of entries
    # in the database. It relies on the ActiveRecord +count+ method.
    def wp_count(options, args, finder) #:nodoc:
      # find out if we are in a model or an association proxy
      klass = (@owner and @reflection) ? @reflection.klass : self
      count_options = wp_parse_count_options(options, klass)

      # we may have to scope ...
      counter = Proc.new { count(count_options) }

      count = if finder.index('find_') == 0 and klass.respond_to?(scoper = finder.sub('find', 'with'))
                # scope_out adds a 'with_finder' method which acts like with_scope, if it's present
                # then execute the count with the scoping provided by the with_finder
                send(scoper, &counter)
              elsif finder =~ /^find_(all_by|by)_([_a-zA-Z]\w*)$/
                # extract conditions from calls like "paginate_by_foo_and_bar"
                attribute_names = $2.split('_and_')
                conditions = construct_attributes_from_arguments(attribute_names, args)
                with_scope(:find => { :conditions => conditions }, &counter)
              else
                counter.call
              end

      count.respond_to?(:length) ? count.length : count
    end
    
    def wp_parse_count_options(options, klass) #:nodoc:
      excludees = [:count, :order, :limit, :offset, :readonly]
      
      # Use :select from scope if it isn't already present.
      # FIXME: this triggers extra queries when going through associations
      # if options[:select].blank? && current_scoped_methods && current_scoped_methods.select_values.present?
      #   options[:select] = current_scoped_methods.select_values.join(", ")
      # end
      
      if options[:select] and options[:select] =~ /^\s*DISTINCT\b/i
        # Remove quoting and check for table_name.*-like statement.
        if options[:select].gsub('`', '') =~ /\w+\.\*/
          options[:select] = "DISTINCT #{klass.table_name}.#{klass.primary_key}"
        end
      else
        excludees << :select
      end
      
      # count expects (almost) the same options as find
      count_options = options.except *excludees

      # merge the hash found in :count
      # this allows you to specify :select, :order, or anything else just for the count query
      count_options.update options[:count] if options[:count]
      
      # forget about includes if they are irrelevant when counting
      if count_options[:include] and count_options[:conditions].blank? and count_options[:group].blank?
        count_options.delete :include
      end
      
      count_options
    end
  end
end
