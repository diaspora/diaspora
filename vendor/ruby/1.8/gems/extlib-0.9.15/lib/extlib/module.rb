require 'extlib/object'
require 'extlib/class'
require 'extlib/blank'

class Module
  def find_const(const_name)
    if const_name[0..1] == '::'
      Object.full_const_get(const_name[2..-1])
    else
      nested_const_lookup(const_name)
    end
  end

  def try_dup
    self
  end

  private

  # Doesn't do any caching since constants can change with remove_const
  def nested_const_lookup(const_name)
    unless equal?(Object)
      constants = []

      name.split('::').each do |part|
        const = constants.last || Object
        constants << const.const_get(part)
      end

      parts = const_name.split('::')

      # from most to least specific constant, use each as a base and try
      # to find a constant with the name const_name within them
      constants.reverse_each do |const|
        # return the nested constant if available
        return const if parts.all? do |part|
          const = if RUBY_VERSION >= '1.9.0'
            const.const_defined?(part, false) ? const.const_get(part, false) : nil
          else
            const.const_defined?(part) ? const.const_get(part) : nil
          end
        end
      end
    end

    # no relative constant found, fallback to an absolute lookup and
    # use const_missing if not found
    Object.full_const_get(const_name)
  end

end # class Module
