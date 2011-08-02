require 'rack'
require 'rack/request'
require 'rack/response'
require 'rack/file'
require 'new_relic/metric_parser/metric_parser'
require 'new_relic/collection_helper'

module NewRelic
  module Rack
    class DeveloperMode

      VIEW_PATH = File.expand_path('../../../../ui/views/', __FILE__)
      HELPER_PATH = File.expand_path('../../../../ui/helpers/', __FILE__)
      require File.join(HELPER_PATH, 'developer_mode_helper.rb')


      include NewRelic::DeveloperModeHelper

      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless /^\/newrelic/ =~ ::Rack::Request.new(env).path_info
        dup._call(env)
      end

      protected

      def _call(env)
        @req = ::Rack::Request.new(env)
        @rendered = false
        case @req.path_info
        when /profile/
          profile
        when /file/
          ::Rack::File.new(VIEW_PATH).call(env)
        when /index/
          index
        when /threads/
          threads
        when /reset/
          reset
        when /show_sample_detail/
          show_sample_data
        when /show_sample_summary/
          show_sample_data
        when /show_sample_sql/
          show_sample_data
        when /explain_sql/
          explain_sql
        when /show_source/
          show_source
        when /^\/newrelic\/?$/
          index
        else
          @app.call(env)
        end
      end

      private

      def index
        get_samples
        render(:index)
      end

      def reset
        NewRelic::Agent.instance.transaction_sampler.reset!
        ::Rack::Response.new{|r| r.redirect('/newrelic/')}.finish
      end

      def explain_sql
        get_segment

        return render(:sample_not_found) unless @sample

        @sql = @segment[:sql]
        @trace = @segment[:backtrace]

        if NewRelic::Agent.agent.record_sql == :obfuscated
          @obfuscated_sql = @segment.obfuscated_sql
        end

        explanations = @segment.explain_sql
        if explanations
          @explanation = explanations.first
          if !@explanation.blank?
            first_row = @explanation.first
            # Show the standard headers if it looks like a mysql explain plan
            # Otherwise show blank headers
            if first_row.length < NewRelic::MYSQL_EXPLAIN_COLUMNS.length
              @row_headers = nil
            else
              @row_headers = NewRelic::MYSQL_EXPLAIN_COLUMNS
            end
          end
        end
        render(:explain_sql)
      end

      def profile
        NewRelic::Control.instance.profiling = params['start'] == 'true'
        index
      end

      def threads
        render(:threads)
      end

      def render(view, layout=true)
        add_rack_array = true
        if view.is_a? Hash
          layout = false
          if view[:object]
            object = view[:object]
          end

          if view[:collection]
            return view[:collection].map do |object|
              render({:partial => view[:partial], :object => object})
            end.join(' ')
          end

          if view[:partial]
            add_rack_array = false
            view = "_#{view[:partial]}"
          end
        end
        binding = Proc.new {}.binding
        if layout
          body = render_with_layout(view) do
            render_without_layout(view, binding)
          end
        else
          body = render_without_layout(view, binding)
        end
        if add_rack_array
          ::Rack::Response.new(body).finish
        else
          body
        end
      end

      # You have to call this with a block - the contents returned from
      # that block are interpolated into the layout
      def render_with_layout(view)
        body = ERB.new(File.read(File.join(VIEW_PATH, 'layouts/newrelic_default.rhtml')))
        body.result(Proc.new {}.binding)
      end

      # you have to pass a binding to this (a proc) so that ERB can have
      # access to helper functions and local variables
      def render_without_layout(view, binding)
        ERB.new(File.read(File.join(VIEW_PATH, 'newrelic', view.to_s + '.rhtml')), nil, nil, 'frobnitz').result(binding)
      end

      def content_tag(tag, contents, opts={})
        opt_values = opts.map {|k, v| "#{k}=\"#{v}\"" }.join(' ')
        "<#{tag} #{opt_values}>#{contents}</#{tag}>"
      end

      def sample
        @sample || @samples[0]
      end

      def params
        @req.params
      end

      def segment
        @segment
      end


      # show the selected source file with the highlighted selected line
      def show_source
        @filename = params['file']
        line_number = params['line'].to_i

        if !File.readable?(@filename)
          @source="<p>Unable to read #{@filename}.</p>"
          return
        end
        begin
          file = File.new(@filename, 'r')
        rescue => e
          @source="<p>Unable to access the source file #{@filename} (#{e.message}).</p>"
          return
        end
        @source = ""

        @source << "<pre>"
        file.each_line do |line|
          # place an anchor 6 lines above the selected line (if the line # < 6)
          if file.lineno == line_number - 6
            @source << "</pre><pre id = 'selected_line'>"
            @source << line.rstrip
            @source << "</pre><pre>"

            # highlight the selected line
          elsif file.lineno == line_number
            @source << "</pre><pre class = 'selected_source_line'>"
            @source << line.rstrip
            @source << "</pre><pre>"
          else
            @source << line
          end
        end
        render(:show_source)
      end

      def show_sample_data
        get_sample

        return render(:sample_not_found) unless @sample

        @request_params = @sample.params['request_params'] || {}
        @custom_params = @sample.params['custom_params'] || {}

        controller_metric = @sample.root_segment.called_segments.first.metric_name

        metric_parser = NewRelic::MetricParser::MetricParser.for_metric_named controller_metric
        @sample_controller_name = metric_parser.controller_name
        @sample_action_name = metric_parser.action_name

        @sql_segments = @sample.sql_segments
        if params['d']
          @sql_segments.sort!{|a,b| b.duration <=> a.duration }
        end
        
        render(:show_sample)
      end

      def get_samples
        @samples = NewRelic::Agent.instance.transaction_sampler.samples.select do |sample|
          sample.params[:path] != nil
        end

        return @samples = @samples.sort{|x,y| y.omit_segments_with('(Rails/Application Code Loading)|(Database/.*/.+ Columns)').duration <=>
          x.omit_segments_with('(Rails/Application Code Loading)|(Database/.*/.+ Columns)').duration} if params['h']
        return @samples = @samples.sort{|x,y| x.params[:uri] <=> y.params[:uri]} if params['u']
        @samples = @samples.reverse
      end

      def get_sample
        get_samples
        id = params['id']
        sample_id = id.to_i
        @samples.each do |s|
          if s.sample_id == sample_id
            @sample = stripped_sample(s)
            return
          end
        end
      end

      def get_segment
        get_sample
        return unless @sample

        segment_id = params['segment'].to_i
        @segment = @sample.find_segment(segment_id)
      end
    end
  end
end
