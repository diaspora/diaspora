require 'capistrano/recipes/deploy/strategy/base'
require 'fileutils'
require 'tempfile'  # Dir.tmpdir

module Capistrano
  module Deploy
    module Strategy

      # This class implements the strategy for deployments which work
      # by preparing the source code locally, compressing it, copying the
      # file to each target host, and uncompressing it to the deployment
      # directory.
      #
      # By default, the SCM checkout command is used to obtain the local copy
      # of the source code. If you would rather use the export operation,
      # you can set the :copy_strategy variable to :export.
      #
      #   set :copy_strategy, :export
      #
      # For even faster deployments, you can set the :copy_cache variable to
      # true. This will cause deployments to do a new checkout of your
      # repository to a new directory, and then copy that checkout. Subsequent
      # deploys will just resync that copy, rather than doing an entirely new
      # checkout. Additionally, you can specify file patterns to exclude from
      # the copy when using :copy_cache; just set the :copy_exclude variable
      # to a file glob (or an array of globs).
      #
      #   set :copy_cache, true
      #   set :copy_exclude, ".git/*"
      #
      # Note that :copy_strategy is ignored when :copy_cache is set. Also, if
      # you want the copy cache put somewhere specific, you can set the variable
      # to the path you want, instead of merely 'true':
      #
      #   set :copy_cache, "/tmp/caches/myapp"
      #
      # This deployment strategy also supports a special variable,
      # :copy_compression, which must be one of :gzip, :bz2, or
      # :zip, and which specifies how the source should be compressed for
      # transmission to each host.
      class Copy < Base
        # Obtains a copy of the source code locally (via the #command method),
        # compresses it to a single file, copies that file to all target
        # servers, and uncompresses it on each of them into the deployment
        # directory.
        def deploy!
          if copy_cache
            if File.exists?(copy_cache)
              logger.debug "refreshing local cache to revision #{revision} at #{copy_cache}"
              system(source.sync(revision, copy_cache))
            else
              logger.debug "preparing local cache at #{copy_cache}"
              system(source.checkout(revision, copy_cache))
            end

            # Check the return code of last system command and rollback if not 0
            unless $? == 0
              raise Capistrano::Error, "shell command failed with return code #{$?}"
            end

            logger.debug "copying cache to deployment staging area #{destination}"
            Dir.chdir(copy_cache) do
              FileUtils.mkdir_p(destination)
              queue = Dir.glob("*", File::FNM_DOTMATCH)
              while queue.any?
                item = queue.shift
                name = File.basename(item)

                next if name == "." || name == ".."
                next if copy_exclude.any? { |pattern| File.fnmatch(pattern, item) }

                if File.symlink?(item)
                  FileUtils.ln_s(File.readlink(File.join(copy_cache, item)), File.join(destination, item))
                elsif File.directory?(item)
                  queue += Dir.glob("#{item}/*", File::FNM_DOTMATCH)
                  FileUtils.mkdir(File.join(destination, item))
                else
                  FileUtils.ln(File.join(copy_cache, item), File.join(destination, item))
                end
              end
            end
          else
            logger.debug "getting (via #{copy_strategy}) revision #{revision} to #{destination}"
            system(command)

            if copy_exclude.any?
              logger.debug "processing exclusions..."
              if copy_exclude.any?
                copy_exclude.each do |pattern| 
                  delete_list = Dir.glob(File.join(destination, pattern), File::FNM_DOTMATCH)
                  # avoid the /.. trap that deletes the parent directories
                  delete_list.delete_if { |dir| dir =~ /\/\.\.$/ }
                  FileUtils.rm_rf(delete_list.compact)
                end
              end
            end
          end

          File.open(File.join(destination, "REVISION"), "w") { |f| f.puts(revision) }

          logger.trace "compressing #{destination} to #{filename}"
          Dir.chdir(tmpdir) { system(compress(File.basename(destination), File.basename(filename)).join(" ")) }

          upload(filename, remote_filename)
          run "cd #{configuration[:releases_path]} && #{decompress(remote_filename).join(" ")} && rm #{remote_filename}"
        ensure
          FileUtils.rm filename rescue nil
          FileUtils.rm_rf destination rescue nil
        end

        def check!
          super.check do |d|
            d.local.command(source.local.command) if source.local.command
            d.local.command(compress(nil, nil).first)
            d.remote.command(decompress(nil).first)
          end
        end

        # Returns the location of the local copy cache, if the strategy should
        # use a local cache + copy instead of a new checkout/export every
        # time. Returns +nil+ unless :copy_cache has been set. If :copy_cache
        # is +true+, a default cache location will be returned.
        def copy_cache
          @copy_cache ||= configuration[:copy_cache] == true ?
            File.join(Dir.tmpdir, configuration[:application]) :
            configuration[:copy_cache]
        end

        private

          # Specify patterns to exclude from the copy. This is only valid
          # when using a local cache.
          def copy_exclude
            @copy_exclude ||= Array(configuration.fetch(:copy_exclude, []))
          end

          # Returns the basename of the release_path, which will be used to
          # name the local copy and archive file.
          def destination
            @destination ||= File.join(tmpdir, File.basename(configuration[:release_path]))
          end

          # Returns the value of the :copy_strategy variable, defaulting to
          # :checkout if it has not been set.
          def copy_strategy
            @copy_strategy ||= configuration.fetch(:copy_strategy, :checkout)
          end

          # Should return the command(s) necessary to obtain the source code
          # locally.
          def command
            @command ||= case copy_strategy
            when :checkout
              source.checkout(revision, destination)
            when :export
              source.export(revision, destination)
            end
          end

          # Returns the name of the file that the source code will be
          # compressed to.
          def filename
            @filename ||= File.join(tmpdir, "#{File.basename(destination)}.#{compression.extension}")
          end

          # The directory to which the copy should be checked out
          def tmpdir
            @tmpdir ||= configuration[:copy_dir] || Dir.tmpdir
          end

          # The directory on the remote server to which the archive should be
          # copied
          def remote_dir
            @remote_dir ||= configuration[:copy_remote_dir] || "/tmp"
          end

          # The location on the remote server where the file should be
          # temporarily stored.
          def remote_filename
            @remote_filename ||= File.join(remote_dir, File.basename(filename))
          end

          # A struct for representing the specifics of a compression type.
          # Commands are arrays, where the first element is the utility to be
          # used to perform the compression or decompression.
          Compression = Struct.new(:extension, :compress_command, :decompress_command)
          
          # The compression method to use, defaults to :gzip.
          def compression
            remote_tar = configuration[:copy_remote_tar] || 'tar'
            local_tar = configuration[:copy_local_tar] || 'tar'
            
            type = configuration[:copy_compression] || :gzip
            case type
            when :gzip, :gz   then Compression.new("tar.gz",  [local_tar, 'czf'], [remote_tar, 'xzf'])
            when :bzip2, :bz2 then Compression.new("tar.bz2", [local_tar, 'cjf'], [remote_tar, 'xjf'])
            when :zip         then Compression.new("zip",     %w(zip -qr), %w(unzip -q))
            else raise ArgumentError, "invalid compression type #{type.inspect}"
            end
          end
          
          # Returns the command necessary to compress the given directory
          # into the given file.
          def compress(directory, file)
            compression.compress_command + [file, directory]
          end

          # Returns the command necessary to decompress the given file,
          # relative to the current working directory. It must also
          # preserve the directory structure in the file.
          def decompress(file)
            compression.decompress_command + [file]
          end
      end

    end
  end
end
