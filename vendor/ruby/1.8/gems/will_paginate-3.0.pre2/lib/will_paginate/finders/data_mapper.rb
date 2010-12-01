require 'will_paginate/finders/base'
require 'dm-core'

module WillPaginate::Finders
  module DataMapper
    include WillPaginate::Finders::Base

  protected
    
    def wp_query(options, pager, args, &block) #:nodoc
      find_options = options.except(:count).update(:offset => pager.offset, :limit => pager.per_page) 

      pager.replace all(find_options, &block)
      
      unless pager.total_entries
        pager.total_entries = wp_count(options)
      end
    end

    def wp_count(options) #:nodoc
      count_options = options.except(:count, :order)
      # merge the hash found in :count
      count_options.update options[:count] if options[:count]

      count_options.empty?? count() : count(count_options)
    end
  end
end

DataMapper::Model.send(:include, WillPaginate::Finders::DataMapper)
