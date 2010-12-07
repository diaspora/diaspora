module Jobs
  class HttpMulti
    @queue = :http

    MAX_RETRIES = 3
    OPTS = {:max_redirects => 3, :timeout => 5000, :method => :post}

    def self.perform(user_id, object_type, object_id, person_ids, retry_count=0)
      user = User.find(user_id)
      people = Person.all(:id.in => person_ids)

      object = object_type.constantize.find(object_id)
      salmon = user.salmon(object)

      failed_request_people = []

      hydra = Typhoeus::Hydra.new
      people.each do |person|

        url = person.receive_url
        xml = salmon.xml_for(person)

        request = Typhoeus::Request.new(url, OPTS.merge(:xml => xml))

        request.on_complete do |response|
          unless response.success?
            failed_request_people << person.id
          end
        end

        hydra.queue request
      end
      hydra.run

      unless failed_request_people.empty? || retry_count >= MAX_RETRIES
        Resque.enqueue(Jobs::HttpMulti, user_id, object_type, object_id, failed_request_people, retry_count+=1 )
      end
    end
  end
end
