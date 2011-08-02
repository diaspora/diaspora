module YARD
  module Tags
    class DefaultFactory
      TYPELIST_OPENING_CHARS = '[({<'
      TYPELIST_CLOSING_CHARS = '>})]'

      # Parses tag text and creates a new tag with descriptive text
      #
      # @param tag_name        the name of the tag to parse
      # @param [String] text   the raw tag text
      # @return [Tag]          a tag object with the tag_name and text values filled
      def parse_tag(tag_name, text)
        Tag.new(tag_name, text.strip)
      end

      # Parses tag text and creates a new tag with a key name and descriptive text
      #
      # @param tag_name        the name of the tag to parse
      # @param [String] text   the raw tag text
      # @return [Tag]          a tag object with the tag_name, name and text values filled
      def parse_tag_with_name(tag_name, text)
        name, text = *extract_name_from_text(text)
        Tag.new(tag_name, text, nil, name)
      end

      # Parses tag text and creates a new tag with formally declared types and
      # descriptive text
      #
      # @param tag_name        the name of the tag to parse
      # @param [String] text   the raw tag text
      # @return [Tag]          a tag object with the tag_name, types and text values filled
      def parse_tag_with_types(tag_name, text)
        name, types, text = *extract_types_and_name_from_text(text)
        raise TagFormatError, "cannot specify a name before type list for '@#{tag_name}'" if name
        Tag.new(tag_name, text, types)
      end

      # Parses tag text and creates a new tag with formally declared types, a key
      # name and descriptive text
      #
      # @param tag_name        the name of the tag to parse
      # @param [String] text   the raw tag text
      # @return [Tag]          a tag object with the tag_name, name, types and text values filled
      def parse_tag_with_types_and_name(tag_name, text)
        name, types, text = *extract_types_and_name_from_text(text)
        name, text = *extract_name_from_text(text) unless name
        Tag.new(tag_name, text, types, name)
      end

      def parse_tag_with_title_and_text(tag_name, text)
        title, desc = *extract_title_and_desc_from_text(text)
        Tag.new(tag_name, desc, nil, title)
      end

      def parse_tag_with_types_name_and_default(tag_name, text)
        # Can't allow () in a default tag, otherwise the grammar is too ambiguous when types is omitted.
        open, close = TYPELIST_OPENING_CHARS.gsub('(', ''), TYPELIST_CLOSING_CHARS.gsub(')', '')
        name, types, text = *extract_types_and_name_from_text(text, open, close)
        name, text = *extract_name_from_text(text) unless name
        if text =~ /\A\(/
          _, default, text = *extract_types_and_name_from_text(text, '(', ')')
          DefaultTag.new(tag_name, text, types, name, default)
        else
          DefaultTag.new(tag_name, text, types, name, nil)
        end
      end

      def parse_tag_with_options(tag_name, text)
        name, text = *extract_name_from_text(text)
        OptionTag.new(tag_name, name, parse_tag_with_types_name_and_default(tag_name, text))
      end

      private

      # Extracts the name from raw tag text returning the name and remaining value
      #
      # @param [String] text the raw tag text
      # @return [Array] an array holding the name as the first element and the
      #                 value as the second element
      def extract_name_from_text(text)
        text.strip.split(/\s+/, 2)
      end

      def extract_title_and_desc_from_text(text)
        raise TagFormatError if text.nil? || text.empty?
        title, desc = nil, nil
        if text =~ /\A[ \t]\n/
          desc = text
        else
          text = text.split(/\r?\n/)
          title = text.shift.squeeze(' ').strip
          desc = text.join("\n")
        end
        [title, desc]
      end

      # Parses a [], <>, {} or () block at the beginning of a line of text
      # into a list of comma delimited values.
      #
      # @example
      #   obj.parse_types('[String, Array<Hash, String>, nil]') # => [nil, ['String', 'Array<Hash, String>', 'nil'], ""]
      #   obj.parse_types('b<String> A string') # => ['b', ['String'], 'A string']
      #
      # @return [Array(String, Array<String>, String)] the text before the type
      #   list (or nil), followed by the type list parsed into an array of
      #   strings, followed by the text following the type list.
      def extract_types_and_name_from_text(text, opening_types = TYPELIST_OPENING_CHARS, closing_types = TYPELIST_CLOSING_CHARS)
        s, e = 0, 0
        before = ''
        list, level, seen_space = [''], 0, false
        text.split(//).each_with_index do |c, i|
          if opening_types.include?(c)
            list.last << c if level > 0
            s = i if level == 0
            level += 1
          elsif closing_types.include?(c)
            level -= 1 unless list.last[-1,1] == '='
            break e = i if level == 0
            list.last << c
          elsif c == ',' && level == 1
            list.push ''
          elsif c =~ /\S/ && level == 0
            break e = i if seen_space && list == ['']
            before << c
          elsif c =~ /\s/ && level == 0 && !before.empty?
            seen_space = true
          elsif level >= 1
            list.last << c
          end
        end

        before = before.empty? ? nil : before.strip
        if list.size == 1 && list.first == ''
          [nil, nil, text.strip]
        else
          [before, list.map {|x| x.strip }, text[(e+1)..-1].strip]
        end
      end
    end
  end
end