require 'spec_helper'

describe "<%= class_name.pluralize %>" do
  describe "GET /<%= table_name %>" do
    it "works! (now write some real specs)" do
      get <%= table_name %>_path
    end
  end
end
