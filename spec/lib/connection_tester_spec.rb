
require "spec_helper"

describe ConnectionTester do
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
    before do
      @result = ConnectionTester::Result.new
      @dns = instance_double("Resolv::DNS")
      allow(@dns).to receive(:close).once
    end

    it "resolves the IP address" do
      tester = ConnectionTester.new("https://pod.example.com", @result)
      expect(tester).to receive(:with_dns_resolver).and_yield(@dns)
      expect(@dns).to receive(:getaddress).and_return("192.168.1.2")

      tester.resolve
      expect(@result.ip).to eq("192.168.1.2")
    end
  end

  describe "#request" do
    before do
      @url = "https://pod.example.com"
      @stub =
      @result = ConnectionTester::Result.new
      @tester = ConnectionTester.new(@url, @result)
    end

    it "performs a successful GET request on '/'" do
      stub_request(:get, @url).to_return(status: 200, body: "Hello World!")

      @tester.request
      expect(@result.rt).to be > -1
      expect(@result.reachable).to be_truthy
      expect(@result.ssl_status).to be_truthy
    end

    it "receives a 'normal' 301 redirect" do
      stub_request(:get, @url).to_return(status: 301, headers: {"Location" => "#{@url}/redirect"})
      stub_request(:get, "#{@url}/redirect").to_return(status: 200, body: "Hello World!")

      @tester.request
    end

    it "receives too many 301 redirects" do
      stub_request(:get, @url).to_return(status: 301, headers: {"Location" => "#{@url}/redirect"})
      stub_request(:get, "#{@url}/redirect").to_return(status: 301, headers: {"Location" => "#{@url}/redirect1"})
      stub_request(:get, "#{@url}/redirect1").to_return(status: 301, headers: {"Location" => "#{@url}/redirect2"})
      stub_request(:get, "#{@url}/redirect2").to_return(status: 301, headers: {"Location" => "#{@url}/redirect3"})
      stub_request(:get, "#{@url}/redirect3").to_return(status: 200, body: "Hello World!")

      expect { @tester.request }.to raise_error(ConnectionTester::HTTPFailure)
    end

    it "receives a 404 not found" do
      stub_request(:get, @url).to_return(status: 404, body: "Not Found!")
      expect { @tester.request }.to raise_error(ConnectionTester::HTTPFailure)
    end

    it "cannot connect" do
      stub_request(:get, @url).to_raise(Faraday::ConnectionFailed.new("Error!"))
      expect { @tester.request }.to raise_error(ConnectionTester::NetFailure)
    end

    it "encounters an invalid SSL setup" do
      stub_request(:get, @url).to_raise(Faraday::SSLError.new("Error!"))
      expect { @tester.request }.to raise_error(ConnectionTester::SSLFailure)
    end
  end

  describe "#nodeinfo" do
    before do
      @url = "https://diaspora.example.com"
      @result = ConnectionTester::Result.new
      @tester = ConnectionTester.new(@url, @result)

      @ni_wellknown = {links: [{rel:  ConnectionTester::NODEINFO_SCHEMA,
                                href: "/nodeinfo"}]}
      @ni_document = {software: {name: "diaspora", version: "a.b.c.d"}}
    end

    it "reads the version from the nodeinfo document" do
      stub_request(:get, "#{@url}#{ConnectionTester::NODEINFO_FRAGMENT}")
        .to_return(status: 200, body: JSON.generate(@ni_wellknown))
      stub_request(:get, "#{@url}/nodeinfo").to_return(status: 200, body: JSON.generate(@ni_document))

      @tester.nodeinfo
      expect(@result.software_version).to eq("diaspora a.b.c.d")
    end

    it "handles a missing nodeinfo document gracefully" do
      stub_request(:get, "#{@url}#{ConnectionTester::NODEINFO_FRAGMENT}")
        .to_return(status: 404, body: "Not Found")
      expect { @tester.nodeinfo }.to raise_error(ConnectionTester::NodeInfoFailure)
    end

    it "handles a malformed document gracefully" do
      stub_request(:get, "#{@url}#{ConnectionTester::NODEINFO_FRAGMENT}")
        .to_return(status: 200, body: '{"json"::::"malformed"}')
      expect { @tester.nodeinfo }.to raise_error(ConnectionTester::NodeInfoFailure)
    end
  end
end
