require File.expand_path('spec_helper', File.dirname(__FILE__))

module Capybara

  describe Searchable do
    class Klass
      include Searchable    

      def all_unfiltered(locator, options = {})
        []
      end  

    end
  
    describe "#all" do
      before do
        @searchable = Klass.new 
      end

      it "should return unfiltered list without options" do
        node1 = stub(Node)
        node2 = stub(Node)
        @searchable.should_receive(:all_unfiltered).with('//x').and_return([node1, node2])
        @searchable.all('//x').should == [node1, node2]
      end
      
      context "with :text filter" do
        before do
          @node1 = stub(Node, :text => 'node one text (with parens)')
          @node2 = stub(Node, :text => 'node two text [-]')
          @searchable.stub(:all_unfiltered).and_return([@node1, @node2])
        end
        
        it "should accept regular expression" do
          @searchable.all('//x', :text => /node one/).should == [@node1]
          @searchable.all('//x', :text => /node two/).should == [@node2]
        end
        
        it "should accept text" do
          @searchable.all('//x', :text => "node one").should == [@node1]
          @searchable.all('//x', :text => "node two").should == [@node2]
        end   

        it "should allow Regexp reserved words in text" do
          @searchable.all('//x', :text => "node one text (with parens)").should == [@node1]
          @searchable.all('//x', :text => "node two text [-]").should == [@node2]
        end
      end
      
      context "with :visible filter" do
        before do
          @visible_node = stub(Node, :visible? => true)
          @hidden_node = stub(Node, :visible? => false)     
          @searchable.stub(:all_unfiltered).and_return([@visible_node, @hidden_node])
        end
        
        it "should filter out hidden nodes" do
          @searchable.all('//x', :visible => true).should == [@visible_node]
        end
      
      end

    end #all
  end

end
