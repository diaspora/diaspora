include T('default/fulldoc/html')

module OverrideFileLinks
  def resolve_links(text)
    result = ''
    log.enter_level(Logger::ERROR) { result = super }
    result
  end
end

Template.extra_includes << OverrideFileLinks

def init
  class << options[:serializer]
    def serialized_path(object)
      if CodeObjects::ExtraFileObject === object
        super.sub(/^file\./, '')
      else
        super
      end
    end
  end if options[:serializer]
  
  generate_assets
  options.delete(:objects)
  options[:files].each {|file| serialize_file(file) }
  serialize_file(options[:readme])
end

def generate_assets
  %w( js/jquery.js js/app.js css/style.css css/common.css ).each do |file|
    asset(file, file(file, true))
  end
end

def serialize_file(file)
  index = options[:files].index(file)
  outfile = file.name + '.html'
  options[:file] = file
  if file.attributes[:namespace]
    options[:object] = Registry.at(file.attributes[:namespace])
  end
  options[:object] ||= Registry.root

  if file == options[:readme]
    serialize_index(options)
  else
    serialize_index(options) if !options[:readme] && index == 0
    Templates::Engine.with_serializer(outfile, options[:serializer]) do
      T('layout').run(options)
    end
  end
  options.delete(:file)
end
