#!/usr/bin/env ruby

module Rake

  # Makefile loader to be used with the import file loader.
  class MakefileLoader
    SPACE_MARK = "__&NBSP;__"

    # Load the makefile dependencies in +fn+.
    def load(fn)
      open(fn) do |mf|
        lines = mf.read
        lines.gsub!(/\\ /, SPACE_MARK)
        lines.gsub!(/#[^\n]*\n/m, "")
        lines.gsub!(/\\\n/, ' ')
        lines.split("\n").each do |line|
          process_line(line)
        end
      end
    end

    private

    # Process one logical line of makefile data.
    def process_line(line)
      file_tasks, args = line.split(':')
      return if args.nil?
      dependents = args.split.map { |d| respace(d) }
      file_tasks.strip.split.each do |file_task|
        file_task = respace(file_task)
        file file_task => dependents
      end
    end
    
    def respace(str)
      str.gsub(/#{SPACE_MARK}/, ' ')
    end
  end

  # Install the handler
  Rake.application.add_loader('mf', MakefileLoader.new)
end
