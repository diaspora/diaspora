require 'rubypython'

module Cucumber
  module PySupport
    class PyLanguage
      include LanguageSupport::LanguageMethods

      def initialize(step_mother)
        @step_def_files = []
        #
        # @python_path = ENV['PYTHONPATH'] ? ENV['PYTHONPATH'].split(':') : []
        # add_to_python_path(File.dirname(__FILE__))
        #
        # RubyPython.start
        # at_exit{RubyPython.stop}
        #
        # import(File.dirname(__FILE__) + '/py_language.py')
      end

      def load_code_file(py_file)
        @step_def_files << py_file
      end

      def alias_adverbs(adverbs)
      end

      def step_definitions_for(py_file)
        mod = import(py_file)
      end

      def snippet_text(code_keyword, step_name, multiline_arg_class)
        "python snippet: #{code_keyword}, #{step_name}"
      end

      def begin_scenario(scenario)
        @python_path = []
        add_to_python_path(File.dirname(__FILE__))
        @step_def_files.each{|f| add_to_python_path(File.dirname(f))}

        RubyPython.start

        @delegate = import(File.dirname(__FILE__) + '/py_language.py')
        @step_def_files.each{|f| import(f)}
      end

      def end_scenario
      end

      def step_matches(step_name, name_to_report)
        @delegate.step_matches(step_name, name_to_report)
      end

      private

      def import(path)
        modname = File.basename(path)[0...-File.extname(path).length]
        begin
          mod = RubyPython.import(modname)
        rescue PythonError => e
#          e.message << "Couldn't load #{path}\nConsider adding #{File.expand_path(File.dirname(path))} to your PYTHONPATH"
          raise e
        end
      end

      def add_to_python_path(dir)
        dir = File.expand_path(dir)
        @python_path.unshift(dir)
        @python_path.uniq!
        ENV['PYTHONPATH'] = @python_path.join(':')
      end
    end
  end
end

class String #:nodoc:
  # RubyPython incorrectly to expects String#end_with? to exist.
  unless defined? end_with? # 1.9
    def end_with?(str) #:nodoc:
      str = str.to_str
      tail = self[-str.length, str.length]
      tail == str
    end
  end
end