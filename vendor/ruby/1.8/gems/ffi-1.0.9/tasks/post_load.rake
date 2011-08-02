
# This file does not define any rake tasks. It is used to load some project
# settings if they are not defined by the user.

PROJ.exclude << ["^#{Regexp.escape(PROJ.ann.file)}$",
                 "^#{Regexp.escape(PROJ.ignore_file)}$",
                 "^#{Regexp.escape(PROJ.rdoc.dir)}/",
                 "^#{Regexp.escape(PROJ.rcov.dir)}/"]

flatten_arrays = lambda do |this,os|
    os.instance_variable_get(:@table).each do |key,val|
      next if key == :dependencies \
           or key == :development_dependencies
      case val
      when Array; val.flatten!
      when OpenStruct; this.call(this,val)
      end
    end
  end
flatten_arrays.call(flatten_arrays,PROJ)

PROJ.changes ||= paragraphs_of(PROJ.history_file, 0..1).join("\n\n")

PROJ.description ||= paragraphs_of(PROJ.readme_file, 'description').join("\n\n")

PROJ.summary ||= PROJ.description.split('.').first

PROJ.gem.files ||= manifest

PROJ.gem.executables ||= PROJ.gem.files.find_all {|fn| fn =~ %r/^bin/}

PROJ.rdoc.main ||= PROJ.readme_file

# EOF
