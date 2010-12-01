#
# Author:: Benjamin Black (<nostromo@gmail.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

provides "kernel/os"

kernel[:os] = from("uname -s")

modules = Mash.new

popen4("modinfo") do |pid, stdin, stdout, stderr|
  stdin.close
  
  # EXAMPLE:
  # Id Loadaddr   Size Info Rev Module Name
  #  6  1180000   4623   1   1  specfs (filesystem for specfs)
  module_description =  /[\s]*([\d]+)[\s]+([a-f\d]+)[\s]+([a-f\d]+)[\s]+(?:[\-\d]+)[\s]+(?:[\d]+)[\s]+([\S]+)[\s]+\((.+)\)$/
  stdout.each do |line|
    if mod = module_description.match(line)
      modules[mod[4]] = { :id => mod[1].to_i, :loadaddr => mod[2], :size => mod[3].to_i(16), :description => mod[5]}
    end
  end
end

kernel[:modules] = modules

