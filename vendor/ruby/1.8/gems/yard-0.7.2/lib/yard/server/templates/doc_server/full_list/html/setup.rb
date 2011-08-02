include T('default/fulldoc/html')

def init
  case @list_type.to_sym
  when :class
    generate_class_list
    @list_title = "Class List"
  when :methods
    generate_method_list
    @list_title = "Method List"
  when :files
    generate_file_list
    @list_title = "File List"
  end
  sections :full_list
end

def asset(file, contents)
  contents
end
