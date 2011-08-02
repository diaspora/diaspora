require 'new_relic/control'

module NewRelic
  module CollectionHelper
  DEFAULT_TRUNCATION_SIZE=256
  DEFAULT_ARRAY_TRUNCATION_SIZE=1024
  # Transform parameter hash into a hash whose values are strictly
  # strings
  def normalize_params(params)
    case params
      when Symbol, FalseClass, TrueClass, nil
        params
      when Numeric
        truncate(params.to_s)
      when String
        truncate(params)
      when Hash
        new_params = {}
        params.each do | key, value |
          new_params[truncate(normalize_params(key),32)] = normalize_params(value)
        end
        new_params
      when Array
        params.first(DEFAULT_ARRAY_TRUNCATION_SIZE).map{|item| normalize_params(item)}
    else
      truncate(flatten(params))
    end
  end

  # Return an array of strings (backtrace), cleaned up for readability
  # Return nil if there is no backtrace

  def strip_nr_from_backtrace(backtrace)
    if backtrace && !NewRelic::Control.instance.disable_backtrace_cleanup?
      # this is for 1.9.1, where strings no longer have Enumerable
      backtrace = backtrace.split("\n") if String === backtrace
      backtrace = backtrace.map &:to_s
      backtrace = backtrace.reject {|line| line.include?(NewRelic::Control.newrelic_root) }
      # rename methods back to their original state
      backtrace = backtrace.collect {|line| line.gsub(/_without_(newrelic|trace)/, "")}
    end
    backtrace
  end

  private

  # Convert any kind of object to a short string.
  def flatten(object)
    s = case object
      when nil then ''
      when object.instance_of?(String) then object
      when String then String.new(object)  # convert string subclasses to strings
      else "#<#{object.class.to_s}>"
    end
  end
  def truncate(string, len=DEFAULT_TRUNCATION_SIZE)
    case string
    when Symbol then string
    when nil then ""
    when String
      real_string = flatten(string)
      if real_string.size > len
        real_string = real_string.slice(0...len)
        real_string << "..."
      end
      real_string
    else
      truncate(flatten(string), len)
    end
  end
  end
end
