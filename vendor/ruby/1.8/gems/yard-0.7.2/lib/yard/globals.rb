# @group Global Convenience Methods

# Shortcut for creating a YARD::CodeObjects::Proxy via a path
#
# @see YARD::CodeObjects::Proxy
# @see YARD::Registry.resolve
def P(namespace, name = nil)
  namespace, name = nil, namespace if name.nil?
  YARD::Registry.resolve(namespace, name, false, true)
end

# The global {YARD::Logger} instance
#
# @return [YARD::Logger] the global {YARD::Logger} instance
# @see YARD::Logger
def log
  YARD::Logger.instance
end
