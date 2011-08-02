module Cucumber
  module Formatter
    module Io
      def ensure_io(path_or_io, name)
        return nil if path_or_io.nil?
        return path_or_io if path_or_io.respond_to?(:write)
        file = File.open(path_or_io, Cucumber.file_mode('w'))
        at_exit do
          unless file.closed?
            file.flush
            file.close
          end
        end
        file
      end

      def ensure_file(path, name)
        raise "You *must* specify --out FILE for the #{name} formatter" unless String === path
        raise "I can't write #{name} to a directory - it has to be a file" if File.directory?(path)
        ensure_io(path, name)
      end

      def ensure_dir(path, name)
        raise "You *must* specify --out DIR for the #{name} formatter" unless String === path
        raise "I can't write #{name} reports to a file - it has to be a directory" if File.file?(path)
        FileUtils.mkdir_p(path) unless File.directory?(path)
        path
      end
    end
  end
end
