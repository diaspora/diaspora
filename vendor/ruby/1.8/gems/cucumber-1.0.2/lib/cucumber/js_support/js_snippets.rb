module Cucumber
  module JsSupport
    module JsSnippets
      PARAM_PATTERN = /"([^"]*)"/
      ESCAPED_PARAM_PATTERN = '"([^\\"]*)"'

      def snippet_text(code_keyword, step_name, multiline_arg_class)
        escaped = Regexp.escape(step_name).gsub('\ ', ' ').gsub('/', '\/')
        escaped = escaped.gsub(PARAM_PATTERN, ESCAPED_PARAM_PATTERN)

        n = 0
        block_args = escaped.scan(ESCAPED_PARAM_PATTERN).map do |a|
          n += 1
          "arg#{n}"
        end
        block_args << multiline_arg_class.default_arg_name unless multiline_arg_class.nil?
        block_arg_string = block_args.empty? ? "" : "#{block_args.join(", ")}"
        multiline_class_comment = ""
        if(multiline_arg_class == Ast::Table)
          multiline_class_comment = "//#{multiline_arg_class.default_arg_name} is a #{multiline_arg_class.to_s}\n"
        end

        "#{code_keyword}(/^#{escaped}$/, function(#{block_arg_string}){\n  #{multiline_class_comment}  //express the regexp above with the code you wish you had\n});"
      end
    end
  end
end
