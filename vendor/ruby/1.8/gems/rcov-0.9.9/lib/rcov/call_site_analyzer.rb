module Rcov
  # A CallSiteAnalyzer can be used to obtain information about:
  # * where a method is defined ("+defsite+")
  # * where a method was called from ("+callsite+")
  #
  # == Example
  # <tt>example.rb</tt>:
  #  class X
  #    def f1; f2 end
  #    def f2; 1 + 1 end
  #    def f3; f1 end
  #  end
  #
  #  analyzer = Rcov::CallSiteAnalyzer.new
  #  x = X.new
  #  analyzer.run_hooked do 
  #    x.f1 
  #  end
  #  # ....
  #  
  #  analyzer.run_hooked do 
  #    x.f3
  #    # the information generated in this run is aggregated
  #    # to the previously recorded one
  #  end
  #
  #  analyzer.analyzed_classes        # => ["X", ... ]
  #  analyzer.methods_for_class("X")  # => ["f1", "f2", "f3"]
  #  analyzer.defsite("X#f1")         # => DefSite object
  #  analyzer.callsites("X#f2")       # => hash with CallSite => count
  #                                   #    associations
  #  defsite = analyzer.defsite("X#f1")
  #  defsite.file                     # => "example.rb"
  #  defsite.line                     # => 2
  #
  # You can have several CallSiteAnalyzer objects at a time, and it is
  # possible to nest the #run_hooked / #install_hook/#remove_hook blocks: each
  # analyzer will manage its data separately. Note however that no special
  # provision is taken to ignore code executed "inside" the CallSiteAnalyzer
  # class. 
  #
  # +defsite+ information is only available for methods that were called under
  # the inspection of the CallSiteAnalyzer, i.o.w. you will only have +defsite+
  # information for those methods for which callsite information is
  # available.
  class CallSiteAnalyzer < DifferentialAnalyzer
    # A method definition site.
    class DefSite < Struct.new(:file, :line)
    end

    # Object representing a method call site.
    # It corresponds to a part of the callstack starting from the context that
    # called the method.   
    class CallSite < Struct.new(:backtrace)
      # The depth of a CallSite is the number of stack frames
      # whose information is included in the CallSite object.
      def depth
        backtrace.size
      end

      # File where the method call originated.
      # Might return +nil+ or "" if it is not meaningful (C extensions, etc).
      def file(level = 0)
        stack_frame = backtrace[level]
        stack_frame ? stack_frame[2] : nil
      end

      # Line where the method call originated.
      # Might return +nil+ or 0 if it is not meaningful (C extensions, etc).
      def line(level = 0)
        stack_frame = backtrace[level]
        stack_frame ? stack_frame[3] : nil
      end

      # Name of the method where the call originated.
      # Returns +nil+ if the call originated in +toplevel+.
      # Might return +nil+ if it could not be determined.
      def calling_method(level = 0)
        stack_frame = backtrace[level]
        stack_frame ? stack_frame[1] : nil
      end

      # Name of the class holding the method where the call originated.
      # Might return +nil+ if it could not be determined.
      def calling_class(level = 0)
        stack_frame = backtrace[level]
        stack_frame ? stack_frame[0] : nil
      end
    end

    @hook_level = 0
    # defined this way instead of attr_accessor so that it's covered
    def self.hook_level      # :nodoc:
      @hook_level
    end

    def self.hook_level=(x)  # :nodoc:
      @hook_level = x
    end

    def initialize
      super(:install_callsite_hook, :remove_callsite_hook,
            :reset_callsite)
    end

    # Classes whose methods have been called.
    # Returns an array of strings describing the classes (just klass.to_s for
    # each of them). Singleton classes are rendered as:
    #   #<Class:MyNamespace::MyClass>
    def analyzed_classes
      raw_data_relative.first.keys.map{|klass, meth| klass}.uniq.sort
    end

    # Methods that were called for the given class. See #analyzed_classes for
    # the notation used for singleton classes.
    # Returns an array of strings or +nil+
    def methods_for_class(classname)
      a = raw_data_relative.first.keys.select{|kl,_| kl == classname}.map{|_,meth| meth}.sort
      a.empty? ? nil : a
    end
    alias_method :analyzed_methods, :methods_for_class

    # Returns a hash with <tt>CallSite => call count</tt> associations or +nil+
    # Can be called in two ways:
    #   analyzer.callsites("Foo#f1")         # instance method
    #   analyzer.callsites("Foo.g1")         # singleton method of the class
    # or
    #   analyzer.callsites("Foo", "f1")
    #   analyzer.callsites("#<class:Foo>", "g1")
    def callsites(classname_or_fullname, methodname = nil)
      rawsites = raw_data_relative.first[expand_name(classname_or_fullname, methodname)]
      return nil unless rawsites
      ret = {}
      # could be a job for inject but it's slow and I don't mind the extra loc
      rawsites.each_pair do |backtrace, count|
        ret[CallSite.new(backtrace)] = count
      end
      ret
    end

    # Returns a DefSite object corresponding to the given method
    # Can be called in two ways:
    #   analyzer.defsite("Foo#f1")         # instance method
    #   analyzer.defsite("Foo.g1")         # singleton method of the class
    # or
    #   analyzer.defsite("Foo", "f1")
    #   analyzer.defsite("#<class:Foo>", "g1")
    def defsite(classname_or_fullname, methodname = nil)
      file, line = raw_data_relative[1][expand_name(classname_or_fullname, methodname)]
      return nil unless file && line
      DefSite.new(file, line)
    end

    private

    def expand_name(classname_or_fullname, methodname = nil)
      if methodname.nil?
        case classname_or_fullname
        when /(.*)#(.*)/ then classname, methodname = $1, $2
        when /(.*)\.(.*)/ then classname, methodname = "#<Class:#{$1}>", $2
        else
          raise ArgumentError, "Incorrect method name"
        end

        return [classname, methodname]
      end

      [classname_or_fullname, methodname]
    end

    def data_default; [{}, {}] end

    def raw_data_absolute
      raw, method_def_site = RCOV__.generate_callsite_info
      ret1 = {}
      ret2 = {}
      raw.each_pair do |(klass, method), hash|
        begin  
          key = [klass.to_s, method.to_s]
          ret1[key] = hash.clone #Marshal.load(Marshal.dump(hash))
          ret2[key] = method_def_site[[klass, method]]
        #rescue Exception
        end
      end

      [ret1, ret2]
    end

    def aggregate_data(aggregated_data, delta)
      callsites1, defsites1 = aggregated_data
      callsites2, defsites2 = delta
    
      callsites2.each_pair do |(klass, method), hash|
        dest_hash = (callsites1[[klass, method]] ||= {})
        hash.each_pair do |callsite, count|
          dest_hash[callsite] ||= 0
          dest_hash[callsite] += count
        end
      end

      defsites1.update(defsites2)
    end

    def compute_raw_data_difference(first, last)
      difference = {}
      default = Hash.new(0)

      callsites1, defsites1 = *first
      callsites2, defsites2 = *last

      callsites2.each_pair do |(klass, method), hash|
        old_hash = callsites1[[klass, method]] || default
        hash.each_pair do |callsite, count|
          diff = hash[callsite] - (old_hash[callsite] || 0)
          if diff > 0
            difference[[klass, method]] ||= {}
            difference[[klass, method]][callsite] = diff
          end
        end
      end

      [difference, defsites1.update(defsites2)]
    end
  end
end