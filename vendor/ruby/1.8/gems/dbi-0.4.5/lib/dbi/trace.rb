# $Id: trace.rb,v 1.1 2006/01/04 02:03:22 francis Exp $
# 
# Tracing for DBI programs
# 
# Copyright (c) 2001 Michael Neumann
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

raise LoadError, "the trace module has been removed until it actually works."

# works only correct with the newest version > 0.3.3
require "aspectr"
require "dbi"      # to work as "ruby -r dbi/trace myapp.rb"

module DBI

class HandleTracer < AspectR::Aspect

  def initialize(klass)
    @never_wrap = /^__|^send$|^id$|^class$|^$ /
    self.wrap(klass, :pre, :post, methods(klass)) 
  end

  # trace methods -------------------------------------------------------------- 

  def pre(method, object, exitstatus, *args)
    
    par = args.collect{|a| a.inspect}.join(", ")

    if object.trace_mode == 2 then
      object.trace_output << "-> #{method} for #{object} (#{par})\n"
    elsif object.trace_mode == 3 then
      object.trace_output << "-> #{method} for #{object.inspect} (#{par})\n"
    end
  end

  def post(method, object, exitstatus, *args)

    case object.trace_mode
    when 1, 2 # return values and errors
      arrow = object.trace_mode == 1 ? "<=" : "<-"
      if exitstatus.kind_of? Array
        object.trace_output << "#{arrow} #{method} for #{object} = #{exitstatus[0] || 'nil'}\n" 
      else
        if exitstatus == true
          object.trace_output << "!! #{$!.message.chomp}\n" 
        end
        object.trace_output << "#{arrow} #{method} for #{object}\n"
      end
 
    when 3
      if exitstatus.kind_of? Array
        object.trace_output << "<- #{method} for #{object.inspect} = #{exitstatus[0].inspect}\n" 
      else
        if exitstatus == true
          object.trace_output << "!! #{$!.inspect}\n" 
        end
        object.trace_output << "<- #{method} for #{object.inspect}\n"
      end
    end
  
  end

  private # helper methods -----------------------------------------------------

  def methods(klass)
    meths = (DBI::Handle.instance_methods | klass.instance_methods) - %w(trace_mode trace_output trace)
    /(#{meths.collect{|m| Regexp.quote(m)}.join('|')})/
  end

end

@@tracer_driver    = HandleTracer.new(DBI::DriverHandle)
@@tracer_database  = HandleTracer.new(DBI::DatabaseHandle)
@@tracer_statement = HandleTracer.new(DBI::StatementHandle)

 
end # module DBI
  
