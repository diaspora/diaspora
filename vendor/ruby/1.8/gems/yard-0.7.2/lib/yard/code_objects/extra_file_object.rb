module YARD::CodeObjects
  # An ExtraFileObject represents an extra documentation file (README or other
  # file). It is not strictly a CodeObject (does not inherit from `Base`) although
  # it implements `path`, `name` and `type`, and therefore should be structurally
  # compatible with most CodeObject interfaces.
  class ExtraFileObject
    attr_accessor :filename
    attr_accessor :attributes
    attr_accessor :name
    attr_accessor :contents

    # Creates a new extra file object.
    # @param [String] filename the location on disk of the file
    # @param [String] contents the file contents. If not set, the contents
    #   will be read from disk using the +filename+.
    def initialize(filename, contents = nil)
      self.filename = filename
      self.name = File.basename(filename).gsub(/\.[^.]+$/, '')
      self.attributes = SymbolHash.new(false)
      parse_contents(contents || File.read(@filename))
    end

    alias path name

    def title
      attributes[:title] || name
    end

    def inspect
      "#<yardoc #{type} #{filename} attrs=#{attributes.inspect}>"
    end
    alias to_s inspect

    def type; 'extra_file' end

    def ==(other)
      return false unless self.class === other
      other.filename == filename
    end
    alias eql? ==
    alias equal? ==
    def hash; filename.hash end

    private

    # @param [String] data the file contents
    def parse_contents(data)
      retried = false
      cut_index = 0
      data = data.split("\n")
      data.each_with_index do |line, index|
        case line
        when /^#!(\S+)\s*$/
          if index == 0
            attributes[:markup] = $1
          else
            cut_index = index
            break
          end
        when /^\s*#\s*@(\S+)\s*(.+?)\s*$/
          attributes[$1] = $2
        else
          cut_index = index
          break
        end
      end
      data = data[cut_index..-1] if cut_index > 0
      self.contents = data.join("\n")
      
      if contents.respond_to?(:force_encoding) && attributes[:encoding]
        begin
          contents.force_encoding(attributes[:encoding])
        rescue ArgumentError
          log.warn "Invalid encoding `#{attributes[:encoding]}' in #{filename}"
        end
      end
    rescue ArgumentError => e
      if retried && e.message =~ /invalid byte sequence/
        # This should never happen.
        log.warn "Could not read #{filename}, #{e.message}. You probably want to set `--charset`."
        self.contents = ''
        return
      end
      data.force_encoding('binary') if data.respond_to?(:force_encoding)
      retried = true
      retry
    end
  end
end