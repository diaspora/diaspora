require 'erb'
require 'rspec/core/formatters/base_text_formatter'

module RSpec
  module Core
    module Formatters
      class HtmlFormatter < BaseTextFormatter
        include ERB::Util # for the #h method

        def initialize(output)
          super(output)
          @example_group_number = 0
          @example_number = 0
          @header_red = nil
        end

        private
        def method_missing(m, *a, &b)
          # no-op
        end

        public
        def message(message)
        end

        # The number of the currently running example_group
        def example_group_number
          @example_group_number
        end

        # The number of the currently running example (a global counter)
        def example_number
          @example_number
        end

        def start(example_count)
          super(example_count)
          @output.puts html_header
          @output.puts report_header
          @output.flush
        end

        def example_group_started(example_group)
          super(example_group)
          @example_group_red = false
          @example_group_number += 1
          unless example_group_number == 1
            @output.puts "  </dl>"
            @output.puts "</div>"
          end
          @output.puts "<div id=\"div_group_#{example_group_number}\" class=\"example_group passed\">"
          @output.puts "  <dl #{current_indentation}>"
          @output.puts "  <dt id=\"example_group_#{example_group_number}\" class=\"passed\">#{h(example_group.description)}</dt>"
          @output.flush
        end

        def start_dump
          @output.puts "  </dl>"
          @output.puts "</div>"
          @output.flush
        end

        def example_started(example)
          super(example)
          @example_number += 1
        end

        def example_passed(example)
          move_progress
          @output.puts "    <dd class=\"example passed\"><span class=\"passed_spec_name\">#{h(example.description)}</span></dd>"
          @output.flush
        end

        def example_failed(example)
          super(example)
          exception = example.metadata[:execution_result][:exception]
          extra = extra_failure_content(exception)
          failure_style = RSpec::Core::PendingExampleFixedError === exception ? 'pending_fixed' : 'failed'
          @output.puts "    <script type=\"text/javascript\">makeRed('rspec-header');</script>" unless @header_red
          @header_red = true
          @output.puts "    <script type=\"text/javascript\">makeRed('div_group_#{example_group_number}');</script>" unless @example_group_red
          @output.puts "    <script type=\"text/javascript\">makeRed('example_group_#{example_group_number}');</script>" unless @example_group_red
          @example_group_red = true
          move_progress
          @output.puts "    <dd class=\"example #{failure_style}\">"
          @output.puts "      <span class=\"failed_spec_name\">#{h(example.description)}</span>"
          @output.puts "      <div class=\"failure\" id=\"failure_#{@failed_examples.size}\">"
          @output.puts "        <div class=\"message\"><pre>#{h(exception.message)}</pre></div>" unless exception.nil?
          @output.puts "        <div class=\"backtrace\"><pre>#{format_backtrace(exception.backtrace, example).join("\n")}</pre></div>" if exception
          @output.puts extra unless extra == ""
          @output.puts "      </div>"
          @output.puts "    </dd>"
          @output.flush
        end

        def example_pending(example)
          message = example.metadata[:execution_result][:pending_message]
          @output.puts "    <script type=\"text/javascript\">makeYellow('rspec-header');</script>" unless @header_red
          @output.puts "    <script type=\"text/javascript\">makeYellow('div_group_#{example_group_number}');</script>" unless @example_group_red
          @output.puts "    <script type=\"text/javascript\">makeYellow('example_group_#{example_group_number}');</script>" unless @example_group_red
          move_progress
          @output.puts "    <dd class=\"example not_implemented\"><span class=\"not_implemented_spec_name\">#{h(example.description)} (PENDING: #{h(message)})</span></dd>"
          @output.flush
        end

        # Override this method if you wish to output extra HTML for a failed spec. For example, you
        # could output links to images or other files produced during the specs.
        #
        def extra_failure_content(exception)
          require 'rspec/core/formatters/snippet_extractor'
          @snippet_extractor ||= SnippetExtractor.new
          "    <pre class=\"ruby\"><code>#{@snippet_extractor.snippet(exception)}</code></pre>"
        end

        def move_progress
          @output.puts "    <script type=\"text/javascript\">moveProgressBar('#{percent_done}');</script>"
          @output.flush
        end

        def percent_done
          result = 100.0
          if @example_count > 0
            result = ((example_number).to_f / @example_count.to_f * 1000).to_i / 10.0
          end
          result
        end

        def dump_failures
        end

        def dump_pending
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          # TODO - kill dry_run?
          if dry_run?
            totals = "This was a dry-run"
          else
            totals =  "#{example_count} example#{'s' unless example_count == 1}, "
            totals << "#{failure_count} failure#{'s' unless failure_count == 1}"
            totals << ", #{pending_count} pending" if pending_count > 0
          end
          @output.puts "<script type=\"text/javascript\">document.getElementById('duration').innerHTML = \"Finished in <strong>#{duration} seconds</strong>\";</script>"
          @output.puts "<script type=\"text/javascript\">document.getElementById('totals').innerHTML = \"#{totals}\";</script>"
          @output.puts "</div>"
          @output.puts "</div>"
          @output.puts "</body>"
          @output.puts "</html>"
          @output.flush
        end
        
        def current_indentation
          "style=\"margin-left: #{(example_group.ancestors.size - 1) * 15}px;\""
        end

        def html_header
          <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>RSpec results</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta http-equiv="Expires" content="-1" />
  <meta http-equiv="Pragma" content="no-cache" />
  <style type="text/css">
  body {
    margin: 0;
    padding: 0;
    background: #fff;
    font-size: 80%;
  }
  </style>
  <script type="text/javascript">
    // <![CDATA[
#{global_scripts}
    // ]]>
  </script>
  <style type="text/css">
#{global_styles}
  </style>
</head>
<body>
EOF
        end

        def report_header
          <<-EOF
<div class="rspec-report">

<div id="rspec-header">
  <div id="label">
    <h1>RSpec Code Examples</h1>
  </div>

  <div id="display-filters">
    <input id="passed_checkbox" name="passed_checkbox" type="checkbox" checked onchange="apply_filters()" value="1"> <label for="passed_checkbox">Passed</label>
    <input id="failed_checkbox" name="failed_checkbox" type="checkbox" checked onchange="apply_filters()" value="2"> <label for="failed_checkbox">Failed</label>
    <input id="pending_checkbox" name="pending_checkbox" type="checkbox" checked onchange="apply_filters()" value="3"> <label for="pending_checkbox">Pending</label>
  </div>

  <div id="summary">
    <p id="totals">&nbsp;</p>
    <p id="duration">&nbsp;</p>
  </div>
</div>


<div class="results">
EOF
        end

        def global_scripts
          <<-EOF

function addClass(element_id, classname) {
  document.getElementById(element_id).className += (" " + classname);
}

function removeClass(element_id, classname) {
  var elem = document.getElementById(element_id);
  var classlist = elem.className.replace(classname,'');
  elem.className = classlist;
}

function moveProgressBar(percentDone) {
  document.getElementById("rspec-header").style.width = percentDone +"%";
}

function makeRed(element_id) {
  removeClass(element_id, 'passed');
  removeClass(element_id, 'not_implemented');
  addClass(element_id,'failed');
}

function makeYellow(element_id) {
  var elem = document.getElementById(element_id);
  if (elem.className.indexOf("failed") == -1) {  // class doesn't includes failed
    if (elem.className.indexOf("not_implemented") == -1) { // class doesn't include not_implemented
      removeClass(element_id, 'passed');
      addClass(element_id,'not_implemented');
    }
  }
}

function apply_filters() {
  var passed_filter = document.getElementById('passed_checkbox').checked;
  var failed_filter = document.getElementById('failed_checkbox').checked;
  var pending_filter = document.getElementById('pending_checkbox').checked;

  assign_display_style("example passed", passed_filter);
  assign_display_style("example failed", failed_filter);
  assign_display_style("example not_implemented", pending_filter);

  assign_display_style_for_group("example_group passed", passed_filter);
  assign_display_style_for_group("example_group not_implemented", pending_filter, pending_filter || passed_filter);
  assign_display_style_for_group("example_group failed", failed_filter, failed_filter || pending_filter || passed_filter);
}

function get_display_style(display_flag) {
  var style_mode = 'none';
  if (display_flag == true) {
    style_mode = 'block';
  }
  return style_mode;
}

function assign_display_style(classname, display_flag) {
  var style_mode = get_display_style(display_flag);
  var elems = document.getElementsByClassName(classname)
  for (var i=0; i<elems.length;i++) {
    elems[i].style.display = style_mode;
  }
}

function assign_display_style_for_group(classname, display_flag, subgroup_flag) {
  var display_style_mode = get_display_style(display_flag);
  var subgroup_style_mode = get_display_style(subgroup_flag);
  var elems = document.getElementsByClassName(classname)
  for (var i=0; i<elems.length;i++) {
    var style_mode = display_style_mode;
    if ((display_flag != subgroup_flag) && (elems[i].getElementsByTagName('dt')[0].innerHTML.indexOf(", ") != -1)) {
      elems[i].style.display = subgroup_style_mode;
    } else {
      elems[i].style.display = display_style_mode;
    }
  }
}
EOF
        end

        def global_styles
          <<-EOF
#rspec-header {
  background: #65C400; color: #fff; height: 4em;
}

.rspec-report h1 {
  margin: 0px 10px 0px 10px;
  padding: 10px;
  font-family: "Lucida Grande", Helvetica, sans-serif;
  font-size: 1.8em;
  position: absolute;
}

#label {
  float:left;
}

#display-filters {
  float:left;
  padding: 28px 0 0 40%;
  font-family: "Lucida Grande", Helvetica, sans-serif;
}

#summary {
  float:right;
  padding: 5px 10px;
  font-family: "Lucida Grande", Helvetica, sans-serif;
  text-align: right;
}

#summary p {
  margin: 0 0 0 2px;
}

#summary #totals {
  font-size: 1.2em;
}

.example_group {
  margin: 0 10px 5px;
  background: #fff;
}

dl {
  margin: 0; padding: 0 0 5px;
  font: normal 11px "Lucida Grande", Helvetica, sans-serif;
}

dt {
  padding: 3px;
  background: #65C400;
  color: #fff;
  font-weight: bold;
}

dd {
  margin: 5px 0 5px 5px;
  padding: 3px 3px 3px 18px;
}


dd.example.passed {
  border-left: 5px solid #65C400;
  border-bottom: 1px solid #65C400;
  background: #DBFFB4; color: #3D7700;
}

dd.example.not_implemented {
  border-left: 5px solid #FAF834;
  border-bottom: 1px solid #FAF834;
  background: #FCFB98; color: #131313;
}

dd.example.pending_fixed {
  border-left: 5px solid #0000C2;
  border-bottom: 1px solid #0000C2;
  color: #0000C2; background: #D3FBFF;
}

dd.example.failed {
  border-left: 5px solid #C20000;
  border-bottom: 1px solid #C20000;
  color: #C20000; background: #FFFBD3;
}


dt.not_implemented {
  color: #000000; background: #FAF834;
}

dt.pending_fixed {
  color: #FFFFFF; background: #C40D0D;
}

dt.failed {
  color: #FFFFFF; background: #C40D0D;
}


#rspec-header.not_implemented {
  color: #000000; background: #FAF834;
}

#rspec-header.pending_fixed {
  color: #FFFFFF; background: #C40D0D;
}

#rspec-header.failed {
  color: #FFFFFF; background: #C40D0D;
}


.backtrace {
  color: #000;
  font-size: 12px;
}

a {
  color: #BE5C00;
}

/* Ruby code, style similar to vibrant ink */
.ruby {
  font-size: 12px;
  font-family: monospace;
  color: white;
  background-color: black;
  padding: 0.1em 0 0.2em 0;
}

.ruby .keyword { color: #FF6600; }
.ruby .constant { color: #339999; }
.ruby .attribute { color: white; }
.ruby .global { color: white; }
.ruby .module { color: white; }
.ruby .class { color: white; }
.ruby .string { color: #66FF00; }
.ruby .ident { color: white; }
.ruby .method { color: #FFCC00; }
.ruby .number { color: white; }
.ruby .char { color: white; }
.ruby .comment { color: #9933CC; }
.ruby .symbol { color: white; }
.ruby .regex { color: #44B4CC; }
.ruby .punct { color: white; }
.ruby .escape { color: white; }
.ruby .interp { color: white; }
.ruby .expr { color: white; }

.ruby .offending { background-color: gray; }
.ruby .linenum {
  width: 75px;
  padding: 0.1em 1em 0.2em 0;
  color: #000000;
  background-color: #FFFBD3;
}
EOF
        end
      end
    end
  end
end
