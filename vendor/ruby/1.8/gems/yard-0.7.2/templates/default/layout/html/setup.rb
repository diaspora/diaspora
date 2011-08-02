def init
  @breadcrumb = []  
  if @onefile
    sections :layout
  elsif @file
    if @file.attributes[:namespace]
      @object = options[:object] = Registry.at(@file.attributes[:namespace]) || Registry.root 
    end
    @breadcrumb_title = "File: " + @file.title
    @page_title = @breadcrumb_title
    sections :layout, [:diskfile]
  elsif object
    case object
    when '_index.html'
      @page_title = options[:title]
      sections :layout, [:index, [:listing, [:files, :objects]]]
    when CodeObjects::Base
      unless object.root?
        cur = object.namespace
        while !cur.root?
          @breadcrumb.unshift(cur)
          cur = cur.namespace
        end
      end
    
      @page_title = format_object_title(object)
      type = object.root? ? :module : object.type
      sections :layout, [T(type)]
    end
  else
    sections :layout, [:contents]
  end
end

def contents
  @contents
end

def index
  @objects_by_letter = {}
  objects = Registry.all(:class, :module).sort_by {|o| o.name.to_s }
  objects = run_verifier(objects)
  objects.each {|o| (@objects_by_letter[o.name.to_s[0,1].upcase] ||= []) << o }
  erb(:index)
end

def diskfile
  @file.attributes[:markup] ||= markup_for_file('', @file.filename)
  data = htmlify(@file.contents, @file.attributes[:markup])
  "<div id='filecontents'>" + data + "</div>"
end

# @return [Array<String>] core javascript files for layout
# @since 0.7.0
def javascripts
  %w(js/jquery.js js/app.js)
end

# @return [Array<String>] core stylesheets for the layout
# @since 0.7.0
def stylesheets
  %w(css/style.css css/common.css)
end

# @return [Array<Hash{Symbol=>String}>] the list of search links and drop-down menus
# @since 0.7.0
def menu_lists
[ { :type => 'class', :title => 'Classes', :search_title => 'Class List' },
  { :type => 'method', :title => 'Methods', :search_title => 'Method List' }, 
  { :type => 'file', :title => 'Files', :search_title => 'File List' } ]
end
