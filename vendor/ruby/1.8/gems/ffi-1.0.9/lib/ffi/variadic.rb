#
# Copyright (C) 2008, 2009 Wayne Meissner
# Copyright (C) 2009 Luc Heinrich
# All rights reserved.
#
# This file is part of ruby-ffi.
#
# This code is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License version 3 only, as
# published by the Free Software Foundation.
#
# This code is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
# version 3 for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# version 3 along with this work.  If not, see <http://www.gnu.org/licenses/>.

module FFI
  class VariadicInvoker    
    def init(arg_types, type_map)
      @fixed = Array.new
      @type_map = type_map
      arg_types.each_with_index do |type, i|
        @fixed << type unless type == Type::VARARGS
      end
    end


    def call(*args, &block)
      param_types = Array.new(@fixed)
      param_values = Array.new
      @fixed.each_with_index do |t, i|
        param_values << args[i]
      end
      i = @fixed.length
      while i < args.length
        param_types << FFI.find_type(args[i], @type_map)
        param_values << args[i + 1]
        i += 2
      end
      invoke(param_types, param_values, &block)
    end

    #
    # Attach the invoker to module +mod+ as +mname+
    #
    def attach(mod, mname)
      invoker = self
      params = "*args"
      call = "call"
      mod.module_eval <<-code
      @@#{mname} = invoker
      def self.#{mname}(#{params})
        @@#{mname}.#{call}(#{params})
      end
      def #{mname}(#{params})
        @@#{mname}.#{call}(#{params})
      end
      code
      invoker
    end
  end
end