require "spec_helper"

describe Pod, type: :model do
  describe ".find_or_create_by" do
    it "takes a url, and makes one by host" do
      pod = Pod.find_or_create_by(url: "https://example.org/u/maxwell")
      expect(pod.host).to eq("example.org")
    end

    it "saves the port" do
      pod = Pod.find_or_create_by(url: "https://example.org:3000/")
      expect(pod.host).to eq("example.org")
      expect(pod.port).to eq(3000)
    end

    it "ignores default ports" do
      pod = Pod.find_or_create_by(url: "https://example.org:443/")
      expect(pod.host).to eq("example.org")
      expect(pod.port).to be_nil
    end

    it "sets ssl boolean" do
      pod = Pod.find_or_create_by(url: "https://example.org/")
      expect(pod.ssl).to be true
    end

    it "updates ssl boolean if upgraded to https" do
      pod = Pod.find_or_create_by(url: "http://example.org/")
      expect(pod.ssl).to be false
      pod = Pod.find_or_create_by(url: "https://example.org/")
      expect(pod.ssl).to be true
    end

    it "does not update ssl boolean if downgraded to http" do
      pod = Pod.find_or_create_by(url: "https://example.org/")
      expect(pod.ssl).to be true
      pod = Pod.find_or_create_by(url: "http://example.org/")
      expect(pod.ssl).to be true
    end

    context "validation" do
      it "is valid" do
        pod = Pod.find_or_create_by(url: "https://example.org/")
        expect(pod).to be_valid
      end

      it "doesn't allow own pod" do
        pod = Pod.find_or_create_by(url: AppConfig.url_to("/"))
        expect(pod).not_to be_valid
      end

      it "doesn't allow own pod with default port" do
        uri = URI.parse("https://example.org/")
        allow(AppConfig).to receive(:pod_uri).and_return(uri)

        pod = Pod.find_or_create_by(url: AppConfig.url_to("/"))
        expect(pod).not_to be_valid
      end

      it "doesn't allow own pod with other scheme" do
        uri = URI.parse("https://example.org/")
        allow(AppConfig).to receive(:pod_uri).and_return(uri)

        pod = Pod.find_or_create_by(url: "http://example.org/")
        expect(pod).not_to be_valid
      end
    end
  end

  describe ".check_all!" do
    before do
      @pods = (0..4).map do
        double("pod").tap do |pod|
          expect(pod).to receive(:test_connection!)
        end
      end
      allow(Pod).to receive(:find_in_batches).and_yield(@pods)
    end

    it "calls #test_connection! on every pod" do
      Pod.check_all!
    end
  end

  describe "#test_connection!" do
    before do
      @pod = FactoryGirl.create(:pod)
      @result = double("result")

      allow(@result).to receive(:rt) { 123 }
      allow(@result).to receive(:software_version) { "diaspora a.b.c.d" }
      allow(@result).to receive(:failure_message) { "hello error!" }

      expect(ConnectionTester).to receive(:check).at_least(:once).and_return(@result)
    end

    it "updates the connectivity values" do
      allow(@result).to receive(:error)
      allow(@result).to receive(:error?)
      @pod.test_connection!

      expect(@pod.status).to eq("no_errors")
      expect(@pod.offline?).to be_falsy
      expect(@pod.response_time).to eq(123)
      expect(@pod.checked_at).to be_within(1.second).of Time.zone.now
    end

    it "handles a failed check" do
      expect(@result).to receive(:error?).at_least(:once) { true }
      expect(@result).to receive(:error).at_least(:once) { ConnectionTester::NetFailure.new }
      @pod.test_connection!

      expect(@pod.offline?).to be_truthy
      expect(@pod.offline_since).to be_within(1.second).of Time.zone.now
    end

    it "preserves the original offline timestamp" do
      expect(@result).to receive(:error?).at_least(:once) { true }
      expect(@result).to receive(:error).at_least(:once) { ConnectionTester::NetFailure.new }
      @pod.test_connection!

      now = Time.zone.now
      expect(@pod.offline_since).to be_within(1.second).of now

      Timecop.travel(Time.zone.today + 30.days) do
        @pod.test_connection!
        expect(@pod.offline_since).to be_within(1.second).of now
        expect(Time.zone.now).to be_within(1.day).of(now + 30.days)
      end
    end
  end

  describe "#url_to" do
    it "appends the path to the pod-url" do
      pod = FactoryGirl.create(:pod)
      expect(pod.url_to("/receive/public")).to eq("https://#{pod.host}/receive/public")
    end
  end
end
