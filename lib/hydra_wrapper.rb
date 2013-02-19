#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HydraWrapper

  OPTS = {:max_redirects => 3, :timeout => 25000, :method => :post,
          :verbose => AppConfig.settings.typhoeus_verbose?,
          :ssl_cacert => AppConfig.environment.certificate_authorities.get,
          :headers => {'Expect'            => '',
                       'Transfer-Encoding' => ''}
         }

  attr_reader :failed_people, :user, :encoded_object_xml
  attr_accessor :dispatcher_class, :people, :hydra

  def initialize(user, people, encoded_object_xml, dispatcher_class)
    @user = user
    @failed_people = []
    @hydra = Typhoeus::Hydra.new
    @people = people
    @dispatcher_class = dispatcher_class
    @encoded_object_xml = encoded_object_xml
  end

  # Delegates run to the @hydra
  def run
    @hydra.run
  end

  # @return [Salmon]
  def xml_factory
    @xml_factory ||= @dispatcher_class.salmon(@user, Base64.decode64(@encoded_object_xml))
  end

  # Group people on their receiving_urls
  # @return [Hash] People grouped by receive_url ([String] => [Array<Person>])
  def grouped_people
    @people.group_by do |person|
      @dispatcher_class.receive_url_for(person)
    end
  end 

  # Inserts jobs for all @people
  def enqueue_batch
    grouped_people.each do |receive_url, people_for_receive_url|
      if xml = xml_factory.xml_for(people_for_receive_url.first)
        self.insert_job(receive_url, xml, people_for_receive_url)
      end
    end
  end

  # Prepares and inserts job into the @hydra queue
  # @param url [String]
  # @param xml [String]
  # @params people [Array<Person>]
  def insert_job(url, xml, people)
    request = Typhoeus::Request.new(url, OPTS.merge(:params => {:xml => CGI::escape(xml)}))
    prepare_request!(request, people)
    @hydra.queue(request)
  end

  # @param request [Typhoeus::Request]
  # @param person [Person]
  def prepare_request!(request, people_for_receive_url)
    request.on_complete do |response|
      # Save the reference to the pod to the database if not already present
      Pod.find_or_create_by_url(response.effective_url)

      if redirecting_to_https?(response) 
        Person.url_batch_update(people_for_receive_url, response.headers_hash['Location'])
      end

      unless response.success?
        Rails.logger.info("event=http_multi_fail sender_id=#{@user.id}  url=#{response.effective_url} response_code='#{response.code}'")
        @failed_people += people_for_receive_url.map{|i| i.id}
      end
    end
  end

  # @return [Boolean]
  def redirecting_to_https?(response)
    if response.code >= 300 && response.code < 400
      response.headers_hash['Location'] == response.request.url.sub('http://', 'https://')
    else
      false
    end
  end
end
