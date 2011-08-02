require 'spec_helper'

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "<%= ns_table_name %>/new.html.<%= options[:template_engine] %>" do
  before(:each) do
    assign(:<%= ns_file_name %>, stub_model(<%= class_name %><%= output_attributes.empty? ? ').as_new_record)' : ',' %>
<% output_attributes.each_with_index do |attribute, attribute_index| -%>
      :<%= attribute.name %> => <%= attribute.default.inspect %><%= attribute_index == output_attributes.length - 1 ? '' : ','%>
<% end -%>
<%= !output_attributes.empty? ? "    ).as_new_record)\n  end" : "  end" %>

  it "renders new <%= ns_file_name %> form" do
    render

<% if webrat? -%>
    rendered.should have_selector("form", :action => <%= table_name %>_path, :method => "post") do |form|
<% for attribute in output_attributes -%>
      form.should have_selector("<%= attribute.input_type -%>#<%= ns_file_name %>_<%= attribute.name %>", :name => "<%= ns_file_name %>[<%= attribute.name %>]")
<% end -%>
    end
<% else -%>
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => <%= index_helper %>_path, :method => "post" do
<% for attribute in output_attributes -%>
      assert_select "<%= attribute.input_type -%>#<%= ns_file_name %>_<%= attribute.name %>", :name => "<%= ns_file_name %>[<%= attribute.name %>]"
<% end -%>
    end
<% end -%>
  end
end
