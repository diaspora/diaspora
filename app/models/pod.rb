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

  scope :check_failed, lambda {
    where(arel_table[:status].gt(Pod.statuses[:no_errors]))
  }

  class << self
    def find_or_create_by(opts) # Rename this method to not override an AR method
      u = URI.parse(opts.fetch(:url))
      find_or_initialize_by(host: u.host).tap do |pod|
        unless pod.persisted?
          pod.ssl = (u.scheme == "https")
          pod.save
        end
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
      Pod.find_in_batches(batch_size: 20).each(&:test_connection!)
    end
  end

  def offline?
    Pod.offline_statuses.include?(Pod.statuses[status])
  end

  def was_offline?
    Pod.offline_statuses.include?(Pod.statuses[status_was])
  end

  def test_connection!
    url = "#{ssl ? 'https' : 'http'}://#{host}"
    result = ConnectionTester.check url
    logger.info "testing pod: '#{url}' - #{result.inspect}"

    transaction do
      update_from_result(result)
    end
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
end
