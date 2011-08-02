shared_examples_for "find_button" do  
  describe '#find_button' do
    before do
      @session.visit('/form')
    end

    it "should find any field" do
      @session.find_button('med')[:id].should == "mediocre"
      @session.find_button('crap321').value.should == "crappy"
    end

    it "should return nil if the field doesn't exist" do
      @session.find_button('Does not exist').should be_nil
    end
  end
end
