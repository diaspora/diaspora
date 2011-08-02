#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'uri'

module Job
  class HttpMulti < Base
    @queue = :http

    Hydra = Typhoeus::Hydra
    Request = Typhoeus::Request
    MAX_RETRIES = 3
    OPTS = {:max_redirects => 3, :timeout => 5000, :method => :post}

    def self.perform(user_id, enc_object_xml, person_ids, retry_count=0)
      user = User.find(user_id)
      people = Person.where(:id => person_ids)

      salmon = Salmon::SalmonSlap.create(user, Base64.decode64(enc_object_xml))

      failed_request_people = []

      hydra = Hydra.new
      people.each do |person|

        url = person.receive_url
        begin
          xml = salmon.xml_for(person)
        rescue OpenSSL::PKey::RSAError => e
          Rails.logger.info(:event => :invalid_rsa_key, :identifier => person.diaspora_handle)
          next
        end

        Rails.logger.info("event=http_multi_send sender_id=#{user_id} recipient_id=#{person.id} url=#{url} xml='#{xml}'")

        request = Request.new(url, OPTS.merge(:params => {:xml => CGI::escape(xml)}))

        request.on_complete do |response|
          if response.code >= 300 && response.code < 400
            if response.headers_hash['Location'] == response.request.url.sub('http://', 'https://')
              location = URI.parse(response.headers_hash['Location'])
              newuri = "#{location.scheme}://#{location.host}"
              newuri += ":#{location.port}" unless ["80", "443"].include?(location.port.to_s)
              newuri += "/"
              person.url = newuri
              person.save
            end
          end
          unless response.success?
            pod = Pod.find_or_create_by_url(response.effective_url)
            log_line = "event=http_multi_fail sender_id=#{user_id} recipient_id=#{person.id} url=#{response.effective_url} response_code='#{response.code}' xml='#{Base64.decode64(enc_object_xml)}'"
            Rails.logger.info(log_line)
            pod.pod_stats.create(:error_message => log_line, :person_id => person.id, :error_code => response.code.to_i)
            failed_request_people << person.id
          end
        end

        hydra.queue request
      end
      hydra.run

      unless failed_request_people.empty?
        if retry_count < MAX_RETRIES
          Resque.enqueue(Job::HttpMulti, user_id, enc_object_xml, failed_request_people, retry_count + 1 )
        else
          Rails.logger.info("event=http_multi_abandon sender_id=#{user_id} failed_recipient_ids='[#{person_ids.join(', ')}] xml='#{Base64.decode64(enc_object_xml)}'")
        end
      end
    end
  end
end
