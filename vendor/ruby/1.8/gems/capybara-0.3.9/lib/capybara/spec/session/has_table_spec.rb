shared_examples_for "has_table" do  
  describe '#has_table?' do
    before do
      @session.visit('/tables')
    end

    it "should be true if the field is on the page" do
      @session.should have_table('Deaths')
      @session.should have_table('villain_table')
    end

    it "should be false if the field is not on the page" do
      @session.should_not have_table('Monkey')
    end

    context 'with rows' do
      it "should be true if a table with the given rows is on the page" do
        @session.should have_table('Ransom', :rows => [['2007', '$300', '$100']])
        @session.should have_table('Deaths', :rows => [['2007', '66', '7'], ['2008', '123', '12']])
      end

      it "should be true if the given rows are incomplete" do
        @session.should have_table('Ransom', :rows => [['$300', '$100']])
      end

      it "should be false if the given table is not on the page" do
        @session.should_not have_table('Does not exist', :selected => 'John')  
      end

      it "should be false if the given rows contain incorrect elements" do
        @session.should_not have_table('Ransom', :rows => [['2007', '$1000000000', '$100']])
      end

      it "should be false if the given rows are incorrectly ordered" do
        @session.should_not have_table('Ransom', :rows => [['2007', '$100', '$300']])
      end

      it "should be false if the only some of the given rows are correct" do
        @session.should_not have_table('Deaths', :rows => [['2007', '66', '7'], ['2007', '99999999', '12']])
      end

      it "should be false if the given rows are out of order" do
        @session.should_not have_table('Deaths', :rows => [['2007', '123', '12'], ['2007', '66', '7']])
      end
    end
  end

  describe '#has_no_table?' do
    before do
      @session.visit('/tables')
    end

    it "should be false if the field is on the page" do
      @session.should_not have_no_table('Deaths')
      @session.should_not have_no_table('villain_table')
    end

    it "should be true if the field is not on the page" do
      @session.should have_no_table('Monkey')
    end

    context 'with rows' do
      it "should be false if a table with the given rows is on the page" do
        @session.should_not have_no_table('Ransom', :rows => [['2007', '$300', '$100']])
        @session.should_not have_no_table('Deaths', :rows => [['2007', '66', '7'], ['2008', '123', '12']])
      end

      it "should be false if the given rows are incomplete" do
        @session.should_not have_no_table('Ransom', :rows => [['$300', '$100']])
      end

      it "should be true if the given table is not on the page" do
        @session.should have_no_table('Does not exist', :selected => 'John')  
      end

      it "should be true if the given rows contain incorrect elements" do
        @session.should have_no_table('Ransom', :rows => [['2007', '$1000000000', '$100']])
      end

      it "should be true if the given rows are incorrectly ordered" do
        @session.should have_no_table('Ransom', :rows => [['2007', '$100', '$300']])
      end

      it "should be true if the only some of the given rows are correct" do
        @session.should have_no_table('Deaths', :rows => [['2007', '66', '7'], ['2007', '99999999', '12']])
      end

      it "should be true if the given rows are out of order" do
        @session.should have_no_table('Deaths', :rows => [['2007', '123', '12'], ['2007', '66', '7']])
      end
    end
  end
end



