#
# Copyright (c) 2008 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require "aws"

module Aws

    class SdbInterface < AwsBase

        include AwsBaseInterface

        DEFAULT_HOST               = 'sdb.amazonaws.com'
        DEFAULT_PORT               = 443
        DEFAULT_PROTOCOL           = 'https'
        DEFAULT_SERVICE            = '/'
        API_VERSION                = '2009-04-15'
        DEFAULT_NIL_REPRESENTATION = 'nil'

        @@bench                    = AwsBenchmarkingBlock.new

        def self.bench_xml;
            @@bench.xml;
        end

        def self.bench_sdb;
            @@bench.service;
        end

        attr_reader :last_query_expression

        # Creates new RightSdb instance.
        #
        # Params:
        #    { :server       => 'sdb.amazonaws.com'  # Amazon service host: 'sdb.amazonaws.com'(default)
        #      :port         => 443                  # Amazon service port: 80(default) or 443
        #      :protocol     => 'https'              # Amazon service protocol: 'http'(default) or 'https'
        #      :signature_version => '2'             # The signature version : '0', '1' or '2' (default)
        #      DEPRECATED :multi_thread => true|false           # Multi-threaded (connection per each thread): true or false(default)
        #      :connection_mode  => :default         # options are :default (will use best known option, may change in the future)
        #                                                  :per_request (opens and closes a connection on every request to SDB)
        #                                                  :single - one connection shared across app (same as old multi_thread=>false)
        #                                                  :per_thread - one connection per ruby thread (same as old multi_thread=>true)
        #                                                  :pool (uses a connection pool with a maximum number of connections - NOT IMPLEMENTED YET)
        #      :logger       => Logger Object        # Logger instance: logs to STDOUT if omitted
        #      :nil_representation => 'mynil'}       # interpret Ruby nil as this string value; i.e. use this string in SDB to represent Ruby nils (default is the string 'nil')
        #      :service      => '/'	                 # Set this to /mdb/request.mgwsi for usage with M/DB #
        #
        # Example:
        #
        #  sdb = Aws::SdbInterface.new('1E3GDYEOGFJPIT7XXXXXX','hgTHt68JY07JKUY08ftHYtERkjgtfERn57XXXXXX', {:connection_mode => :per_request, :logger => Logger.new('/tmp/x.log')}) #=> #<RightSdb:0xa6b8c27c>
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/
        #
        def initialize(aws_access_key_id=nil, aws_secret_access_key=nil, params={})
            @nil_rep = params[:nil_representation] ? params[:nil_representation] : DEFAULT_NIL_REPRESENTATION
            params.delete(:nil_representation)
            init({:name             => 'SDB',
                  :default_host     => ENV['SDB_URL'] ? URI.parse(ENV['SDB_URL']).host : DEFAULT_HOST,
                  :default_port     => ENV['SDB_URL'] ? URI.parse(ENV['SDB_URL']).port : DEFAULT_PORT,
                  :default_protocol => ENV['SDB_URL'] ? URI.parse(ENV['SDB_URL']).scheme : DEFAULT_PROTOCOL,
                  :default_service  => ENV['SDB_URL'] ? URI.parse(ENV['SDB_URL']).path : DEFAULT_SERVICE},
                 #             :service_endpoint => ENV['SDB_URL'] ? URI.parse(ENV['SDB_URL']).path   : DEFAULT_ENDPOINT },
                 aws_access_key_id || ENV['AWS_ACCESS_KEY_ID'],
                 aws_secret_access_key || ENV['AWS_SECRET_ACCESS_KEY'],
                 params)
        end

        #-----------------------------------------------------------------
        #      Requests
        #-----------------------------------------------------------------
        def generate_request(action, params={}, options={}) #:nodoc:
            generate_request2(@aws_access_key_id, @aws_secret_access_key, action, API_VERSION, @params, params, options)
        end


        # Sends request to Amazon and parses the response
        # Raises AwsError if any banana happened
        def request_info(request, parser, options={}) #:nodoc:
#       request_info2(request, parser, :sdb_connection)
            request_info2(request, parser, @params, :sdb_connection, @logger, @@bench, options)

        end

        def close_connection
            close_conn(:sdb_connection)
        end

        # Prepare attributes for putting.
        # (used by put_attributes)
        def pack_attributes(attributes, replace = false, key_prefix = "") #:nodoc:
            result = {}
            if attributes
                idx         = 0
                skip_values = attributes.is_a?(Array)
                attributes.each do |attribute, values|
                    # set replacement attribute
                    result["#{key_prefix}Attribute.#{idx}.Replace"] = 'true' if replace
                    # pack Name/Value
                    unless values.nil?
                        Array(values).each do |value|
                            result["#{key_prefix}Attribute.#{idx}.Name"] = attribute
                            result["#{key_prefix}Attribute.#{idx}.Value"] = ruby_to_sdb(value) unless skip_values
                            idx += 1
                        end
                    else
                        result["#{key_prefix}Attribute.#{idx}.Name"] = attribute
                        result["#{key_prefix}Attribute.#{idx}.Value"] = ruby_to_sdb(nil) unless skip_values
                        idx += 1
                    end
                end
            end
            result
        end


        # Use this helper to manually escape the fields in the query expressions.
        # To escape the single quotes and backslashes and to wrap the string into the single quotes.
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API.html
        #
        def escape(value)
            %Q{'#{value.to_s.gsub(/(['\\])/) { "\\#{$1}" }}'} if value
        end

        # Convert a Ruby language value to a SDB value by replacing Ruby nil with the user's chosen string representation of nil.
        # Non-nil values are unaffected by this filter.
        def ruby_to_sdb(value)
#        puts "value #{value} is frozen? #{value.frozen?}"
#      value.nil? ? @nil_rep : ((value.frozen? || !value.is_a?(String)) ? value : value.force_encoding("UTF-8"))
            value.nil? ? @nil_rep : value
        end

        # Convert a SDB value to a Ruby language value by replacing the user's chosen string representation of nil with Ruby nil.
        # Values are unaffected by this filter unless they match the nil representation exactly.
        def sdb_to_ruby(value)
            value.eql?(@nil_rep) ? nil : value
        end

        # Convert select and query_with_attributes responses to a Ruby language values by replacing the user's chosen string representation of nil with Ruby nil.
        # (This method affects on a passed response value)
        def select_response_to_ruby(response) #:nodoc:
            response[:items].each_with_index do |item, idx|
                item.each do |key, attributes|
                    attributes.each do |name, values|
                        values.collect! { |value| sdb_to_ruby(value) }
                    end
                end
            end
            response
        end

        # Create query expression from an array.
        # (similar to ActiveRecord::Base#find using :conditions => ['query', param1, .., paramN])
        #
        def query_expression_from_array(params) #:nodoc:
            return '' if params.blank?
            query = params[0].to_s
            i     = 1
            query.gsub(/(\\)?(\?)/) do
                if $1 # if escaped '\?' is found - replace it by '?' without backslash
                    "?"
                else # well, if no backslash precedes '?' then replace it by next param from the list
                    ret = escape(params[i])
                    i   +=1
                    ret
                end
            end
        end

        def query_expression_from_hash(hash)
            return '' if hash.blank?
            expression = []
            hash.each do |key, value|
                expression << "#{key}=#{escape(value)}"
            end
            expression.join(' AND ')
        end

        # Retrieve a list of SDB domains from Amazon.
        #
        # Returns a hash:
        #   { :domains     => [domain1, ..., domainN],
        #     :next_token => string || nil,
        #     :box_usage   => string,
        #     :request_id  => string }
        #
        # Example:
        #
        #  sdb = Aws::SdbInterface.new
        #  sdb.list_domains  #=> { :box_usage  => "0.0000071759",
        #                          :request_id => "976709f9-0111-2345-92cb-9ce90acd0982",
        #                          :domains    => ["toys", "dolls"]}
        #
        # If a block is given, this method yields to it.  If the block returns true, list_domains will continue looping the request.  If the block returns false,
        # list_domains will end.
        #
        #   sdb.list_domains(10) do |result|   # list by 10 domains per iteration
        #     puts result.inspect
        #     true
        #   end
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_ListDomains.html
        #
        def list_domains(max_number_of_domains = nil, next_token = nil)
            request_params = {'MaxNumberOfDomains' => max_number_of_domains,
                              'NextToken'          => next_token}
            link           = generate_request("ListDomains", request_params)
            result         = request_info(link, QSdbListDomainParser.new)
            # return result if no block given
            return result unless block_given?
            # loop if block if given
            begin
                # the block must return true if it wanna continue
                break unless yield(result) && result[:next_token]
                # make new request
                request_params['NextToken'] = result[:next_token]
                link                        = generate_request("ListDomains", request_params)
                result                      = request_info(link, QSdbListDomainParser.new)
            end while true
        rescue Exception
            on_exception
        end

        # Retrieve a list of SDB domains from Amazon.
        #
        # Returns a hash:
        #   { :domains     => [domain1, ..., domainN],
        #     :next_token => string || nil,
        #     :box_usage   => string,
        #     :request_id  => string }
        #
        # Example:
        #
        #  sdb = Aws::SdbInterface.new
        #  sdb.list_domains  #=> { :box_usage  => "0.0000071759",
        #                          :request_id => "976709f9-0111-2345-92cb-9ce90acd0982",
        #                          :domains    => ["toys", "dolls"]}
        #
        # If a block is given, this method yields to it.  If the block returns true, list_domains will continue looping the request.  If the block returns false,
        # list_domains will end.
        #
        #   sdb.list_domains(10) do |result|   # list by 10 domains per iteration
        #     puts result.inspect
        #     true
        #   end
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_ListDomains.html
        #
        def domain_metadata(domain_name)
            link   = generate_request("DomainMetadata", 'DomainName' => domain_name)
            result = request_info(link, QSdbDomainMetadataParser.new)
            return result
        rescue Exception
            on_exception
        end


        # Create new SDB domain at Amazon.
        #
        # Returns a hash: { :box_usage, :request_id } on success or an exception on error.
        # (Amazon raises no errors if the domain already exists).
        #
        # Example:
        #
        #  sdb = Aws::SdbInterface.new
        #  sdb.create_domain('toys') # => { :box_usage  => "0.0000071759",
        #                                   :request_id => "976709f9-0111-2345-92cb-9ce90acd0982" }
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_CreateDomain.html
        def create_domain(domain_name)
            link = generate_request("CreateDomain",
                                    'DomainName' => domain_name)
            request_info(link, QSdbSimpleParser.new)
        rescue Exception
            on_exception
        end

        # Delete SDB domain at Amazon.
        #
        # Returns a hash: { :box_usage, :request_id } on success or an exception on error.
        # (Amazon raises no errors if the domain does not exist).
        #
        # Example:
        #
        #  sdb = Aws::SdbInterface.new
        #  sdb.delete_domain('toys') # => { :box_usage  => "0.0000071759",
        #                                   :request_id => "976709f9-0111-2345-92cb-9ce90acd0982" }
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_DeleteDomain.html
        #
        def delete_domain(domain_name)
            link = generate_request("DeleteDomain",
                                    'DomainName' => domain_name)
            request_info(link, QSdbSimpleParser.new)
        rescue Exception
            on_exception
        end

        # Add/Replace item attributes.
        #
        # Params:
        #  domain_name = DomainName
        #  item_name   = ItemName
        #  attributes  = {
        #    'nameA' => [valueA1,..., valueAN],
        #    ...
        #    'nameZ' => [valueZ1,..., valueZN]
        #  }
        #  replace = :replace | any other value to skip replacement
        #  options:
        #    :create_domain => If true and domain does not exist, it will be created. Default is false.
        #
        # Returns a hash: { :box_usage, :request_id } on success or an exception on error.
        # (Amazon raises no errors if the attribute was not overridden, as when the :replace param is unset).
        #
        # Example:
        #
        #  sdb = Aws::SdbInterface.new
        #  sdb.create_domain 'family'
        #
        #  attributes = {}
        #  # create attributes for Jon and Silvia
        #  attributes['Jon']    = %w{ car beer }
        #  attributes['Silvia'] = %w{ beetle rolling_pin kids }
        #  sdb.put_attributes 'family', 'toys', attributes   #=> ok
        #  # now: Jon=>[car, beer], Silvia=>[beetle, rolling_pin, kids]
        #
        #  # add attributes to Jon
        #  attributes.delete('Silvia')
        #  attributes['Jon'] = %w{ girls pub }
        #  sdb.put_attributes 'family', 'toys', attributes   #=> ok
        #  # now: Jon=>[car, beer, girls, pub], Silvia=>[beetle, rolling_pin, kids]
        #
        #  # replace attributes for Jon and add to a cat (the cat had no attributes before)
        #  attributes['Jon'] = %w{ vacuum_cleaner hammer spade }
        #  attributes['cat'] = %w{ mouse clew Jons_socks }
        #  sdb.put_attributes 'family', 'toys', attributes, :replace #=> ok
        #  # now: Jon=>[vacuum_cleaner, hammer, spade], Silvia=>[beetle, rolling_pin, kids], cat=>[mouse, clew, Jons_socks]
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_PutAttributes.html
        #
        def put_attributes(domain_name, item_name, attributes, replace = false, options={})
            params = {'DomainName' => domain_name,
                      'ItemName'   => item_name}.merge(pack_attributes(attributes, replace))
            logger.debug 'PUT=' + params.inspect
            link = generate_request("PutAttributes", params)
            begin
                request_info(link, QSdbSimpleParser.new, options)
            rescue Aws::AwsError => ex
                # puts "RESCUED in put_attributes: " + $!
                if options[:create_domain] && create_domain_if_not_exist(ex, domain_name)
                    options.delete(:create_domain)
                    put_attributes(domain_name, item_name, attributes, replace, options)
                else
                    raise ex
                end
            end
        rescue Exception
            on_exception
        end

        def create_domain_if_not_exist(ex, domain_name)
            if ex.message().index("NoSuchDomain")
                create_domain(domain_name)
                return true
            end
            return false
        end

        #
        # items is an array of Aws::SdbInterface::Item.new(o.id, o.attributes, true)
        def batch_put_attributes(domain_name, items)
            params = {'DomainName' => domain_name}
            i      = 0
            items.each do |item|
                prefix                      = "Item." + i.to_s + "."
                params[prefix + "ItemName"] = item.item_name
                params.merge!(pack_attributes(item.attributes, item.replace, prefix))
                i += 1
            end
            link = generate_request("BatchPutAttributes", params)
            request_info(link, QSdbSimpleParser.new)
        rescue Exception
            on_exception
        end

        #
        # items is an array item_name's or Aws::SdbInterface::Item.new(o.id, o.attributes, true)
        def batch_delete_attributes(domain_name, items)
            params = {'DomainName' => domain_name}
            i      = 0
            items.each do |item|
                prefix = "Item." + i.to_s + "."
                if item.is_a?(String)
                    params[prefix + "ItemName"] = item
                else
                    params[prefix + "ItemName"] = item.item_name
                    params.merge!(pack_attributes(item.attributes, item.replace, prefix))
                end
                i += 1
            end
            link = generate_request("BatchDeleteAttributes", params)
            request_info(link, QSdbSimpleParser.new)
        rescue Exception
            on_exception
        end

        # Retrieve SDB item's attribute(s).
        #
        # Returns a hash:
        #  { :box_usage  => string,
        #    :request_id => string,
        #    :attributes => { 'nameA' => [valueA1,..., valueAN],
        #                     ... ,
        #                     'nameZ' => [valueZ1,..., valueZN] } }
        #
        # Example:
        #  # request all attributes
        #  sdb.get_attributes('family', 'toys') # => { :attributes => {"cat"    => ["clew", "Jons_socks", "mouse"] },
        #                                                              "Silvia" => ["beetle", "rolling_pin", "kids"],
        #                                                              "Jon"    => ["vacuum_cleaner", "hammer", "spade"]},
        #                                              :box_usage  => "0.0000093222",
        #                                              :request_id => "81273d21-000-1111-b3f9-512d91d29ac8" }
        #
        #  # request cat's attributes only
        #  sdb.get_attributes('family', 'toys', 'cat') # => { :attributes => {"cat" => ["clew", "Jons_socks", "mouse"] },
        #                                                     :box_usage  => "0.0000093222",
        #                                                     :request_id => "81273d21-001-1111-b3f9-512d91d29ac8" }
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_GetAttributes.html
        #
        def get_attributes(domain_name, item_name, attribute_name=nil, consistent_read = nil)
            link = generate_request("GetAttributes", 'DomainName' => domain_name,
                                    'ItemName'                    => item_name,
                                    'AttributeName'               => attribute_name,
                                    'ConsistentRead'              => consistent_read)
            res  = request_info(link, QSdbGetAttributesParser.new)
            res[:attributes].each_value do |values|
                values.collect! { |e| sdb_to_ruby(e) }
            end
            res
        rescue Exception
            on_exception
        end

        # Delete value, attribute or item.
        #
        # Example:
        #  # delete 'vodka' and 'girls' from 'Jon' and 'mice' from 'cat'.
        #  sdb.delete_attributes 'family', 'toys', { 'Jon' => ['vodka', 'girls'], 'cat' => ['mice'] }
        #
        #  # delete the all the values from attributes (i.e. delete the attributes)
        #  sdb.delete_attributes 'family', 'toys', { 'Jon' => [], 'cat' => [] }
        #  # or
        #  sdb.delete_attributes 'family', 'toys', [ 'Jon', 'cat' ]
        #
        #  # delete all the attributes from item 'toys' (i.e. delete the item)
        #  sdb.delete_attributes 'family', 'toys'
        #
        # see http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_DeleteAttributes.html
        #
        def delete_attributes(domain_name, item_name, attributes = nil)
            params = {'DomainName' => domain_name,
                      'ItemName'   => item_name}.merge(pack_attributes(attributes))
            link   = generate_request("DeleteAttributes", params)
            request_info(link, QSdbSimpleParser.new)
        rescue Exception
            on_exception
        end


        # QUERY:

        # Perform a query on SDB.
        #
        # Returns a hash:
        #   { :box_usage  => string,
        #     :request_id => string,
        #     :next_token => string,
        #     :items      => [ItemName1,..., ItemNameN] }
        #
        # Example:
        #
        #   query = "['cat' = 'clew']"
        #   sdb.query('family', query)     #=> hash of data
        #   sdb.query('family', query, 10) #=> hash of data with max of 10 items
        #
        # If a block is given, query will iteratively yield results to it as long as the block continues to return true.
        #
        #   # List 10 items per iteration. Don't
        #   # forget to escape single quotes and backslashes and wrap all the items in single quotes.
        #   query = "['cat'='clew'] union ['dog'='Jon\\'s boot']"
        #   sdb.query('family', query, 10) do |result|
        #     puts result.inspect
        #     true
        #   end
        #
        #   # Same query using automatic escaping...to use the auto escape, pass the query and its params as an array:
        #   query = [ "['cat'=?] union ['dog'=?]", "clew", "Jon's boot" ]
        #   sdb.query('family', query)
        #
        #   query = [ "['cat'=?] union ['dog'=?] sort 'cat' desc", "clew", "Jon's boot" ]
        #   sdb.query('family', query)
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/SDB_API_Query.html
        #      http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?SortingData.html
        #
        def query(domain_name, query_expression = nil, max_number_of_items = nil, next_token = nil, consistent_read = nil)
            query_expression = query_expression_from_array(query_expression) if query_expression.is_a?(Array)
            @last_query_expression = query_expression
            #
            request_params         = {'DomainName'       => domain_name,
                                      'QueryExpression'  => query_expression,
                                      'MaxNumberOfItems' => max_number_of_items,
                                      'NextToken'        => next_token,
                                      'ConsistentRead'   => consistent_read}
            link                   = generate_request("Query", request_params)
            result                 = request_info(link, QSdbQueryParser.new)
            # return result if no block given
            return result unless block_given?
            # loop if block if given
            begin
                # the block must return true if it wanna continue
                break unless yield(result) && result[:next_token]
                # make new request
                request_params['NextToken'] = result[:next_token]
                link                        = generate_request("Query", request_params)
                result                      = request_info(link, QSdbQueryParser.new)
            end while true
        rescue Exception
            on_exception
        end

        # Perform a query and fetch specified attributes.
        # If attributes are not specified then fetches the whole list of attributes.
        #
        #
        # Returns a hash:
        #   { :box_usage  => string,
        #     :request_id => string,
        #     :next_token => string,
        #     :items      => [ { ItemName1 => { attribute1 => value1, ...  attributeM => valueM } },
        #                      { ItemName2 => {...}}, ... ]
        #
        # Example:
        #
        #   sdb.query_with_attributes(domain, ['hobby', 'country'], "['gender'='female'] intersection ['name' starts-with ''] sort 'name'") #=>
        #     { :request_id => "06057228-70d0-4487-89fb-fd9c028580d3",
        #       :items =>
        #         [ { "035f1ba8-dbd8-11dd-80bd-001bfc466dd7"=>
        #             { "hobby"   => ["cooking", "flowers", "cats"],
        #               "country" => ["Russia"]}},
        #           { "0327614a-dbd8-11dd-80bd-001bfc466dd7"=>
        #             { "hobby"   => ["patchwork", "bundle jumping"],
        #               "country" => ["USA"]}}, ... ],
        #        :box_usage=>"0.0000504786"}
        #
        #   sdb.query_with_attributes(domain, [], "['gender'='female'] intersection ['name' starts-with ''] sort 'name'") #=>
        #     { :request_id => "75bb19db-a529-4f69-b86f-5e3800f79a45",
        #       :items =>
        #       [ { "035f1ba8-dbd8-11dd-80bd-001bfc466dd7"=>
        #           { "hobby"   => ["cooking", "flowers", "cats"],
        #             "name"    => ["Mary"],
        #             "country" => ["Russia"],
        #             "gender"  => ["female"],
        #             "id"      => ["035f1ba8-dbd8-11dd-80bd-001bfc466dd7"]}},
        #         { "0327614a-dbd8-11dd-80bd-001bfc466dd7"=>
        #           { "hobby"   => ["patchwork", "bundle jumping"],
        #             "name"    => ["Mary"],
        #             "country" => ["USA"],
        #             "gender"  => ["female"],
        #             "id"      => ["0327614a-dbd8-11dd-80bd-001bfc466dd7"]}}, ... ],
        #      :box_usage=>"0.0000506668"}
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?SDB_API_QueryWithAttributes.html
        #
        def query_with_attributes(domain_name, attributes=[], query_expression = nil, max_number_of_items = nil, next_token = nil, consistent_read = nil)
            attributes = attributes.to_a
            query_expression = query_expression_from_array(query_expression) if query_expression.is_a?(Array)
            @last_query_expression = query_expression
            #
            request_params         = {'DomainName'       => domain_name,
                                      'QueryExpression'  => query_expression,
                                      'MaxNumberOfItems' => max_number_of_items,
                                      'NextToken'        => next_token,
                                      'ConsistentRead'   => consistent_read}
            attributes.each_with_index do |attribute, idx|
                request_params["AttributeName.#{idx+1}"] = attribute
            end
            link   = generate_request("QueryWithAttributes", request_params)
            result = select_response_to_ruby(request_info(link, QSdbQueryWithAttributesParser.new))
            # return result if no block given
            return result unless block_given?
            # loop if block if given
            begin
                # the block must return true if it wanna continue
                break unless yield(result) && result[:next_token]
                # make new request
                request_params['NextToken'] = result[:next_token]
                link                        = generate_request("QueryWithAttributes", request_params)
                result                      = select_response_to_ruby(request_info(link, QSdbQueryWithAttributesParser.new))
            end while true
        rescue Exception
            on_exception
        end

        # Perform SQL-like select and fetch attributes.
        # Attribute values must be quoted with a single or double quote. If a quote appears within the attribute value, it must be escaped with the same quote symbol as shown in the following example.
        # (Use array to pass select_expression params to avoid manual escaping).
        #
        #  sdb.select(["select * from my_domain where gender=?", 'female']) #=>
        #    {:request_id =>"8241b843-0fb9-4d66-9100-effae12249ec",
        #     :items =>
        #      [ { "035f1ba8-dbd8-11dd-80bd-001bfc466dd7"=>
        #          {"hobby"   => ["cooking", "flowers", "cats"],
        #           "name"    => ["Mary"],
        #           "country" => ["Russia"],
        #           "gender"  => ["female"],
        #           "id"      => ["035f1ba8-dbd8-11dd-80bd-001bfc466dd7"]}},
        #        { "0327614a-dbd8-11dd-80bd-001bfc466dd7"=>
        #          {"hobby"   => ["patchwork", "bundle jumping"],
        #           "name"    => ["Mary"],
        #           "country" => ["USA"],
        #           "gender"  => ["female"],
        #           "id"      => ["0327614a-dbd8-11dd-80bd-001bfc466dd7"]}}, ... ]
        #     :box_usage =>"0.0000506197"}
        #
        #   sdb.select('select country, name from my_domain') #=>
        #    {:request_id=>"b1600198-c317-413f-a8dc-4e7f864a940a",
        #     :items=>
        #      [ { "035f1ba8-dbd8-11dd-80bd-001bfc466dd7"=> {"name"=>["Mary"],     "country"=>["Russia"]} },
        #        { "376d2e00-75b0-11dd-9557-001bfc466dd7"=> {"name"=>["Putin"],    "country"=>["Russia"]} },
        #        { "0327614a-dbd8-11dd-80bd-001bfc466dd7"=> {"name"=>["Mary"],     "country"=>["USA"]}    },
        #        { "372ebbd4-75b0-11dd-9557-001bfc466dd7"=> {"name"=>["Bush"],     "country"=>["USA"]}    },
        #        { "37a4e552-75b0-11dd-9557-001bfc466dd7"=> {"name"=>["Medvedev"], "country"=>["Russia"]} },
        #        { "38278dfe-75b0-11dd-9557-001bfc466dd7"=> {"name"=>["Mary"],     "country"=>["Russia"]} },
        #        { "37df6c36-75b0-11dd-9557-001bfc466dd7"=> {"name"=>["Mary"],     "country"=>["USA"]}    } ],
        #     :box_usage=>"0.0000777663"}
        #
        # options:
        #     :next_token
        #     :consistent_read
        #     :retries => maximum number of times to retry this query on an error response.
        #
        # see: http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?SDB_API_Select.html
        #      http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?UsingSelect.html
        #      http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?SDBLimits.html
        #
        def select(select_expression, next_token = nil, consistent_read = nil)
            select_expression = query_expression_from_array(select_expression) if select_expression.is_a?(Array)
            @last_query_expression = select_expression

            options                = {}
            if next_token.is_a?(Hash)
                options         = next_token
                next_token      = options[:next_token]
                consistent_read = options[:consistent_read]
            end

            #
            request_params = {'SelectExpression' => select_expression,
                              'NextToken'        => next_token,
                              'ConsistentRead'   => consistent_read}
            link           = generate_request("Select", request_params, options)
            result         = select_response_to_ruby(request_info(link, QSdbSelectParser.new, options))
            return result unless block_given?
            # loop if block if given
            begin
                # the block must return true if it wanna continue
                break unless yield(result) && result[:next_token]
                # make new request
                request_params['NextToken'] = result[:next_token]
                link                        = generate_request("Select", request_params)
                result                      = select_response_to_ruby(request_info(link, QSdbSelectParser.new, options))
            end while true
        rescue Exception
            on_exception
        end

        class Item
            attr_accessor :item_name, :attributes, :replace

            def initialize(item_name, attributes, replace = false)
                @item_name  = item_name
                @attributes = attributes
                @replace    = replace
            end
        end

        #-----------------------------------------------------------------
        #      PARSERS:
        #-----------------------------------------------------------------
        class QSdbListDomainParser < AwsParser #:nodoc:
            def reset
                @result = {:domains => []}
            end

            def tagend(name)
                case name
                    when 'NextToken' then
                        @result[:next_token] = @text
                    when 'DomainName' then
                        @result[:domains] << @text
                    when 'BoxUsage' then
                        @result[:box_usage] = @text
                    when 'RequestId' then
                        @result[:request_id] = @text
                end
            end
        end

        class QSdbDomainMetadataParser < AwsParser #:nodoc:
            def reset
                @result = {}
            end

            def tagend(name)
                case name
                    when 'Timestamp' then
                        @result[:timestamp] = @text
                    when 'ItemCount' then
                        @result[:item_count] = @text.to_i
                    when 'AttributeValueCount' then
                        @result[:attribute_value_count] = @text.to_i
                    when 'AttributeNameCount' then
                        @result[:attribute_name_acount] = @text.to_i
                    when 'ItemNamesSizeBytes' then
                        @result[:item_names_size_bytes] = @text.to_i
                    when 'AttributeValuesSizeBytes' then
                        @result[:attributes_values_size_bytes] = @text.to_i
                    when 'AttributeNamesSizeBytes' then
                        @result[:attributes_names_size_bytes] = @text.to_i

                end
            end
        end


        class QSdbSimpleParser < AwsParser #:nodoc:
            def reset
                @result = {}
            end

            def tagend(name)
                case name
                    when 'BoxUsage' then
                        @result[:box_usage] = @text
                    when 'RequestId' then
                        @result[:request_id] = @text
                end
            end
        end

        class QSdbGetAttributesParser < AwsParser #:nodoc:
            def reset
                @last_attribute_name = nil
                @result              = {:attributes => {}}
            end

            def tagend(name)
                case name
                    when 'Name' then
                        @last_attribute_name = @text
                    when 'Value' then
                        (@result[:attributes][@last_attribute_name] ||= []) << @text
                    when 'BoxUsage' then
                        @result[:box_usage] = @text
                    when 'RequestId' then
                        @result[:request_id] = @text
                end
            end
        end

        class QSdbQueryParser < AwsParser #:nodoc:
            def reset
                @result = {:items => []}
            end

            def tagend(name)
                case name
                    when 'ItemName' then
                        @result[:items] << @text
                    when 'BoxUsage' then
                        @result[:box_usage] = @text
                    when 'RequestId' then
                        @result[:request_id] = @text
                    when 'NextToken' then
                        @result[:next_token] = @text
                end
            end
        end

        class QSdbQueryWithAttributesParser < AwsParser #:nodoc:
            def reset
                @result = {:items => []}
            end

            def tagend(name)
                case name
                    when 'Name'
                        case @xmlpath
                            when 'QueryWithAttributesResponse/QueryWithAttributesResult/Item'
                                @item = @text
                                @result[:items] << {@item => {}}
                            when 'QueryWithAttributesResponse/QueryWithAttributesResult/Item/Attribute'
                                @attribute                              = @text
                                @result[:items].last[@item][@attribute] ||= []
                        end
                    when 'RequestId' then
                        @result[:request_id] = @text
                    when 'BoxUsage' then
                        @result[:box_usage] = @text
                    when 'NextToken' then
                        @result[:next_token] = @text
                    when 'Value' then
                        @result[:items].last[@item][@attribute] << @text
                end
            end
        end

        class QSdbSelectParser < AwsParser #:nodoc:
            def reset
                @result = {:items => []}
            end

            def tagend(name)
                case name
                    when 'Name'
                        case @xmlpath
                            when 'SelectResponse/SelectResult/Item'
                                @item = @text
                                @result[:items] << {@item => {}}
                            when 'SelectResponse/SelectResult/Item/Attribute'
                                @attribute                              = @text
                                @result[:items].last[@item][@attribute] ||= []
                        end
                    when 'RequestId' then
                        @result[:request_id] = @text
                    when 'BoxUsage' then
                        @result[:box_usage] = @text
                    when 'NextToken' then
                        @result[:next_token] = @text
                    when 'Value' then
                        @result[:items].last[@item][@attribute] << @text
                end
            end
        end

    end

end
