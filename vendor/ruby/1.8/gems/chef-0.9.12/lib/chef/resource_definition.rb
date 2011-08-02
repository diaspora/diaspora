#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require 'chef/mixin/from_file'
require 'chef/mixin/params_validate'

class Chef
  class ResourceDefinition
    
    include Chef::Mixin::FromFile
    include Chef::Mixin::ParamsValidate
    
    attr_accessor :name, :params, :recipe, :node
    
    def initialize(node=nil)
      @name = nil
      @params = Hash.new
      @recipe = nil
      @node = node
    end
    
    def define(resource_name, prototype_params=nil, &block)
      unless resource_name.kind_of?(Symbol)
        raise ArgumentError, "You must use a symbol when defining a new resource!"
      end
      @name = resource_name
      if prototype_params
        unless prototype_params.kind_of?(Hash)
          raise ArgumentError, "You must pass a hash as the prototype parameters for a definition."
        end
        @params = prototype_params
      end
      if Kernel.block_given?
        @recipe = block
      else
        raise ArgumentError, "You must pass a block to a definition."
      end
      true
    end
    
    # When we do the resource definition, we're really just setting new values for
    # the paramaters we prototyped at the top.  This method missing is as simple as
    # it gets.
    def method_missing(symbol, *args)
      @params[symbol] = args.length == 1 ? args[0] : args
    end
    
    def to_s
      "#{name.to_s}"
    end
  end
end
