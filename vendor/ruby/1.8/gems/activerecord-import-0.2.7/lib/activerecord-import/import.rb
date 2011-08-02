require "ostruct"

module ActiveRecord::Import::ConnectionAdapters ; end

module ActiveRecord::Import #:nodoc:
  class Result < Struct.new(:failed_instances, :num_inserts)
  end

  module ImportSupport #:nodoc:
    def supports_import? #:nodoc:
      true
    end
  end
  
  module OnDuplicateKeyUpdateSupport #:nodoc:
    def supports_on_duplicate_key_update? #:nodoc:
      true
    end
  end
end

class ActiveRecord::Base
  class << self

    # use tz as set in ActiveRecord::Base
    tproc = lambda do
      ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now
    end
    
    AREXT_RAILS_COLUMNS = {
      :create => { "created_on" => tproc ,
                   "created_at" => tproc },
      :update => { "updated_on" => tproc ,
                   "updated_at" => tproc }
    }
    AREXT_RAILS_COLUMN_NAMES = AREXT_RAILS_COLUMNS[:create].keys + AREXT_RAILS_COLUMNS[:update].keys
  
    # Returns true if the current database connection adapter
    # supports import functionality, otherwise returns false.
    def supports_import?
      connection.supports_import?
    rescue NoMethodError
      false
    end

    # Returns true if the current database connection adapter
    # supports on duplicate key update functionality, otherwise
    # returns false.
    def supports_on_duplicate_key_update?
      connection.supports_on_duplicate_key_update?
    rescue NoMethodError
      false
    end
    
    # Imports a collection of values to the database.  
    #
    # This is more efficient than using ActiveRecord::Base#create or
    # ActiveRecord::Base#save multiple times. This method works well if
    # you want to create more than one record at a time and do not care
    # about having ActiveRecord objects returned for each record
    # inserted. 
    #
    # This can be used with or without validations. It does not utilize
    # the ActiveRecord::Callbacks during creation/modification while
    # performing the import.
    #
    # == Usage
    #  Model.import array_of_models
    #  Model.import column_names, array_of_values
    #  Model.import column_names, array_of_values, options
    # 
    # ==== Model.import array_of_models
    # 
    # With this form you can call _import_ passing in an array of model
    # objects that you want updated.
    #
    # ==== Model.import column_names, array_of_values
    #
    # The first parameter +column_names+ is an array of symbols or
    # strings which specify the columns that you want to update.
    #
    # The second parameter, +array_of_values+, is an array of
    # arrays. Each subarray is a single set of values for a new
    # record. The order of values in each subarray should match up to
    # the order of the +column_names+.
    #
    # ==== Model.import column_names, array_of_values, options
    #
    # The first two parameters are the same as the above form. The third
    # parameter, +options+, is a hash. This is optional. Please see
    # below for what +options+ are available.
    #
    # == Options
    # * +validate+ - true|false, tells import whether or not to use \
    #    ActiveRecord validations. Validations are enforced by default.
    # * +on_duplicate_key_update+ - an Array or Hash, tells import to \
    #    use MySQL's ON DUPLICATE KEY UPDATE ability. See On Duplicate\
    #    Key Update below.
    # * +synchronize+ - an array of ActiveRecord instances for the model
    #   that you are currently importing data into. This synchronizes
    #   existing model instances in memory with updates from the import.
    # * +timestamps+ - true|false, tells import to not add timestamps \
    #   (if false) even if record timestamps is disabled in ActiveRecord::Base
    #
    # == Examples  
    #  class BlogPost < ActiveRecord::Base ; end
    #  
    #  # Example using array of model objects
    #  posts = [ BlogPost.new :author_name=>'Zach Dennis', :title=>'AREXT',
    #            BlogPost.new :author_name=>'Zach Dennis', :title=>'AREXT2',
    #            BlogPost.new :author_name=>'Zach Dennis', :title=>'AREXT3' ]
    #  BlogPost.import posts
    #
    #  # Example using column_names and array_of_values
    #  columns = [ :author_name, :title ]
    #  values = [ [ 'zdennis', 'test post' ], [ 'jdoe', 'another test post' ] ]
    #  BlogPost.import columns, values 
    #
    #  # Example using column_names, array_of_value and options
    #  columns = [ :author_name, :title ]
    #  values = [ [ 'zdennis', 'test post' ], [ 'jdoe', 'another test post' ] ]
    #  BlogPost.import( columns, values, :validate => false  )
    #
    #  # Example synchronizing existing instances in memory
    #  post = BlogPost.find_by_author_name( 'zdennis' )
    #  puts post.author_name # => 'zdennis'
    #  columns = [ :author_name, :title ]
    #  values = [ [ 'yoda', 'test post' ] ]
    #  BlogPost.import posts, :synchronize=>[ post ]
    #  puts post.author_name # => 'yoda'
    #
    #  # Example synchronizing unsaved/new instances in memory by using a uniqued imported field
    #  posts = [BlogPost.new(:title => "Foo"), BlogPost.new(:title => "Bar")]
    #  BlogPost.import posts, :synchronize => posts
    #  puts posts.first.new_record? # => false
    #
    # == On Duplicate Key Update (MySQL only)
    #
    # The :on_duplicate_key_update option can be either an Array or a Hash. 
    # 
    # ==== Using an Array
    #
    # The :on_duplicate_key_update option can be an array of column
    # names. The column names are the only fields that are updated if
    # a duplicate record is found. Below is an example:
    #
    #   BlogPost.import columns, values, :on_duplicate_key_update=>[ :date_modified, :content, :author ]
    #
    # ====  Using A Hash
    #
    # The :on_duplicate_key_update option can be a hash of column name
    # to model attribute name mappings. This gives you finer grained
    # control over what fields are updated with what attributes on your
    # model. Below is an example:
    #   
    #   BlogPost.import columns, attributes, :on_duplicate_key_update=>{ :title => :title } 
    #  
    # = Returns
    # This returns an object which responds to +failed_instances+ and +num_inserts+.
    # * failed_instances - an array of objects that fails validation and were not committed to the database. An empty array if no validation is performed.
    # * num_inserts - the number of insert statements it took to import the data
    def import( *args )
      options = { :validate=>true, :timestamps=>true }
      options.merge!( args.pop ) if args.last.is_a? Hash

      is_validating = options.delete( :validate )

      # assume array of model objects
      if args.last.is_a?( Array ) and args.last.first.is_a? ActiveRecord::Base
        if args.length == 2
          models = args.last
          column_names = args.first
        else
          models = args.first
          column_names = self.column_names.dup
        end
        
        array_of_attributes = models.map do |model|
          # this next line breaks sqlite.so with a segmentation fault
          # if model.new_record? || options[:on_duplicate_key_update]
            column_names.map do |name|
              model.send( "#{name}_before_type_cast" )
            end
          # end
        end
        # supports empty array
      elsif args.last.is_a?( Array ) and args.last.empty?
        return ActiveRecord::Import::Result.new([], 0) if args.last.empty?
        # supports 2-element array and array
      elsif args.size == 2 and args.first.is_a?( Array ) and args.last.is_a?( Array )
        column_names, array_of_attributes = args
      else
        raise ArgumentError.new( "Invalid arguments!" )
      end

      # dup the passed in array so we don't modify it unintentionally
      array_of_attributes = array_of_attributes.dup

      # Force the primary key col into the insert if it's not
      # on the list and we are using a sequence and stuff a nil
      # value for it into each row so the sequencer will fire later
      if !column_names.include?(primary_key) && sequence_name && connection.prefetch_primary_key?
         column_names << primary_key
         array_of_attributes.each { |a| a << nil }
      end

      # record timestamps unless disabled in ActiveRecord::Base
      if record_timestamps && options.delete( :timestamps )
         add_special_rails_stamps column_names, array_of_attributes, options
      end

      return_obj = if is_validating
        import_with_validations( column_names, array_of_attributes, options )
      else
        num_inserts = import_without_validations_or_callbacks( column_names, array_of_attributes, options )
        ActiveRecord::Import::Result.new([], num_inserts)
      end

      if options[:synchronize]
        sync_keys = options[:synchronize_keys] || [self.primary_key]
        synchronize( options[:synchronize], sync_keys)
      end

      return_obj.num_inserts = 0 if return_obj.num_inserts.nil?
      return_obj
    end
    
    # TODO import_from_table needs to be implemented. 
    def import_from_table( options ) # :nodoc:
    end
    
    # Imports the passed in +column_names+ and +array_of_attributes+
    # given the passed in +options+ Hash with validations. Returns an
    # object with the methods +failed_instances+ and +num_inserts+. 
    # +failed_instances+ is an array of instances that failed validations. 
    # +num_inserts+ is the number of inserts it took to import the data. See
    # ActiveRecord::Base.import for more information on
    # +column_names+, +array_of_attributes+ and +options+.
    def import_with_validations( column_names, array_of_attributes, options={} )
      failed_instances = []
    
      # create instances for each of our column/value sets
      arr = validations_array_for_column_names_and_attributes( column_names, array_of_attributes )    

      # keep track of the instance and the position it is currently at. if this fails
      # validation we'll use the index to remove it from the array_of_attributes
      arr.each_with_index do |hsh,i|
        instance = new do |model|
          hsh.each_pair{ |k,v| model.send("#{k}=", v) }
        end
        if not instance.valid?
          array_of_attributes[ i ] = nil
          failed_instances << instance
        end    
      end
      array_of_attributes.compact!
      
      num_inserts = array_of_attributes.empty? ? 0 : import_without_validations_or_callbacks( column_names, array_of_attributes, options )
      ActiveRecord::Import::Result.new(failed_instances, num_inserts)
    end
    
    # Imports the passed in +column_names+ and +array_of_attributes+
    # given the passed in +options+ Hash. This will return the number
    # of insert operations it took to create these records without
    # validations or callbacks. See ActiveRecord::Base.import for more
    # information on +column_names+, +array_of_attributes_ and
    # +options+.
    def import_without_validations_or_callbacks( column_names, array_of_attributes, options={} )
      columns = column_names.map { |name| columns_hash[name.to_s] }

      columns_sql = "(#{column_names.map{|name| connection.quote_column_name(name) }.join(',')})"
      insert_sql = "INSERT #{options[:ignore] ? 'IGNORE ':''}INTO #{quoted_table_name} #{columns_sql} VALUES "
      values_sql = values_sql_for_columns_and_attributes(columns, array_of_attributes)
      if not supports_import?
        number_inserted = 0
        values_sql.each do |values|
          connection.execute(insert_sql + values)
          number_inserted += 1
        end
      else
        # generate the sql
        post_sql_statements = connection.post_sql_statements( quoted_table_name, options )
        
        # perform the inserts
        number_inserted = connection.insert_many( [ insert_sql, post_sql_statements ].flatten, 
                                                  values_sql,
                                                  "#{self.class.name} Create Many Without Validations Or Callbacks" )
      end
      number_inserted
    end

    private

    # Returns SQL the VALUES for an INSERT statement given the passed in +columns+
    # and +array_of_attributes+.
    def values_sql_for_columns_and_attributes(columns, array_of_attributes)   # :nodoc:
      array_of_attributes.map do |arr|
        my_values = arr.each_with_index.map do |val,j|
          column = columns[j]
          if !sequence_name.blank? && column.name == primary_key && val.nil?
             connection.next_value_for_sequence(sequence_name)
          else
            connection.quote(column.type_cast(val), column)
          end
        end
        "(#{my_values.join(',')})"
      end
    end

    def add_special_rails_stamps( column_names, array_of_attributes, options )
      AREXT_RAILS_COLUMNS[:create].each_pair do |key, blk|
        if self.column_names.include?(key)
          value = blk.call
          if index=column_names.index(key)
             # replace every instance of the array of attributes with our value
             array_of_attributes.each{ |arr| arr[index] = value }
          else
            column_names << key
            array_of_attributes.each { |arr| arr << value }
          end
        end
      end

      AREXT_RAILS_COLUMNS[:update].each_pair do |key, blk|
        if self.column_names.include?(key)
          value = blk.call
          if index=column_names.index(key)
             # replace every instance of the array of attributes with our value
             array_of_attributes.each{ |arr| arr[index] = value }
          else
            column_names << key
            array_of_attributes.each { |arr| arr << value }
          end
          
          if supports_on_duplicate_key_update?
            if options[:on_duplicate_key_update]
              options[:on_duplicate_key_update] << key.to_sym if options[:on_duplicate_key_update].is_a?(Array)
              options[:on_duplicate_key_update][key.to_sym] = key.to_sym if options[:on_duplicate_key_update].is_a?(Hash)
            else
              options[:on_duplicate_key_update] = [ key.to_sym ]
            end
          end
        end
      end
    end
    
    # Returns an Array of Hashes for the passed in +column_names+ and +array_of_attributes+.
    def validations_array_for_column_names_and_attributes( column_names, array_of_attributes ) # :nodoc:
      array_of_attributes.map do |attributes|
        Hash[attributes.each_with_index.map {|attr, c| [column_names[c], attr] }]
      end
    end
    
  end
end
