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

# == Tempfile (Patch)
# Tempfile has a horrible bug where it causes an IOError: closed stream in its
# finalizer, leading to intermittent application crashes with confusing stack
# traces. Here we monkey patch the fix into place. You can track the bug on
# ruby's redmine: http://redmine.ruby-lang.org/issues/show/3119
#
# The patch is slightly different for Ruby 1.8 and Ruby 1.9, both patches are
# included here.
class Tempfile # :nodoc:
  # Tempfile has changes between 1.8.x and 1.9.x
  # so we monkey patch separately
  if RUBY_VERSION =~ /^1\.8/
    def unlink
      # keep this order for thread safeness
      begin
        File.unlink(@tmpname) if File.exist?(@tmpname)
        @@cleanlist.delete(@tmpname)
        @tmpname = nil
        ObjectSpace.undefine_finalizer(self)
      rescue Errno::EACCES
        # may not be able to unlink on Windows; just ignore
      end
    end
    alias delete unlink


  # There is a patch for this, to be merged into 1.9 at some point.
  # When that happens, we'll want to also check the RUBY_PATCHLEVEL
  elsif RUBY_VERSION =~ /^1\.9/
    def unlink
      # keep this order for thread safeness
      return unless @tmpname
      begin
        if File.exist?(@tmpname)
          File.unlink(@tmpname)
        end
        # remove tmpname from remover
        @data[0] = @data[2] = nil
        @tmpname = nil
      rescue Errno::EACCES
        # may not be able to unlink on Windows; just ignore
      end
    end
    alias delete unlink
  end
end
