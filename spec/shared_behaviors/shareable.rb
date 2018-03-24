# frozen_string_literal: true

shared_examples_for "a shareable" do
  describe "#subscribed_pods_uris" do
    let(:pods) { Array.new(3) { FactoryGirl.create(:pod) } }
    let(:subscribers) {
      pods.map {|pod|
        FactoryGirl.create(:person, pod: pod)
      }
    }
    let(:pods_uris) {
      pods.map {|pod| pod.url_to("") }
    }

    it "builds pod list basing on subscribers" do
      expect(object).to receive(:subscribers).and_return(subscribers)
      expect(object.subscribed_pods_uris).to match_array(pods_uris)
    end
  end
end
