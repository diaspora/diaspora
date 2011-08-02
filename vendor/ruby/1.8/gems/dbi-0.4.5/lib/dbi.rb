$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
#
# DBI - Database Interface for Ruby. Please see the files README, DBI_SPEC,
# DBD_SPEC for more information.
#
module DBI; end
#--
# Ruby/DBI
#
# Copyright (c) 2001, 2002, 2003 Michael Neumann <mneumann@ntecs.de>
# Copyright (c) 2008 Erik Hollensbe <erik@hollensbe.org>
# 
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions 
# are met:
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright 
#    notice, this list of conditions and the following disclaimer in the 
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
# THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

begin
    require "rubygems"
    gem "deprecated", "= 2.0.1"
rescue LoadError
end

#
# NOTE see the end of the file for requires that live in the DBI namespace.
#

require "deprecated"
require "dbi/row"
require "dbi/utils"
require "dbi/sql"
require "dbi/columninfo"
require 'dbi/types'
require 'dbi/typeutil'
require 'dbi/sql_type_constants'
require 'dbi/exceptions'
require 'dbi/binary'
require 'dbi/handles'
require 'dbi/base_classes'
require "date"
require "thread"
require 'monitor'

class Class
    # Given a Class, returns if the object's (another Class) ancestors contain
    # that class.
    def inherits_from?(klass)
        self.ancestors.include?(klass)
    end
end

Deprecate.set_action(
    proc do |call|
        klass, meth = call.split(/[#.]/)
        klass = klass.split(/::/).inject(Module) { |a,x| a.const_get(x) }

        case klass
        when DBI::Date, DBI::Time, DBI::Timestamp
            warn "DBI::Date/Time/Timestamp are deprecated and will eventually be removed."
        end

        if klass.inherits_from?(DBI::ColumnInfo)
            warn "ColumnInfo methods that do not match a component are deprecated and will eventually be removed"
        end

        warn "You may change the result of calling deprecated code via Deprecate.set_action; Trace follows:"
        warn caller[2..-1].join("\n")
    end
)

#++
module DBI
    VERSION = "0.4.5"

    module DBD # :nodoc:
        API_VERSION = "0.3"
    end

    #  Module functions (of DBI)
    DEFAULT_TRACE_MODE = 2
    DEFAULT_TRACE_OUTPUT = STDERR

    # TODO: Is using class variables within a module such a wise idea? - Dan B.
    @@driver_map     = Hash.new
    @@driver_monitor = ::Monitor.new()
    @@trace_mode     = DEFAULT_TRACE_MODE
    @@trace_output   = DEFAULT_TRACE_OUTPUT
    @@caseless_driver_name_map = nil
    @@convert_types  = true
    @@last_connection = nil

    # Return the last connection attempted.
    def self.last_connection
        @@last_connection
    end

    # Return the current status of type conversion at this level. This status
    # will be propogated to any new DatabaseHandles created.
    def self.convert_types
        @@convert_types
    end

    # Set the current status of type conversion at this level. This status
    # will be propogated to any new DatabaseHandles created.
    def self.convert_types=(bool)
        @@convert_types = bool
    end

    class << self

        # Establish a database connection.  
        #
        # Format goes as such: "dbi:Driver:database_conn_args"
        #
        # * "dbi" is the literal string "dbi". Case is unimportant.
        # * "Driver" is the case-dependent name of your database driver class.
        #   The file "dbd/#{Driver}" will be required. If you are using rubygems to
        #   control your DBDs and DBI, you must make the gem's file path available
        #   via the "gem" command before this will work.
        # * database_conn_args can be:
        #   * The database name.
        #   * A more complex key/value association (to indicate host, etc). This
        #     is driver dependent; you should consult your DBD documentation.
        def connect(driver_url, user=nil, auth=nil, params=nil, &p)
            dr, db_args = _get_full_driver(driver_url)
            dh = dr[0] # driver-handle
            dh.convert_types = @@convert_types
            @@last_connection = dh.connect(db_args, user, auth, params, &p)
        end

        # Load a DBD and returns the DriverHandle object
        def get_driver(driver_url) #:nodoc:
            _get_full_driver(driver_url)[0][0]  # return DriverHandle
        end

        # Extracts the db_args from driver_url and returns the correspondeing
        # entry of the @@driver_map.
        def _get_full_driver(driver_url) #:nodoc:
            db_driver, db_args = parse_url(driver_url)
            db_driver = load_driver(db_driver)
            dr = @@driver_map[db_driver]
            [dr, db_args]
        end

        #
        # Enable tracing mode. Requires that 'dbi/trace' be required before it does anything.
        #
        # As of 0.4.0, this mode does not do anything either way, so this currently just
        # throws an InterfaceError. This issue is expected to be resolved in the next release.
        #
        def trace(mode=nil, output=nil)
            # FIXME trace
            raise InterfaceError, "the trace module has been removed until it actually works."
            @@trace_mode   = mode   || @@trace_mode   || DBI::DEFAULT_TRACE_MODE
            @@trace_output = output || @@trace_output || DBI::DEFAULT_TRACE_OUTPUT
        end

        #
        # Return a list (of String) of the available drivers.
        #
        # NOTE:: This is non-functional for gem installations, due to the
        #        nature of how it currently works. A better solution for 
        #        this will be provided in DBI 0.6.0.
        def collect_drivers
            drivers = { }
            # FIXME rewrite this to leverage require and be more intelligent
            path = File.join(File.dirname(__FILE__), "dbd", "*.rb")
            Dir[path].each do |f|
                if File.file?(f)
                    driver = File.basename(f, ".rb")
                    drivers[driver] = f
                end
            end

            return drivers
        end

        # Returns a list (of String) of the currently available drivers on your system in
        # 'dbi:driver:' format.
        #
        # This currently does not work for rubygems installations, please see
        # DBI.collect_drivers for reasons.
        def available_drivers
            drivers = []
            collect_drivers.each do |key, value|
                drivers.push("dbi:#{key}:")
            end 
            return drivers
        end

        # Attempt to collect the available data sources to the driver,
        # specified in DBI.connect format.
        #
        # The result is heavily dependent on the driver's ability to enumerate
        # these sources, and results will vary.
        def data_sources(driver)
            db_driver, = parse_url(driver)
            db_driver = load_driver(db_driver)
            dh = @@driver_map[db_driver][0]
            dh.data_sources
        end

        #
        # Attempt to disconnect all database handles. If a driver is provided,
        # disconnections will happen under that scope. Otherwise, all loaded
        # drivers (and their handles) will be attempted.
        #
        def disconnect_all( driver = nil )
            if driver.nil?
                @@driver_map.each {|k,v| v[0].disconnect_all}
            else
                db_driver, = parse_url(driver)
                @@driver_map[db_driver][0].disconnect_all
            end
        end

        private

        # Given a driver name, locate and load the associated DBD package,
        # generate a DriverHandle and return it.
        def load_driver(driver_name)
            @@driver_monitor.synchronize do
                unless @@driver_map[driver_name]
                    dc = driver_name.downcase

                    # caseless look for drivers already loaded
                    found = @@driver_map.keys.find {|key| key.downcase == dc}
                    return found if found

                    begin
                        require "dbd/#{driver_name}"
                    rescue LoadError => e1
                        # see if you can find it in the path
                        unless @@caseless_driver_name_map
                            @@caseless_driver_name_map = { } 
                            collect_drivers.each do |key, value|
                                @@caseless_driver_name_map[key.downcase] = value
                            end
                        end

                        begin
                            require @@caseless_driver_name_map[dc] if @@caseless_driver_name_map[dc]
                        rescue LoadError => e2
                            raise e1.class, "Could not find driver #{driver_name} or #{driver_name.downcase} (error: #{e1.message})"
                        end
                    end

                    # On a filesystem that is not case-sensitive (e.g., HFS+ on Mac OS X),
                    # the initial require attempt that loads the driver may succeed even
                    # though the lettercase of driver_name doesn't match the actual
                    # filename. If that happens, const_get will fail and it become
                    # necessary to look though the list of constants and look for a
                    # caseless match.  The result of this match provides the constant
                    # with the proper lettercase -- which can be used to generate the
                    # driver handle.

                    dr = nil
                    dr_error = nil
                    begin
                        dr = DBI::DBD.const_get(driver_name.intern)
                    rescue NameError => dr_error
                        # caseless look for constants to find actual constant
                        dc = driver_name.downcase
                        found = DBI::DBD.constants.find { |e| e.downcase == dc }
                        dr = DBI::DBD.const_get(found.intern) unless found.nil?
                    end

                    # If dr is nil at this point, it means the underlying driver
                    # failed to load.  This usually means it's not installed, but
                    # can fail for other reasons.
                    if dr.nil?
                        err = "Unable to load driver '#{driver_name}'"

                        if dr_error
                            err += " (underlying error: #{dr_error.message})"
                        else
                            err += " (BUG: could not determine underlying error)"
                        end

                        raise DBI::InterfaceError, err
                    end

                    dbd_dr = dr::Driver.new
                    drh = DBI::DriverHandle.new(dbd_dr, @@convert_types)
                    drh.driver_name = dr.driver_name
                    # FIXME trace
                    # drh.trace(@@trace_mode, @@trace_output)
                    @@driver_map[driver_name] = [drh, dbd_dr]
                    return driver_name 
                else
                    return driver_name
                end
            end
        rescue LoadError, NameError
            if $SAFE >= 1
                raise InterfaceError, "Could not load driver (#{$!.message}). Note that in SAFE mode >= 1, driver URLs have to be case sensitive!"
            else
                raise InterfaceError, "Could not load driver (#{$!.message})"
            end
        end

        # Splits a DBI URL into two components - the database driver name
        # and the datasource (along with any options, if any) and returns
        # a two element array, e.g. 'dbi:foo:bar' would return ['foo','bar'].
        #
        # A regular expression is used instead of a simple split to validate
        # the proper format for the URL.  If it isn't correct, an Interface
        # error is raised.
        def parse_url(driver_url)
            if driver_url =~ /^(DBI|dbi):([^:]+)(:(.*))$/ 
                [$2, $4]
            else
                raise InterfaceError, "Invalid Data Source Name"
            end
        end
    end # self
end # module DBI
