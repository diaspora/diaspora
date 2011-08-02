require 'spec_helper'

describe "<%= class_name.pluralize %>" do
  describe "GET /<%= table_name %>" do
    it "works! (now write some real specs)" do
<% if webrat? -%>
      visit <%= index_helper %>_path
<% else -%>
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get <%= index_helper %>_path
<% end -%>
      response.status.should be(200)
    end
  end
end
