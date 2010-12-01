require "spec_helper"

describe <%= class_name %> do
<% for action in actions -%>
  describe "<%= action %>" do
    let(:mail) { <%= class_name %>.<%= action %> }

    it "renders the headers" do
      mail.subject.should eq(<%= action.to_s.humanize.inspect %>)
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

<% end -%>
<% if actions.blank? -%>
  pending "add some examples to (or delete) #{__FILE__}"
<% end -%>
end
