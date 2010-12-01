module RSpec::Rails
  module ModuleInclusion
    def include_self_when_dir_matches(*path_parts)
      lambda do |c|
        c.include self, :example_group => {
          :file_path => Regexp.compile(path_parts.join('[\\\/]'))
        }
      end
    end
  end
end
