# implicitly requires OpenSSL
module Diaspora
  module Camo
    def self.from_markdown(markdown_text)
      return unless markdown_text
      markdown_text.gsub!(/(!\[(.*?)\]\s?\([ \t]*()<?(\S+?)>?[ \t]*((['"])(.*?)\6[ \t]*)?\))/m) do |link|
        link.gsub(Regexp.last_match[4], image_url(Regexp.last_match[4]))
      end
      markdown_text.gsub(/src=(['"])(.+?)\1/m) do |link|
        link.gsub(Regexp.last_match[2], image_url(Regexp.last_match[2]))
      end
    end

    def self.image_url(url)
      return unless url
      return url unless self.url_eligible?(url)

      digest = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha1'),
        AppConfig.privacy.camo.key,
        url
      )

      encoded_url = url.to_enum(:each_byte).map { |byte| '%02x' % byte }.join
      File.join(AppConfig.privacy.camo.root, digest, encoded_url)
    end

    def self.url_eligible?(url)
      return false unless url.start_with?('http', '//')
      return false if url.start_with?(AppConfig.environment.url.to_s,
                                      AppConfig.privacy.camo.root.to_s)
      true
    end
  end
end
