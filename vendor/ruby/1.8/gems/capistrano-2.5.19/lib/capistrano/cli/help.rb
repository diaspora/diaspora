module Capistrano
  class CLI
    module Help
      LINE_PADDING = 7
      MIN_MAX_LEN  = 30
      HEADER_LEN   = 60

      def self.included(base) #:nodoc:
        base.send :alias_method, :execute_requested_actions_without_help, :execute_requested_actions
        base.send :alias_method, :execute_requested_actions, :execute_requested_actions_with_help
      end

      def execute_requested_actions_with_help(config)
        if options[:tasks]
          task_list(config, options[:tasks])
        elsif options[:explain]
          explain_task(config, options[:explain])
        else
          execute_requested_actions_without_help(config)
        end
      end

      def task_list(config, pattern = true) #:nodoc:
        tool_output = options[:tool]

        if pattern.is_a?(String)
          tasks = config.task_list(:all).select {|t| t.fully_qualified_name =~ /#{pattern}/}
        end
        if tasks.nil? || tasks.length == 0
          warn "Pattern '#{pattern}' not found. Listing all tasks.\n\n" if !tool_output && !pattern.is_a?(TrueClass)
          tasks = config.task_list(:all)
        end

        if tasks.empty?
          warn "There are no tasks available. Please specify a recipe file to load." unless tool_output
        else
          all_tasks_length = tasks.length
          if options[:verbose].to_i < 1
            tasks = tasks.reject { |t| t.description.empty? || t.description =~ /^\[internal\]/ }
          end

          tasks = tasks.sort_by { |task| task.fully_qualified_name }

          longest = tasks.map { |task| task.fully_qualified_name.length }.max
          max_length = output_columns - longest - LINE_PADDING
          max_length = MIN_MAX_LEN if max_length < MIN_MAX_LEN

          tasks.each do |task|
            if tool_output
              puts "cap #{task.fully_qualified_name}"
            else
              puts "cap %-#{longest}s # %s" % [task.fully_qualified_name, task.brief_description(max_length)]
            end
          end

          unless tool_output
            if all_tasks_length > tasks.length
              puts
              puts "Some tasks were not listed, either because they have no description,"
              puts "or because they are only used internally by other tasks. To see all"
              puts "tasks, type `#{File.basename($0)} -vT'."
            end

            puts
            puts "Extended help may be available for these tasks."
            puts "Type `#{File.basename($0)} -e taskname' to view it."
          end
        end
      end

      def explain_task(config, name) #:nodoc:
        task = config.find_task(name)
        if task.nil?
          warn "The task `#{name}' does not exist."
        else
          puts "-" * HEADER_LEN
          puts "cap #{name}"
          puts "-" * HEADER_LEN

          if task.description.empty?
            puts "There is no description for this task."
          else
            puts format_text(task.description)
          end

          puts
        end
      end

      def long_help #:nodoc:
        help_text = File.read(File.join(File.dirname(__FILE__), "help.txt"))
        self.class.ui.page_at = self.class.ui.output_rows - 2
        self.class.ui.say format_text(help_text)
      end

      def format_text(text) #:nodoc:
        formatted = ""
        text.each_line do |line|
          indentation = line[/^\s+/] || ""
          indentation_size = indentation.split(//).inject(0) { |c,s| c + (s[0] == ?\t ? 8 : 1) }
          line_length = output_columns - indentation_size
          line_length = MIN_MAX_LEN if line_length < MIN_MAX_LEN
          lines = line.strip.gsub(/(.{1,#{line_length}})(?:\s+|\Z)/, "\\1\n").split(/\n/)
          if lines.empty?
            formatted << "\n"
          else
            formatted << lines.map { |l| "#{indentation}#{l}\n" }.join
          end
        end
        formatted
      end

      def output_columns #:nodoc:
        if ( @output_columns.nil? ) 
          if ( self.class.ui.output_cols.nil? || self.class.ui.output_cols > 80 )
            @output_columns = 80 
          else
            @output_columns = self.class.ui.output_cols
          end
        end
        @output_columns 
      end
    end
  end
end
