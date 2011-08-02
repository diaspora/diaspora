include Helpers::ModuleHelper

def init
  options[:objects] = objects = run_verifier(options[:objects])
  
  return serialize_onefile if options[:onefile]
  generate_assets
  serialize('_index.html')
  options[:files].each_with_index do |file, i| 
    serialize_file(file, file.title) 
  end

  options.delete(:objects)
  options.delete(:files)
  
  objects.each do |object| 
    begin
      serialize(object)
    rescue => e
      path = options[:serializer].serialized_path(object)
      log.error "Exception occurred while generating '#{path}'"
      log.backtrace(e)
    end
  end
end

# Generate an HTML document for the specified object. This method is used by
# most of the objects found in the Registry.
# @param [CodeObject] object to be saved to HTML
def serialize(object)
  options[:object] = object
  serialize_index(options) if object == '_index.html' && options[:files].empty?
  Templates::Engine.with_serializer(object, options[:serializer]) do
    T('layout').run(options)
  end
end

# Generate the documentation output in one file (--one-file) which will load the
# contents of all the javascript and css and output the entire contents without 
# depending on any additional files
def serialize_onefile
  layout = Object.new.extend(T('layout'))
  options[:css_data] = layout.stylesheets.map {|sheet| file(sheet,true) }.join("\n")
  options[:js_data] = layout.javascripts.map {|script| file(script,true) }.join("")
  Templates::Engine.with_serializer('index.html', options[:serializer]) do
    T('onefile').run(options)
  end
end

# Generate the index document for the output
# @params [Hash] options contains data and flags that influence the output 
def serialize_index(options)
  Templates::Engine.with_serializer('index.html', options[:serializer]) do
    T('layout').run(options)
  end
end

# Generate a single HTML file with the layout template applied. This is generally
# the README file or files specified on the command-line.
# 
# @param [File] file object to be saved to the output
# @param [String] title currently unused
# 
# @see layout#diskfile
def serialize_file(file, title = nil)
  options[:object] = Registry.root
  options[:file] = file
  outfile = 'file.' + file.name + '.html'

  serialize_index(options) if file == options[:readme]
  Templates::Engine.with_serializer(outfile, options[:serializer]) do
    T('layout').run(options)
  end
  options.delete(:file)
end

# 
# Generates a file to the output with the specified contents.
# 
# @example saving a custom html file to the documenation root
#
#   asset('my_custom.html','<html><body>Custom File</body></html>')
# 
# @param [String] path relative to the document output where the file will be
#   created.
# @param [String] content the contents that are saved to the file.
def asset(path, content)
  options[:serializer].serialize(path, content) if options[:serializer]
end

# @return [Array<String>] Stylesheet files that are additionally loaded for the 
#   searchable full lists, e.g., Class List, Method List, File List
# @since 0.7.0
def stylesheets_full_list
  %w(css/full_list.css css/common.css)
end

# @return [Array<String>] Javascript files that are additionally loaded for the 
#   searchable full lists, e.g., Class List, Method List, File List.
# @since 0.7.0
def javascripts_full_list
  %w(js/jquery.js js/full_list.js)
end

def menu_lists
  Object.new.extend(T('layout')).menu_lists
end

# Generates all the javascript files, stylesheet files, menu lists
# (i.e. class, method, and file) based on the the values returned from the 
# layout's menu_list method, and the frameset in the documentation output
# 
def generate_assets
  @object = Registry.root

  layout = Object.new.extend(T('layout'))
  (layout.javascripts + javascripts_full_list +
      layout.stylesheets + stylesheets_full_list).uniq.each do |file|
    asset(file, file(file, true))
  end
  layout.menu_lists.each do |list|
    list_generator_method = "generate_#{list[:type]}_list"
    if respond_to?(list_generator_method)
      send(list_generator_method)
    else
      log.error "Unable to generate '#{list[:title]}' list because no method " +
        "'#{list_generator_method}' exists"
    end
  end

  generate_frameset
end

# Generate a searchable method list in the output
# @see ModuleHelper#prune_method_listing
def generate_method_list
  @items = prune_method_listing(Registry.all(:method), false)
  @items = @items.reject {|m| m.name.to_s =~ /=$/ && m.is_attribute? }
  @items = @items.sort_by {|m| m.name.to_s }
  @list_title = "Method List"
  @list_type = "methods"
  asset('method_list.html', erb(:full_list))
end

# Generate a searchable class list in the output
def generate_class_list
  @items = options[:objects] if options[:objects]
  @list_title = "Class List"
  @list_type = "class"
  asset('class_list.html', erb(:full_list))
end

# Generate a searchable file list in the output
def generate_file_list
  @file_list = true
  @items = options[:files]
  @list_title = "File List"
  @list_type = "files"
  asset('file_list.html', erb(:full_list))
  @file_list = nil
end

# Generate the frame documentation in the output
def generate_frameset
  @javascripts = javascripts_full_list
  @stylesheets = stylesheets_full_list
  asset('frames.html', erb(:frames))
end

# @return [String] HTML output of the classes to be displayed in the
#    full_list_class template.
def class_list(root = Registry.root)
  out = ""
  children = run_verifier(root.children)
  if root == Registry.root
    children += @items.select {|o| o.namespace.is_a?(CodeObjects::Proxy) }
  end
  children.reject {|c| c.nil? }.sort_by {|child| child.path }.map do |child|
    if child.is_a?(CodeObjects::NamespaceObject)
      name = child.namespace.is_a?(CodeObjects::Proxy) ? child.path : child.name
      has_children = child.children.any? {|o| o.is_a?(CodeObjects::NamespaceObject) }
      out << "<li>"
      out << "<a class='toggle'></a> " if has_children
      out << linkify(child, name)
      out << " &lt; #{child.superclass.name}" if child.is_a?(CodeObjects::ClassObject) && child.superclass
      out << "<small class='search_info'>"
      if !child.namespace || child.namespace.root?
        out << "Top Level Namespace"
      else
        out << child.namespace.path
      end
      out << "</small>"
      out << "</li>"
      out << "<ul>#{class_list(child)}</ul>" if has_children
    end
  end
  out
end