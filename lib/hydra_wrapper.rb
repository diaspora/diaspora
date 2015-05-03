#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HydraWrapper

  OPTS = {
    maxredirs: 3,
    timeout: 25,
    method: :post,
    verbose: AppConfig.settings.typhoeus_verbose?,
    cainfo: AppConfig.environment.certificate_authorities.get,
    headers: {
      'Expect'            => '',
      'Transfer-Encoding' => '',
      'User-Agent'        => "Diaspora #{AppConfig.version_string}"
    }
  }

  attr_reader :people_to_retry , :user, :encoded_object_xml
  attr_accessor :dispatcher_class, :people
  delegate :run, to: :hydra

  def initialize user, people, encoded_object_xml, dispatcher_class
    @user = user
    @people_to_retry = []
    @people = people
    @dispatcher_class = dispatcher_class
    @encoded_object_xml = encoded_object_xml
    @keep_for_retry_proc = Proc.new do |response|
      true
    end
  end

  # Inserts jobs for all @people
  def enqueue_batch
    grouped_people.each do |receive_url, people_for_receive_url|
      if xml = xml_factory.xml_for(people_for_receive_url.first)
        insert_job(receive_url, xml, people_for_receive_url)
      end
    end
  end

  # This method can be used to tell the hydra whether or not to
  # retry a request that it made which failed.
  # @yieldparam response [Typhoeus::Response] The response object for the failed request.
  # @yieldreturn [Boolean] Whether the request whose response was passed to the block should be retried.
  def keep_for_retry_if &block
    @keep_for_retry_proc = block
  end

  private

  def hydra
    @hydra ||= Typhoeus::Hydra.new(max_concurrency: AppConfig.settings.typhoeus_concurrency.to_i)
  end

  # @return [Salmon]
  def xml_factory
    @xml_factory ||= @dispatcher_class.salmon @user, Base64.decode64(@encoded_object_xml)
  end

  # Group people on their receiving_urls
  # @return [Hash] People grouped by receive_url ([String] => [Array<Person>])
  def grouped_people
    @people.group_by { |person|
      @dispatcher_class.receive_url_for person
    }
  end

  # Prepares and inserts job into the hydra queue
  # @param url [String]
  # @param xml [String]
  # @params people [Array<Person>]
  def insert_job url, xml, people
    request = Typhoeus::Request.new url, OPTS.merge(body: {xml: CGI.escape(xml)})
    prepare_request request, people
    hydra.queue request
  end

  # @param request [Typhoeus::Request]
  # @param person [Person]
  def prepare_request request, people_for_receive_url
    request.on_complete do |response|
      # Save the reference to the pod to the database if not already present
      Pod.find_or_create_by(url: response.effective_url)

      if redirecting_to_https? response
        Person.url_batch_update people_for_receive_url, response.headers_hash['Location']
      end

      unless response.success?
        message = {
          event: "http_multi_fail",
          sender_id: @user.id,
          url: response.effective_url,
          return_code: response.return_code
        }
        Rails.logger.info message.to_a.map { |k,v| "#{k}=#{v}" }.join(' ')

        if @keep_for_retry_proc.call(response)
          @people_to_retry += people_for_receive_url.map(&:id)
        end

      end
    end
  end

  # @return [Boolean]
  def redirecting_to_https? response
    response.code >= 300 && response.code < 400 &&
    response.headers_hash['Location'] == response.request.url.sub('http://', 'https://')
  end
end
