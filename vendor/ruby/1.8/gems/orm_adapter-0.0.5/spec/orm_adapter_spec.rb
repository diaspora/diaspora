require 'spec_helper'

describe OrmAdapter do
  subject { OrmAdapter }
  
  describe "when a new adapter is created (by inheriting form OrmAdapter::Base)" do
    let!(:adapter) { Class.new(OrmAdapter::Base) }
    
    its(:adapters) { should include(adapter) }
    
    describe "and the adapter has a model class" do
      let(:model) { Class.new }
      
      before { adapter.stub!(:model_classes).and_return([model]) }
      
      its(:model_classes) { should include(model) }
    end
    
    after { OrmAdapter.adapters.delete(adapter) }
  end
end
