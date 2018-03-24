# frozen_string_literal: true

require "pathname"
require "json-schema"

module NodeInfo
  VERSIONS = %w(1.0 2.0).freeze
  SCHEMAS = {}
  private_constant :VERSIONS, :SCHEMAS

  # rubocop:disable Metrics/BlockLength
  Document = Struct.new(:version, :software, :protocols, :services, :open_registrations, :usage, :metadata) do
    Software = Struct.new(:name, :version) do
      def initialize(name=nil, version=nil)
        super(name, version)
      end

      def version_10_hash
        {
          "name"    => name,
          "version" => version
        }
      end
    end

    Protocols = Struct.new(:protocols) do
      def initialize(protocols=[])
        super(protocols)
      end

      def version_10_hash
        {
          "inbound"  => protocols,
          "outbound" => protocols
        }
      end

      def version_20_array
        protocols
      end
    end

    Services = Struct.new(:inbound, :outbound) do
      def initialize(inbound=[], outbound=[])
        super(inbound, outbound)
      end

      def version_10_hash
        {
          "inbound"  => inbound,
          "outbound" => outbound
        }
      end
    end

    Usage = Struct.new(:users, :local_posts, :local_comments) do
      Users = Struct.new(:total, :active_halfyear, :active_month) do
        def initialize(total=nil, active_halfyear=nil, active_month=nil)
          super(total, active_halfyear, active_month)
        end

        def version_10_hash
          {
            "total"          => total,
            "activeHalfyear" => active_halfyear,
            "activeMonth"    => active_month
          }
        end
      end

      def initialize(local_posts=nil, local_comments=nil)
        super(Users.new, local_posts, local_comments)
      end

      def version_10_hash
        {
          "users"         => users.version_10_hash,
          "localPosts"    => local_posts,
          "localComments" => local_comments
        }
      end
    end

    def self.build
      new.tap do |doc|
        yield doc
        doc.validate
      end
    end

    def initialize(version=nil, open_registrations=nil, metadata={})
      super(version, Software.new, Protocols.new, Services.new, open_registrations, Usage.new, metadata)
    end

    def as_json(_options={})
      case version
      when "1.0"
        version_10_hash
      when "2.0"
        version_20_hash
      end
    end

    def content_type
      "application/json; profile=http://nodeinfo.diaspora.software/ns/schema/#{version}#"
    end

    def schema
      NodeInfo.schema version
    end

    def validate
      assert NodeInfo.supported_version?(version), "Unknown version #{version}"
      JSON::Validator.validate!(schema, as_json)
    end

    private

    def assert(condition, message)
      raise ArgumentError, message unless condition
    end

    def version_10_hash
      deep_compact(
        "version"           => "1.0",
        "software"          => software.version_10_hash,
        "protocols"         => protocols.version_10_hash,
        "services"          => services.version_10_hash,
        "openRegistrations" => open_registrations,
        "usage"             => usage.version_10_hash,
        "metadata"          => metadata
      )
    end

    def version_20_hash
      deep_compact(
        "version"           => "2.0",
        "software"          => software.version_10_hash,
        "protocols"         => protocols.version_20_array,
        "services"          => services.version_10_hash,
        "openRegistrations" => open_registrations,
        "usage"             => usage.version_10_hash,
        "metadata"          => metadata
      )
    end

    def deep_compact(hash)
      hash.tap do |hash|
        hash.reject! {|_, value|
          deep_compact value if value.is_a? Hash
          value.nil?
        }
      end
    end
  end
  # rubocop:enable Metrics/BlockLength

  def self.schema(version)
    SCHEMAS[version] ||= JSON.parse(
      Pathname.new(__dir__).join("..", "vendor", "nodeinfo", "schemas", "#{version}.json").expand_path.read
    )
  end

  def self.build(&block)
    Document.build(&block)
  end

  def self.jrd(endpoint)
    {
      "links" => VERSIONS.map {|version|
        {
          "rel"  => "http://nodeinfo.diaspora.software/ns/schema/#{version}",
          "href" => endpoint % {version: version}
        }
      }
    }
  end

  def self.supported_version?(version)
    VERSIONS.include? version
  end
end
