require 'tempfile'
require 'subexec'
require 'pathname'

module MiniMagick
  class << self
    attr_accessor :processor
    attr_accessor :timeout


    # Experimental method for automatically selecting a processor
    # such as gm. Only works on *nix.
    #
    # TODO: Write tests for this and figure out what platforms it supports
    def choose_processor
      if `type -P mogrify`.size > 0
        return
      elsif `type -P gm`.size > 0
        self.processor = "gm"
      end
    end
  end

  MOGRIFY_COMMANDS = %w{adaptive-blur adaptive-resize adaptive-sharpen adjoin affine alpha annotate antialias append authenticate auto-gamma auto-level auto-orient background bench iterations bias black-threshold blue-primary point blue-shift factor blur border bordercolor brightness-contrast caption string cdl filename channel type charcoal radius chop clip clamp clip-mask filename clip-path id clone index clut contrast-stretch coalesce colorize color-matrix colors colorspace type combine comment string compose operator composite compress type contrast convolve coefficients crop cycle amount decipher filename debug events define format:option deconstruct delay delete index density depth despeckle direction type display server dispose method distort type coefficients dither method draw string edge radius emboss radius encipher filename encoding type endian type enhance equalize evaluate operator evaluate-sequence operator extent extract family name fft fill filter type flatten flip floodfill flop font name format string frame function name fuzz distance fx expression gamma gaussian-blur geometry gravity type green-primary point help identify ifft implode amount insert index intent type interlace type interline-spacing interpolate method interword-spacing kerning label string lat layers method level limit type linear-stretch liquid-rescale log format loop iterations mask filename mattecolor median radius modulate monitor monochrome morph morphology method kernel motion-blur negate noise radius normalize opaque ordered-dither NxN orient type page paint radius ping pointsize polaroid angle posterize levels precision preview type print string process image-filter profile filename quality quantizespace quiet radial-blur angle raise random-threshold low,high red-primary point regard-warnings region remap filename render repage resample resize respect-parentheses roll rotate degrees sample sampling-factor scale scene seed segments selective-blur separate sepia-tone threshold set attribute shade degrees shadow sharpen shave shear sigmoidal-contrast size sketch solarize threshold splice spread radius strip stroke strokewidth stretch type style type swap indexes swirl degrees texture filename threshold thumbnail tile filename tile-offset tint transform transparent transparent-color transpose transverse treedepth trim type type undercolor unique-colors units type unsharp verbose version view vignette virtual-pixel method wave weight type white-point point white-threshold write filename}

  class Error < RuntimeError; end
  class Invalid < StandardError; end

  class Image
    # @return [String] The location of the current working file
    attr :path

    # Class Methods
    # -------------
    class << self
      # This is the primary loading method used by all of the other class methods.
      #
      # Use this to pass in a stream object. Must respond to Object#read(size) or be a binary string object (BLOBBBB)
      #
      # As a change from the old API, please try and use IOStream objects. They are much, much better and more efficient!
      #
      # Probably easier to use the #open method if you want to open a file or a URL.
      #
      # @param stream [IOStream, String] Some kind of stream object that needs to be read or is a binary String blob!
      # @param ext [String] A manual extension to use for reading the file. Not required, but if you are having issues, give this a try.
      # @return [Image]
      def read(stream, ext = nil)
        if stream.is_a?(String)
          stream = StringIO.new(stream)
        end

        create(ext) do |f|
          while chunk = stream.read(8192)
            f.write(chunk)
          end
        end
      end

      # @deprecated Please use Image.read instead!
      def from_blob(blob, ext = nil)
        warn "Warning: MiniMagick::Image.from_blob method is deprecated. Instead, please use Image.read"
        create(ext) { |f| f.write(blob) }
      end

      # Opens a specific image file either on the local file system or at a URI.
      #
      # Use this if you don't want to overwrite the image file.
      #
      # Extension is either guessed from the path or you can specify it as a second parameter.
      #
      # If you pass in what looks like a URL, we require 'open-uri' before opening it.
      #
      # @param file_or_url [String] Either a local file path or a URL that open-uri can read
      # @param ext [String] Specify the extension you want to read it as
      # @return [Image] The loaded image
      def open(file_or_url, ext = File.extname(file_or_url))
        file_or_url = file_or_url.to_s # Force it to be a String... hell or highwater
        if file_or_url.include?("://")
          require 'open-uri'
          self.read(Kernel::open(file_or_url), ext)
        else
          File.open(file_or_url, "rb") do |f|
            self.read(f, ext)
          end
        end
      end

      # @deprecated Please use MiniMagick::Image.open(file_or_url) now
      def from_file(file, ext = nil)
        warn "Warning: MiniMagick::Image.from_file is now deprecated. Please use Image.open"
        open(file, ext)
      end

      # Used to create a new Image object data-copy. Not used to "paint" or that kind of thing.
      #
      # Takes an extension in a block and can be used to build a new Image object. Used
      # by both #open and #read to create a new object! Ensures we have a good tempfile!
      #
      # @param ext [String] Specify the extension you want to read it as
      # @yield [IOStream] You can #write bits to this object to create the new Image
      # @return [Image] The created image
      def create(ext = nil, &block)
        begin
          tempfile = Tempfile.new(['mini_magick', ext.to_s])
          tempfile.binmode
          block.call(tempfile)
          tempfile.close

          image = self.new(tempfile.path, tempfile)

          if !image.valid?
            raise MiniMagick::Invalid
          end
          return image
        ensure
          tempfile.close if tempfile
        end
      end
    end

    # Create a new MiniMagick::Image object
    #
    # _DANGER_: The file location passed in here is the *working copy*. That is, it gets *modified*.
    # you can either copy it yourself or use the MiniMagick::Image.open(path) method which creates a
    # temporary file for you and protects your original!
    #
    # @param input_path [String] The location of an image file
    # @todo Allow this to accept a block that can pass off to Image#combine_options
    def initialize(input_path, tempfile = nil)
      @path = input_path
      @tempfile = tempfile # ensures that the tempfile will stick around until this image is garbage collected.
    end
    
    def escaped_path
      Pathname.new(@path).to_s.gsub(" ", "\\ ")
    end

    # Checks to make sure that MiniMagick can read the file and understand it.
    #
    # This uses the 'identify' command line utility to check the file. If you are having
    # issues with this, then please work directly with the 'identify' command and see if you
    # can figure out what the issue is.
    #
    # @return [Boolean]
    def valid?
      run_command("identify", @path)
      true
    rescue MiniMagick::Invalid
      false
    end

    # A rather low-level way to interact with the "identify" command. No nice API here, just
    # the crazy stuff you find in ImageMagick. See the examples listed!
    #
    # @example
    #    image["format"]      #=> "TIFF"
    #    image["height"]      #=> 41 (pixels)
    #    image["width"]       #=> 50 (pixels)
    #    image["colorspace"]  #=> "DirectClassRGB"
    #    image["dimensions"]  #=> [50, 41]
    #    image["size"]        #=> 2050 (bits)
    #    image["original_at"] #=> 2005-02-23 23:17:24 +0000 (Read from Exif data)
    #    image["EXIF:ExifVersion"] #=> "0220" (Can read anything from Exif)
    #
    # @param format [String] A format for the "identify" command
    # @see For reference see http://www.imagemagick.org/script/command-line-options.php#format
    # @return [String, Numeric, Array, Time, Object] Depends on the method called! Defaults to String for unknown commands
    def [](value)
      # Why do I go to the trouble of putting in newlines? Because otherwise animated gifs screw everything up
      case value.to_s
      when "colorspace"
        run_command("identify", "-format", format_option("%r"), escaped_path).split("\n")[0]
      when "format"
        run_command("identify", "-format", format_option("%m"), escaped_path).split("\n")[0]
      when "height"
        run_command("identify", "-format", format_option("%h"), escaped_path).split("\n")[0].to_i
      when "width"
        run_command("identify", "-format", format_option("%w"), escaped_path).split("\n")[0].to_i
      when "dimensions"
        run_command("identify", "-format", format_option("%w %h"), escaped_path).split("\n")[0].split.map{|v|v.to_i}
      when "size"
        File.size(@path) # Do this because calling identify -format "%b" on an animated gif fails!
      when "original_at"
        # Get the EXIF original capture as a Time object
        Time.local(*self["EXIF:DateTimeOriginal"].split(/:|\s+/)) rescue nil
      when /^EXIF\:/i
        result = run_command('identify', '-format', "\"%[#{value}]\"", escaped_path).chop
        if result.include?(",")
          read_character_data(result)
        else
          result
        end
      else
        run_command('identify', '-format', "\"#{value}\"", escaped_path).split("\n")[0]
      end
    end

    # Sends raw commands to imagemagick's `mogrify` command. The image path is automatically appended to the command.
    #
    # Remember, we are always acting on this instance of the Image when messing with this.
    #
    # @return [String] Whatever the result from the command line is. May not be terribly useful.
    def <<(*args)
      run_command("mogrify", *args << escaped_path)
    end

    # This is used to change the format of the image. That is, from "tiff to jpg" or something like that.
    # Once you run it, the instance is pointing to a new file with a new extension!
    #
    # *DANGER*: This renames the file that the instance is pointing to. So, if you manually opened the
    # file with Image.new(file_path)... then that file is DELETED! If you used Image.open(file) then
    # you are ok. The original file will still be there. But, any changes to it might not be...
    #
    # Formatting an animation into a non-animated type will result in ImageMagick creating multiple
    # pages (starting with 0).  You can choose which page you want to manipulate.  We default to the
    # first page.
    #
    # @param format [String] The target format... like 'jpg', 'gif', 'tiff', etc.
    # @param page [Integer] If this is an animated gif, say which 'page' you want with an integer. Leave as default if you don't care.
    # @return [nil]
    def format(format, page = 0)
      c = CommandBuilder.new('mogrify', '-format', format)
      yield c if block_given?
      c << @path
      run(c)

      old_path = @path.dup
      @path.sub!(/(\.\w*)?$/, ".#{format}")
      File.delete(old_path) if old_path != @path

      unless File.exists?(@path)
        begin
          FileUtils.copy_file(@path.sub(".#{format}", "-#{page}.#{format}"), @path)
        rescue => ex
          raise MiniMagick::Error, "Unable to format to #{format}; #{ex}" unless File.exist?(@path)
        end
      end
    ensure
      Dir[@path.sub(/(\.\w+)?$/, "-[0-9]*.#{format}")].each do |fname|
        File.unlink(fname)
      end
    end

    # Collapse images with sequences to the first frame (ie. animated gifs) and
    # preserve quality
    def collapse!
      run_command("mogrify", "-quality", "100", "#{path}[0]")
    end

    # Writes the temporary file out to either a file location (by passing in a String) or by
    # passing in a Stream that you can #write(chunk) to repeatedly
    #
    # @param output_to [IOStream, String] Some kind of stream object that needs to be read or a file path as a String
    # @return [IOStream, Boolean] If you pass in a file location [String] then you get a success boolean. If its a stream, you get it back.
    # Writes the temporary image that we are using for processing to the output path
    def write(output_to)
      if output_to.kind_of?(String) || !output_to.respond_to?(:write)
        FileUtils.copy_file @path, output_to
        # We need to escape the output path if it contains a space
        escaped_output_to = output_to.to_s.gsub(' ', '\\ ')
        run_command "identify", escaped_output_to # Verify that we have a good image
      else # stream
        File.open(@path, "rb") do |f|
          f.binmode
          while chunk = f.read(8192)
            output_to.write(chunk)
          end
        end
        output_to
      end
    end

    # Gives you raw image data back
    # @return [String] binary string
    def to_blob
      f = File.new @path
      f.binmode
      f.read
    ensure
      f.close if f
    end

    # If an unknown method is called then it is sent through the morgrify program
    # Look here to find all the commands (http://www.imagemagick.org/script/mogrify.php)
    def method_missing(symbol, *args)
      combine_options do |c|
        c.method_missing(symbol, *args)
      end
    end

    # You can use multiple commands together using this method. Very easy to use!
    #
    # @example
    #   image.combine_options do |c|
    #     c.draw "image Over 0,0 10,10 '#{MINUS_IMAGE_PATH}'"
    #     c.thumbnail "300x500>"
    #     c.background background
    #   end
    #
    # @yieldparam command [CommandBuilder]
    def combine_options(&block)
      c = CommandBuilder.new('mogrify')
      block.call(c)
      c << @path
      run(c)
    end

    # Check to see if we are running on win32 -- we need to escape things differently
    def windows?
      !(RUBY_PLATFORM =~ /win32|mswin|mingw/).nil?
    end

    def composite(other_image, output_extension = 'jpg', &block)
      begin
        second_tempfile = Tempfile.new(output_extension)
        second_tempfile.binmode
      ensure
        second_tempfile.close
      end

      command = CommandBuilder.new("composite")
      block.call(command) if block
      command.push(other_image.path)
      command.push(self.path)
      command.push(second_tempfile.path)

      run(command)
      return Image.new(second_tempfile.path, second_tempfile)
    end

    # Outputs a carriage-return delimited format string for Unix and Windows
    def format_option(format)
      windows? ? "\"#{format}\\n\"" : "\"#{format}\\\\n\""
    end

    def run_command(command, *args)
      # -ping "efficiently determine image characteristics."
      if command == 'identify'
        args.unshift '-ping'
      end

      run(CommandBuilder.new(command, *args))
    end

    def run(command_builder)
      command = command_builder.command

      sub = Subexec.run(command, :timeout => MiniMagick.timeout)

      if sub.exitstatus != 0
        # Clean up after ourselves in case of an error
        destroy!

        # Raise the appropriate error
        if sub.output =~ /no decode delegate/i || sub.output =~ /did not return an image/i
          raise Invalid, sub.output
        else
          # TODO: should we do something different if the command times out ...?
          # its definitely better for logging.. otherwise we dont really know
          raise Error, "Command (#{command.inspect.gsub("\\", "")}) failed: #{{:status_code => sub.exitstatus, :output => sub.output}.inspect}"
        end
      else
        sub.output
      end
    end

    def destroy!
      return if @tempfile.nil?
      File.unlink(@tempfile.path)
      @tempfile = nil
    end

    private
      # Sometimes we get back a list of character values
      def read_character_data(list_of_characters)
        chars = list_of_characters.gsub(" ", "").split(",")
        result = ""
        chars.each do |val|
          result << ("%c" % val.to_i)
        end
        result
      end
  end

  class CommandBuilder
    attr :args
    attr :command

    def initialize(command, *options)
      @command = command
      @args = []
      options.each { |arg| push(arg) }
    end

    def command
      "#{MiniMagick.processor} #{@command} #{@args.join(' ')}".strip
    end

    def method_missing(symbol, *options)
      guessed_command_name = symbol.to_s.gsub('_','-')
      if guessed_command_name == "format"
        raise Error, "You must call 'format' on the image object directly!"
      elsif MOGRIFY_COMMANDS.include?(guessed_command_name)
        add(guessed_command_name, *options)
        self
      else
        super(symbol, *args)
      end
    end

    def +(*options)
      push(@args.pop.gsub /^-/, '+')
      if options.any?
        options.each do |o|
          push "\"#{ o }\""
        end
      end
    end

    def add(command, *options)
      push "-#{command}"
      if options.any?
        options.each do |o|
          push "\"#{ o }\""
        end
      end
    end

    def push(arg)
      @args << arg.to_s.strip
    end
    alias :<< :push
  end
end
