# frozen_string_literal: true

describe BasePresenter do
  it "falls back to nil" do
    p = BasePresenter.new(nil)
    expect(p.anything).to be(nil)
    expect { p.otherthing }.not_to raise_error
  end

  it "calls methods on the wrapped object" do
    obj = double(hello: "world")
    p = BasePresenter.new(obj)

    expect(p.hello).to eql("world")
    expect(obj).to have_received(:hello)
  end

  describe "#as_collection" do
    it "returns an array of data" do
      coll = [double(data: "one"), double(data: "two"), double(data: "three")]
      res = BasePresenter.as_collection(coll, :data)
      expect(res).to eql(["one", "two", "three"])
    end
  end
end
