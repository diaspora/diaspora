# encoding: UTF-8

# --
# Copyright (C) 2008-2010 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ++

module Mongo

  # A named collection of documents in a database.
  class Collection

    attr_reader :db, :name, :pk_factory, :hint

    # Initialize a collection object.
    #
    # @param [DB] db a MongoDB database instance.
    # @param [String, Symbol] name the name of the collection.
    #
    # @raise [InvalidNSName]
    #   if collection name is empty, contains '$', or starts or ends with '.'
    #
    # @raise [TypeError]
    #   if collection name is not a string or symbol
    #
    # @return [Collection]
    #
    # @core collections constructor_details
    def initialize(db, name, pk_factory=nil)
      case name
      when Symbol, String
      else
        raise TypeError, "new_name must be a string or symbol"
      end

      name = name.to_s

      if name.empty? or name.include? ".."
        raise Mongo::InvalidNSName, "collection names cannot be empty"
      end
      if name.include? "$"
        raise Mongo::InvalidNSName, "collection names must not contain '$'" unless name =~ /((^\$cmd)|(oplog\.\$main))/
      end
      if name.match(/^\./) or name.match(/\.$/)
        raise Mongo::InvalidNSName, "collection names must not start or end with '.'"
      end

      @db, @name  = db, name
      @connection = @db.connection
      @logger     = @connection.logger
      @pk_factory = pk_factory || BSON::ObjectId
      @hint = nil
    end

    # Return a sub-collection of this collection by name. If 'users' is a collection, then
    # 'users.comments' is a sub-collection of users.
    #
    # @param [String] name
    #   the collection to return
    #
    # @raise [Mongo::InvalidNSName]
    #   if passed an invalid collection name
    #
    # @return [Collection]
    #   the specified sub-collection
    def [](name)
      name = "#{self.name}.#{name}"
      return Collection.new(db, name) if !db.strict? || db.collection_names.include?(name)
      raise "Collection #{name} doesn't exist. Currently in strict mode."
    end

    # Set a hint field for query optimizer. Hint may be a single field
    # name, array of field names, or a hash (preferably an [OrderedHash]).
    # If using MongoDB > 1.1, you probably don't ever need to set a hint.
    #
    # @param [String, Array, OrderedHash] hint a single field, an array of
    #   fields, or a hash specifying fields
    def hint=(hint=nil)
      @hint = normalize_hint_fields(hint)
      self
    end

    # Query the database.
    #
    # The +selector+ argument is a prototype document that all results must
    # match. For example:
    #
    #   collection.find({"hello" => "world"})
    #
    # only matches documents that have a key "hello" with value "world".
    # Matches can have other keys *in addition* to "hello".
    #
    # If given an optional block +find+ will yield a Cursor to that block,
    # close the cursor, and then return nil. This guarantees that partially
    # evaluated cursors will be closed. If given no block +find+ returns a
    # cursor.
    #
    # @param [Hash] selector
    #   a document specifying elements which must be present for a
    #   document to be included in the result set.
    #
    # @option opts [Array, Hash] :fields field names that should be returned in the result
    #   set ("_id" will always be included). By limiting results to a certain subset of fields,
    #   you can cut down on network traffic and decoding time. If using a Hash, keys should be field
    #   names and values should be either 1 or 0, depending on whether you want to include or exclude
    #   the given field.
    # @option opts [Integer] :skip number of documents to skip from the beginning of the result set
    # @option opts [Integer] :limit maximum number of documents to return
    # @option opts [Array]   :sort an array of [key, direction] pairs to sort by. Direction should
    #   be specified as Mongo::ASCENDING (or :ascending / :asc) or Mongo::DESCENDING (or :descending / :desc)
    # @option opts [String, Array, OrderedHash] :hint hint for query optimizer, usually not necessary if using MongoDB > 1.1
    # @option opts [Boolean] :snapshot ('false') if true, snapshot mode will be used for this query.
    #   Snapshot mode assures no duplicates are returned, or objects missed, which were preset at both the start and
    #   end of the query's execution. For details see http://www.mongodb.org/display/DOCS/How+to+do+Snapshotting+in+the+Mongo+Database
    # @option opts [Boolean] :batch_size (100) the number of documents to returned by the database per GETMORE operation. A value of 0
    #   will let the database server decide how many results to returns. This option can be ignored for most use cases.
    # @option opts [Boolean] :timeout ('true') when +true+, the returned cursor will be subject to
    #   the normal cursor timeout behavior of the mongod process. When +false+, the returned cursor will never timeout. Note
    #   that disabling timeout will only work when #find is invoked with a block. This is to prevent any inadvertant failure to
    #   close the cursor, as the cursor is explicitly closed when block code finishes.
    #
    # @raise [ArgumentError]
    #   if timeout is set to false and find is not invoked in a block
    #
    # @raise [RuntimeError]
    #   if given unknown options
    #
    # @core find find-instance_method
    def find(selector={}, opts={})
      fields = opts.delete(:fields)
      fields = ["_id"] if fields && fields.empty?
      skip   = opts.delete(:skip) || skip || 0
      limit  = opts.delete(:limit) || 0
      sort   = opts.delete(:sort)
      hint   = opts.delete(:hint)
      snapshot = opts.delete(:snapshot)
      batch_size = opts.delete(:batch_size)

      if opts[:timeout] == false && !block_given?
        raise ArgumentError, "Timeout can be set to false only when #find is invoked with a block."
      else
        timeout = opts.delete(:timeout) || false
      end

      if hint
        hint = normalize_hint_fields(hint)
      else
        hint = @hint        # assumed to be normalized already
      end

      raise RuntimeError, "Unknown options [#{opts.inspect}]" unless opts.empty?

      cursor = Cursor.new(self, :selector => selector, :fields => fields, :skip => skip, :limit => limit,
        :order => sort, :hint => hint, :snapshot => snapshot, :timeout => timeout, :batch_size => batch_size)

      if block_given?
        yield cursor
        cursor.close()
        nil
      else
        cursor
      end
    end

    # Return a single object from the database.
    #
    # @return [OrderedHash, Nil]
    #   a single document or nil if no result is found.
    #
    # @param [Hash, ObjectId, Nil] spec_or_object_id a hash specifying elements 
    #   which must be present for a document to be included in the result set or an 
    #   instance of ObjectId to be used as the value for an _id query.
    #   If nil, an empty selector, {}, will be used.
    #
    # @option opts [Hash]
    #   any valid options that can be send to Collection#find
    #
    # @raise [TypeError]
    #   if the argument is of an improper type.
    def find_one(spec_or_object_id=nil, opts={})
      spec = case spec_or_object_id
             when nil
               {}
             when BSON::ObjectId
               {:_id => spec_or_object_id}
             when Hash
               spec_or_object_id
             else
               raise TypeError, "spec_or_object_id must be an instance of ObjectId or Hash, or nil"
             end
      find(spec, opts.merge(:limit => -1)).next_document
    end

    # Save a document to this collection.
    #
    # @param [Hash] doc
    #   the document to be saved. If the document already has an '_id' key,
    #   then an update (upsert) operation will be performed, and any existing
    #   document with that _id is overwritten. Otherwise an insert operation is performed.
    #
    # @return [ObjectId] the _id of the saved document.
    #
    # @option opts [Boolean, Hash] :safe (+false+)
    #   run the operation in safe mode, which run a getlasterror command on the
    #   database to report any assertion. In addition, a hash can be provided to
    #   run an fsync and/or wait for replication of the save (>= 1.5.1). See the options
    #   for DB#error.
    #
    # @raise [OperationFailure] when :safe mode fails.
    #
    # @see DB#remove for options that can be passed to :safe.
    def save(doc, opts={})
      if doc.has_key?(:_id) || doc.has_key?('_id')
        id = doc[:_id] || doc['_id']
        update({:_id => id}, doc, :upsert => true, :safe => opts[:safe])
        id
      else
        insert(doc, :safe => opts[:safe])
      end
    end

    # Insert one or more documents into the collection.
    #
    # @param [Hash, Array] doc_or_docs
    #   a document (as a hash) or array of documents to be inserted.
    #
    # @return [ObjectId, Array]
    #   the _id of the inserted document or a list of _ids of all inserted documents.
    #   Note: the object may have been modified by the database's PK factory, if it has one.
    #
    # @option opts [Boolean, Hash] :safe (+false+)
    #   run the operation in safe mode, which run a getlasterror command on the
    #   database to report any assertion. In addition, a hash can be provided to
    #   run an fsync and/or wait for replication of the insert (>= 1.5.1). See the options
    #   for DB#error.
    #
    # @see DB#remove for options that can be passed to :safe.
    #
    # @core insert insert-instance_method
    def insert(doc_or_docs, options={})
      doc_or_docs = [doc_or_docs] unless doc_or_docs.is_a?(Array)
      doc_or_docs.collect! { |doc| @pk_factory.create_pk(doc) }
      result = insert_documents(doc_or_docs, @name, true, options[:safe])
      result.size > 1 ? result : result.first
    end
    alias_method :<<, :insert

    # Remove all documents from this collection.
    #
    # @param [Hash] selector
    #   If specified, only matching documents will be removed.
    #
    # @option opts [Boolean, Hash] :safe (+false+)
    #   run the operation in safe mode, which run a getlasterror command on the
    #   database to report any assertion. In addition, a hash can be provided to
    #   run an fsync and/or wait for replication of the remove (>= 1.5.1). See the options
    #   for DB#get_last_error.
    #
    # @example remove all documents from the 'users' collection:
    #   users.remove
    #   users.remove({})
    #
    # @example remove only documents that have expired:
    #   users.remove({:expire => {"$lte" => Time.now}})
    #
    # @return [True]
    #
    # @raise [Mongo::OperationFailure] an exception will be raised iff safe mode is enabled
    #   and the operation fails.
    #
    # @see DB#remove for options that can be passed to :safe.
    #
    # @core remove remove-instance_method
    def remove(selector={}, opts={})
      # Initial byte is 0.
      message = BSON::ByteBuffer.new("\0\0\0\0")
      BSON::BSON_RUBY.serialize_cstr(message, "#{@db.name}.#{@name}")
      message.put_int(0)
      message.put_binary(BSON::BSON_CODER.serialize(selector, false, true).to_s)

      @logger.debug("MONGODB #{@db.name}['#{@name}'].remove(#{selector.inspect})") if @logger
      if opts[:safe]
        @connection.send_message_with_safe_check(Mongo::Constants::OP_DELETE, message, @db.name, nil, opts[:safe])
        # the return value of send_message_with_safe_check isn't actually meaningful --
        # only the fact that it didn't raise an error is -- so just return true
        true
      else
        @connection.send_message(Mongo::Constants::OP_DELETE, message)
      end
    end

    # Update a single document in this collection.
    #
    # @param [Hash] selector
    #   a hash specifying elements which must be present for a document to be updated. Note:
    #   the update command currently updates only the first document matching the
    #   given selector. If you want all matching documents to be updated, be sure
    #   to specify :multi => true.
    # @param [Hash] document
    #   a hash specifying the fields to be changed in the selected document,
    #   or (in the case of an upsert) the document to be inserted
    #
    # @option [Boolean] :upsert (+false+) if true, performs an upsert (update or insert)
    # @option [Boolean] :multi (+false+) update all documents matching the selector, as opposed to
    #   just the first matching document. Note: only works in MongoDB 1.1.3 or later.
    # @option opts [Boolean] :safe (+false+) 
    #   If true, check that the save succeeded. OperationFailure
    #   will be raised on an error. Note that a safe check requires an extra
    #   round-trip to the database.
    #
    # @core update update-instance_method
    def update(selector, document, options={})
      # Initial byte is 0.
      message = BSON::ByteBuffer.new("\0\0\0\0")
      BSON::BSON_RUBY.serialize_cstr(message, "#{@db.name}.#{@name}")
      update_options  = 0
      update_options += 1 if options[:upsert]
      update_options += 2 if options[:multi]
      message.put_int(update_options)
      message.put_binary(BSON::BSON_CODER.serialize(selector, false, true).to_s)
      message.put_binary(BSON::BSON_CODER.serialize(document, false, true).to_s)
      @logger.debug("MONGODB #{@db.name}['#{@name}'].update(#{selector.inspect}, #{document.inspect})") if @logger
      if options[:safe]
        @connection.send_message_with_safe_check(Mongo::Constants::OP_UPDATE, message, @db.name, nil, options[:safe])
      else
        @connection.send_message(Mongo::Constants::OP_UPDATE, message, nil)
      end
    end

    # Create a new index.
    #
    # @param [String, Array] spec
    #   should be either a single field name or an array of
    #   [field name, direction] pairs. Directions should be specified
    #   as Mongo::ASCENDING, Mongo::DESCENDING, or Mongo::GEO2D.
    #
    #   Note that geospatial indexing only works with versions of MongoDB >= 1.3.3+. Keep in mind, too,
    #   that in order to geo-index a given field, that field must reference either an array or a sub-object
    #   where the first two values represent x- and y-coordinates. Examples can be seen below.
    #
    #   Also note that it is permissible to create compound indexes that include a geospatial index as
    #   long as the geospatial index comes first.
    #
    # @option opts [Boolean] :unique (false) if true, this index will enforce a uniqueness constraint.
    # @option opts [Boolean] :background (false) indicate that the index should be built in the background. This
    #   feature is only available in MongoDB >= 1.3.2.
    # @option opts [Boolean] :dropDups If creating a unique index on a collection with pre-existing records,
    #   this option will keep the first document the database indexes and drop all subsequent with duplicate values.
    # @option opts [Integer] :min specify the minimum longitude and latitude for a geo index.
    # @option opts [Integer] :max specify the maximum longitude and latitude for a geo index.
    #
    # @example Creating a compound index:
    #   @posts.create_index([['subject', Mongo::ASCENDING], ['created_at', Mongo::DESCENDING]])
    #
    # @example Creating a geospatial index:
    #   @restaurants.create_index([['location', Mongo::GEO2D]])
    #
    #   # Note that this will work only if 'location' represents x,y coordinates:
    #   {'location': [0, 50]}
    #   {'location': {'x' => 0, 'y' => 50}}
    #   {'location': {'latitude' => 0, 'longitude' => 50}}
    #
    # @example A geospatial index with alternate longitude and latitude:
    #   @restaurants.create_index([['location', Mongo::GEO2D]], :min => 500, :max => 500)
    #
    # @return [String] the name of the index created.
    #
    # @core indexes create_index-instance_method
    def create_index(spec, opts={})
      opts.assert_valid_keys(:min, :max, :name, :background, :unique, :dropDups)
      field_spec = BSON::OrderedHash.new
      if spec.is_a?(String) || spec.is_a?(Symbol)
        field_spec[spec.to_s] = 1
      elsif spec.is_a?(Array) && spec.all? {|field| field.is_a?(Array) }
        spec.each do |f|
          if [Mongo::ASCENDING, Mongo::DESCENDING, Mongo::GEO2D].include?(f[1])
            field_spec[f[0].to_s] = f[1]
          else
            raise MongoArgumentError, "Invalid index field #{f[1].inspect}; " + 
              "should be one of Mongo::ASCENDING (1), Mongo::DESCENDING (-1) or Mongo::GEO2D ('2d')."
          end
        end
      else
        raise MongoArgumentError, "Invalid index specification #{spec.inspect}; " + 
          "should be either a string, symbol, or an array of arrays."
      end

      name = opts.delete(:name) || generate_index_name(field_spec)

      selector = {
        :name   => name,
        :ns     => "#{@db.name}.#{@name}",
        :key    => field_spec
      }
      selector.merge!(opts)
      begin
        response = insert_documents([selector], Mongo::DB::SYSTEM_INDEX_COLLECTION, false, true)
      rescue Mongo::OperationFailure
        raise Mongo::OperationFailure, "Failed to create index #{selector.inspect} with the following errors: #{response}"
      end
      name
    end

    # Drop a specified index.
    #
    # @param [String] name
    #
    # @core indexes
    def drop_index(name)
      @db.drop_index(@name, name)
    end

    # Drop all indexes.
    #
    # @core indexes
    def drop_indexes

      # Note: calling drop_indexes with no args will drop them all.
      @db.drop_index(@name, '*')
    end

    # Drop the entire collection. USE WITH CAUTION.
    def drop
      @db.drop_collection(@name)
    end


    # Atomically update and return a document using MongoDB's findAndModify command. (MongoDB > 1.3.0)
    #
    # @option opts [Hash] :query ({}) a query selector document for matching the desired document.
    # @option opts [Hash] :update (nil) the update operation to perform on the matched document.
    # @option opts [Array, String, OrderedHash] :sort ({}) specify a sort option for the query using any
    #   of the sort options available for Cursor#sort. Sort order is important if the query will be matching
    #   multiple documents since only the first matching document will be updated and returned.
    # @option opts [Boolean] :remove (false) If true, removes the the returned document from the collection.
    # @option opts [Boolean] :new (false) If true, returns the updated document; otherwise, returns the document
    #   prior to update.
    #
    # @return [Hash] the matched document.
    #
    # @core findandmodify find_and_modify-instance_method
    def find_and_modify(opts={})
      cmd = BSON::OrderedHash.new
      cmd[:findandmodify] = @name
      cmd.merge!(opts)
      cmd[:sort] = Mongo::Support.format_order_clause(opts[:sort]) if opts[:sort]

      @db.command(cmd)['value']
    end

    # Perform a map/reduce operation on the current collection.
    #
    # @param [String, BSON::Code] map a map function, written in JavaScript.
    # @param [String, BSON::Code] reduce a reduce function, written in JavaScript.
    #
    # @option opts [Hash] :query ({}) a query selector document, like what's passed to #find, to limit
    #   the operation to a subset of the collection.
    # @option opts [Array] :sort ([]) an array of [key, direction] pairs to sort by. Direction should
    #   be specified as Mongo::ASCENDING (or :ascending / :asc) or Mongo::DESCENDING (or :descending / :desc)
    # @option opts [Integer] :limit (nil) if passing a query, number of objects to return from the collection.
    # @option opts [String, BSON::Code] :finalize (nil) a javascript function to apply to the result set after the
    #   map/reduce operation has finished.
    # @option opts [String] :out (nil) the name of the output collection. If specified, the collection will not be treated as temporary.
    # @option opts [Boolean] :keeptemp (false) if true, the generated collection will be persisted. default is false.
    # @option opts [Boolean ] :verbose (false) if true, provides statistics on job execution time.
    # @option opts [Boolean] :raw (false) if true, return the raw result object from the map_reduce command, and not
    #   the instantiated collection that's returned by default.
    #
    # @return [Collection] a collection containing the results of the operation.
    #
    # @see http://www.mongodb.org/display/DOCS/MapReduce Offical MongoDB map/reduce documentation.
    #
    # @core mapreduce map_reduce-instance_method
    def map_reduce(map, reduce, opts={})
      map    = BSON::Code.new(map) unless map.is_a?(BSON::Code)
      reduce = BSON::Code.new(reduce) unless reduce.is_a?(BSON::Code)
      raw    = opts.delete(:raw)

      hash = BSON::OrderedHash.new
      hash['mapreduce'] = self.name
      hash['map'] = map
      hash['reduce'] = reduce
      hash.merge! opts

      result = @db.command(hash)
      unless Mongo::Support.ok?(result)
        raise Mongo::OperationFailure, "map-reduce failed: #{result['errmsg']}"
      end

      if raw
        result
      else
        @db[result["result"]]
      end
    end
    alias :mapreduce :map_reduce

    # Perform a group aggregation.
    #
    # @param [Array, String, BSON::Code, Nil] :key either 1) an array of fields to group by,
    #   2) a javascript function to generate the key object, or 3) nil.
    # @param [Hash] condition an optional document specifying a query to limit the documents over which group is run.
    # @param [Hash] initial initial value of the aggregation counter object
    # @param [String, BSON::Code] reduce aggregation function, in JavaScript
    # @param [String, BSON::Code] finalize :: optional. a JavaScript function that receives and modifies
    #              each of the resultant grouped objects. Available only when group is run
    #              with command set to true.
    #
    # @return [Array] the grouped items.
    def group(key, condition, initial, reduce, finalize=nil)
      reduce = BSON::Code.new(reduce) unless reduce.is_a?(BSON::Code)

      group_command = {
        "group" => {
          "ns"      => @name,
          "$reduce" => reduce,
          "cond"    => condition,
          "initial" => initial
        }
      }

      unless key.nil?
        if key.is_a? Array
          key_type = "key"
          key_value = {}
          key.each { |k| key_value[k] = 1 }
        else
          key_type  = "$keyf"
          key_value = key.is_a?(BSON::Code) ? key : BSON::Code.new(key)
        end

        group_command["group"][key_type] = key_value
      end

      finalize = BSON::Code.new(finalize) if finalize.is_a?(String)
      if finalize.is_a?(BSON::Code)
        group_command['group']['finalize'] = finalize
      end

      result = @db.command(group_command)

      if Mongo::Support.ok?(result)
        result["retval"]
      else
        raise OperationFailure, "group command failed: #{result['errmsg']}"
      end
    end

    # Return a list of distinct values for +key+ across all
    # documents in the collection. The key may use dot notation
    # to reach into an embedded object.
    #
    # @param [String, Symbol, OrderedHash] key or hash to group by.
    # @param [Hash] query a selector for limiting the result set over which to group.
    #
    # @example Saving zip codes and ages and returning distinct results.
    #   @collection.save({:zip => 10010, :name => {:age => 27}})
    #   @collection.save({:zip => 94108, :name => {:age => 24}})
    #   @collection.save({:zip => 10010, :name => {:age => 27}})
    #   @collection.save({:zip => 99701, :name => {:age => 24}})
    #   @collection.save({:zip => 94108, :name => {:age => 27}})
    #
    #   @collection.distinct(:zip)
    #     [10010, 94108, 99701]
    #   @collection.distinct("name.age")
    #     [27, 24]
    #
    #   # You may also pass a document selector as the second parameter
    #   # to limit the documents over which distinct is run:
    #   @collection.distinct("name.age", {"name.age" => {"$gt" => 24}})
    #     [27]
    #
    # @return [Array] an array of distinct values.
    def distinct(key, query=nil)
      raise MongoArgumentError unless [String, Symbol].include?(key.class)
      command = BSON::OrderedHash.new
      command[:distinct] = @name
      command[:key]      = key.to_s
      command[:query]    = query

      @db.command(command)["values"]
    end

    # Rename this collection.
    #
    # Note: If operating in auth mode, the client must be authorized as an admin to
    # perform this operation. 
    #
    # @param [String] new_name the new name for this collection
    #
    # @raise [Mongo::InvalidNSName] if +new_name+ is an invalid collection name.
    def rename(new_name)
      case new_name
      when Symbol, String
      else
        raise TypeError, "new_name must be a string or symbol"
      end

      new_name = new_name.to_s

      if new_name.empty? or new_name.include? ".."
        raise Mongo::InvalidNSName, "collection names cannot be empty"
      end
      if new_name.include? "$"
        raise Mongo::InvalidNSName, "collection names must not contain '$'"
      end
      if new_name.match(/^\./) or new_name.match(/\.$/)
        raise Mongo::InvalidNSName, "collection names must not start or end with '.'"
      end

      @db.rename_collection(@name, new_name)
    end

    # Get information on the indexes for this collection.
    #
    # @return [Hash] a hash where the keys are index names.
    #
    # @core indexes
    def index_information
      @db.index_information(@name)
    end

    # Return a hash containing options that apply to this collection.
    # For all possible keys and values, see DB#create_collection.
    #
    # @return [Hash] options that apply to this collection.
    def options
      @db.collections_info(@name).next_document['options']
    end

    # Return stats on the collection. Uses MongoDB's collstats command.
    #
    # @return [Hash]
    def stats
      @db.command({:collstats => @name})
    end

    # Get the number of documents in this collection.
    #
    # @return [Integer]
    def count
      find().count()
    end

    alias :size :count

    protected

    def normalize_hint_fields(hint)
      case hint
      when String
        {hint => 1}
      when Hash
        hint
      when nil
        nil
      else
        h = BSON::OrderedHash.new
        hint.to_a.each { |k| h[k] = 1 }
        h
      end
    end

    private

    # Sends a Mongo::Constants::OP_INSERT message to the database.
    # Takes an array of +documents+, an optional +collection_name+, and a
    # +check_keys+ setting.
    def insert_documents(documents, collection_name=@name, check_keys=true, safe=false)
      # Initial byte is 0.
      message = BSON::ByteBuffer.new("\0\0\0\0")
      BSON::BSON_RUBY.serialize_cstr(message, "#{@db.name}.#{collection_name}")
      documents.each do |doc|
        message.put_binary(BSON::BSON_CODER.serialize(doc, check_keys, true).to_s)
      end
      raise InvalidOperation, "Exceded maximum insert size of 16,000,000 bytes" if message.size > 16_000_000

      @logger.debug("MONGODB #{@db.name}['#{collection_name}'].insert(#{documents.inspect})") if @logger
      if safe
        @connection.send_message_with_safe_check(Mongo::Constants::OP_INSERT, message, @db.name, nil, safe)
      else
        @connection.send_message(Mongo::Constants::OP_INSERT, message, nil)
      end
      documents.collect { |o| o[:_id] || o['_id'] }
    end

    def generate_index_name(spec)
      indexes = []
      spec.each_pair do |field, direction|
        indexes.push("#{field}_#{direction}")
      end
      indexes.join("_")
    end
  end

end
