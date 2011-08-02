module FactoryGirl

  class << self
    # An Array of strings specifying locations that should be searched for
    # factory definitions. By default, factory_girl will attempt to require
    # "factories," "test/factories," and "spec/factories." Only the first
    # existing file will be loaded.
    attr_accessor :definition_file_paths
  end
  self.definition_file_paths = %w(factories test/factories spec/factories)

  def self.find_definitions #:nodoc:
    definition_file_paths.each do |path|
      path = File.expand_path(path)

      require("#{path}.rb") if File.exists?("#{path}.rb")

      if File.directory? path
        Dir[File.join(path, '**', '*.rb')].sort.each do |file|
          require file
        end
      end
    end
  end
end
