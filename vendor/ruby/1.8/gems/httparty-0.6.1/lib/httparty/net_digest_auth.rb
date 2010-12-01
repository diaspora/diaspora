require 'digest/md5'
require 'net/http'

module Net
  module HTTPHeader
    def digest_auth(user, password, response)
      response['www-authenticate'] =~ /^(\w+) (.*)/

      params = {}
      $2.gsub(/(\w+)="(.*?)"/) { params[$1] = $2 }
      params.merge!("cnonce" => Digest::MD5.hexdigest("%x" % (Time.now.to_i + rand(65535))))

      a_1 = Digest::MD5.hexdigest("#{user}:#{params['realm']}:#{password}")
      a_2 = Digest::MD5.hexdigest("#{@method}:#{@path}")

      request_digest = Digest::MD5.hexdigest(
        [a_1, params['nonce'], "0", params['cnonce'], params['qop'], a_2].join(":")
      )

      header = [
        %Q(Digest username="#{user}"),
        %Q(realm="#{params['realm']}"),
        %Q(qop="#{params['qop']}"),
        %Q(uri="#{@path}"),
        %Q(nonce="#{params['nonce']}"),
        %Q(nc="0"),
        %Q(cnonce="#{params['cnonce']}"),
        %Q(opaque="#{params['opaque']}"),
        %Q(response="#{request_digest}")
      ]

      @header['Authorization'] = header
    end
  end
end
