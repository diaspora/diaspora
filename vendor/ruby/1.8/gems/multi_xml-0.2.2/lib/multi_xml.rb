require 'base64'
require 'bigdecimal'
require 'date'
require 'multi_xml/core_extensions'
require 'time'
require 'yaml'

module MultiXml
  class ParseError < StandardError; end

  class << self

    REQUIREMENT_MAP = [
      ['libxml', :libxml],
      ['nokogiri', :nokogiri],
      ['rexml/document', :rexml]
    ] unless defined?(REQUIREMENT_MAP)

    CONTENT_ROOT = '__content__'.freeze unless defined?(CONTENT_ROOT)

    # TODO: use Time.xmlschema instead of Time.parse;
    #       use regexp instead of Date.parse
    unless defined?(PARSING)
      PARSING = {
        'symbol'       => Proc.new{|symbol| symbol.to_sym},
        'date'         => Proc.new{|date| Date.parse(date)},
        'datetime'     => Proc.new{|time| Time.parse(time).utc rescue DateTime.parse(time).utc},
        'integer'      => Proc.new{|integer| integer.to_i},
        'float'        => Proc.new{|float| float.to_f},
        'decimal'      => Proc.new{|number| BigDecimal(number)},
        'boolean'      => Proc.new{|boolean| !%w(0 false).include?(boolean.strip)},
        'string'       => Proc.new{|string| string.to_s},
        'yaml'         => Proc.new{|yaml| YAML::load(yaml) rescue yaml},
        'base64Binary' => Proc.new{|binary| binary.unpack('m').first},
        'binary'       => Proc.new{|binary, entity| parse_binary(binary, entity)},
        'file'         => Proc.new{|file, entity| parse_file(file, entity)}
      }

      PARSING.update(
        'double'   => PARSING['float'],
        'dateTime' => PARSING['datetime']
      )
    end

    # Get the current parser class.
    def parser
      return @parser if @parser
      self.parser = self.default_parser
      @parser
    end

    # The default parser based on what you currently
    # have loaded and installed. First checks to see
    # if any parsers are already loaded, then checks
    # to see which are installed if none are loaded.
    def default_parser
      return :libxml if defined?(::LibXML)
      return :nokogiri if defined?(::Nokogiri)

      REQUIREMENT_MAP.each do |(library, parser)|
        begin
          require library
          return parser
        rescue LoadError
          next
        end
      end
    end

    # Set the XML parser utilizing a symbol, string, or class.
    # Supported by default are:
    #
    # * <tt>:libxml</tt>
    # * <tt>:nokogiri</tt>
    # * <tt>:rexml</tt>
    def parser=(new_parser)
      case new_parser
      when String, Symbol
        require "multi_xml/parsers/#{new_parser.to_s.downcase}"
        @parser = MultiXml::Parsers.const_get("#{new_parser.to_s.split('_').map{|s| s.capitalize}.join('')}")
      when Class, Module
        @parser = new_parser
      else
        raise "Did not recognize your parser specification. Please specify either a symbol or a class."
      end
    end

    # Parse an XML string into Ruby.
    #
    # <b>Options</b>
    #
    # <tt>:symbolize_keys</tt> :: If true, will use symbols instead of strings for the keys.
    def parse(xml, options={})
      xml.strip!
      begin
        hash = typecast_xml_value(undasherize_keys(parser.parse(xml))) || {}
      rescue parser.parse_error => error
        raise ParseError, error.to_s, error.backtrace
      end
      hash = symbolize_keys(hash) if options[:symbolize_keys]
      hash
    end

    # This module decorates files with the <tt>original_filename</tt>
    # and <tt>content_type</tt> methods.
    module FileLike #:nodoc:
      attr_writer :original_filename, :content_type

      def original_filename
        @original_filename || 'untitled'
      end

      def content_type
        @content_type || 'application/octet-stream'
      end
    end

    private

    # TODO: Add support for other encodings
    def self.parse_binary(binary, entity) #:nodoc:
      case entity['encoding']
      when 'base64'
        Base64.decode64(binary)
      else
        binary
      end
    end

    def self.parse_file(file, entity)
      f = StringIO.new(Base64.decode64(file))
      f.extend(FileLike)
      f.original_filename = entity['name']
      f.content_type = entity['content_type']
      f
    end

    def symbolize_keys(hash)
      hash.inject({}) do |result, (key, value)|
        new_key = case key
        when String
          key.to_sym
        else
          key
        end
        new_value = case value
        when Hash
          symbolize_keys(value)
        else
          value
        end
        result[new_key] = new_value
        result
      end
    end

    def undasherize_keys(params)
      case params
      when Hash
        params.inject({}) do |hash, (key, value)|
          hash[key.to_s.tr('-', '_')] = undasherize_keys(value)
          hash
        end
      when Array
        params.map{|value| undasherize_keys(value)}
      else
        params
      end
    end

    def typecast_xml_value(value)
      case value
      when Hash
        if value['type'] == 'array'
          _, entries = Array.wrap(value.detect{|key, value| key != 'type'})
          if entries.blank? || (value.is_a?(Hash) && c = value[CONTENT_ROOT] && c.blank?)
            []
          else
            case entries
            when Array
              entries.map{|value| typecast_xml_value(value)}
            when Hash
              [typecast_xml_value(entries)]
            else
              raise "can't typecast #{entries.class.name}: #{entries.inspect}"
            end
          end
        elsif value.has_key?(CONTENT_ROOT)
          content = value[CONTENT_ROOT]
          if block = PARSING[value['type']]
            block.arity == 1 ? block.call(content) : block.call(content, value)
          else
            content
          end
        elsif value['type'] == 'string' && value['nil'] != 'true'
          ''
        # blank or nil parsed values are represented by nil
        elsif value.blank? || value['nil'] == 'true'
          nil
        # If the type is the only element which makes it then
        # this still makes the value nil, except if type is
        # a XML node(where type['value'] is a Hash)
        elsif value['type'] && value.size == 1 && !value['type'].is_a?(Hash)
          nil
        else
          xml_value = value.inject({}) do |hash, (key, value)|
            hash[key] = typecast_xml_value(value)
            hash
          end

          # Turn {:files => {:file => #<StringIO>} into {:files => #<StringIO>} so it is compatible with
          # how multipart uploaded files from HTML appear
          xml_value['file'].is_a?(StringIO) ? xml_value['file'] : xml_value
        end
      when Array
        value.map!{|i| typecast_xml_value(i)}
        value.length > 1 ? value : value.first
      when String
        value
      else
        raise "can't typecast #{value.class.name}: #{value.inspect}"
      end
    end
  end

end
