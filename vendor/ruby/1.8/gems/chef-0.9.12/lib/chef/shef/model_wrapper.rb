#--
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
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
#

require 'chef/mixin/convert_to_class_name'
require 'chef/mixin/language'

module Shef
  class ModelWrapper

    include Chef::Mixin::ConvertToClassName

    attr_reader :model_symbol

    def initialize(model_class, symbol=nil)
      @model_class = model_class
      @model_symbol = symbol || convert_to_snake_case(model_class.name, "Chef").to_sym
    end

    def search(query)
      return all if query.to_s == "all"
      results = []
      Chef::Search::Query.new.search(@model_symbol, format_query(query)) do |obj|
        if block_given?
          results << yield(obj)
        else
          results << obj
        end
      end
      results
    end

    alias :find :search

    def all(&block)
      all_objects = list_objects
      block_given? ? all_objects.map(&block) : all_objects
    end

    alias :list :all

    def show(obj_id)
      @model_class.load(obj_id)
    end

    alias :load :show

    def transform(what_to_transform, &block)
      if what_to_transform == :all
        objects_to_transform = list_objects
      else
        objects_to_transform = search(what_to_transform)
      end
      objects_to_transform.each do |obj|
        if result = yield(obj)
          obj.save
        end
      end
    end

    alias :bulk_edit :transform

    private

    # paper over inconsistencies in the model classes APIs, and return the objects
    # the user wanted instead of the URI=>object stuff
    def list_objects
      objects = @model_class.method(:list).arity == 0? @model_class.list : @model_class.list(true)
      objects.map { |obj| Array(obj).find {|o| o.kind_of?(@model_class)} }
    end

    def format_query(query)
      if query.respond_to?(:keys)
        query.map { |key, value| "#{key}:#{value}" }.join(" AND ")
      else
        query
      end
    end
  end

  class NamedDataBagWrapper < ModelWrapper

    def initialize(databag_name)
      @model_symbol = @databag_name = databag_name
    end


    alias :list :all

    def show(item)
      Chef::DataBagItem.load(@databag_name, item)
    end

    private

    def list_objects
      all_items = []
      Chef::Search::Query.new.search(@databag_name) do |item|
        all_items << item
      end
      all_items
    end

  end

end