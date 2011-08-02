def init
  tags = Tags::Library.visible_tags - [:abstract, :deprecated, :note, :todo]
  create_tag_methods(tags - [:example, :option, :overload, :see])
  sections :index, tags
  sections.any(:overload).push(T('docstring'))
end

def return
  if object.type == :method
    return if object.name == :initialize && object.scope == :instance
    return if object.tags(:return).size == 1 && object.tag(:return).types == ['void']
  end
  tag(:return)
end

private

def tag(name, opts = nil)
  return unless object.has_tag?(name)
  opts ||= options_for_tag(name)
  @no_names = true if opts[:no_names]
  @no_types = true if opts[:no_types]
  @name = name
  out = erb('tag')
  @no_names, @no_types = nil, nil
  out
end

def create_tag_methods(tags)
  tags.each do |tag|
    next if respond_to?(tag)
    instance_eval(<<-eof, __FILE__, __LINE__ + 1)
      def #{tag}; tag(#{tag.inspect}) end
    eof
  end
end

def options_for_tag(tag)
  opts = {:no_types => true, :no_names => true}
  case Tags::Library.factory_method_for(tag)
  when :with_types
    opts[:no_types] = false
  when :with_types_and_name
    opts[:no_types] = false
    opts[:no_names] = false
  when :with_name
    opts[:no_names] = false
  end
  opts
end
