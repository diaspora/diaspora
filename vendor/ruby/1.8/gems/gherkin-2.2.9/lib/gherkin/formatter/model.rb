require 'gherkin/native'

module Gherkin
  module Formatter
    module Model
      class Hashable
        def to_hash
          instance_variables.inject({}) do |hash, ivar|
            value = instance_variable_get(ivar)
            value = value.to_hash if value.respond_to?(:to_hash)
            if Array === value
              value = value.map do |e|
                e.respond_to?(:to_hash) ? e.to_hash : e
              end
            end
            hash[ivar[1..-1]] = value unless [[], nil].index(value)
            hash
          end
        end
      end
      
      class BasicStatement < Hashable
        attr_reader :comments, :keyword, :name, :line
        
        def initialize(comments, keyword, name, line)
          @comments, @keyword, @name, @line = comments, keyword, name, line
        end

        def line_range
          first = @comments.any? ? @comments[0].line : first_non_comment_line
          first..line
        end

        def first_non_comment_line
          @line
        end
      end

      class DescribedStatement < BasicStatement
        attr_reader :description

        def initialize(comments, keyword, name, description, line)
          super(comments, keyword, name, line)
          @description = description
        end
      end

      class TagStatement < DescribedStatement
        attr_reader :tags

        def initialize(comments, tags, keyword, name, description, line)
          super(comments, keyword, name, description, line)
          @tags = tags
        end

        def first_non_comment_line
          @tags.any? ? @tags[0].line : @line
        end
      end

      class Feature < TagStatement
        native_impl('gherkin')

        def initialize(comments, tags, keyword, name, description, line)
          super(comments, tags, keyword, name, description, line)
        end

        def replay(formatter)
          formatter.feature(self)
        end
      end

      class Background < DescribedStatement
        native_impl('gherkin')

        def initialize(comments, keyword, name, description, line)
          super(comments, keyword, name, description, line)
          @type = "background"
        end

        def replay(formatter)
          formatter.background(self)
        end
      end

      class Scenario < TagStatement
        native_impl('gherkin')

        def initialize(comments, tags, keyword, name, description, line)
          super(comments, tags, keyword, name, description, line)
          @type = "scenario"
        end

        def replay(formatter)
          formatter.scenario(self)
        end
      end

      class ScenarioOutline < TagStatement
        native_impl('gherkin')

        def initialize(comments, tags, keyword, name, description, line)
          super(comments, tags, keyword, name, description, line)
          @type = "scenario_outline"
        end

        def replay(formatter)
          formatter.scenario_outline(self)
        end
      end

      class Examples < TagStatement
        native_impl('gherkin')

        attr_accessor :rows

        def initialize(comments, tags, keyword, name, description, line, rows=nil)
          super(comments, tags, keyword, name, description, line)
          @rows = rows
        end

        def replay(formatter)
          formatter.examples(self)
        end
      end

      class Step < BasicStatement
        native_impl('gherkin')

        attr_accessor :multiline_arg, :result

        def initialize(comments, keyword, name, line, multiline_arg=nil, result=nil)
          super(comments, keyword, name, line)
          @multiline_arg = multiline_arg
          @result = result
        end

        def line_range
          range = super
          case multiline_arg
          when Array
            range = range.first..multiline_arg[-1].line
          when Model::PyString
            range = range.first..multiline_arg.line_range.last
          end
          range
        end

        def replay(formatter)
          formatter.step(self)
        end

        def status
          result ? result.status : 'undefined'
        end

        def arguments
          result ? result.arguments : []
        end

        def to_hash
          hash = super
          if Array === @multiline_arg
            hash['multiline_arg'] = {
              'type' => 'table',
              'value' => hash['multiline_arg']
            }
          elsif PyString === @multiline_arg
            hash['multiline_arg']['type'] = 'py_string'
          end
          hash
        end
      end

      class Comment < Hashable
        native_impl('gherkin')

        attr_reader :value, :line
        
        def initialize(value, line)
          @value, @line = value, line
        end
      end

      class Tag < Hashable
        native_impl('gherkin')

        attr_reader :name, :line
        
        def initialize(name, line)
          @name, @line = name, line
        end
        
        def eql?(tag)
          @name.eql?(tag.name)
        end

        def hash
          @name.hash
        end
      end

      class PyString < Hashable
        native_impl('gherkin')

        attr_reader :value, :line
        
        def initialize(value, line)
          @value, @line = value, line
        end

        def line_range
          line_count = value.split(/\r?\n/).length
          line..(line+line_count+1)
        end
      end

      class Row < Hashable
        native_impl('gherkin')

        attr_reader :comments, :cells, :line

        def initialize(comments, cells, line)
          @comments, @cells, @line = comments, cells, line
        end
      end

      class Result
        native_impl('gherkin')

        attr_reader :status, :error_message, :arguments, :stepdef_location
        
        def initialize(status, error_message, arguments, stepdef_location)
          @status, @error_message, @arguments, @stepdef_location = status, error_message, arguments, stepdef_location
        end
      end
    end
  end
end