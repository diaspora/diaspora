# rcov Copyright (c) 2004-2006 Mauricio Fernandez <mfp@acm.org>
#
# See LEGAL and LICENSE for licensing information.

require 'rcov/version'

module Rcov

# RCOV__ performs the low-level tracing of the execution, gathering code
# coverage information in the process. The C core made available through the
# rcovrt extension will be used if possible. Otherwise the functionality
# will be emulated using set_trace_func, but this is very expensive and
# will fail if other libraries (e.g. breakpoint) change the trace_func.
#
# Do not use this module; it is very low-level and subject to frequent
# changes. Rcov::CodeCoverageAnalyzer offers a much more convenient and
# stable interface.

module RCOV__
  COVER = {}
  CALLSITES = {}
  DEFSITES = {}
  pure_ruby_impl_needed = true
  unless defined? $rcov_do_not_use_rcovrt 
    begin
      require 'rcovrt'
      abi = [0,0,0]
      begin
        abi = RCOV__.ABI
        raise if abi[0] != RCOVRT_ABI[0] || abi[1] < RCOVRT_ABI[1]
        pure_ruby_impl_needed = false
      rescue
        $stderr.puts <<-EOF
The rcovrt extension I found was built for a different version of rcov.
The required ABI is:              #{RCOVRT_ABI.join(".")}
Your current rcovrt extension is: #{abi.join(".")}

Please delete rcovrt.{so,bundle,dll,...} and install the required one.
        EOF
        raise LoadError
      end
    rescue LoadError
      $stderr.puts <<-EOF

Since the rcovrt extension couldn't be loaded, rcov will run in pure-Ruby
mode, which is about two orders of magnitude slower.

If you're on win32, you can find a pre-built extension (usable with recent
One Click Installer and mswin32 builds) at http://eigenclass.org/hiki.rb?rcov .

      EOF
    end
  end

  if pure_ruby_impl_needed
    methods = %w[install_coverage_hook remove_coverage_hook reset_coverage 
                 install_callsite_hook remove_callsite_hook reset_callsite 
                 generate_coverage_info generate_callsite_info]
    sklass = class << self; self end
    (methods & sklass.instance_methods).each do |meth|
      sklass.class_eval{ remove_method meth }
    end

    @coverage_hook_activated = @callsite_hook_activated = false

    def self.install_coverage_hook # :nodoc:
      install_common_hook
      @coverage_hook_activated = true
    end

    def self.install_callsite_hook # :nodoc:
      install_common_hook
      @callsite_hook_activated = true
    end

    def self.install_common_hook # :nodoc:
      set_trace_func lambda {|event, file, line, id, binding, klass|
        next unless SCRIPT_LINES__.has_key? file
        case event
        when 'call'
          if @callsite_hook_activated
            receiver = eval("self", binding)
            klass = class << klass; self end unless klass === receiver
            begin
              DEFSITES[[klass.to_s, id.to_s]] = [file, line]
            rescue Exception
            end
            caller_arr = self.format_backtrace_array(caller[1,1])
            begin
              hash = CALLSITES[[klass.to_s, id.to_s]] ||= {}
              hash[caller_arr] ||= 0
              hash[caller_arr] += 1
              #puts "#{event} #{file} #{line} #{klass.inspect} " +
              #     "#{klass.object_id} #{id} #{eval('self', binding)}"
            rescue Exception
            end
          end
        when 'c-call', 'c-return', 'class'
          return
        end
        if @coverage_hook_activated
          COVER[file] ||= Array.new(SCRIPT_LINES__[file].size, 0)
          COVER[file][line - 1] ||= 0
          COVER[file][line - 1] += 1
        end
      }
    end

    def self.remove_coverage_hook # :nodoc:
      @coverage_hook_activated = false
      set_trace_func(nil) if !@callsite_hook_activated
    end

    def self.remove_callsite_hook # :nodoc:
      @callsite_hook_activated = false
      set_trace_func(nil) if !@coverage_hook_activated
    end

    def self.reset_coverage # :nodoc:
      COVER.replace({})
    end

    def self.reset_callsite # :nodoc:
      CALLSITES.replace({})
      DEFSITES.replace({})
    end

    def self.generate_coverage_info # :nodoc:
      Marshal.load(Marshal.dump(COVER))
    end

    def self.generate_callsite_info # :nodoc:
      [CALLSITES, DEFSITES]
    end

    def self.format_backtrace_array(backtrace)
      backtrace.map do |line|
        md = /^([^:]*)(?::(\d+)(?::in `(.*)'))?/.match(line)
        raise "Bad backtrace format" unless md
        [nil, md[3] ? md[3].to_sym : nil, md[1], (md[2] || '').to_i]
      end
    end
  end
end 

end 
