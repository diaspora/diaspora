# encoding: UTF-8

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

module Mongo

  # A cursor over query results. Returned objects are hashes.
  class Cursor
    include Mongo::Conversions
    include Enumerable

    attr_reader :collection, :selector, :fields,
      :order, :hint, :snapshot, :timeout,
      :full_collection_name, :batch_size

    # Create a new cursor.
    #
    # Note: cursors are created when executing queries using [Collection#find] and other
    # similar methods. Application developers shouldn't have to create cursors manually.
    #
    # @return [Cursor]
    #
    # @core cursors constructor_details
    def initialize(collection, options={})
      @db         = collection.db
      @collection = collection
      @connection = @db.connection
      @logger     = @connection.logger

      @selector   = options[:selector] || {}
      @fields     = convert_fields_for_query(options[:fields])
      @skip       = options[:skip]     || 0
      @limit      = options[:limit]    || 0
      @order      = options[:order]
      @hint       = options[:hint]
      @snapshot   = options[:snapshot]
      @timeout    = options[:timeout]  || true
      @explain    = options[:explain]
      @socket     = options[:socket]
      @tailable   = options[:tailable] || false
      batch_size(options[:batch_size] || 0)

      @full_collection_name = "#{@collection.db.name}.#{@collection.name}"
      @cache        = []
      @closed       = false
      @query_run    = false
      @returned     = 0
    end

    # Get the next document specified the cursor options.
    #
    # @return [Hash, Nil] the next document or Nil if no documents remain.
    def next_document
      refresh if @cache.length == 0#empty?# num_remaining == 0
      doc = @cache.shift

      if doc && doc['$err']
        err = doc['$err']

        # If the server has stopped being the master (e.g., it's one of a
        # pair but it has died or something like that) then we close that
        # connection. The next request will re-open on master server.
        if err == "not master"
          @connection.close
          raise ConnectionFailure, err
        end

        raise OperationFailure, err
      end

      doc
    end

    # Reset this cursor on the server. Cursor options, such as the
    # query string and the values for skip and limit, are preserved.
    def rewind!
      close
      @cache.clear
      @cursor_id  = nil
      @closed     = false
      @query_run  = false
      @n_received = nil
      true
    end

    # Determine whether this cursor has any remaining results.
    #
    # @return [Boolean]
    def has_next?
      num_remaining > 0
    end

    # Get the size of the result set for this query.
    #
    # @return [Integer] the number of objects in the result set for this query. Does
    #   not take limit and skip into account. 
    #
    # @raise [OperationFailure] on a database error.
    def count
      command = BSON::OrderedHash["count",  @collection.name,
                            "query",  @selector,
                            "fields", @fields]
      response = @db.command(command)
      return response['n'].to_i if Mongo::Support.ok?(response)
      return 0 if response['errmsg'] == "ns missing"
      raise OperationFailure, "Count failed: #{response['errmsg']}"
    end

    # Sort this cursor's results.
    #
    # This method overrides any sort order specified in the Collection#find
    # method, and only the last sort applied has an effect.
    #
    # @param [Symbol, Array] key_or_list either 1) a key to sort by or 2) 
    #   an array of [key, direction] pairs to sort by. Direction should
    #   be specified as Mongo::ASCENDING (or :ascending / :asc) or Mongo::DESCENDING (or :descending / :desc)
    #
    # @raise [InvalidOperation] if this cursor has already been used.
    #
    # @raise [InvalidSortValueError] if the specified order is invalid.
    def sort(key_or_list, direction=nil)
      check_modifiable

      if !direction.nil?
        order = [[key_or_list, direction]]
      else
        order = key_or_list
      end

      @order = order
      self
    end

    # Limit the number of results to be returned by this cursor.
    #
    # This method overrides any limit specified in the Collection#find method,
    # and only the last limit applied has an effect.
    #
    # @return [Integer] the current number_to_return if no parameter is given.
    #
    # @raise [InvalidOperation] if this cursor has already been used.
    #
    # @core limit limit-instance_method
    def limit(number_to_return=nil)
      return @limit unless number_to_return
      check_modifiable
      raise ArgumentError, "limit requires an integer" unless number_to_return.is_a? Integer

      @limit = number_to_return
      self
    end

    # Skips the first +number_to_skip+ results of this cursor.
    # Returns the current number_to_skip if no parameter is given.
    #
    # This method overrides any skip specified in the Collection#find method,
    # and only the last skip applied has an effect.
    #
    # @return [Integer]
    #
    # @raise [InvalidOperation] if this cursor has already been used.
    def skip(number_to_skip=nil)
      return @skip unless number_to_skip
      check_modifiable
      raise ArgumentError, "skip requires an integer" unless number_to_skip.is_a? Integer

      @skip = number_to_skip
      self
    end

    # Set the batch size for server responses.
    #
    # Note that the batch size will take effect only on queries
    # where the number to be returned is greater than 100.
    #
    # @param [Integer] size either 0 or some integer greater than 1. If 0,
    #   the server will determine the batch size.
    #
    # @return [Cursor]
    def batch_size(size=0)
      check_modifiable
      if size < 0 || size == 1
        raise ArgumentError, "Invalid value for batch_size #{size}; must be 0 or > 1."
      else
        @batch_size = size > @limit ? @limit : size
      end

      self
    end

    # Iterate over each document in this cursor, yielding it to the given
    # block.
    #
    # Iterating over an entire cursor will close it.
    #
    # @yield passes each document to a block for processing.
    #
    # @example if 'comments' represents a collection of comments:
    #   comments.find.each do |doc|
    #     puts doc['user']
    #   end
    def each
      #num_returned = 0
      #while has_next? && (@limit <= 0 || num_returned < @limit)
      while doc = next_document
        yield doc #next_document
        #num_returned += 1
      end
    end

    # Receive all the documents from this cursor as an array of hashes.
    #
    # Notes:
    #
    # If you've already started iterating over the cursor, the array returned
    # by this method contains only the remaining documents. See Cursor#rewind! if you
    # need to reset the cursor.
    #
    # Use of this method is discouraged - in most cases, it's much more
    # efficient to retrieve documents as you need them by iterating over the cursor.
    #
    # @return [Array] an array of documents.
    def to_a
      super
    end

    # Get the explain plan for this cursor.
    #
    # @return [Hash] a document containing the explain plan for this cursor.
    #
    # @core explain explain-instance_method
    def explain
      c = Cursor.new(@collection, query_options_hash.merge(:limit => -@limit.abs, :explain => true))
      explanation = c.next_document
      c.close

      explanation
    end

    # Close the cursor.
    #
    # Note: if a cursor is read until exhausted (read until Mongo::Constants::OP_QUERY or
    # Mongo::Constants::OP_GETMORE returns zero for the cursor id), there is no need to
    # close it manually.
    #
    # Note also: Collection#find takes an optional block argument which can be used to
    # ensure that your cursors get closed.
    #
    # @return [True]
    def close
      if @cursor_id && @cursor_id != 0
        message = BSON::ByteBuffer.new([0, 0, 0, 0])
        message.put_int(1)
        message.put_long(@cursor_id)
        @logger.debug("MONGODB cursor.close #{@cursor_id}") if @logger
        @connection.send_message(Mongo::Constants::OP_KILL_CURSORS, message, nil)
      end
      @cursor_id = 0
      @closed    = true
    end

    # Is this cursor closed?
    #
    # @return [Boolean]
    def closed?; @closed; end

    # Returns an integer indicating which query options have been selected.
    #
    # @return [Integer]
    #
    # @see http://www.mongodb.org/display/DOCS/Mongo+Wire+Protocol#MongoWireProtocol-Mongo::Constants::OPQUERY
    # The MongoDB wire protocol.
    def query_opts
      opts     = 0
      opts    |= Mongo::Constants::OP_QUERY_NO_CURSOR_TIMEOUT unless @timeout
      opts    |= Mongo::Constants::OP_QUERY_SLAVE_OK if @connection.slave_ok?
      opts    |= Mongo::Constants::OP_QUERY_TAILABLE if @tailable
      opts
    end

    # Get the query options for this Cursor.
    #
    # @return [Hash]
    def query_options_hash
      { :selector => @selector,
        :fields   => @fields,
        :skip     => @skip_num,
        :limit    => @limit_num,
        :order    => @order,
        :hint     => @hint,
        :snapshot => @snapshot,
        :timeout  => @timeout }
    end

    # Clean output for inspect.
    def inspect
      "<Mongo::Cursor:0x#{object_id.to_s(16)} namespace='#{@db.name}.#{@collection.name}' " +
        "@selector=#{@selector.inspect}>"
    end

    private

    # Convert the +:fields+ parameter from a single field name or an array
    # of fields names to a hash, with the field names for keys and '1' for each
    # value.
    def convert_fields_for_query(fields)
      case fields
        when String, Symbol
          {fields => 1}
        when Array
          return nil if fields.length.zero?
          fields.each_with_object({}) { |field, hash| hash[field] = 1 }
        when Hash
          return fields
      end
    end

    # Return the number of documents remaining for this cursor.
    def num_remaining
      refresh if @cache.length == 0
      @cache.length
    end

    def refresh
      return if send_initial_query || @cursor_id.zero?
      message = BSON::ByteBuffer.new([0, 0, 0, 0])

      # DB name.
      BSON::BSON_RUBY.serialize_cstr(message, "#{@db.name}.#{@collection.name}")

      # Number of results to return.
      if @limit > 0
        limit = @limit - @returned
        if @batch_size > 0
          limit = limit < @batch_size ? limit : @batch_size
        end
        message.put_int(limit)
      else
        message.put_int(@batch_size)
      end

      # Cursor id.
      message.put_long(@cursor_id)
      @logger.debug("MONGODB cursor.refresh() for cursor #{@cursor_id}") if @logger
      results, @n_received, @cursor_id = @connection.receive_message(Mongo::Constants::OP_GET_MORE,
                                                                     message, nil, @socket)
      @returned += @n_received
      @cache += results
      close_cursor_if_query_complete
    end

    # Run query the first time we request an object from the wire
    def send_initial_query
      if @query_run
        false
      else
        message = construct_query_message
        @logger.debug query_log_message if @logger
        results, @n_received, @cursor_id = @connection.receive_message(Mongo::Constants::OP_QUERY, message, nil, @socket)
        @returned += @n_received
        @cache += results
        @query_run = true
        close_cursor_if_query_complete
        true
      end
    end

    def construct_query_message
      message = BSON::ByteBuffer.new
      message.put_int(query_opts)
      BSON::BSON_RUBY.serialize_cstr(message, "#{@db.name}.#{@collection.name}")
      message.put_int(@skip)
      message.put_int(@limit)
      spec = query_contains_special_fields? ? construct_query_spec : @selector
      message.put_binary(BSON::BSON_CODER.serialize(spec, false).to_s)
      message.put_binary(BSON::BSON_CODER.serialize(@fields, false).to_s) if @fields
      message
    end

    def query_log_message
      "#{@db.name}['#{@collection.name}'].find(#{@selector.inspect}, #{@fields ? @fields.inspect : '{}'})" +
      "#{@skip != 0 ? ('.skip(' + @skip.to_s + ')') : ''}#{@limit != 0 ? ('.limit(' + @limit.to_s + ')') : ''}" +
      "#{@order ? ('.sort(' + @order.inspect + ')') : ''}"
    end

    def construct_query_spec
      return @selector if @selector.has_key?('$query')
      spec = BSON::OrderedHash.new
      spec['$query']    = @selector
      spec['$orderby']  = Mongo::Support.format_order_clause(@order) if @order
      spec['$hint']     = @hint if @hint && @hint.length > 0
      spec['$explain']  = true if @explain
      spec['$snapshot'] = true if @snapshot
      spec
    end

    # Returns true if the query contains order, explain, hint, or snapshot.
    def query_contains_special_fields?
      @order || @explain || @hint || @snapshot
    end

    def to_s
      "DBResponse(flags=#@result_flags, cursor_id=#@cursor_id, start=#@starting_from)"
    end

    def close_cursor_if_query_complete
      if @limit > 0 && @returned >= @limit
        close
      end
    end

    def check_modifiable
      if @query_run || @closed
        raise InvalidOperation, "Cannot modify the query once it has been run or closed."
      end
    end
  end
end
