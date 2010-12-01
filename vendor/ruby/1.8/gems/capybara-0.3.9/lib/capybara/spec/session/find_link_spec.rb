shared_examples_for "find_link" do

  describe '#find_link' do
    before do
      @session.visit('/with_html')
    end

    it "should find any field" do
      @session.find_link('foo').text.should == "ullamco"
      @session.find_link('labore')[:href].should == "/with_simple_html"
    end

    it "should return nil if the field doesn't exist" do
      @session.find_link('Does not exist').should be_nil
    end
  end
end
