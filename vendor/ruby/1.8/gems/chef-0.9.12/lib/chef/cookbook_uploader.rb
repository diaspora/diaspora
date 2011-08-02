require 'rest_client'
require 'chef/cookbook_loader'
require 'chef/checksum_cache'
require 'chef/sandbox'
require 'chef/cookbook_version'
require 'chef/cookbook/syntax_check'
require 'chef/cookbook/file_system_file_vendor'

class Chef
  class CookbookUploader
    class << self

      def upload_cookbook(cookbook)
        Chef::Log.info("Saving #{cookbook.name}")

        rest = Chef::REST.new(Chef::Config[:chef_server_url])

        # Syntax Check
        validate_cookbook(cookbook)
        # Generate metadata.json from metadata.rb
        build_metadata(cookbook)

        # generate checksums of cookbook files and create a sandbox
        checksum_files = cookbook.checksums
        checksums = checksum_files.inject({}){|memo,elt| memo[elt.first]=nil ; memo}
        new_sandbox = rest.post_rest("sandboxes", { :checksums => checksums })

        Chef::Log.info("Uploading files")
        # upload the new checksums and commit the sandbox
        new_sandbox['checksums'].each do |checksum, info|
          if info['needs_upload'] == true
            Chef::Log.info("Uploading #{checksum_files[checksum]} (checksum hex = #{checksum}) to #{info['url']}")

            # Checksum is the hexadecimal representation of the md5,
            # but we need the base64 encoding for the content-md5
            # header
            checksum64 = Base64.encode64([checksum].pack("H*")).strip
            timestamp = Time.now.utc.iso8601
            file_contents = File.read(checksum_files[checksum])
            # TODO - 5/28/2010, cw: make signing and sending the request streaming
            sign_obj = Mixlib::Authentication::SignedHeaderAuth.signing_object(
                                                                               :http_method => :put,
                                                                               :path        => URI.parse(info['url']).path,
                                                                               :body        => file_contents,
                                                                               :timestamp   => timestamp,
                                                                               :user_id     => rest.client_name
                                                                               )
            headers = { 'content-type' => 'application/x-binary', 'content-md5' => checksum64, :accept => 'application/json' }
            headers.merge!(sign_obj.sign(OpenSSL::PKey::RSA.new(rest.signing_key)))
            begin
              RestClient::Resource.new(info['url'], :headers=>headers, :timeout=>1800, :open_timeout=>1800).put(file_contents)
            rescue RestClient::Exception => e
              Chef::Log.error("Upload failed: #{e.message}\n#{e.response.body}")
              raise
            end
          else
            Chef::Log.debug("#{checksum_files[checksum]} has not changed")
          end
        end
        sandbox_url = new_sandbox['uri']
        Chef::Log.debug("Committing sandbox")
        # Retry if S3 is claims a checksum doesn't exist (the eventual
        # in eventual consistency)
        retries = 0
        begin
          rest.put_rest(sandbox_url, {:is_completed => true})
        rescue Net::HTTPServerException => e
          if e.message =~ /^400/ && (retries += 1) <= 5
            sleep 2
            retry
          else
            raise
          end
        end
        # files are uploaded, so save the manifest
        cookbook.save
        Chef::Log.info("Upload complete!")
      end

      def build_metadata(cookbook)
        Chef::Log.debug("Generating metadata")
        # FIXME: This knife command should be factored out into a
        # library for use here
        kcm = Chef::Knife::CookbookMetadata.new
        kcm.config[:cookbook_path] = Chef::Config[:cookbook_path]
        kcm.name_args = [ cookbook.name.to_s ]
        kcm.run
        cookbook.reload_metadata!
      end

      def validate_cookbook(cookbook)
        syntax_checker = Chef::Cookbook::SyntaxCheck.for_cookbook(cookbook.name, @user_cookbook_path)
        Chef::Log.info("Validating ruby files")
        exit(1) unless syntax_checker.validate_ruby_files
        Chef::Log.info("Validating templates")
        exit(1) unless syntax_checker.validate_templates
        Chef::Log.info("Syntax OK")
        true
      end

    end
  end
end
