require 'will_paginate/finders/base'
require 'active_resource'

module WillPaginate::Finders
  # Paginate your ActiveResource models.
  # 
  #   @posts = Post.paginate :all, :params => {
  #              :page => params[:page], :order => 'created_at DESC'
  #            }
  # 
  module ActiveResource
    include WillPaginate::Finders::Base
    
  protected
  
    def wp_query(options, pager, args, &block) #:nodoc:
      unless args.empty? or args.first == :all
        raise ArgumentError, "finder arguments other than :all are not supported for pagination (#{args.inspect} given)"
      end
      params = (options[:params] ||= {})
      params[:page] = pager.current_page
      params[:per_page] = pager.per_page
      
      pager.replace find_every(options, &block)
    end
    
    # Takes the format that Hash.from_xml produces out of an unknown type
    # (produced by WillPaginate::Collection#to_xml_with_collection_type), 
    # parses it into a WillPaginate::Collection,
    # and forwards the result to the former +instantiate_collection+ method.
    # It only does this for hashes that have a :type => "collection".
    def instantiate_collection_with_collection(collection, prefix_options = {}) #:nodoc:
      if collection.is_a?(Hash) && collection["type"] == "collection"
        collectables = collection.values.find{ |c| c.is_a?(Hash) || c.is_a?(Array) }
        collectables = [collectables].compact unless collectables.kind_of?(Array)
        instantiated_collection = WillPaginate::Collection.create(collection["current_page"], collection["per_page"], collection["total_entries"]) do |pager|
          pager.replace instantiate_collection_without_collection(collectables, prefix_options)
        end
      else
        instantiate_collection_without_collection(collection, prefix_options)
      end
    end
  end
end

ActiveResource::Base.class_eval do
  extend WillPaginate::Finders::ActiveResource
  class << self
    # alias_method_chain :instantiate_collection, :collection
  end
end