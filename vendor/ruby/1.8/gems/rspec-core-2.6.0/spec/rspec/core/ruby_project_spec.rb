module RSpec
  module Core
    describe RubyProject do

      describe "#determine_root" do

        context "with ancestor containing spec directory" do
          it "returns ancestor containing the spec directory" do
            RubyProject.stub(:ascend_until).and_return('foodir')
            RubyProject.determine_root.should == 'foodir'
          end
        end

        context "without ancestor containing spec directory" do
          it "returns current working directory" do
            RubyProject.stub(:find_first_parent_containing).and_return(nil)
            RubyProject.determine_root.should == '.'
          end
        end

      end
    end
  end
end
