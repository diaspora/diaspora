#--
# Fallback classes for default behavior of DBD driver
# must be inherited by the DBD driver classes
#++
module DBI
    class Base #:nodoc:
    end
end

require 'dbi/base_classes/driver'
require 'dbi/base_classes/database'
require 'dbi/base_classes/statement'
