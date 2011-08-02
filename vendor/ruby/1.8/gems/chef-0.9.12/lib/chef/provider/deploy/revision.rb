#
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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

class Chef
  class Provider
    class Deploy
      class Revision < Chef::Provider::Deploy
        
        def all_releases
          sorted_releases
        end
        
        protected
        
        def release_created(release)
          sorted_releases {|r| r.delete(release); r << release }
        end
        
        def release_deleted(release)
          sorted_releases { |r| r.delete(release)}
        end
        
        def release_slug
          scm_provider.revision_slug
        end
        
        private
        
        def sorted_releases
          cache = load_cache
          if block_given?
            yield cache
            save_cache(cache)
          end
          cache
        end
        
        def sorted_releases_from_filesystem
          Dir.glob(new_resource.deploy_to + "/releases/*").sort_by { |d| ::File.ctime(d) }
        end

        def load_cache
          begin
            JSON.parse(Chef::FileCache.load("revision-deploys/#{new_resource.name}"))
          rescue Chef::Exceptions::FileNotFound
            sorted_releases_from_filesystem
          end
        end
        
        def save_cache(cache)
          Chef::FileCache.store("revision-deploys/#{new_resource.name}", cache.to_json)
          cache
        end
        
      end
    end
  end
end
