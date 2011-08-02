require 'nokogiri'
require 'fog/core/parser'

module Fog
  module AWS

    extend Fog::Provider

    service_path 'fog/aws'
    service 'cdn'
    service 'compute'
    service 'ec2'
    service 'elb'
    service 'iam'
    service 's3'
    service 'simpledb'
    service 'storage'

    def self.indexed_param(key, values)
      params = {}
      unless key.include?('%d')
        key << '.%d'
      end
      [*values].each_with_index do |value, index|
        params[format(key, index + 1)] = value
      end
      params
    end

    def self.indexed_filters(filters)
      params = {}
      filters.keys.each_with_index do |key, key_index|
        key_index += 1
        params[format('Filter.%d.Name', key_index)] = key
        [*filters[key]].each_with_index do |value, value_index|
          value_index += 1
          params[format('Filter.%d.Value.%d', key_index, value_index)] = value
        end
      end
      params
    end

    def self.signed_params(params, options = {})
      params.merge!({
        'AWSAccessKeyId'    => options[:aws_access_key_id],
        'SignatureMethod'   => 'HmacSHA256',
        'SignatureVersion'  => '2',
        'Timestamp'         => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
        'Version'           => options[:version]
      })

      body = ''
      for key in params.keys.sort
        unless (value = params[key]).nil?
          body << "#{key}=#{CGI.escape(value.to_s).gsub(/\+/, '%20')}&"
        end
      end
      string_to_sign = "POST\n#{options[:host]}\n#{options[:path]}\n" << body.chop
      signed_string = options[:hmac].sign(string_to_sign)
      body << "Signature=#{CGI.escape(Base64.encode64(signed_string).chomp!).gsub(/\+/, '%20')}"

      body
    end

    class Mock

      def self.availability_zone
        "us-east-1" << random_selection('abcd', 1)
      end

      def self.box_usage
        sprintf("%0.10f", rand / 100).to_f
      end

      def self.dns_name_for(ip_address)
        "ec2-#{ip_address.gsub('.','-')}.compute-1.amazonaws.com"
      end

      def self.private_dns_name_for(ip_address)
        "ip-#{ip_address.gsub('.','-')}.ec2.internal"
      end

      def self.etag
        hex(32)
      end

      def self.image
        path = []
        (rand(3) + 2).times do
          path << letters(rand(9) + 8)
        end
        {
          "imageOwnerId"   => letters(rand(5) + 4),
          "blockDeviceMapping" => [],
          "productCodes"   => [],
          "kernelId"       => kernel_id,
          "ramdiskId"      => ramdisk_id,
          "imageState"     => "available",
          "imageId"        => image_id,
          "architecture"   => "i386",
          "isPublic"       => true,
          "imageLocation"  => path.join('/'),
          "imageType"      => "machine",
          "rootDeviceType" => ["ebs","instance-store"][rand(2)],
          "rootDeviceName" => "/dev/sda1"
        }
      end

      def self.image_id
        "ami-#{hex(8)}"
      end

      def self.key_fingerprint
        fingerprint = []
        20.times do
          fingerprint << hex(2)
        end
        fingerprint.join(':')
      end

      def self.instance_id
        "i-#{hex(8)}"
      end

      def self.ip_address
        ip = []
        4.times do
          ip << numbers(rand(3) + 1).to_i.to_s # remove leading 0
        end
        ip.join('.')
      end

      def self.kernel_id
        "aki-#{hex(8)}"
      end

      def self.key_material
        key_material = ['-----BEGIN RSA PRIVATE KEY-----']
        20.times do
          key_material << base64(76)
        end
        key_material << base64(67) + '='
        key_material << '-----END RSA PRIVATE KEY-----'
        key_material.join("\n")
      end

      def self.owner_id
        numbers(12)
      end

      def self.ramdisk_id
        "ari-#{hex(8)}"
      end

      def self.request_id
        request_id = []
        request_id << hex(8)
        3.times do
          request_id << hex(4)
        end
        request_id << hex(12)
        request_id.join('-')
      end

      def self.reservation_id
        "r-#{hex(8)}"
      end

      def self.snapshot_id
        "snap-#{hex(8)}"
      end

      def self.volume_id
        "vol-#{hex(8)}"
      end

      private
      
      def self.random_selection(characters, length)
        selection = ''
        length.times do
          position = rand(characters.length)
          selection << characters[position..position]
        end
        selection
      end

      def self.letters(length)
        random_selection(
          'abcdefghijklmnopqrstuvwxyz',
          length
        )
      end

      def self.numbers(length)
        max = ('9' * length).to_i
        rand(max).to_s
      end

      def self.hex(length)
        max = ('f' * length).to_i(16)
        rand(max).to_s(16).rjust(length, '0')
      end

      def self.base64(length)
        random_selection(
          "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
          length
        )
      end

    end
  end
end
