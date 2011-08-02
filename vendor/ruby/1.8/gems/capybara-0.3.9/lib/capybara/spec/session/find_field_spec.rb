shared_examples_for "find_field" do  
  describe '#find_field' do
    before do
      @session.visit('/form')
    end

    it "should find any field" do
      @session.find_field('Dog').value.should == 'dog'
      @session.find_field('form_description').text.should == 'Descriptive text goes here'
      @session.find_field('Region')[:name].should == 'form[region]'
    end

    it "should be nil if the field doesn't exist" do
      @session.find_field('Does not exist').should be_nil
    end

    it "should be aliased as 'field_labeled' for webrat compatibility" do
      @session.field_labeled('Dog').value.should == 'dog'
      @session.field_labeled('Does not exist').should be_nil
    end
  end
end
