require 'spec_helper'

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "<%= ns_table_name %>/edit.html.<%= options[:template_engine] %>" do
  before(:each) do
    @<%= ns_file_name %> = assign(:<%= ns_file_name %>, stub_model(<%= class_name %><%= output_attributes.empty? ? '))' : ',' %>
<% output_attributes.each_with_index do |attribute, attribute_index| -%>
      :<%= attribute.name %> => <%= attribute.default.inspect %><%= attribute_index == output_attributes.length - 1 ? '' : ','%>
<% end -%>
<%= output_attributes.empty? ? "" : "    ))\n" -%>
  end

  it "renders the edit <%= ns_file_name %> form" do
    render

<% if webrat? -%>
    rendered.should have_selector("form", :action => <%= ns_file_name %>_path(@<%= ns_file_name %>), :method => "post") do |form|
<% for attribute in output_attributes -%>
      form.should have_selector("<%= attribute.input_type -%>#<%= ns_file_name %>_<%= attribute.name %>", :name => "<%= ns_file_name %>[<%= attribute.name %>]")
<% end -%>
    end
<% else -%>
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => <%= index_helper %>_path(@<%= ns_file_name %>), :method => "post" do
<% for attribute in output_attributes -%>
      assert_select "<%= attribute.input_type -%>#<%= ns_file_name %>_<%= attribute.name %>", :name => "<%= ns_file_name %>[<%= attribute.name %>]"
<% end -%>
    end
<% end -%>
  end
end
