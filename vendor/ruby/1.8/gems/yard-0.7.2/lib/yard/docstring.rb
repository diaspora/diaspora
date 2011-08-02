module YARD
  # A documentation string, or "docstring" for short, encapsulates the
  # comments and metadata, or "tags", of an object. Meta-data is expressed
  # in the form +@tag VALUE+, where VALUE can span over multiple lines as
  # long as they are indented. The following +@example+ tag shows how tags
  # can be indented:
  #
  #   # @example My example
  #   #   a = "hello world"
  #   #   a.reverse
  #   # @version 1.0
  #
  # Tags can be nested in a documentation string, though the {Tags::Tag}
  # itself is responsible for parsing the inner tags.
  class Docstring < String
    # @return [Array<Tags::RefTag>] the list of reference tags
    attr_reader :ref_tags

    # @return [CodeObjects::Base] the object that owns the docstring.
    attr_accessor :object

    # @return [Range] line range in the {#object}'s file where the docstring was parsed from
    attr_accessor :line_range

    # @return [String] the raw documentation (including raw tag text)
    attr_reader :all

    # @return [Boolean] whether the docstring was started with "##"
    attr_reader :hash_flag
    def hash_flag=(v) @hash_flag = v == nil ? false : v end

    # Matches a tag at the start of a comment line
    META_MATCH = /^@([a-z_0-9]+)(?:\s+(.*))?$/i

    # @group Creating a Docstring Object

    # Creates a new docstring with the raw contents attached to an optional
    # object.
    #
    # @example
    #   Docstring.new("hello world\n@return Object return", someobj)
    #
    # @param [String] content the raw comments to be parsed into a docstring
    #   and associated meta-data.
    # @param [CodeObjects::Base] object an object to associate the docstring
    #   with.
    def initialize(content = '', object = nil)
      @object = object
      @summary = nil
      @hash_flag = false

      self.all = content
    end

    # Adds another {Docstring}, copying over tags.
    #
    # @param [Docstring, String] other the other docstring (or string) to
    #   add.
    # @return [Docstring] a new docstring with both docstrings combines
    def +(other)
      case other
      when Docstring
        Docstring.new([all, other.all].join("\n"), object)
      else
        super
      end
    end

    # Replaces the docstring with new raw content. Called by {#all=}.
    # @param [String] content the raw comments to be parsed
    def replace(content)
      content = content.join("\n") if content.is_a?(Array)
      @tags, @ref_tags = [], []
      @all = content
      super parse_comments(content)
    end
    alias all= replace
    
    # Deep-copies a docstring
    # 
    # @note This method creates a new docstring with new tag lists, but does
    #   not create new individual tags. Modifying the tag objects will still
    #   affect the original tags.
    # @return [Docstring] a new copied docstring
    # @since 0.7.0
    def dup
      obj = super
      %w(all summary tags ref_tags).each do |name|
        val = instance_variable_get("@#{name}")
        obj.instance_variable_set("@#{name}", val ? val.dup : nil)
      end
      obj
    end

    # @endgroup

    # @return [Fixnum] the first line of the {#line_range}
    # @return [nil] if there is no associated {#line_range}
    def line
      line_range ? line_range.first : nil
    end

    # Gets the first line of a docstring to the period or the first paragraph.
    # @return [String] The first line or paragraph of the docstring; always ends with a period.
    def summary
      return @summary if @summary
      open_parens = ['{', '(', '[']
      close_parens = ['}', ')', ']']
      num_parens = 0
      idx = length.times do |index|
        case self[index, 1]
        when ".", "\r", "\n"
          next_char = self[index + 1, 1].to_s
          if num_parens == 0 && next_char =~ /^\s*$/
            break index - 1
          end
        when "{", "(", "["
          num_parens += 1
        when "}", ")", "]"
          num_parens -= 1
        end
      end
      @summary = self[0..idx]
      @summary += '.' unless @summary.empty?
      @summary
    end
    
    # Reformats and returns a raw representation of the tag data using the
    # current tag and docstring data, not the original text.
    # 
    # @return [String] the updated raw formatted docstring data
    # @since 0.7.0
    # @todo Add Tags::Tag#to_raw and refactor
    def to_raw
      tag_data = tags.sort_by {|t| t.tag_name }.map do |tag|
        case tag
        when Tags::OverloadTag
          tag_text = "@#{tag.tag_name} #{tag.signature}\n"
          unless tag.docstring.blank?
            tag_text += "\n" + tag.docstring.all.gsub(/\r?\n/, "\n  ")
          end
        else
          tag_text = '@' + tag.tag_name
          tag_text += ' [' + tag.types.join(', ') + ']' if tag.types
          tag_text += ' ' + tag.name.to_s if tag.name
          tag_text += "\n " if tag.name && tag.text
          tag_text += ' ' + tag.text.strip.gsub(/\n/, "\n  ") if tag.text
        end
        tag_text
      end
      [strip, tag_data.join("\n")].reject {|l| l.empty? }.compact.join("\n")
    end

    # @group Creating and Accessing Meta-data

    # Creates a tag from the {Tags::DefaultFactory tag factory}.
    # 
    # To add an already created tag object, use {#add_tag}
    #
    # @param [String] tag_name the tag name
    # @param [String] tag_buf the text attached to the tag with newlines removed.
    # @return [Tags::Tag, Tags::RefTag] a tag
    def create_tag(tag_name, tag_buf)
      if tag_buf =~ /\A\s*(?:(\S+)\s+)?\(\s*see\s+(\S+)\s*\)\s*\Z/
        return create_ref_tag(tag_name, $1, $2)
      end

      tag_factory = Tags::Library.instance
      tag_method = "#{tag_name}_tag"
      if tag_name && tag_factory.respond_to?(tag_method)
        add_tag(*[tag_factory.send(tag_method, tag_buf)].flatten)
      else
        log.warn "Unknown tag @#{tag_name}" + (object ? " in file `#{object.file}` near line #{object.line}" : "")
      end
    rescue Tags::TagFormatError
      log.warn "Invalid tag format for @#{tag_name}" + (object ? " in file `#{object.file}` near line #{object.line}" : "")
    end

    # Adds a tag or reftag object to the tag list. If you want to parse
    # tag data based on the {Tags::DefaultFactory} tag factory, use {#create_tag}
    # instead.
    # 
    # @param [Tags::Tag, Tags::RefTag] tags list of tag objects to add
    # @return [void]
    def add_tag(*tags)
      tags.each_with_index do |tag, i|
        case tag
        when Tags::Tag
          tag.object = object
          @tags << tag
        when Tags::RefTag
          @ref_tags << tag
        else
          raise ArgumentError, "expected Tag or RefTag, got #{tag.class} (at index #{i})"
        end
      end
    end

    # Convenience method to return the first tag
    # object in the list of tag objects of that name
    #
    # @example
    #   doc = Docstring.new("@return zero when nil")
    #   doc.tag(:return).text  # => "zero when nil"
    #
    # @param [#to_s] name the tag name to return data for
    # @return [Tags::Tag] the first tag in the list of {#tags}
    def tag(name)
      tags.find {|tag| tag.tag_name.to_s == name.to_s }
    end

    # Returns a list of tags specified by +name+ or all tags if +name+ is not specified.
    #
    # @param [#to_s] name the tag name to return data for, or nil for all tags
    # @return [Array<Tags::Tag>] the list of tags by the specified tag name
    def tags(name = nil)
      list = @tags + convert_ref_tags
      return list unless name
      list.select {|tag| tag.tag_name.to_s == name.to_s }
    end

    # Returns true if at least one tag by the name +name+ was declared
    #
    # @param [String] name the tag name to search for
    # @return [Boolean] whether or not the tag +name+ was declared
    def has_tag?(name)
      tags.any? {|tag| tag.tag_name.to_s == name.to_s }
    end
    
    # Delete all tags with +name+
    # @param [String] name the tag name
    # @return [void]
    # @since 0.7.0
    def delete_tags(name)
      delete_tag_if {|tag| tag.tag_name.to_s == name.to_s }
    end
    
    # Deletes all tags where the block returns true
    # @yieldparam [Tags::Tag] tag the tag that is being tested
    # @yieldreturn [Boolean] true if the tag should be deleted 
    # @return [void]
    # @since 0.7.0
    def delete_tag_if(&block)
      @tags.delete_if(&block)
      @ref_tags.delete_if(&block)
    end

    # Returns true if the docstring has no content that is visible to a template.
    #
    # @param [Boolean] only_visible_tags whether only {Tags::Library.visible_tags}
    #   should be checked, or if all tags should be considered.
    # @return [Boolean] whether or not the docstring has content
    def blank?(only_visible_tags = true)
      if only_visible_tags
        empty? && !tags.any? {|tag| Tags::Library.visible_tags.include?(tag.tag_name.to_sym) }
      else
        empty? && @tags.empty? && @ref_tags.empty?
      end
    end

    # @endgroup

    private

    # Maps valid reference tags
    #
    # @return [Array<Tags::RefTag>] the list of valid reference tags
    def convert_ref_tags
      list = @ref_tags.reject {|t| CodeObjects::Proxy === t.owner }
      list.map {|t| t.tags }.flatten
    end

    # Creates a {Tags::RefTag}
    def create_ref_tag(tag_name, name, object_name)
      @ref_tags << Tags::RefTagList.new(tag_name, P(object, object_name), name)
    end

    # Parses out comments split by newlines into a new code object
    #
    # @param [String] comments
    #   the newline delimited array of comments. If the comments
    #   are passed as a String, they will be split by newlines.
    #
    # @return [String] the non-metadata portion of the comments to
    #   be used as a docstring
    def parse_comments(comments)
      comments = comments.split(/\r?\n/) if comments.is_a?(String)
      return '' if !comments || comments.empty?
      docstring = ""

      indent, last_indent = comments.first[/^\s*/].length, 0
      orig_indent = 0
      last_line = ""
      tag_name, tag_klass, tag_buf = nil, nil, []

      (comments+['']).each_with_index do |line, index|
        indent = line[/^\s*/].length
        empty = (line =~ /^\s*$/ ? true : false)
        done = comments.size == index

        if tag_name && (((indent < orig_indent && !empty) || done ||
            (indent == 0 && !empty)) || (indent <= last_indent && line =~ META_MATCH))
          create_tag(tag_name, tag_buf.join("\n"))
          tag_name, tag_buf, = nil, []
          orig_indent = 0
        end

        # Found a meta tag
        if line =~ META_MATCH
          tag_name, tag_buf = $1, [($2 || '')]
        elsif tag_name && indent >= orig_indent && !empty
          orig_indent = indent if orig_indent == 0
          # Extra data added to the tag on the next line
          last_empty = last_line =~ /^[ \t]*$/ ? true : false

          tag_buf << '' if last_empty
          tag_buf << line.gsub(/^[ \t]{#{orig_indent}}/, '')
        elsif !tag_name
          # Regular docstring text
          docstring << line << "\n"
        end

        last_indent = indent
        last_line = line
      end

      # Remove trailing/leading whitespace / newlines
      docstring.gsub!(/\A[\r\n\s]+|[\r\n\s]+\Z/, '')
    end
  end
end
