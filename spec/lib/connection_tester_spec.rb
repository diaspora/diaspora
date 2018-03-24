# frozen_string_literal: true

describe ConnectionTester do
  let(:url) { "https://pod.example.com" }
  let(:result) { ConnectionTester::Result.new }
  let(:tester) { ConnectionTester.new(url, result) }

  describe "::check" do
    it "takes a http url and returns a result object" do
      res = ConnectionTester.check("https://pod.example.com")
      expect(res).to be_a(ConnectionTester::Result)
    end

    it "still returns a result object, even for invalid urls" do
      res = ConnectionTester.check("i:am/not)a+url")
      expect(res).to be_a(ConnectionTester::Result)
      expect(res.error).to be_a(ConnectionTester::Failure)
    end
  end

  describe "#initialize" do
    it "accepts the http protocol" do
      expect {
        ConnectionTester.new("https://pod.example.com")
      }.not_to raise_error
    end
    it "rejects unexpected protocols" do
      expect {
        ConnectionTester.new("xmpp:user@example.com")
      }.to raise_error(ConnectionTester::AddressFailure)
    end
  end

  describe "#resolve" do
    it "resolves the IP address" do
      expect(IPSocket).to receive(:getaddress).with("pod.example.com").and_return("192.168.1.2")

      tester.resolve
      expect(result.ip).to eq("192.168.1.2")
    end

    it "raises DNSFailure if host is unknown" do
      expect(IPSocket).to receive(:getaddress).with("pod.example.com").and_raise(SocketError.new("Error!"))

      expect { tester.resolve }.to raise_error(ConnectionTester::DNSFailure, "'pod.example.com' - Error!")
    end
  end

  describe "#request" do
    it "performs a successful GET request on '/' and '/.well-known/host-meta'" do
      stub_request(:get, url).to_return(status: 200, body: "Hello World!")
      stub_request(:get, "#{url}/.well-known/host-meta").to_return(status: 200, body: "host-meta")

      tester.request
      expect(result.rt).to be > -1
      expect(result.reachable).to be_truthy
      expect(result.ssl).to be_truthy
    end

    it "receives a 'normal' 301 redirect" do
      stub_request(:get, url).to_return(status: 301, headers: {"Location" => "#{url}/redirect"})
      stub_request(:get, "#{url}/redirect").to_return(status: 200, body: "Hello World!")
      stub_request(:get, "#{url}/.well-known/host-meta").to_return(status: 200, body: "host-meta")

      tester.request
    end

    it "updates ssl after https redirect" do
      tester = ConnectionTester.new("http://pod.example.com/", result)
      stub_request(:get, "http://pod.example.com/").to_return(status: 200, body: "Hello World!")
      stub_request(:get, "http://pod.example.com/.well-known/host-meta")
        .to_return(status: 301, headers: {"Location" => "#{url}/.well-known/host-meta"})
      stub_request(:get, "#{url}/.well-known/host-meta").to_return(status: 200, body: "host-meta")

      tester.request
      expect(result.ssl).to be_truthy
    end

    it "rejects other hostname after redirect redirect" do
      stub_request(:get, url).to_return(status: 200, body: "Hello World!")
      stub_request(:get, "#{url}/.well-known/host-meta")
        .to_return(status: 301, headers: {"Location" => "https://example.com/.well-known/host-meta"})
      stub_request(:get, "https://example.com/.well-known/host-meta").to_return(status: 200, body: "host-meta")

      expect { tester.request }.to raise_error(ConnectionTester::HTTPFailure)
    end

    it "receives too many 301 redirects" do
      stub_request(:get, url).to_return(status: 301, headers: {"Location" => "#{url}/redirect"})
      stub_request(:get, "#{url}/redirect").to_return(status: 301, headers: {"Location" => "#{url}/redirect1"})
      stub_request(:get, "#{url}/redirect1").to_return(status: 301, headers: {"Location" => "#{url}/redirect2"})
      stub_request(:get, "#{url}/redirect2").to_return(status: 301, headers: {"Location" => "#{url}/redirect3"})
      stub_request(:get, "#{url}/redirect3").to_return(status: 200, body: "Hello World!")

      expect { tester.request }.to raise_error(ConnectionTester::HTTPFailure)
    end

    it "receives a 404 not found" do
      stub_request(:get, url).to_return(status: 404, body: "Not Found!")
      expect { tester.request }.to raise_error(ConnectionTester::HTTPFailure)
    end

    it "cannot connect" do
      stub_request(:get, url).to_raise(Faraday::ConnectionFailed.new("Error!"))
      expect { tester.request }.to raise_error(ConnectionTester::NetFailure)
    end

    it "encounters an invalid SSL setup" do
      stub_request(:get, url).to_raise(Faraday::SSLError.new("Error!"))
      expect { tester.request }.to raise_error(ConnectionTester::SSLFailure)
    end
  end

  describe "#nodeinfo" do
    let(:ni_wellknown) { {links: [{rel: ConnectionTester::NODEINFO_SCHEMA, href: "/nodeinfo"}]} }

    it "reads the version from the nodeinfo document" do
      ni_document = NodeInfo.build do |doc|
        doc.version = "1.0"
        doc.open_registrations = true
        doc.protocols.protocols << "diaspora"
        doc.software.name = "diaspora"
        doc.software.version = "a.b.c.d"
      end

      stub_request(:get, "#{url}#{ConnectionTester::NODEINFO_FRAGMENT}")
        .to_return(status: 200, body: JSON.generate(ni_wellknown))
      stub_request(:get, "#{url}/nodeinfo").to_return(status: 200, body: JSON.generate(ni_document.as_json))

      tester.nodeinfo
      expect(result.software_version).to eq("diaspora a.b.c.d")
    end

    it "handles a missing nodeinfo document gracefully" do
      stub_request(:get, "#{url}#{ConnectionTester::NODEINFO_FRAGMENT}")
        .to_return(status: 404, body: "Not Found")
      expect { tester.nodeinfo }.to raise_error(ConnectionTester::NodeInfoFailure)
    end

    it "handles a malformed document gracefully" do
      stub_request(:get, "#{url}#{ConnectionTester::NODEINFO_FRAGMENT}")
        .to_return(status: 200, body: '{"json"::::"malformed"}')
      expect { tester.nodeinfo }.to raise_error(ConnectionTester::NodeInfoFailure)
    end

    it "handles a invalid jrd document gracefully" do
      invalid_wellknown = {links: {rel: ConnectionTester::NODEINFO_SCHEMA, href: "/nodeinfo"}}
      stub_request(:get, "#{url}#{ConnectionTester::NODEINFO_FRAGMENT}")
        .to_return(status: 200, body: JSON.generate(invalid_wellknown))
      expect { tester.nodeinfo }.to raise_error(ConnectionTester::NodeInfoFailure)
    end

    it "handles a invalid nodeinfo document gracefully" do
      stub_request(:get, "#{url}#{ConnectionTester::NODEINFO_FRAGMENT}")
        .to_return(status: 200, body: JSON.generate(ni_wellknown))
      stub_request(:get, "#{url}/nodeinfo").to_return(status: 200, body: '{"software": "invalid nodeinfo"}')
      expect { tester.nodeinfo }.to raise_error(ConnectionTester::NodeInfoFailure)
    end
  end
end
