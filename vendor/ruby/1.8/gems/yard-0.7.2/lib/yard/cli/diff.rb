require 'tmpdir'
require 'fileutils'
require 'open-uri'

module YARD
  module CLI
    # CLI command to return the objects that were added/removed from 2 versions
    # of a project (library, gem, working copy).
    # @since 0.6.0
    class Diff < Command
      def initialize
        super
        @list_all = false
        @use_git = false
        @old_git_commit = nil
        @old_path = Dir.pwd
        log.show_backtraces = true
      end

      def description
        'Returns the object diff of two gems or .yardoc files'
      end

      def run(*args)
        registry = optparse(*args).map do |gemfile|
          if @use_git
            load_git_commit(gemfile)
            Registry.all.map {|o| o.path }
          else
            if load_gem_data(gemfile)
              log.info "Found #{gemfile}"
              Registry.all.map {|o| o.path }
            else
              log.error "Cannot find gem #{gemfile}"
              nil
            end
          end
        end.compact

        return if registry.size != 2

        [   ["Added objects", registry[1] - registry[0]],
            ["Removed objects", registry[0] - registry[1]]].each do |name, objects|
          next if objects.empty?
          last_object = nil
          all_objects_notice = false
          puts name + ":"
          objects.sort.each do |object|
            if !@list_all && last_object && object =~ /#{Regexp.quote last_object}(::|\.|#)/
              print " (...)" unless all_objects_notice
              all_objects_notice = true
              next
            else
              puts
            end
            all_objects_notice = false
            print "  " + object
            last_object = object
          end
          puts
          puts
        end
      end

      private
      
      def load_git_commit(commit)
        commit_path = 'git_commit' + commit.gsub(/\W/, '_')
        tmpdir = File.join(Dir.tmpdir, commit_path)
        log.info "Expanding #{commit} to #{tmpdir}..."
        Dir.chdir(@old_path)
        FileUtils.mkdir_p(tmpdir)
        FileUtils.cp_r('.', tmpdir)
        Dir.chdir(tmpdir)
        log.info("git says: " + `git reset --hard #{commit}`.chomp)
        generate_yardoc(tmpdir)
        Dir.chdir(@old_path)
        cleanup(commit_path)
      end

      def load_gem_data(gemfile)
        require_rubygems
        Registry.clear

        # First check for argument as .yardoc file
        [File.join(gemfile, '.yardoc'), gemfile].each do |yardoc|
          log.info "Searching for .yardoc db at #{yardoc}"
          if File.directory?(yardoc)
            Registry.load_yardoc(yardoc)
            Registry.load_all
            return true
          end
        end

        # Next check installed RubyGems
        gemfile_without_ext = gemfile.sub(/\.gem$/, '')
        log.info "Searching for installed gem #{gemfile_without_ext}"
        Gem.source_index.find_name('').find do |spec|
          if spec.full_name == gemfile_without_ext
            if yardoc = Registry.yardoc_file_for_gem(spec.name, "= #{spec.version}")
              Registry.load_yardoc(yardoc)
              Registry.load_all
            else
              log.enter_level(Logger::ERROR) do
                olddir = Dir.pwd
                Gems.run(spec.name, spec.version.to_s)
                Dir.chdir(olddir)
              end
            end
            return true
          end
        end

        # Look for local .gem file
        gemfile += '.gem' unless gemfile =~ /\.gem$/
        log.info "Searching for local gem file #{gemfile}"
        if File.exist?(gemfile)
          File.open(gemfile, 'rb') do |io|
            expand_and_parse(gemfile, io)
          end
          return true
        end

        # Remote gemfile from rubygems.org
        url = "http://rubygems.org/downloads/#{gemfile}"
        log.info "Searching for remote gem file #{url}"
        begin
          open(url) {|io| expand_and_parse(gemfile, io) }
          return true
        rescue OpenURI::HTTPError
        end
        false
      end

      def expand_and_parse(gemfile, io)
        dir = expand_gem(gemfile, io)
        generate_yardoc(dir)
        cleanup(gemfile)
      end

      def generate_yardoc(dir)
        olddir = Dir.pwd
        Dir.chdir(dir)
        log.enter_level(Logger::ERROR) { Yardoc.run('-n', '--no-save') }
        Dir.chdir(olddir)
      end

      def expand_gem(gemfile, io)
        tmpdir = File.join(Dir.tmpdir, gemfile)
        log.info "Expanding #{gemfile} to #{tmpdir}..."
        FileUtils.mkdir_p(tmpdir)
        Gem::Package.open(io) do |pkg|
          pkg.each do |entry|
            pkg.extract_entry(tmpdir, entry)
          end
        end
        tmpdir
      end

      def require_rubygems
        require 'rubygems'
        require 'rubygems/package'
      rescue LoadError => e
        log.error "Missing RubyGems, cannot run this command."
        raise(e)
      end

      def cleanup(gemfile)
        dir = File.join(Dir.tmpdir, gemfile)
        log.info "Cleaning up #{dir}..."
        FileUtils.rm_rf(dir)
      end

      def optparse(*args)
        opts = OptionParser.new
        opts.banner = "Usage: yard diff [options] oldgem newgem"
        opts.separator ""
        opts.separator "Example: yard diff yard-0.5.6 yard-0.5.8"
        opts.separator ""
        opts.separator "If the files don't exist locally, they will be grabbed using the `gem fetch`"
        opts.separator "command. If the gem is a .yardoc directory, it will be used. Finally, if the"
        opts.separator "gem name matches an installed gem (full name-version syntax), that gem will be used."

        opts.on('-a', '--all', 'List all objects, even if they are inside added/removed module/class') do
          @list_all = true
        end
        opts.on('--git', 'Compare versions from two git commit/branches') do
          @use_git = true
        end
        common_options(opts)
        parse_options(opts, args)
        unless args.size == 2
          puts opts.banner
          exit(0)
        end

        args
      end
    end
  end
end