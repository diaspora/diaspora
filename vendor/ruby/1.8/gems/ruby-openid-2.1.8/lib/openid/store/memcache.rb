require 'openid/util'
require 'openid/store/interface'
require 'openid/store/nonce'
require 'time'

module OpenID
  module Store
    class Memcache < Interface
      attr_accessor :key_prefix

      def initialize(cache_client, key_prefix='openid-store:')
        @cache_client = cache_client
        self.key_prefix = key_prefix
      end

      # Put a Association object into storage.
      # When implementing a store, don't assume that there are any limitations
      # on the character set of the server_url.  In particular, expect to see
      # unescaped non-url-safe characters in the server_url field.
      def store_association(server_url, association)
        serialized = serialize(association)
        [nil, association.handle].each do |handle|
          key = assoc_key(server_url, handle)
          @cache_client.set(key, serialized, expiry(association.lifetime))
        end
      end

      # Returns a Association object from storage that matches
      # the server_url.  Returns nil if no such association is found or if
      # the one matching association is expired. (Is allowed to GC expired
      # associations when found.)
      def get_association(server_url, handle=nil)
        serialized = @cache_client.get(assoc_key(server_url, handle))
        if serialized
          return deserialize(serialized)
        else
          return nil
        end
      end

      # If there is a matching association, remove it from the store and
      # return true, otherwise return false.
      def remove_association(server_url, handle)
        deleted = delete(assoc_key(server_url, handle))
        server_assoc = get_association(server_url)
        if server_assoc && server_assoc.handle == handle
          deleted = delete(assoc_key(server_url)) | deleted
        end
        return deleted
      end

      # Return true if the nonce has not been used before, and store it
      # for a while to make sure someone doesn't try to use the same value
      # again.  Return false if the nonce has already been used or if the
      # timestamp is not current.
      # You can use OpenID::Store::Nonce::SKEW for your timestamp window.
      # server_url: URL of the server from which the nonce originated
      # timestamp: time the nonce was created in seconds since unix epoch
      # salt: A random string that makes two nonces issued by a server in
      #       the same second unique
      def use_nonce(server_url, timestamp, salt)
        return false if (timestamp - Time.now.to_i).abs > Nonce.skew
        ts = timestamp.to_s # base 10 seconds since epoch
        nonce_key = key_prefix + 'N' + server_url + '|' + ts + '|' + salt
        result = @cache_client.add(nonce_key, '', expiry(Nonce.skew + 5))
        return !!(result =~ /^STORED/)
      end

      def assoc_key(server_url, assoc_handle=nil)
        key = key_prefix + 'A' + server_url
        if assoc_handle
          key += '|' + assoc_handle
        end
        return key
      end

      def cleanup_nonces
      end

      def cleanup
      end

      def cleanup_associations
      end

      protected

      def delete(key)
        result = @cache_client.delete(key)
        return !!(result =~ /^DELETED/)
      end

      def serialize(assoc)
        Marshal.dump(assoc)
      end

      def deserialize(assoc_str)
        Marshal.load(assoc_str)
      end

      # Convert a lifetime in seconds into a memcache expiry value
      def expiry(t)
        Time.now.to_i + t
      end
    end
  end
end
