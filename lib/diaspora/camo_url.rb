# implicitly requires OpenSSL

module Diaspora
  module CamoUrl
    def self.image_url(url)
      digest = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new("sha1"),
        AppConfig.privacy.camo.key,
        url
      )
      encoded_url = url.to_enum(:each_byte).map {|byte| "%02x" % byte}.join

      "#{AppConfig.privacy.camo.root}#{digest}/#{encoded_url}"
    end
  end
end
