require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WebMock::Util::HashKeysStringifier do

  it "should recursively stringify all symbol keys" do
    hash = {
      :a => {
        :b => [
          {
            :c => [{:d => "1"}]
          }
        ]
      }
    }
    stringified = {
      'a' => {
        'b' => [
          {
            'c' => [{'d' => "1"}]
          }
        ]
      }
    }
    WebMock::Util::HashKeysStringifier.stringify_keys!(hash).should == stringified
  end

end
