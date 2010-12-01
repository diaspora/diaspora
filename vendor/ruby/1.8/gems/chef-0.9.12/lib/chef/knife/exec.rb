#--
# Author:: Daniel DeLeo (<dan@opscode.com)
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

require 'chef/knife'

class Chef::Knife::Exec < Chef::Knife

  banner "knife exec [SCRIPT] (options)"

  option :exec,
    :short => "-E CODE",
    :long => "--exec CODE",
    :description => "a string of Chef code to execute"

  def late_load_deps
    require 'chef/shef/ext'
  end

  def run
    late_load_deps
    scripts = Array(name_args)
    context = Object.new
    Shef::Extensions.extend_context_object(context)
    if config[:exec]
      context.instance_eval(config[:exec], "-E Argument", 0)
    elsif !scripts.empty?
      scripts.each do |script|
        file = File.expand_path(script)
        context.instance_eval(IO.read(file), file, 0)
      end
    else
      script = STDIN.read
      context.instance_eval(script, "STDIN", 0)
    end
  end
  
end