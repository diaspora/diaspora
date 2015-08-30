require "spec_helper"

describe Pod, type: :model do
  describe "::find_or_create_by" do
    it "takes a url, and makes one by host" do
      pod = Pod.find_or_create_by(url: "https://joindiaspora.com/maxwell")
      expect(pod.host).to eq("joindiaspora.com")
    end

    it "sets ssl boolean (side-effect)" do
      pod = Pod.find_or_create_by(url: "https://joindiaspora.com/maxwell")
      expect(pod.ssl).to be true
    end
  end

  describe "::check_all!" do
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
end
