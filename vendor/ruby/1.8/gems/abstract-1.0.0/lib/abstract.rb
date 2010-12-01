##
## $Rev: 1 $
## $Release: 1.0.0 $
## copyright(c) 2006 kuwata-lab.com all rights reserved.
##
##
## helper to define abstract method in Ruby.
##
##
## example1. (shorter notation)
##
##   require 'abstract'
##   class Foo
##     abstract_method 'arg1, arg2=""', :method1, :method2, :method3
##   end
##
##
## example2. (RDoc friendly notation)
##
##   require 'abstract'
##   class Bar
##     # ... method1 description ...
##     def method1(arg1, arg2="")
##       not_implemented
##     end
##
##     # ... method2 description ...
##     def method2(arg1, arg2="")
##       not_implemented
##     end
##   end
##


##
class Module

  ##
  ## define abstract methods
  ##
  def abstract_method args_str, *method_names
    method_names.each do |name|
      module_eval <<-END
        def #{name}(#{args_str})
          mesg = "class \#{self.class.name} must implement abstract method `#{self.name}##{name}()'."
          #mesg = "\#{self.class.name}##{name}() is not implemented."
          err = NotImplementedError.new mesg
          err.set_backtrace caller()
          raise err
        end
      END
    end
  end

end


##
module Kernel

  ##
  ## raise NotImplementedError
  ##
  def not_implemented     #:doc:
    backtrace = caller()
    method_name = (backtrace.shift =~ /`(\w+)'$/) && $1
    mesg = "class #{self.class.name} must implement abstract method '#{method_name}()'."
    #mesg = "#{self.class.name}##{method_name}() is not implemented."
    err = NotImplementedError.new mesg
    err.set_backtrace backtrace
    raise err
  end
  private :not_implemented

end
