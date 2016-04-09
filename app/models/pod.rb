class Pod < ActiveRecord::Base
  enum status: %i(
    unchecked
    no_errors
    dns_failed
    net_failed
    ssl_failed
    http_failed
    version_failed
    unknown_error
  )

  ERROR_MAP = {
    ConnectionTester::AddressFailure  => :dns_failed,
    ConnectionTester::DNSFailure      => :dns_failed,
    ConnectionTester::NetFailure      => :net_failed,
    ConnectionTester::SSLFailure      => :ssl_failed,
    ConnectionTester::HTTPFailure     => :http_failed,
    ConnectionTester::NodeInfoFailure => :version_failed
  }

  DEFAULT_PORTS = [URI::HTTP::DEFAULT_PORT, URI::HTTPS::DEFAULT_PORT]

  has_many :people

  scope :check_failed, lambda {
    where(arel_table[:status].gt(Pod.statuses[:no_errors])).where.not(status: Pod.statuses[:version_failed])
  }

  validate :not_own_pod

  class << self
    def find_or_create_by(opts) # Rename this method to not override an AR method
      uri = URI.parse(opts.fetch(:url))
      port = DEFAULT_PORTS.include?(uri.port) ? nil : uri.port
      find_or_initialize_by(host: uri.host, port: port).tap do |pod|
        pod.ssl ||= (uri.scheme == "https")
        pod.save
      end
    end

    # don't consider a failed version reading to be fatal
    def offline_statuses
      [Pod.statuses[:dns_failed],
       Pod.statuses[:net_failed],
       Pod.statuses[:ssl_failed],
       Pod.statuses[:http_failed],
       Pod.statuses[:unknown_error]]
    end

    def check_all!
      Pod.find_in_batches(batch_size: 20) {|batch| batch.each(&:test_connection!) }
    end
  end

  def offline?
    Pod.offline_statuses.include?(Pod.statuses[status])
  end

  def was_offline?
    Pod.offline_statuses.include?(Pod.statuses[status_was])
  end

  def test_connection!
    result = ConnectionTester.check uri.to_s
    logger.debug "tested pod: '#{uri}' - #{result.inspect}"

    transaction do
      update_from_result(result)
    end
  end

  # @param path [String]
  # @return [String]
  def url_to(path)
    uri.tap {|uri| uri.path = path }.to_s
  end

  private

  def update_from_result(result)
    self.status = status_from_result(result)

    if offline?
      touch(:offline_since) unless was_offline?
      logger.warn "OFFLINE #{result.failure_message}"
    else
      self.offline_since = nil
    end

    attributes_from_result(result)
    touch(:checked_at)

    save
  end

  def attributes_from_result(result)
    self.ssl ||= result.ssl
    self.error = result.failure_message[0..254] if result.error?
    self.software = result.software_version[0..254] if result.software_version.present?
    self.response_time = result.rt
  end

  def status_from_result(result)
    if result.error?
      ERROR_MAP.fetch(result.error.class, :unknown_error)
    else
      :no_errors
    end
  end

  # @return [URI]
  def uri
    @uri ||= (ssl ? URI::HTTPS : URI::HTTP).build(host: host, port: port)
    @uri.dup
  end

  def not_own_pod
    pod_uri = AppConfig.pod_uri
    pod_port = DEFAULT_PORTS.include?(pod_uri.port) ? nil : pod_uri.port
    errors.add(:base, "own pod not allowed") if pod_uri.host == host && pod_port == port
  end
end
