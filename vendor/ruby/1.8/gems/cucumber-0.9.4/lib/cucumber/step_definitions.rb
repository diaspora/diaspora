require 'json'
module Cucumber
  class StepDefinitions
    def initialize(configuration = Configuration.default)
      configuration = Configuration.parse(configuration)
      @support_code = Runtime::SupportCode.new(nil, false)
      @support_code.load_files_from_paths(configuration.autoload_code_paths)
    end
    
    def to_json
      @support_code.step_definitions.map{|stepdef| stepdef.to_hash}.to_json
    end
  end
end