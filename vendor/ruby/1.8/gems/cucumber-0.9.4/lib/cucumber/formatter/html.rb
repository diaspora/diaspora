require 'erb'
require 'cucumber/formatter/ordered_xml_markup'
require 'cucumber/formatter/duration'
require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    class Html
      include ERB::Util # for the #h method
      include Duration
      include Io

      def initialize(step_mother, path_or_io, options)
        @io = ensure_io(path_or_io, "html")
        @step_mother = step_mother
        @options = options
        @buffer = {}
        @builder = create_builder(@io)
        @feature_number = 0
        @scenario_number = 0
        @step_number = 0
        @header_red = nil
        @delayed_announcements = []
      end

      def embed(file, mime_type)
        case(mime_type)
        when /^image\/(png|gif|jpg|jpeg)/
          embed_image(file)
        end
      end

      def embed_image(file)
        id = file.hash
        @builder.span(:class => 'embed') do |pre|
          pre << %{<a href="" onclick="img=document.getElementById('#{id}'); img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false">Screenshot</a><br>&nbsp;
          <img id="#{id}" style="display: none" src="#{file}"/>}
        end
      end


      def before_features(features)
        @step_count = get_step_count(features)

        # <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        @builder.declare!(
          :DOCTYPE,
          :html, 
          :PUBLIC, 
          '-//W3C//DTD XHTML 1.0 Strict//EN',
          'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
        )

        @builder << '<html xmlns ="http://www.w3.org/1999/xhtml">'
          @builder.head do
          @builder.meta(:content => 'text/html;charset=utf-8')
          @builder.title 'Cucumber'
          inline_css
          inline_js
        end
        @builder << '<body>'
        @builder << "<!-- Step count #{@step_count}-->"
        @builder << '<div class="cucumber">'
        @builder.div(:id => 'cucumber-header') do
          @builder.div(:id => 'label') do
            @builder.h1('Cucumber Features')
          end
          @builder.div(:id => 'summary') do
            @builder.p('',:id => 'totals')
            @builder.p('',:id => 'duration')
            @builder.div(:id => 'expand-collapse') do
              @builder.p('Expand All', :id => 'expander')
              @builder.p('Collapse All', :id => 'collapser')
            end
          end
        end
      end

      def after_features(features)
        print_stats(features)
        @builder << '</div>'
        @builder << '</body>'
        @builder << '</html>'
      end

      def before_feature(feature)
        @exceptions = []
        @builder << '<div class="feature">'
      end

      def after_feature(feature)
        @builder << '</div>'
      end
  
      def before_comment(comment)
        @builder << '<pre class="comment">'
      end

      def after_comment(comment)
        @builder << '</pre>'
      end
  
      def comment_line(comment_line)
        @builder.text!(comment_line)
        @builder.br
      end
  
      def after_tags(tags)
        @tag_spacer = nil
      end
  
      def tag_name(tag_name)
        @builder.text!(@tag_spacer) if @tag_spacer
        @tag_spacer = ' '
        @builder.span(tag_name, :class => 'tag')
      end
  
      def feature_name(keyword, name)
        lines = name.split(/\r?\n/)
        return if lines.empty?
        @builder.h2 do |h2|
          @builder.span(keyword + ': ' + lines[0], :class => 'val')
        end
        @builder.p(:class => 'narrative') do
          lines[1..-1].each do |line|
            @builder.text!(line.strip)
            @builder.br
          end
        end
      end
  
      def before_background(background)
        @in_background = true
        @builder << '<div class="background">'
      end
  
      def after_background(background)
        @in_background = nil
        @builder << '</div>'
      end
  
      def background_name(keyword, name, file_colon_line, source_indent)
        @listing_background = true
        @builder.h3 do |h3|
          @builder.span(keyword, :class => 'keyword')
          @builder.text!(' ')
          @builder.span(name, :class => 'val')
        end
      end

      def before_feature_element(feature_element)
        @scenario_number+=1
        @scenario_red = false
        css_class = {
          Ast::Scenario        => 'scenario',
          Ast::ScenarioOutline => 'scenario outline'
        }[feature_element.class]      
        @builder << "<div class='#{css_class}'>"
      end

      def after_feature_element(feature_element)
        @builder << '</div>'
        @open_step_list = true
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @listing_background = false
        @builder.h3(:id => "scenario_#{@scenario_number}") do
          @builder.span(keyword + ':', :class => 'keyword')
          @builder.text!(' ')
          @builder.span(name, :class => 'val')
        end
      end
  
      def before_outline_table(outline_table)
        @outline_row = 0
        @builder << '<table>'
      end
  
      def after_outline_table(outline_table)
        @builder << '</table>'
        @outline_row = nil
      end
      
      def before_examples(examples)
         @builder << '<div class="examples">'
      end
      
      def after_examples(examples)
        @builder << '</div>'
      end

      def examples_name(keyword, name)
        @builder.h4 do
          @builder.span(keyword, :class => 'keyword')
          @builder.text!(' ')
          @builder.span(name, :class => 'val')
        end
      end
  
      def before_steps(steps)
        @builder << '<ol>'
      end
  
      def after_steps(steps)
        @builder << '</ol>'
      end

      def before_step(step)
        @step_id = step.dom_id
        @step_number += 1
        @step = step
      end

      def after_step(step)
        move_progress
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        @step_match = step_match
        @hide_this_step = false
        if exception
          if @exceptions.include?(exception)
            @hide_this_step = true
            return
          end
          @exceptions << exception
        end
        if status != :failed && @in_background ^ background
          @hide_this_step = true
          return
        end
        @status = status
        return if @hide_this_step
        set_scenario_color(status)      
        @builder << "<li id='#{@step_id}' class='step #{status}'>"            
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        return if @hide_this_step
        # print snippet for undefined steps
        if status == :undefined
          step_multiline_class = @step.multiline_arg ? @step.multiline_arg.class : nil
          @builder.pre do |pre|
            pre << @step_mother.snippet_text(@step.actual_keyword,step_match.instance_variable_get("@name") || '',step_multiline_class)
          end
        end
        @builder << '</li>'
        print_announcements
      end

      def step_name(keyword, step_match, status, source_indent, background)
        @step_matches ||= []
        background_in_scenario = background && !@listing_background
        @skip_step = @step_matches.index(step_match) || background_in_scenario
        @step_matches << step_match

        unless @skip_step
          build_step(keyword, step_match, status)
        end
      end

      def exception(exception, status)
        build_exception_detail(exception)
      end

      def extra_failure_content(file_colon_line)
        @snippet_extractor ||= SnippetExtractor.new
        "<pre class=\"ruby\"><code>#{@snippet_extractor.snippet(file_colon_line)}</code></pre>"
      end

      def before_multiline_arg(multiline_arg)
        return if @hide_this_step || @skip_step
        if Ast::Table === multiline_arg
          @builder << '<table>'
        end
      end
  
      def after_multiline_arg(multiline_arg)
        return if @hide_this_step || @skip_step
        if Ast::Table === multiline_arg
          @builder << '</table>'
        end
      end

      def py_string(string)
        return if @hide_this_step
        @builder.pre(:class => 'val') do |pre|
          @builder << string.gsub("\n", '&#x000A;')
        end
      end
  
  
      def before_table_row(table_row)
        @row_id = table_row.dom_id
        @col_index = 0
        return if @hide_this_step
        @builder << "<tr class='step' id='#{@row_id}'>"
      end
  
      def after_table_row(table_row)
        return if @hide_this_step
        print_table_row_announcements
        @builder << '</tr>'
        if table_row.exception
          @builder.tr do
            @builder.td(:colspan => @col_index.to_s, :class => 'failed') do
              @builder.pre do |pre|
                pre << format_exception(table_row.exception)
              end
            end
          end
          set_scenario_color_failed
        end
        if @outline_row
          @outline_row += 1
        end
        @step_number += 1
        move_progress
      end

      def table_cell_value(value, status)
        return if @hide_this_step
        
        @cell_type = @outline_row == 0 ? :th : :td
        attributes = {:id => "#{@row_id}_#{@col_index}", :class => 'step'}
        attributes[:class] += " #{status}" if status
        build_cell(@cell_type, value, attributes)
        set_scenario_color(status)
        @col_index += 1
      end

      def announce(announcement)
        @delayed_announcements << announcement
        #@builder.pre(announcement, :class => 'announcement')
      end
      
      def print_announcements
        return if @delayed_announcements.empty?
        
        #@builder.ol do
          @delayed_announcements.each do |ann|
            @builder.li(:class => 'step announcement') do
              @builder << ann
            end
          end
        #end
        empty_announcements
      end
      
      def print_table_row_announcements
        return if @delayed_announcements.empty?
        
        @builder.td(:class => 'announcement') do
          @builder << @delayed_announcements.join(", ")
        end
        empty_announcements
      end
      
      def empty_announcements
        @delayed_announcements = []
      end

      protected

      def build_exception_detail(exception)
        backtrace = Array.new
        @builder.div(:class => 'message') do
          message = exception.message
          if defined?(RAILS_ROOT) && message.include?('Exception caught')
            matches = message.match(/Showing <i>(.+)<\/i>(?:.+)#(\d+)/)
            backtrace += ["#{RAILS_ROOT}/#{matches[1]}:#{matches[2]}"]
            message = message.match(/<code>([^(\/)]+)<\//m)[1]
          end
          @builder.pre do 
            @builder.text!(message)
          end
        end
        @builder.div(:class => 'backtrace') do
          @builder.pre do
            backtrace = exception.backtrace
            backtrace.delete_if { |x| x =~ /\/gems\/(cucumber|rspec)/ }
            @builder << backtrace_line(backtrace.join("\n"))
          end
        end
        extra = extra_failure_content(backtrace)
        @builder << extra unless extra == ""
      end

      def set_scenario_color(status)
        if status == :undefined
          set_scenario_color_pending
        end
        if status == :failed
          set_scenario_color_failed
        end
      end
      
      def set_scenario_color_failed
        @builder.script do
          @builder.text!("makeRed('cucumber-header');") unless @header_red
          @header_red = true
          @builder.text!("makeRed('scenario_#{@scenario_number}');") unless @scenario_red
          @scenario_red = true
        end
      end
      
      def set_scenario_color_pending
        @builder.script do
          @builder.text!("makeYellow('cucumber-header');") unless @header_red
          @builder.text!("makeYellow('scenario_#{@scenario_number}');") unless @scenario_red
        end         
      end

      def get_step_count(features)
        count = 0
        features = features.instance_variable_get("@features")
        features.each do |feature|
          #get background steps
          if feature.instance_variable_get("@background")
            background = feature.instance_variable_get("@background")
            background.init
            background_steps = background.instance_variable_get("@steps").instance_variable_get("@steps")
            count += background_steps.size
          end
          #get scenarios
          feature.instance_variable_get("@feature_elements").each do |scenario|
            scenario.init
            #get steps
            steps = scenario.instance_variable_get("@steps").instance_variable_get("@steps")
            count += steps.size

            #get example table
            examples = scenario.instance_variable_get("@examples_array")
            unless examples.nil?
              examples.each do |example|
                example_matrix = example.instance_variable_get("@outline_table").instance_variable_get("@cell_matrix")
                count += example_matrix.size
              end
            end

            #get multiline step tables
            steps.each do |step|
              multi_arg = step.instance_variable_get("@multiline_arg")
              next if multi_arg.nil?
              matrix = multi_arg.instance_variable_get("@cell_matrix")
              count += matrix.size unless matrix.nil?
            end
          end
        end
        return count
      end

      def build_step(keyword, step_match, status)
        step_name = step_match.format_args(lambda{|param| %{<span class="param">#{param}</span>}})
        @builder.div(:class => 'step_name') do |div|
          @builder.span(keyword, :class => 'keyword')
          @builder.span(:class => 'step val') do |name|
            name << h(step_name).gsub(/&lt;span class=&quot;(.*?)&quot;&gt;/, '<span class="\1">').gsub(/&lt;\/span&gt;/, '</span>')
          end            
        end
        
        step_file = step_match.file_colon_line
        step_file.gsub(/^([^:]*\.rb):(\d*)/) do
          if ENV['TM_PROJECT_DIRECTORY']
            step_file = "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
          end
        end
        
        @builder.div(:class => 'step_file') do |div|
          @builder.span do
            @builder << step_file
          end
        end
      end

      def build_cell(cell_type, value, attributes)
        @builder.__send__(cell_type, attributes) do
          @builder.div do
            @builder.span(value,:class => 'step param')
          end
        end
      end

      def inline_css
        @builder.style(:type => 'text/css') do
          @builder << File.read(File.dirname(__FILE__) + '/cucumber.css')
        end
      end

      def inline_js
        @builder.script(:type => 'text/javascript') do
          @builder << inline_jquery
          @builder << inline_js_content
        end
      end

      def inline_jquery
        File.read(File.dirname(__FILE__) + '/jquery-min.js')
      end
      
      def inline_js_content
        <<-EOF

  SCENARIOS = "h3[id^='scenario_']";
  
  $(document).ready(function() {
    $(SCENARIOS).css('cursor', 'pointer');
    $(SCENARIOS).click(function() {
      $(this).siblings().toggle(250);
    });
    
    $("#collapser").css('cursor', 'pointer');
    $("#collapser").click(function() {
      $(SCENARIOS).siblings().hide();
    });
    
    $("#expander").css('cursor', 'pointer');
    $("#expander").click(function() {
      $(SCENARIOS).siblings().show();
    });
  })
  
  function moveProgressBar(percentDone) {
    $("cucumber-header").css('width', percentDone +"%");
  }
  function makeRed(element_id) {
    $('#'+element_id).css('background', '#C40D0D');
    $('#'+element_id).css('color', '#FFFFFF');
  }
  function makeYellow(element_id) {
    $('#'+element_id).css('background', '#FAF834');
    $('#'+element_id).css('color', '#000000');
  }
  
        EOF
      end

      def move_progress
        @builder << " <script type=\"text/javascript\">moveProgressBar('#{percent_done}');</script>"
      end

      def percent_done
        result = 100.0
        if @step_count != 0
          result = ((@step_number).to_f / @step_count.to_f * 1000).to_i / 10.0
        end
        result
      end

      def format_exception(exception)
        (["#{exception.message}"] + exception.backtrace).join("\n")
      end

      def backtrace_line(line)
        line.gsub(/^([^:]*\.(?:rb|feature|haml)):(\d*)/) do
          if ENV['TM_PROJECT_DIRECTORY']
            "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
          else
            line
          end
        end
      end

      def print_stats(features)
        @builder <<  "<script type=\"text/javascript\">document.getElementById('duration').innerHTML = \"Finished in <strong>#{format_duration(features.duration)} seconds</strong>\";</script>"
        @builder <<  "<script type=\"text/javascript\">document.getElementById('totals').innerHTML = \"#{print_stat_string(features)}\";</script>"
      end

      def print_stat_string(features)
        string = String.new
        string << dump_count(@step_mother.scenarios.length, "scenario")
        scenario_count = print_status_counts{|status| @step_mother.scenarios(status)}
        string << scenario_count if scenario_count
        string << "<br />"
        string << dump_count(@step_mother.steps.length, "step")
        step_count = print_status_counts{|status| @step_mother.steps(status)}
        string << step_count if step_count
      end

      def print_status_counts
        counts = [:failed, :skipped, :undefined, :pending, :passed].map do |status|
          elements = yield status
          elements.any? ? "#{elements.length} #{status.to_s}" : nil
        end.compact
        return " (#{counts.join(', ')})" if counts.any?
      end

      def dump_count(count, what, state=nil)
        [count, state, "#{what}#{count == 1 ? '' : 's'}"].compact.join(" ")
      end

      def create_builder(io)
        OrderedXmlMarkup.new(:target => io, :indent => 0)
      end

      class SnippetExtractor #:nodoc:
        class NullConverter; def convert(code, pre); code; end; end #:nodoc:
        begin; require 'syntax/convertors/html'; @@converter = Syntax::Convertors::HTML.for_syntax "ruby"; rescue LoadError => e; @@converter = NullConverter.new; end

        def snippet(error)
          raw_code, line = snippet_for(error[0])
          highlighted = @@converter.convert(raw_code, false)
          highlighted << "\n<span class=\"comment\"># gem install syntax to get syntax highlighting</span>" if @@converter.is_a?(NullConverter)
          post_process(highlighted, line)
        end

        def snippet_for(error_line)
          if error_line =~ /(.*):(\d+)/
            file = $1
            line = $2.to_i
            [lines_around(file, line), line]
          else
            ["# Couldn't get snippet for #{error_line}", 1]
          end
        end

        def lines_around(file, line)
          if File.file?(file)
            lines = File.open(file).read.split("\n")
            min = [0, line-3].max
            max = [line+1, lines.length-1].min
            selected_lines = []
            selected_lines.join("\n")
            lines[min..max].join("\n")
          else
            "# Couldn't get snippet for #{file}"
          end
        end

        def post_process(highlighted, offending_line)
          new_lines = []
          highlighted.split("\n").each_with_index do |line, i|
            new_line = "<span class=\"linenum\">#{offending_line+i-2}</span>#{line}"
            new_line = "<span class=\"offending\">#{new_line}</span>" if i == 2
            new_lines << new_line
          end
          new_lines.join("\n")
        end

      end
    end
  end
end
