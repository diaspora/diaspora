module Rcov
  module Formatters
    class HtmlErbTemplate
      attr_accessor :local_variables

      def initialize(template_file, locals={})
        require "erb"

        template_path = File.expand_path("#{File.dirname(__FILE__)}/../templates/#{template_file}")
        @template = ERB.new(File.read(template_path))
        @local_variables = locals
        @path_relativizer = Hash.new{|h,base|
          h[base] = Pathname.new(base).cleanpath.to_s.gsub(%r{^\w:[/\\]}, "").gsub(/\./, "_").gsub(/[\\\/]/, "-") + ".html"
        }
      end

      def render
        @template.result(get_binding)
      end

      def coverage_threshold_classes(percentage)
        return 110 if percentage == 100
        return (1..10).find_all{|i| i * 10 > percentage}.map{|i| i.to_i * 10} * " " 
      end
      
      def code_coverage_html(code_coverage_percentage, is_total=false)
        %{<div class="percent_graph_legend"><tt class='#{ is_total ? 'coverage_total' : ''}'>#{ "%3.2f" % code_coverage_percentage }%</tt></div>
          <div class="percent_graph">
            <div class="covered" style="width:#{ code_coverage_percentage.round }px"></div>
            <div class="uncovered" style="width:#{ 100 - code_coverage_percentage.round }px"></div>
          </div>}
      end

      def file_filter_classes(file_path)
        file_path.split('/')[0..-2] * " "
      end
      
      def relative_filename(path)
        @path_relativizer[path]
      end
    
      def line_css(line_number)
        case fileinfo.coverage[line_number]
        when true
          "marked"
        when :inferred
          "inferred"
        else
          "uncovered"
        end
      end

      def method_missing(key, *args)
        local_variables.has_key?(key) ? local_variables[key] : super
      end

      def get_binding
        binding 
      end
    end
  end
end