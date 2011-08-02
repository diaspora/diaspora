require 'pathname'
require File.expand_path('../google_pie_chart', __FILE__)
require 'new_relic/collection_helper'
require 'new_relic/metric_parser/metric_parser'
module NewRelic::DeveloperModeHelper
  include NewRelic::CollectionHelper

  private

  # limit of how many detail/SQL rows we display - very large data sets (~10000+) crash browsers
  def trace_row_display_limit
    2000
  end

  def trace_row_display_limit_reached
   (!@detail_segment_count.nil? && @detail_segment_count > trace_row_display_limit) || @sample.sql_segments.length > trace_row_display_limit
  end

  # return the sample but post processed to strip out segments that normally don't show
  # up in production (after the first execution, at least) such as application code loading
  def stripped_sample(sample = @sample)
    sample.omit_segments_with('(Rails/Application Code Loading)|(Database/.*/.+ Columns)')
  end

  # return the highest level in the call stack for the trace that is not rails or
  # newrelic agent code
  def application_caller(trace)
    trace = strip_nr_from_backtrace(trace) unless params[:show_nr]
    trace.each do |trace_line|
      file = file_and_line(trace_line).first
      unless exclude_file_from_stack_trace?(file, false)
        return trace_line
      end
    end
    trace.last
  end

  def application_stack_trace(trace, include_rails = false)
    trace = strip_nr_from_backtrace(trace) unless params[:show_nr]
    trace.reject do |trace_line|
      file = file_and_line(trace_line).first
      exclude_file_from_stack_trace?(file, include_rails)
    end
  end

  def render_backtrace
    if @segment[:backtrace]
      content_tag('h3', 'Application Stack Trace') +
      render(:partial => 'stack_trace')
    end
  end

  def h(text)
    text
  end

  def agent_views_path(path)
    path
  end

  def url_for_source(trace_line)
    file, line = file_and_line(trace_line)

    begin
      file = Pathname.new(file).realpath
    rescue Errno::ENOENT
      # we hit this exception when Pathame.realpath fails for some reason; attempt a link to
      # the file without a real path.  It may also fail, only when the user clicks on this specific
      # entry in the stack trace
    rescue
      # catch all other exceptions.  We're going to create an invalid link below, but that's okay.
    end

    if using_textmate?
      "txmt://open?url=file://#{file}&line=#{line}"
    else
      "show_source?file=#{file}&amp;line=#{line}&amp;anchor=selected_line"
    end
  end

  def dev_name(metric_name)
    NewRelic::MetricParser::MetricParser.parse(metric_name).developer_name
  end

  # write the metric label for a segment metric in the detail view
  def write_segment_label(segment)
    if source_available && segment[:backtrace] && (source_url = url_for_source(application_caller(segment[:backtrace])))
      link_to dev_name(segment.metric_name), source_url
    else
      dev_name(segment.metric_name)
    end
  end

  def source_available
    true
  end

  # write the metric label for a segment metric in the summary table of metrics
  def write_summary_segment_label(segment)
    dev_name(segment.metric_name)
  end

  def write_stack_trace_line(trace_line)
    link_to trace_line, url_for_source(trace_line)
  end

  # write a link to the source for a trace
  def link_to_source(trace)
    image_url = 'file/images/' + (using_textmate? ? "textmate.png" : "file_icon.png")

    link_to "<img src=#{image_url} alt=\"View Source\" title=\"View Source\"/>", url_for_source(application_caller(trace))
  end

  # print the formatted timestamp for a segment
  def timestamp(segment)
    sprintf("%1.3f", segment.entry_timestamp)
  end

  def format_timestamp(time)
    time.strftime("%H:%M:%S")
  end

  def colorize(value, yellow_threshold = 0.05, red_threshold = 0.15, s=to_ms(value))
    if value > yellow_threshold
      color = (value > red_threshold ? 'red' : 'orange')
      "<font color=#{color}>#{s}</font>"
    else
      "#{s}"
    end
  end

  def expanded_image_path()
    '/newrelic/file/images/arrow-open.png'
  end

  def collapsed_image_path()
    '/newrelic/file/images/arrow-close.png'
  end

  def explain_sql_url(segment)
    "explain_sql?id=#{@sample.sample_id}&amp;segment=#{segment.segment_id}"
  end

  def segment_duration_value(segment)
    link_to colorize(segment.duration, 0.05, 0.15, "#{with_delimiter(to_ms(segment.duration))} ms"), explain_sql_url(segment)
  end

  def line_wrap_sql(sql)
    sql.gsub(/\,/,', ').squeeze(' ') if sql
  end

  def render_sample_details(sample)
    @indentation_depth=0
    # skip past the root segments to the first child, which is always the controller
    first_segment = sample.root_segment.called_segments.first

    # render the segments, then the css classes to indent them
    render_segment_details(first_segment).to_s + render_indentation_classes(@indentation_depth).to_s
  end

  # the rows logger plugin disables the sql tracing functionality of the NewRelic agent -
  # notify the user about this
  def rows_logger_present?
    File.exist?(File.join(File.dirname(__FILE__), "../../../rows_logger/init.rb"))
  end

  def expand_segment_image(segment, depth)
    if depth > 0
      if !segment.called_segments.empty?
        row_class =segment_child_row_class(segment)
        link_to_function("<img src=\"#{collapsed_image_path}\" id=\"image_#{row_class}\" class_for_children=\"#{row_class}\" class=\"#{(!segment.called_segments.empty?) ? 'parent_segment_image' : 'child_segment_image'}\"", "toggle_row_class(this)")
      end
    end
  end

  def segment_child_row_class(segment)
    "segment#{segment.segment_id}"
  end

  def summary_pie_chart(sample, width, height)
    pie_chart = GooglePieChart.new
    pie_chart.color, pie_chart.width, pie_chart.height = '6688AA', width, height

    chart_data = sample.breakdown_data(6)
    chart_data.each { |s| pie_chart.add_data_point dev_name(s.metric_name), to_ms(s.exclusive_time) }

    pie_chart.render
  end

  def segment_row_classes(segment, depth)
    classes = []

    classes << "segment#{segment.parent_segment.segment_id}" if depth > 1

    classes << "view_segment" if segment.metric_name.index('View') == 0
    classes << "summary_segment" if segment.is_a?(NewRelic::TransactionSample::CompositeSegment)

    classes.join(' ')
  end

  # render_segment_details should be called before calling this method
  def render_indentation_classes(depth)
    styles = []
     (1..depth).each do |d|
      styles <<  ".segment_indent_level#{d} { display: inline-block; margin-left: #{(d-1)*20}px }"
    end
    content_tag("style", styles.join(' '))
  end

  def sql_link_mouseover_options(segment)
    { :onmouseover => "sql_mouse_over(#{segment.segment_id})", :onmouseout => "sql_mouse_out(#{segment.segment_id})"}
  end

  def explain_sql_link(segment, child_sql = false)
    link_to 'SQL', explain_sql_url(segment)+ '"' + sql_link_mouseover_options(segment).map {|k,v| "#{k}=\"#{v}\""}.join(' ')+ 'fake=\"'
  end

  def explain_sql_links(segment)
    if segment[:sql]
      explain_sql_link segment
    else
      links = []
      segment.called_segments.each do |child|
        if child[:sql]
          links << explain_sql_link(child, true)
        end
      end
      links[0..1].join(', ') + (links.length > 2?', ...':'')
    end
  end

  private
  def file_and_line(stack_trace_line)
    stack_trace_line.match(/(.*):(\d+)/)[1..2]
  end

  def using_textmate?
    NewRelic::Control.instance.use_textmate?
  end


  def render_segment_details(segment, depth=0)
    @detail_segment_count ||= 0
    @detail_segment_count += 1

    return '' if @detail_segment_count > trace_row_display_limit

    @indentation_depth = depth if depth > @indentation_depth
    repeat = nil
    if segment.is_a?(NewRelic::TransactionSample::CompositeSegment)
      html = ''
    else
      repeat = segment.parent_segment.detail_segments.length if segment.parent_segment.is_a?(NewRelic::TransactionSample::CompositeSegment)
      html = render(:partial => 'segment', :object => [segment, depth, repeat])
      depth += 1
    end

    segment.called_segments.each do |child|
      html << render_segment_details(child, depth)
    end

    html
  end

  def exclude_file_from_stack_trace?(file, include_rails)
    return false if include_rails
    return true if file !~ /\.(rb|java)/
    %w[/actionmailer/
             /activerecord
             /activeresource
             /activesupport
             /lib/mongrel
             /actionpack
             /passenger/
             /railties
             benchmark.rb].each { |s| return true if file.include? s }
     false
  end

  def show_view_link(title, page_name)
    link_to_function("[#{title}]", "show_view('#{page_name}')");
  end


  def link_to(name, location)
    location = "/newrelic/#{location}" unless /:\/\// =~ location
    "<a href=\"#{location}\">#{name}</a>"
  end

  def link_to_if(predicate, text, location="")
    if predicate
      link_to(text, location)
    else
      text
    end
  end

  def link_to_unless_current(text, hash)
    unless params[hash.keys[0].to_s]
      link_to(text,"?#{hash.keys[0]}=#{hash.values[0]}")
    else
      text
    end
  end

  def cycle(even, odd)
    @cycle ||= 'a'
    if @cycle == 'a'
      @cycle = 'b'
      even
    else
      @cycle = 'a'
      odd
    end
  end

  def link_to_function(title, javascript)
    "<a href=\"#\" onclick=\"#{javascript}; return false;\">#{title}</a>"
  end

  def mime_type_from_extension(extension)
    extension = extension[/[^.]*$/].dncase
    case extension
      when 'png'; 'image/png'
      when 'gif'; 'image/gif'
      when 'jpg'; 'image/jpg'
      when 'css'; 'text/css'
      when 'js'; 'text/javascript'
    else 'text/plain'
    end
  end
  def to_ms(number)
   (number*1000).round
  end
  def to_percentage(value)
   (value * 100).round if value
  end
  def with_delimiter(val)
    return '0' if val.nil?
    parts = val.to_s.split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    parts.join '.'
  end

  def profile_table(profile)
    out = StringIO.new
    printer = RubyProf::GraphHtmlPrinter.new(profile)
    printer.print(out, :min_percent=>0.5)
    out.string[/<body>(.*)<\/body>/im, 0].gsub('<table>', '<table class=profile>')
  end
end
