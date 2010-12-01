require File.expand_path( File.join( File.dirname( __FILE__ ), "spec_helper.rb" ) ) 

require 'launchy/paths'

describe Launchy::Paths do
  it "can access the root dir of the project" do
    Launchy::Paths.root_dir.should == File.expand_path( File.join( File.dirname( __FILE__ ), ".." ) ) + ::File::SEPARATOR
  end

  %w[ lib ].each do |sub|
    it "can access the #{sub} path of the project" do
      Launchy::Paths.send("#{sub}_path" ).should == File.expand_path( File.join( File.dirname( __FILE__ ), "..", sub ) ) + ::File::SEPARATOR
    end
  end
end
