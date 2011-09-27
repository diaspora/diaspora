require 'spec_helper'

describe Base64 do
  describe ".urlsafe_encode64_stripped" do
    it "strips the trailing '=' from the url_safe characters" do
      pending
      Base64.should_receive(:urlsafe_encode64).and_return("MTIzMTIzMQ==")
      Base64.urlsafe_encode64_stripped("random stuff").should == "MTIzMTIzMQ"
    end
  end
end
