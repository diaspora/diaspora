require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'

describe YARD::CLI::Stats do
  before do
    Registry.clear
    YARD.parse_string <<-eof
      class A
        CONST = 1
        
        def foo; end
        
        # Documented
        def bar; end
      end
      module B; end
    eof
    
    @main_stats = 
      "Files:           1\n" +
      "Modules:         1 (    1 undocumented)\n" +
      "Classes:         1 (    1 undocumented)\n" +
      "Constants:       1 (    1 undocumented)\n" +
      "Methods:         2 (    1 undocumented)\n" +
      " 20.00% documented\n"
    
    @output = StringIO.new
    @stats = CLI::Stats.new(false)
    @stats.stub!(:support_rdoc_document_file!).and_return([])
    @stats.stub!(:yardopts).and_return([])
    @stats.stub!(:puts) {|*args| @output << args.join("\n") << "\n" }
  end
  
  it "should list undocumented objects with --list-undoc" do
    @stats.run('--list-undoc')
    @output.string.should == <<-eof
#{@main_stats}
Undocumented Objects:

(in file: (stdin))
B
A
A::CONST
A#foo
eof
  end
  
  it "should list no undocumented objects with --list-undoc when objects are undocumented" do
    Registry.clear
    YARD.parse_string <<-eof
      # documentation
      def foo; end
    eof
    @stats.run('--list-undoc')
    @output.string.should ==  "Files:           1\n" +
                              "Modules:         0 (    0 undocumented)\n" +
                              "Classes:         0 (    0 undocumented)\n" +
                              "Constants:       0 (    0 undocumented)\n" +
                              "Methods:         1 (    0 undocumented)\n" +
                              " 100.00% documented\n"
  end
  
  it "should list undocumented objects in compact mode with --list-undoc --compact" do
    @stats.run('--list-undoc', '--compact')
    @output.string.should == <<-eof
#{@main_stats}
Undocumented Objects:
B            ((stdin))
A            ((stdin))
A::CONST     ((stdin))
A#foo        ((stdin))
eof
  end
  
  it "should still list stats with --quiet" do
    @stats.run('--quiet')
    @output.string.should == @main_stats
  end
  
  it "should not include public methods in stats with --no-public" do
    @stats.run('--no-public')
    @output.string.should == 
      "Files:           1\n" +
      "Modules:         1 (    1 undocumented)\n" +
      "Classes:         1 (    1 undocumented)\n" +
      "Constants:       1 (    1 undocumented)\n" +
      "Methods:         0 (    0 undocumented)\n" +
      " 0.00% documented\n"
  end
end