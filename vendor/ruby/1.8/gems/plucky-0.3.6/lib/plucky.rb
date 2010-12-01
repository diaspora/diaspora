# encoding: UTF-8
require 'set'
require 'mongo'
require 'plucky/extensions'

module Plucky
  autoload :CriteriaHash, 'plucky/criteria_hash'
  autoload :OptionsHash,  'plucky/options_hash'
  autoload :Query,        'plucky/query'
  autoload :Version,      'plucky/version'

  module Pagination
    autoload :Decorator,  'plucky/pagination/decorator'
    autoload :Paginator,  'plucky/pagination/paginator'
  end

  def self.to_object_id(value)
    if value.nil? || (value.respond_to?(:empty?) && value.empty?)
      nil
    elsif value.is_a?(BSON::ObjectId)
      value
    else
      BSON::ObjectId.from_string(value.to_s)
    end
  end
end
