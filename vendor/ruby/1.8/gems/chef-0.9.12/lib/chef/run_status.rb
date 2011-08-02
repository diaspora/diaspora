#
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

# == Chef::RunStatus
# Tracks various aspects of a Chef run, including the Node and RunContext,
# start and end time, and any Exception that stops the run. RunStatus objects
# are passed to any notification or exception handlers at the completion of a
# Chef run.
class Chef::RunStatus

  attr_reader :run_context

  attr_writer :run_context

  attr_reader :start_time

  attr_reader :end_time

  attr_reader :exception

  attr_writer :exception

  def initialize(node)
    @node = node
  end

  def node
    @node
  end

  # sets +start_time+ to the current time.
  def start_clock
    @start_time = Time.now
  end

  # sets +end_time+ to the current time
  def stop_clock
    @end_time = Time.now
  end

  # The elapsed time between +start_time+ and +end_time+. Returns +nil+ if
  # either value is not set.
  def elapsed_time
    if @start_time && @end_time
      @end_time - @start_time
    else
      nil
    end
  end

  # The list of all resources in the current run context's +resource_collection+
  def all_resources
    @run_context && @run_context.resource_collection.all_resources
  end

  # The list of all resources in the current run context's +resource_collection+
  # that are marked as updated
  def updated_resources
    @run_context && @run_context.resource_collection.select { |r| r.updated }
  end

  # The backtrace from +exception+, if any
  def backtrace
    @exception && @exception.backtrace
  end

  # Did the Chef run fail?
  def failed?
    !success?
  end

  # Did the chef run succeed? returns +true+ if no exception has been set.
  def success?
    @exception.nil?
  end

  # A Hash representation of the RunStatus, with the following (Symbol) keys:
  # * :node
  # * :success
  # * :start_time
  # * :end_time
  # * :elapsed_time
  # * :all_resources
  # * :updated_resources
  # * :exception
  # * :backtrace
  def to_hash
    # use a flat hash here so we can't errors from intermediate values being nil
    { :node => node,
      :success => success?,
      :start_time => start_time,
      :end_time => end_time,
      :elapsed_time => elapsed_time,
      :all_resources => all_resources,
      :updated_resources => updated_resources,
      :exception => formatted_exception,
      :backtrace => backtrace}
  end

  # Returns a string of the format "ExceptionClass: message" or +nil+ if no
  # +exception+ is set.
  def formatted_exception
    @exception && "#{@exception.class.name}: #{@exception.message}"
  end

end