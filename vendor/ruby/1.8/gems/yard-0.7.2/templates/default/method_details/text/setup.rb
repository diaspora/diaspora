def init
  super
  sections.last.pop
end

def format_object_title(object)
  title = "Method: #{object.name(true)}"
  title += " (#{object.namespace})" if !object.namespace.root?
  title
end