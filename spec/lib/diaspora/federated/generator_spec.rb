require "spec_helper"

describe "adds root author on reshare" do
  before do
    @generator = Federated::Generator.new(double("user", id: 1), double)
    @root_author = double("root_author")
    root = double("root", author: @root_author)
    parent = double("parent", root: root)
    @relayable = double("relayable", parent: parent, class: "foo", guid: "123")
  end

  it "adds root to additional subscribers" do
    @generator.add_root_author(@relayable)
    additional_subscribers = @generator.instance_variable_get(:@dispatcher_opts)[:additional_subscribers]
    expect(additional_subscribers).to include(@root_author)
  end

  it "calls add_root_author" do
    allow(Postzord::Dispatcher).to receive(:defer_build_and_post).and_return(true)
    allow(@generator).to receive(:build).and_return(@relayable)
    allow(@relayable).to receive(:save!).and_return(true)
    expect(@generator).to receive(:add_root_author)
    @generator.create!
  end
end
