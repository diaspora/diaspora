require 'cucumber/formatter/console'
require 'cucumber/formatter/io'
require 'fileutils'

begin
  require 'rubygems'
  require 'prawn/core'
  require "prawn/layout"
rescue LoadError => e
  e.message << "\nYou need the prawn gem. Please do 'gem install prawn'"
  raise e
end

module Cucumber
  module Formatter

    BLACK = '000000'
    GREY = '999999'

    class Pdf
      include FileUtils
      include Console
      include Io
      attr_writer :indent

      def initialize(step_mother, path_or_io, options)
        @step_mother = step_mother
        @file = ensure_file(path_or_io, "pdf")

        if(options[:dry_run])
          @status_colors = { :passed => BLACK, :skipped => BLACK, :undefined => BLACK, :failed => BLACK, :putsd => GREY}
        else
          @status_colors = { :passed => '055902', :skipped => GREY, :undefined => 'F27405', :failed => '730202', :putsd => GREY}
        end

        @pdf = Prawn::Document.new
        @scrap = Prawn::Document.new
        @doc = @scrap
        @options = options
        @exceptions = []
        @indent = 0
        @buffer = []
        load_cover_page_image
        @pdf.text "\n\n\nCucumber features", :align => :center, :size => 32
        @pdf.draw_text "Generated: #{Time.now.strftime("%Y-%m-%d %H:%M")}", :size => 10, :at => [0, 24]
        @pdf.draw_text "$ cucumber #{ARGV.join(" ")}", :size => 10, :at => [0,10]
        unless options[:dry_run]
          @pdf.bounding_box [450,100] , :width => 100 do  
            @pdf.text 'Legend', :size => 10
            @status_colors.each do |k,v|
              @pdf.fill_color v
              @pdf.text k.to_s, :size => 10
              @pdf.fill_color BLACK
            end
          end
        end
      end

      def load_cover_page_image()
        if (!load_image("features/support/logo.png"))
          load_image("features/support/logo.jpg")
        end
      end

      def load_image(image_path)
        begin
          @pdf.image open(image_path, "rb"), :position => :center, :width => 500
          true
        rescue Errno::ENOENT
          false
        end
      end

      def puts(message)
        @pdf.fill_color(@status_colors[:putsd])  
        @pdf.text message, :size => 10
        @pdf.fill_color BLACK
      end


      def after_features(features)
        @pdf.render_file(@file.path)
        puts "\ndone"
      end

      def feature_name(keyword, name)
        @pdf.start_new_page
        names = name.split("\n")
        @pdf.fill_color GREY
        @pdf.text(keyword, :align => :center)
        @pdf.fill_color BLACK
        names.each_with_index do |nameline, i|
          case i
          when 0
            @pdf.text(nameline.strip, :size => 30, :align => :center )
            @pdf.text("\n")
          else
            @pdf.text(nameline.strip, :size => 12)
          end
        end
        @pdf.move_down(30)
      end

      def after_feature_element(feature_element)
        flush
      end

      def after_feature(feature)
        flush
      end

      def feature_element_name(keyword, name)
        names = name.empty? ? [name] : name.split("\n")
        print "."
        STDOUT.flush

        keep_with do
          @doc.move_down(20)
          @doc.fill_color GREY
          @doc.text("#{keyword}", :size => 8)
          @doc.fill_color BLACK
          @doc.text("#{names[0]}", :size => 16)
          names[1..-1].each { |s| @doc.text(s, :size => 12) }
          @doc.text("\n")
        end
      end

      def step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
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
      end

      def step_name(keyword, step_match, status, source_indent, background)
        return if @hide_this_step
        line = "#{keyword} #{step_match.format_args("%s")}"
        colorize(line, status)
      end

      def before_background(background)
        @in_background = true
      end

      def after_background(background)
        @in_background = nil
      end

      def before_multiline_arg(table)
        return if @hide_this_step
        if(table.kind_of? Cucumber::Ast::Table)
          keep_with do
            print_table(table, ['ffffff', 'f0f0f0'])
          end
        end
      end

      #using row_color hack to highlight each row correctly
      def before_outline_table(table)
        return if @hide_this_step
        row_colors = table.example_rows.map { |r| @status_colors[r.status] unless r.status == :skipped}
        keep_with do
          print_table(table, row_colors)
        end
      end

      def before_doc_string(string)
        return if @hide_this_step
        s = %{"""\n#{string}\n"""}.indent(10)
        s = s.split("\n").map{|l| l =~ /^\s+$/ ? '' : l}
        s.each do |line|
          keep_with { @doc.text(line, :size => 8) }
        end
      end

      def tag_name(tag_name)
        return if @hide_this_step
        tag = format_string(tag_name, :tag).indent(@indent)
        # TODO should we render tags at all? skipped for now. difficult to place due to page breaks
      end

      def background_name(keyword, name, file_colon_line, source_indent)
        feature_element_name(keyword, name)
      end

      def examples_name(keyword, name)
        feature_element_name(keyword, name)
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        feature_element_name(keyword, name)
      end
      
      private

      def colorize(text, status)
        keep_with do
          @doc.fill_color(@status_colors[status] || BLACK)
          @doc.text(text)
          @doc.fill_color(BLACK)
        end
      end
      
      def keep_with(&block)
        @buffer << block
      end

      def render(doc)
        @doc = doc
        @buffer.each do |proc|
          proc.call
        end
      end

      # This method does a 'test' rendering on a blank page, to see the rendered height of the buffer
      # if that too high for the space left on the age in the real document, we do a page break.
      # This obviously doesn't work if a scenario is longer than a whole page (God forbid)
      def flush
        @scrap.start_new_page
        oldy = @scrap.y
        render @scrap
        height = (oldy - @scrap.y) + 36 # whops magic number
        if ((@pdf.y - height) < @pdf.bounds.bottom)
          @pdf.start_new_page
        end
        render @pdf
        @pdf.move_down(20)
        @buffer = []
      end
      
      def print_table(table, row_colors)
        @doc.table(table.rows, :headers => table.headers, :position => :center, :row_colors => row_colors)
      end
    end
  end
end
