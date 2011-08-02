module Fog
  class Vcloud

    class Real
      unauthenticated_basic_request :get_versions
    end

    class Mock

      def get_versions(versions_uri)
        #
        # Based off of:
        # http://support.theenterprisecloud.com/kb/default.asp?id=535&Lang=1&SID=
        # https://community.vcloudexpress.terremark.com/en-us/product_docs/w/wiki/02-get-versions.aspx
        # vCloud API Guide v0.9 - Page 89
        #
        xml = Builder::XmlMarkup.new

        mock_it 200,
          xml.SupportedVersions( xmlns.merge("xmlns" => "http://www.vmware.com/vcloud/versions")) {

            mock_data.versions.select {|version| version.supported }.each do |version|
              xml.VersionInfo {
                xml.Version(version.version)
                xml.LoginUrl(version.login_url)
              }
            end
          }

      end

    end
  end
end
