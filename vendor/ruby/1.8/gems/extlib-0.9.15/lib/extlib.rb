require 'pathname'

require 'extlib/pathname'
require 'extlib/class.rb'
require 'extlib/object'
require 'extlib/object_space'
require 'extlib/local_object_space'
require 'extlib/array'
require 'extlib/string'
require 'extlib/symbol'
require 'extlib/hash'
require 'extlib/mash'
require 'extlib/virtual_file'
require 'extlib/logger'
require 'extlib/time'
require 'extlib/datetime'
require 'extlib/assertions'
require 'extlib/blank'
require 'extlib/boolean'
require 'extlib/byte_array'
require 'extlib/inflection'
require 'extlib/lazy_array'
require 'extlib/module'
require 'extlib/nil'
require 'extlib/numeric'
require 'extlib/blank'
require 'extlib/simple_set'
require 'extlib/struct'
require 'extlib/symbol'
require 'extlib/try_dup'

Extlib.autoload('Hook', 'extlib/hook')
Extlib.autoload('Pooling', 'extlib/pooling')

module Extlib

  def self.exiting= bool
    if bool && Extlib.const_defined?('Pooling')
      if Extlib::Pooling.scavenger?
        Extlib::Pooling.scavenger.wakeup
      end
    end
    @exiting = true
  end

  def self.exiting
    return @exiting if defined?(@exiting)
    @exiting = false
  end

end
