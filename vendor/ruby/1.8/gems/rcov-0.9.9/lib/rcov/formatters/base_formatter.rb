module Rcov
  class BaseFormatter # :nodoc:
    require 'pathname'
    require 'rbconfig'
    RCOV_IGNORE_REGEXPS = [ /\A#{Regexp.escape(Pathname.new(::RbConfig::CONFIG['libdir']).cleanpath.to_s)}/, 
                            /\btc_[^.]*.rb/, 
                            /_test\.rb\z/, 
                            /\btest\//, 
                            /\bvendor\//, 
                            /\A#{Regexp.escape(__FILE__)}\z/
                          ]

    DEFAULT_OPTS = { :ignore => RCOV_IGNORE_REGEXPS, :sort => :name, :sort_reverse => false,
                     :output_threshold => 101, :dont_ignore => [], :callsite_analyzer => nil, \
                     :comments_run_by_default => false }

    def initialize(opts = {})
      options = DEFAULT_OPTS.clone.update(opts)
      @failure_threshold = options[:failure_threshold]
      @files = {}
      @ignore_files = options[:ignore]
      @dont_ignore_files = options[:dont_ignore]
      @sort_criterium = case options[:sort]
      when :loc then lambda{|fname, finfo| finfo.num_code_lines}
      when :coverage then lambda{|fname, finfo| finfo.code_coverage}
      else lambda { |fname, finfo| fname }
      end
      @sort_reverse = options[:sort_reverse]
      @output_threshold = options[:output_threshold]
      @callsite_analyzer = options[:callsite_analyzer]
      @comments_run_by_default = options[:comments_run_by_default]
      @callsite_index = nil

      @mangle_filename = Hash.new{|h,base|
        h[base] = Pathname.new(base).cleanpath.to_s.gsub(%r{^\w:[/\\]}, "").gsub(/\./, "_").gsub(/[\\\/]/, "-") + ".html"
      }
    end

    def add_file(filename, lines, coverage, counts)
      old_filename = filename
      filename = normalize_filename(filename)
      SCRIPT_LINES__[filename] = SCRIPT_LINES__[old_filename]
      if @ignore_files.any?{|x| x === filename} &&
        !@dont_ignore_files.any?{|x| x === filename}
        return nil
      end
      if @files[filename]
        @files[filename].merge(lines, coverage, counts)
      else
        @files[filename] = FileStatistics.new(filename, lines, counts,
        @comments_run_by_default)
      end
    end

    def normalize_filename(filename)
      File.expand_path(filename).gsub(/^#{Regexp.escape(Dir.getwd)}\//, '')
    end

    def mangle_filename(base)
      @mangle_filename[base]
    end

    def each_file_pair_sorted(&b)
      return sorted_file_pairs unless block_given?
      sorted_file_pairs.each(&b)
    end

    def sorted_file_pairs
      pairs = @files.sort_by do |fname, finfo|
        @sort_criterium.call(fname, finfo)
      end.select{|_, finfo| 100 * finfo.code_coverage < @output_threshold}
      @sort_reverse ? pairs.reverse : pairs
    end

    def total_coverage
      lines = 0
      total = 0.0
      @files.each do |k,f|
        total += f.num_lines * f.total_coverage
        lines += f.num_lines
      end
      return 0 if lines == 0
      total / lines
    end

    def code_coverage
      lines = 0
      total = 0.0
      @files.each do |k,f|
        total += f.num_code_lines * f.code_coverage
        lines += f.num_code_lines
      end
      return 0 if lines == 0
      total / lines
    end

    def num_code_lines
      lines = 0
      @files.each{|k, f| lines += f.num_code_lines }
      lines
    end

    def num_lines
      lines = 0
      @files.each{|k, f| lines += f.num_lines }
      lines
    end

    private
    
    def cross_references_for(filename, lineno)
      return nil unless @callsite_analyzer
      @callsite_index ||= build_callsite_index
      @callsite_index[normalize_filename(filename)][lineno]
    end

    def reverse_cross_references_for(filename, lineno)
      return nil unless @callsite_analyzer
      @callsite_reverse_index ||= build_reverse_callsite_index
      @callsite_reverse_index[normalize_filename(filename)][lineno]
    end

    def build_callsite_index
      index = Hash.new{|h,k| h[k] = {}}
      @callsite_analyzer.analyzed_classes.each do |classname|
        @callsite_analyzer.analyzed_methods(classname).each do |methname|
          defsite = @callsite_analyzer.defsite(classname, methname)
          index[normalize_filename(defsite.file)][defsite.line] =
          @callsite_analyzer.callsites(classname, methname)
        end
      end
      index
    end

    def build_reverse_callsite_index
      index = Hash.new{|h,k| h[k] = {}}
      @callsite_analyzer.analyzed_classes.each do |classname|
        @callsite_analyzer.analyzed_methods(classname).each do |methname|
          callsites = @callsite_analyzer.callsites(classname, methname)
          defsite = @callsite_analyzer.defsite(classname, methname)
          callsites.each_pair do |callsite, count|
            next unless callsite.file
            fname = normalize_filename(callsite.file)
            (index[fname][callsite.line] ||= []) << [classname, methname, defsite, count]
          end
        end
      end
      index
    end

    class XRefHelper < Struct.new(:file, :line, :klass, :mid, :count) # :nodoc:
    end

    def _get_defsites(ref_blocks, filename, lineno, linetext, label, &format_call_ref)
      if @do_cross_references and
        (rev_xref = reverse_cross_references_for(filename, lineno))
        refs = rev_xref.map do |classname, methodname, defsite, count|
          XRefHelper.new(defsite.file, defsite.line, classname, methodname, count)
        end.sort_by{|r| r.count}.reverse
        ref_blocks << [refs, label, format_call_ref]
      end
    end

    def _get_callsites(ref_blocks, filename, lineno, linetext, label, &format_called_ref)
      if @do_callsites and
        (refs = cross_references_for(filename, lineno))
        refs = refs.sort_by{|k,count| count}.map do |ref, count|
          XRefHelper.new(ref.file, ref.line, ref.calling_class, ref.calling_method, count)
        end.reverse
        ref_blocks << [refs, label, format_called_ref]
      end
    end
  end
end
