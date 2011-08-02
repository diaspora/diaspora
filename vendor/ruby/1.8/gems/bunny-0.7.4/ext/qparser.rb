# encoding: utf-8

require 'json'
require 'erb'
require 'pathname'
require 'yaml'

def spec_v8_0_0?(spec)
  spec['major'] == '8' && spec['minor'] == '0' && spec['revision'] == '0'
end

def spec_details(spec)
  meta = {}

  meta['major']     = spec['major-version']
  meta['minor']     = spec['minor-version']
  meta['revision']  = spec['revision'] || '0'
  meta['port']      = spec['port']
  meta['comment']   = "AMQ Protocol version #{meta['major']}.#{meta['minor']}.#{meta['revision']}"

  meta
end

def process_constants(spec)
  # AMQP constants

  frame_constants = {}
  other_constants = {}

  spec['constants'].each do |constant|
    if constant['name'].match(/^frame/i)
      frame_constants[constant['value'].to_i] =
      constant['name'].sub(/^frame./i,'').split(/\s|-/).map{|w| w.downcase.capitalize}.join
    else
      other_constants[constant['value']] = constant['name']
    end
  end

  [frame_constants.sort, other_constants.sort]
end

def domain_types(spec, major, minor, revision)
  # AMQP domain types

  # add types that may be missing in the spec version
  dt_arr = add_types(spec)
  spec["domains"].each do |domain|
    # JSON spec gives domain types as two element arrays like ["channel-id", "longstr"]
    dt_arr << domain.last
  end

  # Return sorted array
  dt_arr.uniq.sort
end

def classes(spec, major, minor, revision)
  # AMQP classes
  spec['classes'].map do |amqp_class|
    cls_hash = {}
    cls_hash[:name]   = amqp_class['name']
    cls_hash[:index]  = amqp_class['id']
    # Get fields for class
    cls_hash[:fields] = fields(amqp_class) # are these amqp_class["properties"] ?
    # Get methods for class
    meth_arr          = class_methods(amqp_class)
    # Add missing methods
    add_arr =[]
    add_arr = add_methods(spec) if cls_hash[:name] == 'queue'
    method_arr = meth_arr + add_arr
    # Add array to class hash
    cls_hash[:methods] = method_arr
    cls_hash
  end
end

# Get methods for class
def class_methods(amqp_class)
  amqp_class['methods'].map do |method|
    meth_hash = {}
    meth_hash[:name]  = method['name']
    meth_hash[:index] = method['id']
    # Get fields for method
    meth_hash[:fields] = fields(method)
    meth_hash
  end
end

# Get the fields for a class or method
def fields(element)
  # The JSON spec puts these in "properties" for a class and "arguments" for a
  # method
  (element['arguments'] || element['properties'] || []).map do |field|
    field_hash = {}
    field_hash[:name]   = field['name'].tr(' ', '-')
    field_hash[:domain] = field['type'] || field['domain']

    # Convert domain type if necessary
    conv_arr = convert_type(field_hash[:domain])
    field_hash[:domain] = conv_arr.last unless conv_arr.empty?

    field_hash
  end
end

def add_types(spec)
  spec_v8_0_0?(spec) ? ['long', 'longstr', 'octet', 'timestamp'] : []
end

def add_methods(spec)
  meth_arr = []

  if spec_v8_0_0?(spec)
    # Add Queue Unbind method
    meth_hash = {:name => 'unbind',
                 :index => '50',
                 :fields => [{:name => 'ticket', :domain => 'short'},
                             {:name => 'queue', :domain => 'shortstr'},
                             {:name => 'exchange', :domain => 'shortstr'},
                             {:name => 'routing_key', :domain => 'shortstr'},
                             {:name => 'arguments', :domain => 'table'}
                            ]
                }

    meth_arr << meth_hash

    # Add Queue Unbind-ok method
    meth_hash = {:name => 'unbind-ok',
                 :index => '51',
                 :fields => []
                }

    meth_arr << meth_hash
  end

  # Return methods
  meth_arr

end

def convert_type(name)
  type_arr = @type_conversion.select {|k,v| k == name}.flatten
end

# Start of Main program

# Read in config options
CONFIG = YAML::load(File.read('config.yml'))

# Get path to the spec file and the spec file name on its own
specpath = CONFIG[:spec_in]
path = Pathname.new(specpath)
specfile = path.basename.to_s

# Read in the spec file
spec = JSON.parse(IO.read(specpath))

# Declare type conversion hash
@type_conversion = {'path' => 'shortstr',
                    'known hosts' => 'shortstr',
                    'known-hosts' => 'shortstr',
                    'reply code' => 'short',
                    'reply-code' => 'short',
                    'reply text' => 'shortstr',
                    'reply-text' => 'shortstr',
                    'class id' => 'short',
                    'class-id' => 'short',
                    'method id' => 'short',
                    'method-id' => 'short',
                    'channel-id' => 'longstr',
                    'access ticket' => 'short',
                    'access-ticket' => 'short',
                    'exchange name' => 'shortstr',
                    'exchange-name' => 'shortstr',
                    'queue name' => 'shortstr',
                    'queue-name' => 'shortstr',
                    'consumer tag' => 'shortstr',
                    'consumer-tag' => 'shortstr',
                    'delivery tag' => 'longlong',
                    'delivery-tag' => 'longlong',
                    'redelivered' => 'bit',
                    'no ack' => 'bit',
                    'no-ack' => 'bit',
                    'no local' => 'bit',
                    'no-local' => 'bit',
                    'peer properties' => 'table',
                    'peer-properties' => 'table',
                    'destination' => 'shortstr',
                    'duration' => 'longlong',
                    'security-token' => 'longstr',
                    'reject-code' => 'short',
                    'reject-text' => 'shortstr',
                    'offset' => 'longlong',
                    'no-wait' => 'bit',
                    'message-count' => 'long'
                   }

# Spec details
spec_info = spec_details(spec)

# Constants
constants = process_constants(spec)

# Frame constants
frame_constants = constants[0].select {|k,v| k <= 8}
frame_footer = constants[0].select {|k,v| v == 'End'}[0][0]

# Other constants
other_constants = constants[1]

# Domain types
data_types = domain_types(spec, spec_info['major'], spec_info['minor'], spec_info['revision'])

# Classes
class_defs = classes(spec, spec_info['major'], spec_info['minor'], spec_info['revision'])

# Generate spec.rb
spec_rb = File.open(CONFIG[:spec_out], 'w')
spec_rb.puts(
ERB.new(%q[
  # encoding: utf-8
  
  
  #:stopdoc:
  # this file was autogenerated on <%= Time.now.to_s %>
  # using <%= specfile.ljust(16) %> (mtime: <%= File.mtime(specpath) %>)
  #
  # DO NOT EDIT! (edit ext/qparser.rb and config.yml instead, and run 'ruby qparser.rb')

  module Qrack
    module Protocol
      HEADER        = "AMQP".freeze
      VERSION_MAJOR = <%= spec_info['major'] %>
      VERSION_MINOR = <%= spec_info['minor'] %>
      REVISION      = <%= spec_info['revision'] %>
      PORT          = <%= spec_info['port'] %>

      RESPONSES = {
        <%- other_constants.each do |value, name| -%>
        <%= value %> => :<%= name.gsub(/\s|-/, '_').upcase -%>,
        <%- end -%>
      }

      FIELDS = [
        <%- data_types.each do |d| -%>
        :<%= d -%>,
        <%- end -%>
      ]

      class Class
        class << self
          FIELDS.each do |f|
            class_eval %[
              def #{f} name
                properties << [ :#{f}, name ] unless properties.include?([:#{f}, name])
                attr_accessor name
              end
            ]
          end

          def properties() @properties ||= [] end

          def id()   self::ID end
          def name() self::NAME.to_s end
        end

        class Method
          class << self
            FIELDS.each do |f|
              class_eval %[
                def #{f} name
                  arguments << [ :#{f}, name ] unless arguments.include?([:#{f}, name])
                  attr_accessor name
                end
              ]
            end

            def arguments() @arguments ||= [] end

            def parent() Protocol.const_get(self.to_s[/Protocol::(.+?)::/,1]) end
            def id()     self::ID end
            def name()   self::NAME.to_s end
          end

          def == b
            self.class.arguments.inject(true) do |eql, (type, name)|
              eql and __send__("#{name}") == b.__send__("#{name}")
            end
          end
        end

        def self.methods() @methods ||= {} end

        def self.Method(id, name)
          @_base_methods ||= {}
          @_base_methods[id] ||= ::Class.new(Method) do
            class_eval %[
              def self.inherited klass
                klass.const_set(:ID, #{id})
                klass.const_set(:NAME, :#{name.to_s})
                klass.parent.methods[#{id}] = klass
                klass.parent.methods[klass::NAME] = klass
              end
            ]
          end
        end
      end

      def self.classes() @classes ||= {} end

      def self.Class(id, name)
        @_base_classes ||= {}
        @_base_classes[id] ||= ::Class.new(Class) do
          class_eval %[
            def self.inherited klass
              klass.const_set(:ID, #{id})
              klass.const_set(:NAME, :#{name.to_s})
              Protocol.classes[#{id}] = klass
              Protocol.classes[klass::NAME] = klass
            end
          ]
        end
      end
    end
  end

  module Qrack
    module Protocol
      <%- class_defs.each do |h| -%>
      class <%= h[:name].capitalize.ljust(12) %> < Class( <%= h[:index].to_s.rjust(3) %>, :<%= h[:name].ljust(12) %> ); end
      <%- end -%>

      <%- class_defs.each do |c| -%>
      class <%= c[:name].capitalize %>
        <%- c[:fields].each do |p| -%>
        <%= p[:domain].ljust(10) %> :<%= p[:name].tr('-','_') %>
        <%- end if c[:fields] -%>

        <%- c[:methods].each do |m| -%>
        class <%= m[:name].capitalize.gsub(/-(.)/){ "#{$1.upcase}"}.ljust(12) %> < Method( <%= m[:index].to_s.rjust(3) %>, :<%= m[:name].tr('- ','_').ljust(14) %> ); end
        <%- end -%>

        <%- c[:methods].each do |m| -%>

        class <%= m[:name].capitalize.gsub(/-(.)/){ "#{$1.upcase}"} %>
          <%- m[:fields].each do |a| -%>
          <%- if a[:domain] -%>
          <%= a[:domain].ljust(16) %> :<%= a[:name].tr('- ','_') %>
          <%- end -%>
          <%- end -%>
        end
        <%- end -%>

      end

      <%- end -%>
    end

  end
].gsub!(/^  /,''), nil, '>-%').result(binding)
)

# Close spec.rb file
spec_rb.close

# Generate frame.rb file

frame_rb = File.open(CONFIG[:frame_out], 'w')
frame_rb.puts(
ERB.new(%q[
  # encoding: utf-8
  

  #:stopdoc:
  # this file was autogenerated on <%= Time.now.to_s %>
  #
  # DO NOT EDIT! (edit ext/qparser.rb and config.yml instead, and run 'ruby qparser.rb')

  module Qrack
    module Transport
      class Frame

        FOOTER = <%= frame_footer %>
        ID = 0

        @types = {
                       <%- frame_constants.each do |value, name| -%>
                   <%= value %> => '<%= name %>',
                 <%- end -%>
                 }

        attr_accessor :channel, :payload

        def initialize payload = nil, channel = 0
          @channel, @payload = channel, payload
        end

        def id
          self.class::ID
        end

        def to_binary
          buf = Transport::Buffer.new
          buf.write :octet, id
          buf.write :short, channel
          buf.write :longstr, payload
          buf.write :octet, FOOTER
          buf.rewind
          buf
        end

        def to_s
          to_binary.to_s
        end

        def == frame
          [ :id, :channel, :payload ].inject(true) do |eql, field|
            eql and __send__(field) == frame.__send__(field)
          end
        end

        def self.parse buf
          buf = Transport::Buffer.new(buf) unless buf.is_a? Transport::Buffer
          buf.extract do
            id, channel, payload, footer = buf.read(:octet, :short, :longstr, :octet)
            Qrack::Transport.const_get(@types[id]).new(payload, channel) if footer == FOOTER
          end
        end

      end

      class Method < Frame

        ID = 1

        def initialize payload = nil, channel = 0
          super
          unless @payload.is_a? Protocol::Class::Method or @payload.nil?
            @payload = Protocol.parse(@payload)
          end
        end
      end

      class Header < Frame

        ID = 2

        def initialize payload = nil, channel = 0
          super
          unless @payload.is_a? Protocol::Header or @payload.nil?
            @payload = Protocol::Header.new(@payload)
          end
        end
      end

      <%- frame_constants.each do |value, name| -%>
      <%- if value > 2 -%>
      class <%= name %> < Frame
        ID = <%= value %>
      end

      <%- end -%>
      <%- end -%>
    end
  end
  ].gsub!(/^  /,''), nil, '>-%').result(binding)
  )

  # Close frame.rb file
  frame_rb.close
