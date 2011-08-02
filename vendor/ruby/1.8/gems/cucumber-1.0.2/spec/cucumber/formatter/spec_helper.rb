module Cucumber
  module Formatter

    module SpecHelperDsl
      attr_reader :feature_content, :step_defs, :feature_filename
    
      def define_feature(string, feature_file = 'spec.feature')
        @feature_content = string
        @feature_filename = feature_file
      end
    
      def define_steps(&block)
        @step_defs = block
      end
    end

    module SpecHelper
      def run_defined_feature
        define_steps
        features = load_features(self.class.feature_content || raise("No feature content defined!"))
        run(features)
      end
      
      def step_mother
        @step_mother ||= Runtime.new
      end
      
      def load_features(content)
        feature_file = FeatureFile.new(self.class.feature_filename, content)
        features = Ast::Features.new
        filters = []
        feature = feature_file.parse(filters, {})
        features.add_feature(feature) if feature
        features
      end
    
      def run(features)
        configuration = Cucumber::Configuration.default
        tree_walker = Cucumber::Ast::TreeWalker.new(step_mother, [@formatter], configuration)
        tree_walker.visit_features(features)
      end
    
      def define_steps
        return unless step_defs = self.class.step_defs
        rb = step_mother.load_programming_language('rb')
        dsl = Object.new
        dsl.extend RbSupport::RbDsl
        dsl.instance_exec &step_defs
      end 
    end
  end
end
