module Fog
  module AWS
    class Storage
      class Real

        # Get a hash of hidden fields for form uploading to S3, in the form {:field_name => :field_value}
        # Form should look like: <form action="http://#{bucket_name}.s3.amazonaws.com/" method="post" enctype="multipart/form-data">
        # These hidden fields should then appear, followed by a field named 'file' which is either a textarea or file input.
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * acl<~String> - access control list, in ['private', 'public-read', 'public-read-write', 'authenticated-read', 'bucket-owner-read', 'bucket-owner-full-control']
        #   * Cache-Control - same as REST header
        #   * Content-Type - same as REST header
        #   * Content-Disposition - same as REST header
        #   * Content-Encoding - same as REST header
        #   * Expires - same as REST header
        #   * key - key for object, set to '${filename}' to use filename provided by user
        #   * policy - security policy for upload
        #   * success_action_redirect - url to redirct to upon success
        #   * success_action_status - status code to return on success, in [200, 201, 204]
        #   * x-amz-security-token - devpay security token
        #   * x-amz-meta-... - meta data tags
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/dev/HTTPPOSTForms.html

        def post_object_hidden_fields(options = {})
          if options['policy']
            options['policy'] = options['policy'].to_json
            options['AWSAccessKeyId'] = @aws_access_key_id
            string_to_sign = Base64.encode64(options['policy']).chomp!
            signed_string = @hmac.sign(string_to_sign)
            options['Signature'] = Base64.encode64(signed_string).chomp!
          end
          options
        end

      end

      class Mock # :nodoc:all

        def post_object_hidden_fields(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
