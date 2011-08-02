module Fog
  class Vcloud

    class Real


      def login
        unauthenticated_request({
          :expects  => 200,
          :headers  => {
            'Authorization' => authorization_header
          },
          :method   => 'POST',
          :parse    => true,
          :uri      => login_uri
        })
      end

    end

    class Mock

      def login
        #
        # Based off of:
        # http://support.theenterprisecloud.com/kb/default.asp?id=536&Lang=1&SID=
        # https://community.vcloudexpress.terremark.com/en-us/product_docs/w/wiki/01-get-login-token.aspx
        # vCloud API Guide v0.9 - Page 17
        #
        xml = Builder::XmlMarkup.new

        mock_it 200,
          xml.OrgList(xmlns) {
              mock_data.organizations.each do |organization|
                xml.Org( :type => "application/vnd.vmware.vcloud.org+xml", :href => organization.href, :name => organization.name )
              end
            },
            { 'Set-Cookie' => 'vcloud-token=fc020a05-21d7-4f33-9b2a-25d8cd05a44e; path=/',
              'Content-Type' => 'application/vnd.vmware.vcloud.orgslist+xml' }

      end

    end
  end
end

