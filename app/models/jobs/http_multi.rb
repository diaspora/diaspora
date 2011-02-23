module Job
  class HttpMulti < Base
    @queue = :http

    MAX_RETRIES = 3
    OPTS = {:max_redirects => 3, :timeout => 5000, :method => :post}

    def self.perform_delegate(user_id, enc_object_xml, person_ids, retry_count=0)
      user = User.find(user_id)
      people = Person.where(:id => person_ids)

      salmon = Salmon::SalmonSlap.create(user, Base64.decode64(enc_object_xml))

      failed_request_people = []

      hydra = Typhoeus::Hydra.new
      people.each do |person|

        url = person.receive_url
        xml = salmon.xml_for(person)

        request = Typhoeus::Request.new(url, OPTS.merge(:params => {:xml => CGI::escape(xml)}))

        request.on_complete do |response|
          unless response.success?
            failed_request_people << person.id
          end
        end

        hydra.queue request
      end
      hydra.run

      unless failed_request_people.empty? || retry_count >= MAX_RETRIES
        Resque.enqueue(Job::HttpMulti, user_id, enc_object_xml, failed_request_people, retry_count+=1 )
      end
    end
  end
end
