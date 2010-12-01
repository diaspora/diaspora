#
# Author:: James Gartrell (<jgartrel@gmail.com>)
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

class String
  # Add string function to handle WMI property conversion to json hash keys
  # Makes an underscored, lowercase form from the expression in the string.
  # underscore will also change ’::’ to ’/’ to convert namespaces to paths. 
  # This should implement the same functionality as underscore method in
  # ActiveSupport::CoreExtensions::String::Inflections
  def wmi_underscore
     self.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
     gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end
end
