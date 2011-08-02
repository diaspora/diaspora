# encoding:utf-8
#--
# Addressable, Copyright (c) 2006-2010 Bob Aman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require "addressable/version"
require "addressable/idna"

module Addressable
  ##
  # This is an implementation of a URI parser based on
  # <a href="http://www.ietf.org/rfc/rfc3986.txt">RFC 3986</a>,
  # <a href="http://www.ietf.org/rfc/rfc3987.txt">RFC 3987</a>.
  class URI
    ##
    # Raised if something other than a uri is supplied.
    class InvalidURIError < StandardError
    end

    ##
    # Container for the character classes specified in
    # <a href="http://www.ietf.org/rfc/rfc3986.txt">RFC 3986</a>.
    module CharacterClasses
      ALPHA = "a-zA-Z"
      DIGIT = "0-9"
      GEN_DELIMS = "\\:\\/\\?\\#\\[\\]\\@"
      SUB_DELIMS = "\\!\\$\\&\\'\\(\\)\\*\\+\\,\\;\\="
      RESERVED = GEN_DELIMS + SUB_DELIMS
      UNRESERVED = ALPHA + DIGIT + "\\-\\.\\_\\~"
      PCHAR = UNRESERVED + SUB_DELIMS + "\\:\\@"
      SCHEME = ALPHA + DIGIT + "\\-\\+\\."
      AUTHORITY = PCHAR
      PATH = PCHAR + "\\/"
      QUERY = PCHAR + "\\/\\?"
      FRAGMENT = PCHAR + "\\/\\?"
    end

    ##
    # Returns a URI object based on the parsed string.
    #
    # @param [String, Addressable::URI, #to_str] uri
    #   The URI string to parse.
    #   No parsing is performed if the object is already an
    #   <code>Addressable::URI</code>.
    #
    # @return [Addressable::URI] The parsed URI.
    def self.parse(uri)
      # If we were given nil, return nil.
      return nil unless uri
      # If a URI object is passed, just return itself.
      return uri if uri.kind_of?(self)

      # If a URI object of the Ruby standard library variety is passed,
      # convert it to a string, then parse the string.
      # We do the check this way because we don't want to accidentally
      # cause a missing constant exception to be thrown.
      if uri.class.name =~ /^URI\b/
        uri = uri.to_s
      end

      if !uri.respond_to?(:to_str)
        raise TypeError, "Can't convert #{uri.class} into String."
      end
      # Otherwise, convert to a String
      uri = uri.to_str

      # This Regexp supplied as an example in RFC 3986, and it works great.
      uri_regex =
        /^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?$/
      scan = uri.scan(uri_regex)
      fragments = scan[0]
      scheme = fragments[1]
      authority = fragments[3]
      path = fragments[4]
      query = fragments[6]
      fragment = fragments[8]
      user = nil
      password = nil
      host = nil
      port = nil
      if authority != nil
        # The Regexp above doesn't split apart the authority.
        userinfo = authority[/^([^\[\]]*)@/, 1]
        if userinfo != nil
          user = userinfo.strip[/^([^:]*):?/, 1]
          password = userinfo.strip[/:(.*)$/, 1]
        end
        host = authority.gsub(/^([^\[\]]*)@/, "").gsub(/:([^:@\[\]]*?)$/, "")
        port = authority[/:([^:@\[\]]*?)$/, 1]
      end
      if port == ""
        port = nil
      end

      return Addressable::URI.new(
        :scheme => scheme,
        :user => user,
        :password => password,
        :host => host,
        :port => port,
        :path => path,
        :query => query,
        :fragment => fragment
      )
    end

    ##
    # Converts an input to a URI. The input does not have to be a valid
    # URI — the method will use heuristics to guess what URI was intended.
    # This is not standards-compliant, merely user-friendly.
    #
    # @param [String, Addressable::URI, #to_str] uri
    #   The URI string to parse.
    #   No parsing is performed if the object is already an
    #   <code>Addressable::URI</code>.
    # @param [Hash] hints
    #   A <code>Hash</code> of hints to the heuristic parser.
    #   Defaults to <code>{:scheme => "http"}</code>.
    #
    # @return [Addressable::URI] The parsed URI.
    def self.heuristic_parse(uri, hints={})
      # If we were given nil, return nil.
      return nil unless uri
      # If a URI object is passed, just return itself.
      return uri if uri.kind_of?(self)
      if !uri.respond_to?(:to_str)
        raise TypeError, "Can't convert #{uri.class} into String."
      end
      # Otherwise, convert to a String
      uri = uri.to_str.dup
      hints = {
        :scheme => "http"
      }.merge(hints)
      case uri
      when /^http:\/+/
        uri.gsub!(/^http:\/+/, "http://")
      when /^feed:\/+http:\/+/
        uri.gsub!(/^feed:\/+http:\/+/, "feed:http://")
      when /^feed:\/+/
        uri.gsub!(/^feed:\/+/, "feed://")
      when /^file:\/+/
        uri.gsub!(/^file:\/+/, "file:///")
      end
      parsed = self.parse(uri)
      if parsed.scheme =~ /^[^\/?#\.]+\.[^\/?#]+$/
        parsed = self.parse(hints[:scheme] + "://" + uri)
      end
      if parsed.path.include?(".")
        new_host = parsed.path[/^([^\/]+\.[^\/]*)/, 1]
        if new_host
          parsed.defer_validation do
            new_path = parsed.path.gsub(
              Regexp.new("^" + Regexp.escape(new_host)), "")
            parsed.host = new_host
            parsed.path = new_path
            parsed.scheme = hints[:scheme] unless parsed.scheme
          end
        end
      end
      return parsed
    end

    ##
    # Converts a path to a file scheme URI. If the path supplied is
    # relative, it will be returned as a relative URI. If the path supplied
    # is actually a non-file URI, it will parse the URI as if it had been
    # parsed with <code>Addressable::URI.parse</code>. Handles all of the
    # various Microsoft-specific formats for specifying paths.
    #
    # @param [String, Addressable::URI, #to_str] path
    #   Typically a <code>String</code> path to a file or directory, but
    #   will return a sensible return value if an absolute URI is supplied
    #   instead.
    #
    # @return [Addressable::URI]
    #   The parsed file scheme URI or the original URI if some other URI
    #   scheme was provided.
    #
    # @example
    #   base = Addressable::URI.convert_path("/absolute/path/")
    #   uri = Addressable::URI.convert_path("relative/path")
    #   (base + uri).to_s
    #   #=> "file:///absolute/path/relative/path"
    #
    #   Addressable::URI.convert_path(
    #     "c:\\windows\\My Documents 100%20\\foo.txt"
    #   ).to_s
    #   #=> "file:///c:/windows/My%20Documents%20100%20/foo.txt"
    #
    #   Addressable::URI.convert_path("http://example.com/").to_s
    #   #=> "http://example.com/"
    def self.convert_path(path)
      # If we were given nil, return nil.
      return nil unless path
      # If a URI object is passed, just return itself.
      return path if path.kind_of?(self)
      if !path.respond_to?(:to_str)
        raise TypeError, "Can't convert #{path.class} into String."
      end
      # Otherwise, convert to a String
      path = path.to_str.strip

      path.gsub!(/^file:\/?\/?/, "") if path =~ /^file:\/?\/?/
      path = "/" + path if path =~ /^([a-zA-Z])[\|:]/
      uri = self.parse(path)

      if uri.scheme == nil
        # Adjust windows-style uris
        uri.path.gsub!(/^\/?([a-zA-Z])[\|:][\\\/]/) do
          "/#{$1.downcase}:/"
        end
        uri.path.gsub!(/\\/, "/")
        if File.exists?(uri.path) &&
            File.stat(uri.path).directory?
          uri.path.gsub!(/\/$/, "")
          uri.path = uri.path + '/'
        end

        # If the path is absolute, set the scheme and host.
        if uri.path =~ /^\//
          uri.scheme = "file"
          uri.host = ""
        end
        uri.normalize!
      end

      return uri
    end

    ##
    # Joins several URIs together.
    #
    # @param [String, Addressable::URI, #to_str] *uris
    #   The URIs to join.
    #
    # @return [Addressable::URI] The joined URI.
    #
    # @example
    #   base = "http://example.com/"
    #   uri = Addressable::URI.parse("relative/path")
    #   Addressable::URI.join(base, uri)
    #   #=> #<Addressable::URI:0xcab390 URI:http://example.com/relative/path>
    def self.join(*uris)
      uri_objects = uris.collect do |uri|
        if !uri.respond_to?(:to_str)
          raise TypeError, "Can't convert #{uri.class} into String."
        end
        uri.kind_of?(self) ? uri : self.parse(uri.to_str)
      end
      result = uri_objects.shift.dup
      for uri in uri_objects
        result.join!(uri)
      end
      return result
    end

    ##
    # Percent encodes a URI component.
    #
    # @param [String, #to_str] component The URI component to encode.
    #
    # @param [String, Regexp] character_class
    #   The characters which are not percent encoded. If a <code>String</code>
    #   is passed, the <code>String</code> must be formatted as a regular
    #   expression character class. (Do not include the surrounding square
    #   brackets.)  For example, <code>"b-zB-Z0-9"</code> would cause
    #   everything but the letters 'b' through 'z' and the numbers '0' through
    #  '9' to be percent encoded. If a <code>Regexp</code> is passed, the
    #   value <code>/[^b-zB-Z0-9]/</code> would have the same effect. A set of
    #   useful <code>String</code> values may be found in the
    #   <code>Addressable::URI::CharacterClasses</code> module. The default
    #   value is the reserved plus unreserved character classes specified in
    #   <a href="http://www.ietf.org/rfc/rfc3986.txt">RFC 3986</a>.
    #
    # @return [String] The encoded component.
    #
    # @example
    #   Addressable::URI.encode_component("simple/example", "b-zB-Z0-9")
    #   => "simple%2Fex%61mple"
    #   Addressable::URI.encode_component("simple/example", /[^b-zB-Z0-9]/)
    #   => "simple%2Fex%61mple"
    #   Addressable::URI.encode_component(
    #     "simple/example", Addressable::URI::CharacterClasses::UNRESERVED
    #   )
    #   => "simple%2Fexample"
    def self.encode_component(component, character_class=
        CharacterClasses::RESERVED + CharacterClasses::UNRESERVED)
      return nil if component.nil?
      if !component.respond_to?(:to_str)
        raise TypeError, "Can't convert #{component.class} into String."
      end
      component = component.to_str
      if ![String, Regexp].include?(character_class.class)
        raise TypeError,
          "Expected String or Regexp, got #{character_class.inspect}"
      end
      if character_class.kind_of?(String)
        character_class = /[^#{character_class}]/
      end
      if component.respond_to?(:force_encoding)
        # We can't perform regexps on invalid UTF sequences, but
        # here we need to, so switch to ASCII.
        component = component.dup
        component.force_encoding(Encoding::ASCII_8BIT)
      end
      return component.gsub(character_class) do |sequence|
        (sequence.unpack('C*').map { |c| "%" + ("%02x" % c).upcase }).join("")
      end
    end

    class << self
      alias_method :encode_component, :encode_component
    end

    ##
    # Unencodes any percent encoded characters within a URI component.
    # This method may be used for unencoding either components or full URIs,
    # however, it is recommended to use the <code>unencode_component</code>
    # alias when unencoding components.
    #
    # @param [String, Addressable::URI, #to_str] uri
    #   The URI or component to unencode.
    #
    # @param [Class] returning
    #   The type of object to return.
    #   This value may only be set to <code>String</code> or
    #   <code>Addressable::URI</code>. All other values are invalid. Defaults
    #   to <code>String</code>.
    #
    # @return [String, Addressable::URI]
    #   The unencoded component or URI.
    #   The return type is determined by the <code>returning</code> parameter.
    def self.unencode(uri, returning=String)
      return nil if uri.nil?
      if !uri.respond_to?(:to_str)
        raise TypeError, "Can't convert #{uri.class} into String."
      end
      if ![String, ::Addressable::URI].include?(returning)
        raise TypeError,
          "Expected Class (String or Addressable::URI), " +
          "got #{returning.inspect}"
      end
      result = uri.to_str.gsub(/%[0-9a-f]{2}/i) do |sequence|
        sequence[1..3].to_i(16).chr
      end
      result.force_encoding("utf-8") if result.respond_to?(:force_encoding)
      if returning == String
        return result
      elsif returning == ::Addressable::URI
        return ::Addressable::URI.parse(result)
      end
    end

    class << self
      alias_method :unescape, :unencode
      alias_method :unencode_component, :unencode
      alias_method :unescape_component, :unencode
    end


    ##
    # Normalizes the encoding of a URI component.
    #
    # @param [String, #to_str] component The URI component to encode.
    #
    # @param [String, Regexp] character_class
    #   The characters which are not percent encoded. If a <code>String</code>
    #   is passed, the <code>String</code> must be formatted as a regular
    #   expression character class. (Do not include the surrounding square
    #   brackets.)  For example, <code>"b-zB-Z0-9"</code> would cause
    #   everything but the letters 'b' through 'z' and the numbers '0' through
    #  '9' to be percent encoded. If a <code>Regexp</code> is passed, the
    #   value <code>/[^b-zB-Z0-9]/</code> would have the same effect. A set of
    #   useful <code>String</code> values may be found in the
    #   <code>Addressable::URI::CharacterClasses</code> module. The default
    #   value is the reserved plus unreserved character classes specified in
    #   <a href="http://www.ietf.org/rfc/rfc3986.txt">RFC 3986</a>.
    #
    # @return [String] The normalized component.
    #
    # @example
    #   Addressable::URI.normalize_component("simpl%65/%65xampl%65", "b-zB-Z")
    #   => "simple%2Fex%61mple"
    #   Addressable::URI.normalize_component(
    #     "simpl%65/%65xampl%65", /[^b-zB-Z]/
    #   )
    #   => "simple%2Fex%61mple"
    #   Addressable::URI.normalize_component(
    #     "simpl%65/%65xampl%65",
    #     Addressable::URI::CharacterClasses::UNRESERVED
    #   )
    #   => "simple%2Fexample"
    def self.normalize_component(component, character_class=
        CharacterClasses::RESERVED + CharacterClasses::UNRESERVED)
      return nil if component.nil?
      if !component.respond_to?(:to_str)
        raise TypeError, "Can't convert #{component.class} into String."
      end
      component = component.to_str
      if ![String, Regexp].include?(character_class.class)
        raise TypeError,
          "Expected String or Regexp, got #{character_class.inspect}"
      end
      if character_class.kind_of?(String)
        character_class = /[^#{character_class}]/
      end
      if component.respond_to?(:force_encoding)
        # We can't perform regexps on invalid UTF sequences, but
        # here we need to, so switch to ASCII.
        component = component.dup
        component.force_encoding(Encoding::ASCII_8BIT)
      end
      unencoded = self.unencode_component(component)
      begin
        encoded = self.encode_component(
          Addressable::IDNA.unicode_normalize_kc(unencoded),
          character_class
        )
      rescue ArgumentError
        encoded = self.encode_component(unencoded)
      end
      return encoded
    end

    ##
    # Percent encodes any special characters in the URI.
    #
    # @param [String, Addressable::URI, #to_str] uri
    #   The URI to encode.
    #
    # @param [Class] returning
    #   The type of object to return.
    #   This value may only be set to <code>String</code> or
    #   <code>Addressable::URI</code>. All other values are invalid. Defaults
    #   to <code>String</code>.
    #
    # @return [String, Addressable::URI]
    #   The encoded URI.
    #   The return type is determined by the <code>returning</code> parameter.
    def self.encode(uri, returning=String)
      return nil if uri.nil?
      if !uri.respond_to?(:to_str)
        raise TypeError, "Can't convert #{uri.class} into String."
      end
      if ![String, ::Addressable::URI].include?(returning)
        raise TypeError,
          "Expected Class (String or Addressable::URI), " +
          "got #{returning.inspect}"
      end
      uri_object = uri.kind_of?(self) ? uri : self.parse(uri.to_str)
      encoded_uri = Addressable::URI.new(
        :scheme => self.encode_component(uri_object.scheme,
          Addressable::URI::CharacterClasses::SCHEME),
        :authority => self.encode_component(uri_object.authority,
          Addressable::URI::CharacterClasses::AUTHORITY),
        :path => self.encode_component(uri_object.path,
          Addressable::URI::CharacterClasses::PATH),
        :query => self.encode_component(uri_object.query,
          Addressable::URI::CharacterClasses::QUERY),
        :fragment => self.encode_component(uri_object.fragment,
          Addressable::URI::CharacterClasses::FRAGMENT)
      )
      if returning == String
        return encoded_uri.to_s
      elsif returning == ::Addressable::URI
        return encoded_uri
      end
    end

    class << self
      alias_method :escape, :encode
    end

    ##
    # Normalizes the encoding of a URI. Characters within a hostname are
    # not percent encoded to allow for internationalized domain names.
    #
    # @param [String, Addressable::URI, #to_str] uri
    #   The URI to encode.
    #
    # @param [Class] returning
    #   The type of object to return.
    #   This value may only be set to <code>String</code> or
    #   <code>Addressable::URI</code>. All other values are invalid. Defaults
    #   to <code>String</code>.
    #
    # @return [String, Addressable::URI]
    #   The encoded URI.
    #   The return type is determined by the <code>returning</code> parameter.
    def self.normalized_encode(uri, returning=String)
      if !uri.respond_to?(:to_str)
        raise TypeError, "Can't convert #{uri.class} into String."
      end
      if ![String, ::Addressable::URI].include?(returning)
        raise TypeError,
          "Expected Class (String or Addressable::URI), " +
          "got #{returning.inspect}"
      end
      uri_object = uri.kind_of?(self) ? uri : self.parse(uri.to_str)
      components = {
        :scheme => self.unencode_component(uri_object.scheme),
        :user => self.unencode_component(uri_object.user),
        :password => self.unencode_component(uri_object.password),
        :host => self.unencode_component(uri_object.host),
        :port => uri_object.port,
        :path => self.unencode_component(uri_object.path),
        :query => self.unencode_component(uri_object.query),
        :fragment => self.unencode_component(uri_object.fragment)
      }
      components.each do |key, value|
        if value != nil
          begin
            components[key] =
              Addressable::IDNA.unicode_normalize_kc(value.to_str)
          rescue ArgumentError
            # Likely a malformed UTF-8 character, skip unicode normalization
            components[key] = value.to_str
          end
        end
      end
      encoded_uri = Addressable::URI.new(
        :scheme => self.encode_component(components[:scheme],
          Addressable::URI::CharacterClasses::SCHEME),
        :user => self.encode_component(components[:user],
          Addressable::URI::CharacterClasses::UNRESERVED),
        :password => self.encode_component(components[:password],
          Addressable::URI::CharacterClasses::UNRESERVED),
        :host => components[:host],
        :port => components[:port],
        :path => self.encode_component(components[:path],
          Addressable::URI::CharacterClasses::PATH),
        :query => self.encode_component(components[:query],
          Addressable::URI::CharacterClasses::QUERY),
        :fragment => self.encode_component(components[:fragment],
          Addressable::URI::CharacterClasses::FRAGMENT)
      )
      if returning == String
        return encoded_uri.to_s
      elsif returning == ::Addressable::URI
        return encoded_uri
      end
    end

    ##
    # Encodes a set of key/value pairs according to the rules for the
    # <code>application/x-www-form-urlencoded</code> MIME type.
    #
    # @param [#to_hash, #to_ary] form_values
    #   The form values to encode.
    #
    # @param [TrueClass, FalseClass] sort
    #   Sort the key/value pairs prior to encoding.
    #   Defaults to <code>false</code>.
    #
    # @return [String]
    #   The encoded value.
    def self.form_encode(form_values, sort=false)
      if form_values.respond_to?(:to_hash)
        form_values = form_values.to_hash.to_a
      elsif form_values.respond_to?(:to_ary)
        form_values = form_values.to_ary
      else
        raise TypeError, "Can't convert #{form_values.class} into Array."
      end
      form_values = form_values.map do |(key, value)|
        [key.to_s, value.to_s]
      end
      if sort
        # Useful for OAuth and optimizing caching systems
        form_values = form_values.sort
      end
      escaped_form_values = form_values.map do |(key, value)|
        # Line breaks are CRLF pairs
        [
          self.encode_component(
            key.gsub(/(\r\n|\n|\r)/, "\r\n"),
            CharacterClasses::UNRESERVED
          ).gsub("%20", "+"),
          self.encode_component(
            value.gsub(/(\r\n|\n|\r)/, "\r\n"),
            CharacterClasses::UNRESERVED
          ).gsub("%20", "+")
        ]
      end
      return (escaped_form_values.map do |(key, value)|
        "#{key}=#{value}"
      end).join("&")
    end

    ##
    # Decodes a <code>String</code> according to the rules for the
    # <code>application/x-www-form-urlencoded</code> MIME type.
    #
    # @param [String, #to_str] encoded_value
    #   The form values to decode.
    #
    # @return [Array]
    #   The decoded values.
    #   This is not a <code>Hash</code> because of the possibility for
    #   duplicate keys.
    def self.form_unencode(encoded_value)
      if !encoded_value.respond_to?(:to_str)
        raise TypeError, "Can't convert #{encoded_value.class} into String."
      end
      encoded_value = encoded_value.to_str
      split_values = encoded_value.split("&").map do |pair|
        pair.split("=", 2)
      end
      return split_values.map do |(key, value)|
        [
          key ? self.unencode_component(
            key.gsub("+", "%20")).gsub(/(\r\n|\n|\r)/, "\n") : nil,
          value ? (self.unencode_component(
            value.gsub("+", "%20")).gsub(/(\r\n|\n|\r)/, "\n")) : nil
        ]
      end
    end

    ##
    # Creates a new uri object from component parts.
    #
    # @option [String, #to_str] scheme The scheme component.
    # @option [String, #to_str] user The user component.
    # @option [String, #to_str] password The password component.
    # @option [String, #to_str] userinfo
    #   The userinfo component. If this is supplied, the user and password
    #   components must be omitted.
    # @option [String, #to_str] host The host component.
    # @option [String, #to_str] port The port component.
    # @option [String, #to_str] authority
    #   The authority component. If this is supplied, the user, password,
    #   userinfo, host, and port components must be omitted.
    # @option [String, #to_str] path The path component.
    # @option [String, #to_str] query The query component.
    # @option [String, #to_str] fragment The fragment component.
    #
    # @return [Addressable::URI] The constructed URI object.
    def initialize(options={})
      if options.has_key?(:authority)
        if (options.keys & [:userinfo, :user, :password, :host, :port]).any?
          raise ArgumentError,
            "Cannot specify both an authority and any of the components " +
            "within the authority."
        end
      end
      if options.has_key?(:userinfo)
        if (options.keys & [:user, :password]).any?
          raise ArgumentError,
            "Cannot specify both a userinfo and either the user or password."
        end
      end

      self.defer_validation do
        # Bunch of crazy logic required because of the composite components
        # like userinfo and authority.
        self.scheme = options[:scheme] if options[:scheme]
        self.user = options[:user] if options[:user]
        self.password = options[:password] if options[:password]
        self.userinfo = options[:userinfo] if options[:userinfo]
        self.host = options[:host] if options[:host]
        self.port = options[:port] if options[:port]
        self.authority = options[:authority] if options[:authority]
        self.path = options[:path] if options[:path]
        self.query = options[:query] if options[:query]
        self.fragment = options[:fragment] if options[:fragment]
      end
    end

    ##
    # The scheme component for this URI.
    #
    # @return [String] The scheme component.
    def scheme
      return @scheme ||= nil
    end

    ##
    # The scheme component for this URI, normalized.
    #
    # @return [String] The scheme component, normalized.
    def normalized_scheme
      @normalized_scheme ||= (begin
        if self.scheme != nil
          if self.scheme =~ /^\s*ssh\+svn\s*$/i
            "svn+ssh"
          else
            Addressable::URI.normalize_component(
              self.scheme.strip.downcase,
              Addressable::URI::CharacterClasses::SCHEME
            )
          end
        else
          nil
        end
      end)
    end

    ##
    # Sets the scheme component for this URI.
    #
    # @param [String, #to_str] new_scheme The new scheme component.
    def scheme=(new_scheme)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_scheme && !new_scheme.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_scheme.class} into String."
      elsif new_scheme
        new_scheme = new_scheme.to_str
      end
      if new_scheme && new_scheme !~ /[a-z][a-z0-9\.\+\-]*/i
        raise InvalidURIError, "Invalid scheme format."
      end
      @scheme = new_scheme
      @scheme = nil if @scheme.to_s.strip == ""

      # Reset dependant values
      @normalized_scheme = nil
      @uri_string = nil
      @hash = nil

      # Ensure we haven't created an invalid URI
      validate()
    end

    ##
    # The user component for this URI.
    #
    # @return [String] The user component.
    def user
      return @user ||= nil
    end

    ##
    # The user component for this URI, normalized.
    #
    # @return [String] The user component, normalized.
    def normalized_user
      @normalized_user ||= (begin
        if self.user
          if normalized_scheme =~ /https?/ && self.user.strip == "" &&
              (!self.password || self.password.strip == "")
            nil
          else
            Addressable::URI.normalize_component(
              self.user.strip,
              Addressable::URI::CharacterClasses::UNRESERVED
            )
          end
        else
          nil
        end
      end)
    end

    ##
    # Sets the user component for this URI.
    #
    # @param [String, #to_str] new_user The new user component.
    def user=(new_user)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_user && !new_user.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_user.class} into String."
      end
      @user = new_user ? new_user.to_str : nil

      # You can't have a nil user with a non-nil password
      @password ||= nil
      if @password != nil
        @user = "" if @user.nil?
      end

      # Reset dependant values
      @userinfo = nil
      @normalized_userinfo = nil
      @authority = nil
      @normalized_user = nil
      @uri_string = nil
      @hash = nil

      # Ensure we haven't created an invalid URI
      validate()
    end

    ##
    # The password component for this URI.
    #
    # @return [String] The password component.
    def password
      return @password ||= nil
    end

    ##
    # The password component for this URI, normalized.
    #
    # @return [String] The password component, normalized.
    def normalized_password
      @normalized_password ||= (begin
        if self.password
          if normalized_scheme =~ /https?/ && self.password.strip == "" &&
              (!self.user || self.user.strip == "")
            nil
          else
            Addressable::URI.normalize_component(
              self.password.strip,
              Addressable::URI::CharacterClasses::UNRESERVED
            )
          end
        else
          nil
        end
      end)
    end

    ##
    # Sets the password component for this URI.
    #
    # @param [String, #to_str] new_password The new password component.
    def password=(new_password)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_password && !new_password.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_password.class} into String."
      end
      @password = new_password ? new_password.to_str : nil

      # You can't have a nil user with a non-nil password
      @password ||= nil
      @user ||= nil
      if @password != nil
        @user = "" if @user.nil?
      end

      # Reset dependant values
      @userinfo = nil
      @normalized_userinfo = nil
      @authority = nil
      @normalized_password = nil
      @uri_string = nil
      @hash = nil

      # Ensure we haven't created an invalid URI
      validate()
    end

    ##
    # The userinfo component for this URI.
    # Combines the user and password components.
    #
    # @return [String] The userinfo component.
    def userinfo
      @userinfo ||= (begin
        current_user = self.user
        current_password = self.password
        if !current_user && !current_password
          nil
        elsif current_user && current_password
          "#{current_user}:#{current_password}"
        elsif current_user && !current_password
          "#{current_user}"
        end
      end)
    end

    ##
    # The userinfo component for this URI, normalized.
    #
    # @return [String] The userinfo component, normalized.
    def normalized_userinfo
      @normalized_userinfo ||= (begin
        current_user = self.normalized_user
        current_password = self.normalized_password
        if !current_user && !current_password
          nil
        elsif current_user && current_password
          "#{current_user}:#{current_password}"
        elsif current_user && !current_password
          "#{current_user}"
        end
      end)
    end

    ##
    # Sets the userinfo component for this URI.
    #
    # @param [String, #to_str] new_userinfo The new userinfo component.
    def userinfo=(new_userinfo)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_userinfo && !new_userinfo.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_userinfo.class} into String."
      end
      new_user, new_password = if new_userinfo
        [
          new_userinfo.to_str.strip[/^(.*):/, 1],
          new_userinfo.to_str.strip[/:(.*)$/, 1]
        ]
      else
        [nil, nil]
      end

      # Password assigned first to ensure validity in case of nil
      self.password = new_password
      self.user = new_user

      # Reset dependant values
      @authority = nil
      @uri_string = nil
      @hash = nil

      # Ensure we haven't created an invalid URI
      validate()
    end

    ##
    # The host component for this URI.
    #
    # @return [String] The host component.
    def host
      return @host ||= nil
    end

    ##
    # The host component for this URI, normalized.
    #
    # @return [String] The host component, normalized.
    def normalized_host
      @normalized_host ||= (begin
        if self.host != nil
          if self.host.strip != ""
            result = ::Addressable::IDNA.to_ascii(
              self.class.unencode_component(self.host.strip.downcase)
            )
            if result[-1..-1] == "."
              # Trailing dots are unnecessary
              result = result[0...-1]
            end
            result
          else
            ""
          end
        else
          nil
        end
      end)
    end

    ##
    # Sets the host component for this URI.
    #
    # @param [String, #to_str] new_host The new host component.
    def host=(new_host)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_host && !new_host.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_host.class} into String."
      end
      @host = new_host ? new_host.to_str : nil

      # Reset dependant values
      @authority = nil
      @normalized_host = nil
      @uri_string = nil
      @hash = nil

      # Ensure we haven't created an invalid URI
      validate()
    end

    ##
    # The authority component for this URI.
    # Combines the user, password, host, and port components.
    #
    # @return [String] The authority component.
    def authority
      @authority ||= (begin
        if self.host.nil?
          nil
        else
          authority = ""
          if self.userinfo != nil
            authority << "#{self.userinfo}@"
          end
          authority << self.host
          if self.port != nil
            authority << ":#{self.port}"
          end
          authority
        end
      end)
    end

    ##
    # The authority component for this URI, normalized.
    #
    # @return [String] The authority component, normalized.
    def normalized_authority
      @normalized_authority ||= (begin
        if self.normalized_host.nil?
          nil
        else
          authority = ""
          if self.normalized_userinfo != nil
            authority << "#{self.normalized_userinfo}@"
          end
          authority << self.normalized_host
          if self.normalized_port != nil
            authority << ":#{self.normalized_port}"
          end
          authority
        end
      end)
    end

    ##
    # Sets the authority component for this URI.
    #
    # @param [String, #to_str] new_authority The new authority component.
    def authority=(new_authority)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_authority
        if !new_authority.respond_to?(:to_str)
          raise TypeError, "Can't convert #{new_authority.class} into String."
        end
        new_authority = new_authority.to_str
        new_userinfo = new_authority[/^([^\[\]]*)@/, 1]
        if new_userinfo
          new_user = new_userinfo.strip[/^([^:]*):?/, 1]
          new_password = new_userinfo.strip[/:(.*)$/, 1]
        end
        new_host =
          new_authority.gsub(/^([^\[\]]*)@/, "").gsub(/:([^:@\[\]]*?)$/, "")
        new_port =
          new_authority[/:([^:@\[\]]*?)$/, 1]
      end

      # Password assigned first to ensure validity in case of nil
      self.password = defined?(new_password) ? new_password : nil
      self.user = defined?(new_user) ? new_user : nil
      self.host = defined?(new_host) ? new_host : nil
      self.port = defined?(new_port) ? new_port : nil

      # Reset dependant values
      @inferred_port = nil
      @userinfo = nil
      @normalized_userinfo = nil
      @uri_string = nil
      @hash = nil

      # Ensure we haven't created an invalid URI
      validate()
    end

    ##
    # The origin for this URI, serialized to ASCII, as per
    # draft-ietf-websec-origin-00, section 5.2.
    #
    # @return [String] The serialized origin.
    def origin
      return (if self.scheme && self.authority
        if self.normalized_port
          (
            "#{self.normalized_scheme}://#{self.normalized_host}" +
            ":#{self.normalized_port}"
          )
        else
          "#{self.normalized_scheme}://#{self.normalized_host}"
        end
      else
        "null"
      end)
    end

    # Returns an array of known ip-based schemes. These schemes typically
    # use a similar URI form:
    # <code>//<user>:<password>@<host>:<port>/<url-path></code>
    def self.ip_based_schemes
      return self.port_mapping.keys
    end

    # Returns a hash of common IP-based schemes and their default port
    # numbers. Adding new schemes to this hash, as necessary, will allow
    # for better URI normalization.
    def self.port_mapping
      @port_mapping ||= {
        "http" => 80,
        "https" => 443,
        "ftp" => 21,
        "tftp" => 69,
        "sftp" => 22,
        "ssh" => 22,
        "svn+ssh" => 22,
        "telnet" => 23,
        "nntp" => 119,
        "gopher" => 70,
        "wais" => 210,
        "ldap" => 389,
        "prospero" => 1525
      }
    end

    ##
    # The port component for this URI.
    # This is the port number actually given in the URI. This does not
    # infer port numbers from default values.
    #
    # @return [Integer] The port component.
    def port
      return @port ||= nil
    end

    ##
    # The port component for this URI, normalized.
    #
    # @return [Integer] The port component, normalized.
    def normalized_port
      @normalized_port ||= (begin
        if self.class.port_mapping[normalized_scheme] == self.port
          nil
        else
          self.port
        end
      end)
    end

    ##
    # Sets the port component for this URI.
    #
    # @param [String, Integer, #to_s] new_port The new port component.
    def port=(new_port)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_port != nil && new_port.respond_to?(:to_str)
        new_port = Addressable::URI.unencode_component(new_port.to_str)
      end
      if new_port != nil && !(new_port.to_s =~ /^\d+$/)
        raise InvalidURIError,
          "Invalid port number: #{new_port.inspect}"
      end

      @port = new_port.to_s.to_i
      @port = nil if @port == 0

      # Reset dependant values
      @authority = nil
      @inferred_port = nil
      @normalized_port = nil
      @uri_string = nil
      @hash = nil

      # Ensure we haven't created an invalid URI
      validate()
    end

    ##
    # The inferred port component for this URI.
    # This method will normalize to the default port for the URI's scheme if
    # the port isn't explicitly specified in the URI.
    #
    # @return [Integer] The inferred port component.
    def inferred_port
      @inferred_port ||= (begin
        if port.to_i == 0
          if scheme
            self.class.port_mapping[scheme.strip.downcase]
          else
            nil
          end
        else
          port.to_i
        end
      end)
    end

    ##
    # The combination of components that represent a site.
    # Combines the scheme, user, password, host, and port components.
    # Primarily useful for HTTP and HTTPS.
    #
    # For example, <code>"http://example.com/path?query"</code> would have a
    # <code>site</code> value of <code>"http://example.com"</code>.
    #
    # @return [String] The components that identify a site.
    def site
      @site ||= (begin
        if self.scheme || self.authority
          site_string = ""
          site_string << "#{self.scheme}:" if self.scheme != nil
          site_string << "//#{self.authority}" if self.authority != nil
          site_string
        else
          nil
        end
      end)
    end

    ##
    # The normalized combination of components that represent a site.
    # Combines the scheme, user, password, host, and port components.
    # Primarily useful for HTTP and HTTPS.
    #
    # For example, <code>"http://example.com/path?query"</code> would have a
    # <code>site</code> value of <code>"http://example.com"</code>.
    #
    # @return [String] The normalized components that identify a site.
    def normalized_site
      @site ||= (begin
        if self.normalized_scheme || self.normalized_authority
          site_string = ""
          if self.normalized_scheme != nil
            site_string << "#{self.normalized_scheme}:"
          end
          if self.normalized_authority != nil
            site_string << "//#{self.normalized_authority}"
          end
          site_string
        else
          nil
        end
      end)
    end

    ##
    # Sets the site value for this URI.
    #
    # @param [String, #to_str] new_site The new site value.
    def site=(new_site)
      if new_site
        if !new_site.respond_to?(:to_str)
          raise TypeError, "Can't convert #{new_site.class} into String."
        end
        new_site = new_site.to_str
        # These two regular expressions derived from the primary parsing
        # expression
        self.scheme = new_site[/^(?:([^:\/?#]+):)?(?:\/\/(?:[^\/?#]*))?$/, 1]
        self.authority = new_site[
          /^(?:(?:[^:\/?#]+):)?(?:\/\/([^\/?#]*))?$/, 1
        ]
      else
        self.scheme = nil
        self.authority = nil
      end
    end

    ##
    # The path component for this URI.
    #
    # @return [String] The path component.
    def path
      @path ||= ""
      return @path
    end

    ##
    # The path component for this URI, normalized.
    #
    # @return [String] The path component, normalized.
    def normalized_path
      @normalized_path ||= (begin
        if self.scheme == nil && self.path != nil && self.path != "" &&
            self.path =~ /^(?!\/)[^\/:]*:.*$/
          # Relative paths with colons in the first segment are ambiguous.
          self.path.sub!(":", "%2F")
        end
        # String#split(delimeter, -1) uses the more strict splitting behavior
        # found by default in Python.
        result = (self.path.strip.split("/", -1).map do |segment|
          Addressable::URI.normalize_component(
            segment,
            Addressable::URI::CharacterClasses::PCHAR
          )
        end).join("/")
        result = self.class.normalize_path(result)
        if result == "" &&
            ["http", "https", "ftp", "tftp"].include?(self.normalized_scheme)
          result = "/"
        end
        result
      end)
    end

    ##
    # Sets the path component for this URI.
    #
    # @param [String, #to_str] new_path The new path component.
    def path=(new_path)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_path && !new_path.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_path.class} into String."
      end
      @path = (new_path || "").to_str
      if @path != "" && @path[0..0] != "/" && host != nil
        @path = "/#{@path}"
      end

      # Reset dependant values
      @normalized_path = nil
      @uri_string = nil
      @hash = nil
    end

    ##
    # The basename, if any, of the file in the path component.
    #
    # @return [String] The path's basename.
    def basename
      # Path cannot be nil
      return File.basename(self.path).gsub(/;[^\/]*$/, "")
    end

    ##
    # The extname, if any, of the file in the path component.
    # Empty string if there is no extension.
    #
    # @return [String] The path's extname.
    def extname
      return nil unless self.path
      return File.extname(self.basename)
    end

    ##
    # The query component for this URI.
    #
    # @return [String] The query component.
    def query
      return @query ||= nil
    end

    ##
    # The query component for this URI, normalized.
    #
    # @return [String] The query component, normalized.
    def normalized_query
      @normalized_query ||= (begin
        if self.query
          Addressable::URI.normalize_component(
            self.query.strip,
            Addressable::URI::CharacterClasses::QUERY
          )
        else
          nil
        end
      end)
    end

    ##
    # Sets the query component for this URI.
    #
    # @param [String, #to_str] new_query The new query component.
    def query=(new_query)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_query && !new_query.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_query.class} into String."
      end
      @query = new_query ? new_query.to_str : nil

      # Reset dependant values
      @normalized_query = nil
      @uri_string = nil
      @hash = nil
    end

    ##
    # Converts the query component to a Hash value.
    #
    # @option [Symbol] notation
    #   May be one of <code>:flat</code>, <code>:dot</code>, or
    #   <code>:subscript</code>. The <code>:dot</code> notation is not
    #   supported for assignment. Default value is <code>:subscript</code>.
    #
    # @return [Hash, Array] The query string parsed as a Hash or Array object.
    #
    # @example
    #   Addressable::URI.parse("?one=1&two=2&three=3").query_values
    #   #=> {"one" => "1", "two" => "2", "three" => "3"}
    #   Addressable::URI.parse("?one[two][three]=four").query_values
    #   #=> {"one" => {"two" => {"three" => "four"}}}
    #   Addressable::URI.parse("?one.two.three=four").query_values(
    #     :notation => :dot
    #   )
    #   #=> {"one" => {"two" => {"three" => "four"}}}
    #   Addressable::URI.parse("?one[two][three]=four").query_values(
    #     :notation => :flat
    #   )
    #   #=> {"one[two][three]" => "four"}
    #   Addressable::URI.parse("?one.two.three=four").query_values(
    #     :notation => :flat
    #   )
    #   #=> {"one.two.three" => "four"}
    #   Addressable::URI.parse(
    #     "?one[two][three][]=four&one[two][three][]=five"
    #   ).query_values
    #   #=> {"one" => {"two" => {"three" => ["four", "five"]}}}
    #   Addressable::URI.parse(
    #     "?one=two&one=three").query_values(:notation => :flat_array)
    #   #=> [['one', 'two'], ['one', 'three']]
    def query_values(options={})
      defaults = {:notation => :subscript}
      options = defaults.merge(options)
      if ![:flat, :dot, :subscript, :flat_array].include?(options[:notation])
        raise ArgumentError,
          "Invalid notation. Must be one of: " +
          "[:flat, :dot, :subscript, :flat_array]."
      end
      dehash = lambda do |hash|
        hash.each do |(key, value)|
          if value.kind_of?(Hash)
            hash[key] = dehash.call(value)
          end
        end
        if hash != {} && hash.keys.all? { |key| key =~ /^\d+$/ }
          hash.sort.inject([]) do |accu, (key, value)|
            accu << value; accu
          end
        else
          hash
        end
      end
      return nil if self.query == nil
      empty_accumulator = :flat_array == options[:notation] ? [] : {}
      return ((self.query.split("&").map do |pair|
        pair.split("=", 2) if pair && pair != ""
      end).compact.inject(empty_accumulator.dup) do |accumulator, (key, value)|
        value = true if value.nil?
        key = self.class.unencode_component(key)
        if value != true
          value = self.class.unencode_component(value.gsub(/\+/, " "))
        end
        if options[:notation] == :flat
          if accumulator[key]
            raise ArgumentError, "Key was repeated: #{key.inspect}"
          end
          accumulator[key] = value
        elsif options[:notation] == :flat_array
          accumulator << [key, value]
        else
          if options[:notation] == :dot
            array_value = false
            subkeys = key.split(".")
          elsif options[:notation] == :subscript
            array_value = !!(key =~ /\[\]$/)
            subkeys = key.split(/[\[\]]+/)
          end
          current_hash = accumulator
          for i in 0...(subkeys.size - 1)
            subkey = subkeys[i]
            current_hash[subkey] = {} unless current_hash[subkey]
            current_hash = current_hash[subkey]
          end
          if array_value
            current_hash[subkeys.last] = [] unless current_hash[subkeys.last]
            current_hash[subkeys.last] << value
          else
            current_hash[subkeys.last] = value
          end
        end
        accumulator
      end).inject(empty_accumulator.dup) do |accumulator, (key, value)|
        if options[:notation] == :flat_array
          accumulator << [key, value]
        else
          accumulator[key] = value.kind_of?(Hash) ? dehash.call(value) : value
        end
        accumulator
      end
    end

    ##
    # Sets the query component for this URI from a Hash object.
    # This method produces a query string using the :subscript notation.
    # An empty Hash will result in a nil query.
    #
    # @param [Hash, #to_hash, Array] new_query_values The new query values.
    def query_values=(new_query_values)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?
      if new_query_values == nil
        self.query = nil
        return nil
      end

      if !new_query_values.is_a?(Array)
        if !new_query_values.respond_to?(:to_hash)
          raise TypeError,
            "Can't convert #{new_query_values.class} into Hash."
        end
        new_query_values = new_query_values.to_hash
        new_query_values = new_query_values.map do |key, value|
          key = key.to_s if key.kind_of?(Symbol)
          [key, value]
        end
        # Useful default for OAuth and caching.
        # Only to be used for non-Array inputs. Arrays should preserve order.
        new_query_values.sort!
      end
      # new_query_values have form [['key1', 'value1'], ['key2', 'value2']]

      # Algorithm shamelessly stolen from Julien Genestoux, slightly modified
      buffer = ""
      stack = []
      e = lambda do |component|
        component = component.to_s if component.kind_of?(Symbol)
        self.class.encode_component(component, CharacterClasses::UNRESERVED)
      end
      new_query_values.each do |key, value|
        if value.kind_of?(Hash)
          stack << [key, value]
        elsif value.kind_of?(Array)
          stack << [
            key,
            value.inject({}) { |accu, x| accu[accu.size.to_s] = x; accu }
          ]
        elsif value == true
          buffer << "#{e.call(key)}&"
        else
          buffer << "#{e.call(key)}=#{e.call(value)}&"
        end
      end
      stack.each do |(parent, hash)|
        (hash.sort_by { |key| key.to_s }).each do |(key, value)|
          if value.kind_of?(Hash)
            stack << ["#{parent}[#{key}]", value]
          elsif value == true
            buffer << "#{parent}[#{e.call(key)}]&"
          else
            buffer << "#{parent}[#{e.call(key)}]=#{e.call(value)}&"
          end
        end
      end
      self.query = buffer.chop
    end

    ##
    # The HTTP request URI for this URI.  This is the path and the
    # query string.
    #
    # @return [String] The request URI required for an HTTP request.
    def request_uri
      return nil if self.absolute? && self.scheme !~ /^https?$/
      return (
        (self.path != "" ? self.path : "/") +
        (self.query ? "?#{self.query}" : "")
      )
    end

    ##
    # Sets the HTTP request URI for this URI.
    #
    # @param [String, #to_str] new_request_uri The new HTTP request URI.
    def request_uri=(new_request_uri)
      if !new_request_uri.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_request_uri.class} into String."
      end
      if self.absolute? && self.scheme !~ /^https?$/
        raise InvalidURIError,
          "Cannot set an HTTP request URI for a non-HTTP URI."
      end
      new_request_uri = new_request_uri.to_str
      path_component = new_request_uri[/^([^\?]*)\?(?:.*)$/, 1]
      query_component = new_request_uri[/^(?:[^\?]*)\?(.*)$/, 1]
      path_component = path_component.to_s
      path_component = (path_component != "" ? path_component : "/")
      self.path = path_component
      self.query = query_component

      # Reset dependant values
      @uri_string = nil
      @hash = nil
    end

    ##
    # The fragment component for this URI.
    #
    # @return [String] The fragment component.
    def fragment
      return @fragment ||= nil
    end

    ##
    # The fragment component for this URI, normalized.
    #
    # @return [String] The fragment component, normalized.
    def normalized_fragment
      @normalized_fragment ||= (begin
        if self.fragment
          Addressable::URI.normalize_component(
            self.fragment.strip,
            Addressable::URI::CharacterClasses::FRAGMENT
          )
        else
          nil
        end
      end)
    end

    ##
    # Sets the fragment component for this URI.
    #
    # @param [String, #to_str] new_fragment The new fragment component.
    def fragment=(new_fragment)
      # Check for frozenness
      raise TypeError, "Can't modify frozen URI." if self.frozen?

      if new_fragment && !new_fragment.respond_to?(:to_str)
        raise TypeError, "Can't convert #{new_fragment.class} into String."
      end
      @fragment = new_fragment ? new_fragment.to_str : nil

      # Reset dependant values
      @normalized_fragment = nil
      @uri_string = nil
      @hash = nil

      # Ensure we haven't created an invalid URI
      validate()
    end

    ##
    # Determines if the scheme indicates an IP-based protocol.
    #
    # @return [TrueClass, FalseClass]
    #   <code>true</code> if the scheme indicates an IP-based protocol.
    #   <code>false</code> otherwise.
    def ip_based?
      if self.scheme
        return self.class.ip_based_schemes.include?(
          self.scheme.strip.downcase)
      end
      return false
    end

    ##
    # Determines if the URI is relative.
    #
    # @return [TrueClass, FalseClass]
    #   <code>true</code> if the URI is relative. <code>false</code>
    #   otherwise.
    def relative?
      return self.scheme.nil?
    end

    ##
    # Determines if the URI is absolute.
    #
    # @return [TrueClass, FalseClass]
    #   <code>true</code> if the URI is absolute. <code>false</code>
    #   otherwise.
    def absolute?
      return !relative?
    end

    ##
    # Joins two URIs together.
    #
    # @param [String, Addressable::URI, #to_str] The URI to join with.
    #
    # @return [Addressable::URI] The joined URI.
    def join(uri)
      if !uri.respond_to?(:to_str)
        raise TypeError, "Can't convert #{uri.class} into String."
      end
      if !uri.kind_of?(self.class)
        # Otherwise, convert to a String, then parse.
        uri = self.class.parse(uri.to_str)
      end
      if uri.to_s == ""
        return self.dup
      end

      joined_scheme = nil
      joined_user = nil
      joined_password = nil
      joined_host = nil
      joined_port = nil
      joined_path = nil
      joined_query = nil
      joined_fragment = nil

      # Section 5.2.2 of RFC 3986
      if uri.scheme != nil
        joined_scheme = uri.scheme
        joined_user = uri.user
        joined_password = uri.password
        joined_host = uri.host
        joined_port = uri.port
        joined_path = self.class.normalize_path(uri.path)
        joined_query = uri.query
      else
        if uri.authority != nil
          joined_user = uri.user
          joined_password = uri.password
          joined_host = uri.host
          joined_port = uri.port
          joined_path = self.class.normalize_path(uri.path)
          joined_query = uri.query
        else
          if uri.path == nil || uri.path == ""
            joined_path = self.path
            if uri.query != nil
              joined_query = uri.query
            else
              joined_query = self.query
            end
          else
            if uri.path[0..0] == "/"
              joined_path = self.class.normalize_path(uri.path)
            else
              base_path = self.path.dup
              base_path = "" if base_path == nil
              base_path = self.class.normalize_path(base_path)

              # Section 5.2.3 of RFC 3986
              #
              # Removes the right-most path segment from the base path.
              if base_path =~ /\//
                base_path.gsub!(/\/[^\/]+$/, "/")
              else
                base_path = ""
              end

              # If the base path is empty and an authority segment has been
              # defined, use a base path of "/"
              if base_path == "" && self.authority != nil
                base_path = "/"
              end

              joined_path = self.class.normalize_path(base_path + uri.path)
            end
            joined_query = uri.query
          end
          joined_user = self.user
          joined_password = self.password
          joined_host = self.host
          joined_port = self.port
        end
        joined_scheme = self.scheme
      end
      joined_fragment = uri.fragment

      return Addressable::URI.new(
        :scheme => joined_scheme,
        :user => joined_user,
        :password => joined_password,
        :host => joined_host,
        :port => joined_port,
        :path => joined_path,
        :query => joined_query,
        :fragment => joined_fragment
      )
    end
    alias_method :+, :join

    ##
    # Destructive form of <code>join</code>.
    #
    # @param [String, Addressable::URI, #to_str] The URI to join with.
    #
    # @return [Addressable::URI] The joined URI.
    #
    # @see Addressable::URI#join
    def join!(uri)
      replace_self(self.join(uri))
    end

    ##
    # Merges a URI with a <code>Hash</code> of components.
    # This method has different behavior from <code>join</code>. Any
    # components present in the <code>hash</code> parameter will override the
    # original components. The path component is not treated specially.
    #
    # @param [Hash, Addressable::URI, #to_hash] The components to merge with.
    #
    # @return [Addressable::URI] The merged URI.
    #
    # @see Hash#merge
    def merge(hash)
      if !hash.respond_to?(:to_hash)
        raise TypeError, "Can't convert #{hash.class} into Hash."
      end
      hash = hash.to_hash

      if hash.has_key?(:authority)
        if (hash.keys & [:userinfo, :user, :password, :host, :port]).any?
          raise ArgumentError,
            "Cannot specify both an authority and any of the components " +
            "within the authority."
        end
      end
      if hash.has_key?(:userinfo)
        if (hash.keys & [:user, :password]).any?
          raise ArgumentError,
            "Cannot specify both a userinfo and either the user or password."
        end
      end

      uri = Addressable::URI.new
      uri.defer_validation do
        # Bunch of crazy logic required because of the composite components
        # like userinfo and authority.
        uri.scheme =
          hash.has_key?(:scheme) ? hash[:scheme] : self.scheme
        if hash.has_key?(:authority)
          uri.authority =
            hash.has_key?(:authority) ? hash[:authority] : self.authority
        end
        if hash.has_key?(:userinfo)
          uri.userinfo =
            hash.has_key?(:userinfo) ? hash[:userinfo] : self.userinfo
        end
        if !hash.has_key?(:userinfo) && !hash.has_key?(:authority)
          uri.user =
            hash.has_key?(:user) ? hash[:user] : self.user
          uri.password =
            hash.has_key?(:password) ? hash[:password] : self.password
        end
        if !hash.has_key?(:authority)
          uri.host =
            hash.has_key?(:host) ? hash[:host] : self.host
          uri.port =
            hash.has_key?(:port) ? hash[:port] : self.port
        end
        uri.path =
          hash.has_key?(:path) ? hash[:path] : self.path
        uri.query =
          hash.has_key?(:query) ? hash[:query] : self.query
        uri.fragment =
          hash.has_key?(:fragment) ? hash[:fragment] : self.fragment
      end

      return uri
    end

    ##
    # Destructive form of <code>merge</code>.
    #
    # @param [Hash, Addressable::URI, #to_hash] The components to merge with.
    #
    # @return [Addressable::URI] The merged URI.
    #
    # @see Addressable::URI#merge
    def merge!(uri)
      replace_self(self.merge(uri))
    end

    ##
    # Returns the shortest normalized relative form of this URI that uses the
    # supplied URI as a base for resolution. Returns an absolute URI if
    # necessary. This is effectively the opposite of <code>route_to</code>.
    #
    # @param [String, Addressable::URI, #to_str] uri The URI to route from.
    #
    # @return [Addressable::URI]
    #   The normalized relative URI that is equivalent to the original URI.
    def route_from(uri)
      uri = self.class.parse(uri).normalize
      normalized_self = self.normalize
      if normalized_self.relative?
        raise ArgumentError, "Expected absolute URI, got: #{self.to_s}"
      end
      if uri.relative?
        raise ArgumentError, "Expected absolute URI, got: #{uri.to_s}"
      end
      if normalized_self == uri
        return Addressable::URI.parse("##{normalized_self.fragment}")
      end
      components = normalized_self.to_hash
      if normalized_self.scheme == uri.scheme
        components[:scheme] = nil
        if normalized_self.authority == uri.authority
          components[:user] = nil
          components[:password] = nil
          components[:host] = nil
          components[:port] = nil
          if normalized_self.path == uri.path
            components[:path] = nil
            if normalized_self.query == uri.query
              components[:query] = nil
            end
          else
            if uri.path != "/"
              components[:path].gsub!(
                Regexp.new("^" + Regexp.escape(uri.path)), "")
            end
          end
        end
      end
      # Avoid network-path references.
      if components[:host] != nil
        components[:scheme] = normalized_self.scheme
      end
      return Addressable::URI.new(
        :scheme => components[:scheme],
        :user => components[:user],
        :password => components[:password],
        :host => components[:host],
        :port => components[:port],
        :path => components[:path],
        :query => components[:query],
        :fragment => components[:fragment]
      )
    end

    ##
    # Returns the shortest normalized relative form of the supplied URI that
    # uses this URI as a base for resolution. Returns an absolute URI if
    # necessary. This is effectively the opposite of <code>route_from</code>.
    #
    # @param [String, Addressable::URI, #to_str] uri The URI to route to.
    #
    # @return [Addressable::URI]
    #   The normalized relative URI that is equivalent to the supplied URI.
    def route_to(uri)
      return self.class.parse(uri).route_from(self)
    end

    ##
    # Returns a normalized URI object.
    #
    # NOTE: This method does not attempt to fully conform to specifications.
    # It exists largely to correct other people's failures to read the
    # specifications, and also to deal with caching issues since several
    # different URIs may represent the same resource and should not be
    # cached multiple times.
    #
    # @return [Addressable::URI] The normalized URI.
    def normalize
      # This is a special exception for the frequently misused feed
      # URI scheme.
      if normalized_scheme == "feed"
        if self.to_s =~ /^feed:\/*http:\/*/
          return self.class.parse(
            self.to_s[/^feed:\/*(http:\/*.*)/, 1]
          ).normalize
        end
      end

      return Addressable::URI.new(
        :scheme => normalized_scheme,
        :authority => normalized_authority,
        :path => normalized_path,
        :query => normalized_query,
        :fragment => normalized_fragment
      )
    end

    ##
    # Destructively normalizes this URI object.
    #
    # @return [Addressable::URI] The normalized URI.
    #
    # @see Addressable::URI#normalize
    def normalize!
      replace_self(self.normalize)
    end

    ##
    # Creates a URI suitable for display to users. If semantic attacks are
    # likely, the application should try to detect these and warn the user.
    # See <a href="http://www.ietf.org/rfc/rfc3986.txt">RFC 3986</a>,
    # section 7.6 for more information.
    #
    # @return [Addressable::URI] A URI suitable for display purposes.
    def display_uri
      display_uri = self.normalize
      display_uri.host = ::Addressable::IDNA.to_unicode(display_uri.host)
      return display_uri
    end

    ##
    # Returns <code>true</code> if the URI objects are equal. This method
    # normalizes both URIs before doing the comparison, and allows comparison
    # against <code>Strings</code>.
    #
    # @param [Object] uri The URI to compare.
    #
    # @return [TrueClass, FalseClass]
    #   <code>true</code> if the URIs are equivalent, <code>false</code>
    #   otherwise.
    def ===(uri)
      if uri.respond_to?(:normalize)
        uri_string = uri.normalize.to_s
      else
        begin
          uri_string = ::Addressable::URI.parse(uri).normalize.to_s
        rescue InvalidURIError, TypeError
          return false
        end
      end
      return self.normalize.to_s == uri_string
    end

    ##
    # Returns <code>true</code> if the URI objects are equal. This method
    # normalizes both URIs before doing the comparison.
    #
    # @param [Object] uri The URI to compare.
    #
    # @return [TrueClass, FalseClass]
    #   <code>true</code> if the URIs are equivalent, <code>false</code>
    #   otherwise.
    def ==(uri)
      return false unless uri.kind_of?(self.class)
      return self.normalize.to_s == uri.normalize.to_s
    end

    ##
    # Returns <code>true</code> if the URI objects are equal. This method
    # does NOT normalize either URI before doing the comparison.
    #
    # @param [Object] uri The URI to compare.
    #
    # @return [TrueClass, FalseClass]
    #   <code>true</code> if the URIs are equivalent, <code>false</code>
    #   otherwise.
    def eql?(uri)
      return false unless uri.kind_of?(self.class)
      return self.to_s == uri.to_s
    end

    ##
    # A hash value that will make a URI equivalent to its normalized
    # form.
    #
    # @return [Integer] A hash of the URI.
    def hash
      return @hash ||= (self.to_s.hash * -1)
    end

    ##
    # Clones the URI object.
    #
    # @return [Addressable::URI] The cloned URI.
    def dup
      duplicated_uri = Addressable::URI.new(
        :scheme => self.scheme ? self.scheme.dup : nil,
        :user => self.user ? self.user.dup : nil,
        :password => self.password ? self.password.dup : nil,
        :host => self.host ? self.host.dup : nil,
        :port => self.port,
        :path => self.path ? self.path.dup : nil,
        :query => self.query ? self.query.dup : nil,
        :fragment => self.fragment ? self.fragment.dup : nil
      )
      return duplicated_uri
    end

    ##
    # Freezes the URI object.
    #
    # @return [Addressable::URI] The frozen URI.
    def freeze
      # Unfortunately, because of the memoized implementation of many of the
      # URI methods, the default freeze method will cause unexpected errors.
      # As an alternative, we freeze the string representation of the URI
      # instead. This should generally produce the desired effect.
      self.to_s.freeze
      return self
    end

    ##
    # Determines if the URI is frozen.
    #
    # @return [TrueClass, FalseClass]
    #   <code>true</code> if the URI is frozen, <code>false</code> otherwise.
    def frozen?
      self.to_s.frozen?
    end

    ##
    # Omits components from a URI.
    #
    # @param [Symbol] *components The components to be omitted.
    #
    # @return [Addressable::URI] The URI with components omitted.
    #
    # @example
    #   uri = Addressable::URI.parse("http://example.com/path?query")
    #   #=> #<Addressable::URI:0xcc5e7a URI:http://example.com/path?query>
    #   uri.omit(:scheme, :authority)
    #   #=> #<Addressable::URI:0xcc4d86 URI:/path?query>
    def omit(*components)
      invalid_components = components - [
        :scheme, :user, :password, :userinfo, :host, :port, :authority,
        :path, :query, :fragment
      ]
      unless invalid_components.empty?
        raise ArgumentError,
          "Invalid component names: #{invalid_components.inspect}."
      end
      duplicated_uri = self.dup
      duplicated_uri.defer_validation do
        components.each do |component|
          duplicated_uri.send((component.to_s + "=").to_sym, nil)
        end
        duplicated_uri.user = duplicated_uri.normalized_user
      end
      duplicated_uri
    end

    ##
    # Destructive form of omit.
    #
    # @param [Symbol] *components The components to be omitted.
    #
    # @return [Addressable::URI] The URI with components omitted.
    #
    # @see Addressable::URI#omit
    def omit!(*components)
      replace_self(self.omit(*components))
    end

    ##
    # Converts the URI to a <code>String</code>.
    #
    # @return [String] The URI's <code>String</code> representation.
    def to_s
      @uri_string ||= (begin
        uri_string = ""
        uri_string << "#{self.scheme}:" if self.scheme != nil
        uri_string << "//#{self.authority}" if self.authority != nil
        uri_string << self.path.to_s
        uri_string << "?#{self.query}" if self.query != nil
        uri_string << "##{self.fragment}" if self.fragment != nil
        if uri_string.respond_to?(:force_encoding)
          uri_string.force_encoding(Encoding::UTF_8)
        end
        uri_string
      end)
    end

    ##
    # URI's are glorified <code>Strings</code>. Allow implicit conversion.
    alias_method :to_str, :to_s

    ##
    # Returns a Hash of the URI components.
    #
    # @return [Hash] The URI as a <code>Hash</code> of components.
    def to_hash
      return {
        :scheme => self.scheme,
        :user => self.user,
        :password => self.password,
        :host => self.host,
        :port => self.port,
        :path => self.path,
        :query => self.query,
        :fragment => self.fragment
      }
    end

    ##
    # Returns a <code>String</code> representation of the URI object's state.
    #
    # @return [String] The URI object's state, as a <code>String</code>.
    def inspect
      sprintf("#<%s:%#0x URI:%s>", self.class.to_s, self.object_id, self.to_s)
    end

    ##
    # This method allows you to make several changes to a URI simultaneously,
    # which separately would cause validation errors, but in conjunction,
    # are valid.  The URI will be revalidated as soon as the entire block has
    # been executed.
    #
    # @param [Proc] block
    #   A set of operations to perform on a given URI.
    def defer_validation(&block)
      raise LocalJumpError, "No block given." unless block
      @validation_deferred = true
      block.call()
      @validation_deferred = false
      validate
      return nil
    end

  private
    ##
    # Resolves paths to their simplest form.
    #
    # @param [String] path The path to normalize.
    #
    # @return [String] The normalized path.
    def self.normalize_path(path)
      # Section 5.2.4 of RFC 3986

      return nil if path.nil?
      normalized_path = path.dup
      previous_state = normalized_path.dup
      begin
        previous_state = normalized_path.dup
        normalized_path.gsub!(/\/\.\//, "/")
        normalized_path.gsub!(/\/\.$/, "/")
        parent = normalized_path[/\/([^\/]+)\/\.\.\//, 1]
        if parent != "." && parent != ".."
          normalized_path.gsub!(/\/#{parent}\/\.\.\//, "/")
        end
        parent = normalized_path[/\/([^\/]+)\/\.\.$/, 1]
        if parent != "." && parent != ".."
          normalized_path.gsub!(/\/#{parent}\/\.\.$/, "/")
        end
        normalized_path.gsub!(/^\.\.?\/?/, "")
        normalized_path.gsub!(/^\/\.\.?\//, "/")

        # Non-standard
        normalized_path.gsub!(/^(\/\.\.?)+\/?$/, "/")
      end until previous_state == normalized_path
      return normalized_path
    end

    ##
    # Ensures that the URI is valid.
    def validate
      return if !!@validation_deferred
      if self.scheme != nil &&
          (self.host == nil || self.host == "") &&
          (self.path == nil || self.path == "")
        raise InvalidURIError,
          "Absolute URI missing hierarchical segment: '#{self.to_s}'"
      end
      if self.host == nil
        if self.port != nil ||
            self.user != nil ||
            self.password != nil
          raise InvalidURIError, "Hostname not supplied: '#{self.to_s}'"
        end
      end
      if self.path != nil && self.path != "" && self.path[0..0] != "/" &&
          self.authority != nil
        raise InvalidURIError,
          "Cannot have a relative path with an authority set: '#{self.to_s}'"
      end
      return nil
    end

    ##
    # Replaces the internal state of self with the specified URI's state.
    # Used in destructive operations to avoid massive code repetition.
    #
    # @param [Addressable::URI] uri The URI to replace <code>self</code> with.
    #
    # @return [Addressable::URI] <code>self</code>.
    def replace_self(uri)
      # Reset dependant values
      instance_variables.each do |var|
        instance_variable_set(var, nil)
      end

      @scheme = uri.scheme
      @user = uri.user
      @password = uri.password
      @host = uri.host
      @port = uri.port
      @path = uri.path
      @query = uri.query
      @fragment = uri.fragment
      return self
    end
  end
end
