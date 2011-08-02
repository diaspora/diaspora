module Rcov
  class HTMLCoverage < BaseFormatter # :nodoc:
    require 'fileutils'

    DEFAULT_OPTS = {:color => false, :fsr => 30, :destdir => "coverage",
                    :callsites => false, :cross_references => false,
                    :charset => nil }

    def initialize(opts = {})
      options = DEFAULT_OPTS.clone.update(opts)
      super(options)
      @dest = options[:destdir]
      @css = options[:css]
      @color = options[:color]
      @fsr = options[:fsr]
      @do_callsites = options[:callsites]
      @do_cross_references = options[:cross_references]
      @span_class_index = 0
      @charset = options[:charset]
    end

    def execute
      return if @files.empty?
      FileUtils.mkdir_p @dest
      
      # Copy collaterals
      ['screen.css','print.css','rcov.js','jquery-1.3.2.min.js','jquery.tablesorter.min.js'].each do |_file|
        _src = File.expand_path("#{File.dirname(__FILE__)}/../templates/#{_file}")
        FileUtils.cp(_src, File.join(@dest, "#{_file}"))
      end

      # Copy custom CSS, if any
      if @css
        begin
          _src = File.expand_path("#{@dest}/../#{@css}")
          FileUtils.cp(_src, File.join(@dest, "custom.css"))
        rescue
          @css = nil
        end
      end
      
      create_index(File.join(@dest, "index.html"))

      each_file_pair_sorted do |filename, fileinfo|
        create_file(File.join(@dest, mangle_filename(filename)), fileinfo)
      end
    end

    private

    class SummaryFileInfo  # :nodoc:
      def initialize(obj)
        @o = obj 
      end

      def num_lines
        @o.num_lines
      end

      def num_code_lines
        @o.num_code_lines
      end

      def code_coverage
        @o.code_coverage
      end

      def code_coverage_for_report
        code_coverage * 100
      end

      def total_coverage
        @o.total_coverage
      end

      def total_coverage_for_report
        total_coverage * 100
      end

      def name
        "TOTAL" 
      end
    end

    def create_index(destname)

      doc = Rcov::Formatters::HtmlErbTemplate.new('index.html.erb',
        :project_name => project_name,
        :generated_on => Time.now,
        :css => @css,
        :rcov => Rcov,
        :formatter => self,
        :output_threshold => @output_threshold,
        :total => SummaryFileInfo.new(self),
        :files => each_file_pair_sorted.map{|k,v| v}
      )
      File.open(destname, "w") { |f| f.puts doc.render }
    end

    def create_file(destfile, fileinfo)
      doc = Rcov::Formatters::HtmlErbTemplate.new('detail.html.erb',
        :project_name => project_name,
        :rcov_page_title => fileinfo.name, 
        :css => @css,
        :generated_on => Time.now,
        :rcov => Rcov,
        :formatter => self,
        :output_threshold => @output_threshold,
        :fileinfo => fileinfo
      )
      File.open(destfile, "w")  { |f| f.puts doc.render }
    end
    
    private
    
    def project_name
      Dir.pwd.split('/')[-1].split(/[^a-zA-Z0-9]/).map{|i| i.gsub(/[^a-zA-Z0-9]/,'').capitalize} * " " || ""
    end
    
  end

  class HTMLProfiling < HTMLCoverage # :nodoc:
    DEFAULT_OPTS = {:destdir => "profiling"}
    def initialize(opts = {})
      options = DEFAULT_OPTS.clone.update(opts)
      super(options)
      @max_cache = {}
      @median_cache = {}
    end

    def default_title
      "Bogo-profile information"
    end

    def default_color
      if @color
        "rgb(179,205,255)"
      else
        "rgb(255, 255, 255)"
      end
    end

    def output_color_table?
      false
    end

    def span_class(sourceinfo, marked, count)
      full_scale_range = @fsr # dB
      nz_count = sourceinfo.counts.select{|x| x && x != 0}
      nz_count << 1 # avoid div by 0
      max = @max_cache[sourceinfo] ||= nz_count.max
      #avg = @median_cache[sourceinfo] ||= 1.0 *
      #    nz_count.inject{|a,b| a+b} / nz_count.size
      median = @median_cache[sourceinfo] ||= 1.0 * nz_count.sort[nz_count.size/2]
      max ||= 2
      max = 2 if max == 1
      if marked == true
        count = 1 if !count || count == 0
        idx = 50 + 1.0 * (500/full_scale_range) * Math.log(count/median) / Math.log(10)
        idx = idx.to_i
        idx = 0 if idx < 0
        idx = 100 if idx > 100
        "run#{idx}"
      else
        nil
      end
    end
  end

  class RubyAnnotation < BaseFormatter # :nodoc:
    DEFAULT_OPTS = { :destdir => "coverage" }
    def initialize(opts = {})
      options = DEFAULT_OPTS.clone.update(opts)
      super(options)
      @dest = options[:destdir]
      @do_callsites = true
      @do_cross_references = true

      @mangle_filename = Hash.new{ |h,base|
        h[base] = Pathname.new(base).cleanpath.to_s.gsub(%r{^\w:[/\\]}, "").gsub(/\./, "_").gsub(/[\\\/]/, "-") + ".rb"
      }
    end

    def execute
      return if @files.empty?
      FileUtils.mkdir_p @dest
      each_file_pair_sorted do |filename, fileinfo|
        create_file(File.join(@dest, mangle_filename(filename)), fileinfo)
      end
    end

    private

    def format_lines(file)
      result = ""
      format_line = "%#{file.num_lines.to_s.size}d"
      file.num_lines.times do |i|
        line = file.lines[i].chomp
        marked = file.coverage[i]
        count = file.counts[i]
        result << create_cross_refs(file.name, i+1, line, marked) + "\n"
      end
      result
    end

    def create_cross_refs(filename, lineno, linetext, marked)
      return linetext unless @callsite_analyzer && @do_callsites
      ref_blocks = []
      _get_defsites(ref_blocks, filename, lineno, linetext, ">>") do |ref|
        if ref.file
          ref.file.sub!(%r!^./!, '')
          where = "at #{mangle_filename(ref.file)}:#{ref.line}"
        else
          where = "(C extension/core)"
        end
        "#{ref.klass}##{ref.mid} " + where + ""
      end
      _get_callsites(ref_blocks, filename, lineno, linetext, "<<") do |ref| # "
        ref.file.sub!(%r!^./!, '')
        "#{mangle_filename(ref.file||'C code')}:#{ref.line} " + "in #{ref.klass}##{ref.mid}"
      end

      create_cross_reference_block(linetext, ref_blocks, marked)
    end

    def create_cross_reference_block(linetext, ref_blocks, marked)
      codelen = 75
      if ref_blocks.empty?
        if marked
          return "%-#{codelen}s #o" % linetext
        else
          return linetext
        end
      end
      ret = ""
      @cross_ref_idx ||= 0
      @known_files ||= sorted_file_pairs.map{|fname, finfo| normalize_filename(fname)}
      ret << "%-#{codelen}s # " % linetext
      ref_blocks.each do |refs, toplabel, label_proc|
        unless !toplabel || toplabel.empty?
          ret << toplabel << " "
        end
        refs.each do |dst|
          dstfile = normalize_filename(dst.file) if dst.file
          dstline = dst.line
          label = label_proc.call(dst)
          if dst.file && @known_files.include?(dstfile)
            ret << "[[" << label << "]], "
          else
            ret << label << ", "
          end
        end
      end
      ret
    end

    def create_file(destfile, fileinfo)
      #body = format_lines(fileinfo)
      #File.open(destfile, "w") do |f|
        #f.puts body
        #f.puts footer(fileinfo)
      #end
    end

    def footer(fileinfo)
      s  = "# Total lines    : %d\n" % fileinfo.num_lines
      s << "# Lines of code  : %d\n" % fileinfo.num_code_lines
      s << "# Total coverage : %3.1f%%\n" % [ fileinfo.total_coverage*100 ]
      s << "# Code coverage  : %3.1f%%\n\n" % [ fileinfo.code_coverage*100 ]
      # prevents false positives on Emacs
      s << "# Local " "Variables:\n" "# mode: " "rcov-xref\n" "# End:\n"
    end
  end
end
