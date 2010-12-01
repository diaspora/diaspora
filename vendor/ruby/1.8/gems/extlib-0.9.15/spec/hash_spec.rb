require 'spec_helper'
require 'extlib/hash'

describe Hash, "environmentize_keys!" do
  it "should transform keys to uppercase text" do
    { :test_1  => 'test', 'test_2' => 'test', 1 => 'test' }.environmentize_keys!.should ==
      { 'TEST_1' => 'test', 'TEST_2' => 'test', '1' => 'test' }
  end

  it "should only transform one level of keys" do
    { :test_1  => { :test2 => 'test'} }.environmentize_keys!.should ==
      { 'TEST_1' => { :test2 => 'test'} }
  end
end


describe Hash, "only" do
  before do
    @hash = { :one => 'ONE', 'two' => 'TWO', 3 => 'THREE', 4 => nil }
  end

  it "should return a hash with only the given key(s)" do
    @hash.only(:not_in_there).should == {}
    @hash.only(4).should == {4 => nil}
    @hash.only(:one).should == { :one => 'ONE' }
    @hash.only(:one, 3).should == { :one => 'ONE', 3 => 'THREE' }
  end
end


describe Hash, "except" do
  before do
    @hash = { :one => 'ONE', 'two' => 'TWO', 3 => 'THREE' }
  end

  it "should return a hash without only the given key(s)" do
    @hash.except(:one).should == { 'two' => 'TWO', 3 => 'THREE' }
    @hash.except(:one, 3).should == { 'two' => 'TWO' }
  end
end


describe Hash, "to_xml_attributes" do
  before do
    @hash = { :one => "ONE", "two" => "TWO" }
  end

  it "should turn the hash into xml attributes" do
    attrs = @hash.to_xml_attributes
    attrs.should match(/one="ONE"/m)
    attrs.should match(/two="TWO"/m)
  end

  it 'should preserve _ in hash keys' do
    attrs = {
      :some_long_attribute => "with short value",
      :crash               => :burn,
      :merb                => "uses extlib"
    }.to_xml_attributes

    attrs.should =~ /some_long_attribute="with short value"/
    attrs.should =~ /merb="uses extlib"/
    attrs.should =~ /crash="burn"/
  end
end


describe Hash, "from_xml" do
  it "should transform a simple tag with content" do
    xml = "<tag>This is the contents</tag>"
    Hash.from_xml(xml).should == { 'tag' => 'This is the contents' }
  end

  it "should work with cdata tags" do
    xml = <<-END
      <tag>
      <![CDATA[
        text inside cdata
      ]]>
      </tag>
    END
    Hash.from_xml(xml)["tag"].strip.should == "text inside cdata"
  end

  it "should transform a simple tag with attributes" do
    xml = "<tag attr1='1' attr2='2'></tag>"
    hash = { 'tag' => { 'attr1' => '1', 'attr2' => '2' } }
    Hash.from_xml(xml).should == hash
  end

  it "should transform repeating siblings into an array" do
    xml =<<-XML
      <opt>
        <user login="grep" fullname="Gary R Epstein" />
        <user login="stty" fullname="Simon T Tyson" />
      </opt>
    XML

    Hash.from_xml(xml)['opt']['user'].should be_an_instance_of(Array)

    hash = {
      'opt' => {
        'user' => [{
          'login'    => 'grep',
          'fullname' => 'Gary R Epstein'
        },{
          'login'    => 'stty',
          'fullname' => 'Simon T Tyson'
        }]
      }
    }

    Hash.from_xml(xml).should == hash
  end

  it "should not transform non-repeating siblings into an array" do
    xml =<<-XML
      <opt>
        <user login="grep" fullname="Gary R Epstein" />
      </opt>
    XML

    Hash.from_xml(xml)['opt']['user'].should be_an_instance_of(Hash)

    hash = {
      'opt' => {
        'user' => {
          'login' => 'grep',
          'fullname' => 'Gary R Epstein'
        }
      }
    }

    Hash.from_xml(xml).should == hash
  end

  it "should typecast an integer" do
    xml = "<tag type='integer'>10</tag>"
    Hash.from_xml(xml)['tag'].should == 10
  end

  it "should typecast a true boolean" do
    xml = "<tag type='boolean'>true</tag>"
    Hash.from_xml(xml)['tag'].should be_true
  end

  it "should typecast a false boolean" do
    ["false"].each do |w|
      Hash.from_xml("<tag type='boolean'>#{w}</tag>")['tag'].should be_false
    end
  end

  it "should typecast a datetime" do
    xml = "<tag type='datetime'>2007-12-31 10:32</tag>"
    Hash.from_xml(xml)['tag'].should == Time.parse( '2007-12-31 10:32' ).utc
  end

  it "should typecast a date" do
    xml = "<tag type='date'>2007-12-31</tag>"
    Hash.from_xml(xml)['tag'].should == Date.parse('2007-12-31')
  end

  it "should unescape html entities" do
    values = {
      "<" => "&lt;",
      ">" => "&gt;",
      '"' => "&quot;",
      "'" => "&apos;",
      "&" => "&amp;"
    }
    values.each do |k,v|
      xml = "<tag>Some content #{v}</tag>"
      Hash.from_xml(xml)['tag'].should match(Regexp.new(k))
    end
  end

  it "should undasherize keys as tags" do
    xml = "<tag-1>Stuff</tag-1>"
    Hash.from_xml(xml).should have_key('tag_1')
  end

  it "should undasherize keys as attributes" do
    xml = "<tag1 attr-1='1'></tag1>"
    Hash.from_xml(xml)['tag1'].should have_key('attr_1')
  end

  it "should undasherize keys as tags and attributes" do
    xml = "<tag-1 attr-1='1'></tag-1>"
    Hash.from_xml(xml).should have_key('tag_1' )
    Hash.from_xml(xml)['tag_1'].should have_key('attr_1')
  end

  it "should render nested content correctly" do
    xml = "<root><tag1>Tag1 Content <em><strong>This is strong</strong></em></tag1></root>"
    Hash.from_xml(xml)['root']['tag1'].should == "Tag1 Content <em><strong>This is strong</strong></em>"
  end

  it "should render nested content with split text nodes correctly" do
    xml = "<root>Tag1 Content<em>Stuff</em> Hi There</root>"
    Hash.from_xml(xml)['root'].should == "Tag1 Content<em>Stuff</em> Hi There"
  end

  it "should ignore attributes when a child is a text node" do
    xml = "<root attr1='1'>Stuff</root>"
    Hash.from_xml(xml).should == { "root" => "Stuff" }
  end

  it "should ignore attributes when any child is a text node" do
    xml = "<root attr1='1'>Stuff <em>in italics</em></root>"
    Hash.from_xml(xml).should == { "root" => "Stuff <em>in italics</em>" }
  end

  it "should correctly transform multiple children" do
    xml = <<-XML
    <user gender='m'>
      <age type='integer'>35</age>
      <name>Home Simpson</name>
      <dob type='date'>1988-01-01</dob>
      <joined-at type='datetime'>2000-04-28 23:01</joined-at>
      <is-cool type='boolean'>true</is-cool>
    </user>
    XML

    hash =  {
      "user" => {
        "gender"    => "m",
        "age"       => 35,
        "name"      => "Home Simpson",
        "dob"       => Date.parse('1988-01-01'),
        "joined_at" => Time.parse("2000-04-28 23:01"),
        "is_cool"   => true
      }
    }

    Hash.from_xml(xml).should == hash
  end

  it "should properly handle nil values (ActiveSupport Compatible)" do
    topic_xml = <<-EOT
      <topic>
        <title></title>
        <id type="integer"></id>
        <approved type="boolean"></approved>
        <written-on type="date"></written-on>
        <viewed-at type="datetime"></viewed-at>
        <content type="yaml"></content>
        <parent-id></parent-id>
      </topic>
    EOT

    expected_topic_hash = {
      'title'      => nil,
      'id'         => nil,
      'approved'   => nil,
      'written_on' => nil,
      'viewed_at'  => nil,
      'content'    => nil,
      'parent_id'  => nil
    }
    Hash.from_xml(topic_xml)["topic"].should == expected_topic_hash
  end

  it "should handle a single record from xml (ActiveSupport Compatible)" do
    topic_xml = <<-EOT
      <topic>
        <title>The First Topic</title>
        <author-name>David</author-name>
        <id type="integer">1</id>
        <approved type="boolean"> true </approved>
        <replies-count type="integer">0</replies-count>
        <replies-close-in type="integer">2592000000</replies-close-in>
        <written-on type="date">2003-07-16</written-on>
        <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
        <content type="yaml">--- \n1: should be an integer\n:message: Have a nice day\narray: \n- should-have-dashes: true\n  should_have_underscores: true\n</content>
        <author-email-address>david@loudthinking.com</author-email-address>
        <parent-id></parent-id>
        <ad-revenue type="decimal">1.5</ad-revenue>
        <optimum-viewing-angle type="float">135</optimum-viewing-angle>
        <resident type="symbol">yes</resident>
      </topic>
    EOT

    expected_topic_hash = {
      'title' => "The First Topic",
      'author_name' => "David",
      'id' => 1,
      'approved' => true,
      'replies_count' => 0,
      'replies_close_in' => 2592000000,
      'written_on' => Date.new(2003, 7, 16),
      'viewed_at' => Time.utc(2003, 7, 16, 9, 28),
      # Changed this line where the key is :message.  The yaml specifies this as a symbol, and who am I to change what you specify
      # The line in ActiveSupport is
      # 'content' => { 'message' => "Have a nice day", 1 => "should be an integer", "array" => [{ "should-have-dashes" => true, "should_have_underscores" => true }] },
      'content' => { :message => "Have a nice day", 1 => "should be an integer", "array" => [{ "should-have-dashes" => true, "should_have_underscores" => true }] },
      'author_email_address' => "david@loudthinking.com",
      'parent_id' => nil,
      'ad_revenue' => BigDecimal("1.50"),
      'optimum_viewing_angle' => 135.0,
      'resident' => :yes
    }

    Hash.from_xml(topic_xml)["topic"].each do |k,v|
      v.should == expected_topic_hash[k]
    end
  end

  it "should handle multiple records (ActiveSupport Compatible)" do
    topics_xml = <<-EOT
      <topics type="array">
        <topic>
          <title>The First Topic</title>
          <author-name>David</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id nil="true"></parent-id>
        </topic>
        <topic>
          <title>The Second Topic</title>
          <author-name>Jason</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id></parent-id>
        </topic>
      </topics>
    EOT

    expected_topic_hash = {
      'title' => "The First Topic",
      'author_name' => "David",
      'id' => 1,
      'approved' => false,
      'replies_count' => 0,
      'replies_close_in' => 2592000000,
      'written_on' => Date.new(2003, 7, 16),
      'viewed_at' => Time.utc(2003, 7, 16, 9, 28),
      'content' => "Have a nice day",
      'author_email_address' => "david@loudthinking.com",
      'parent_id' => nil
    }
    # puts Hash.from_xml(topics_xml)['topics'].first.inspect
    Hash.from_xml(topics_xml)["topics"].first.each do |k,v|
      v.should == expected_topic_hash[k]
    end
  end

  it "should handle a single record from_xml with attributes other than type (ActiveSupport Compatible)" do
    topic_xml = <<-EOT
    <rsp stat="ok">
      <photos page="1" pages="1" perpage="100" total="16">
        <photo id="175756086" owner="55569174@N00" secret="0279bf37a1" server="76" title="Colored Pencil PhotoBooth Fun" ispublic="1" isfriend="0" isfamily="0"/>
      </photos>
    </rsp>
    EOT

    expected_topic_hash = {
      'id' => "175756086",
      'owner' => "55569174@N00",
      'secret' => "0279bf37a1",
      'server' => "76",
      'title' => "Colored Pencil PhotoBooth Fun",
      'ispublic' => "1",
      'isfriend' => "0",
      'isfamily' => "0",
    }
    Hash.from_xml(topic_xml)["rsp"]["photos"]["photo"].each do |k,v|
      v.should == expected_topic_hash[k]
    end
  end

  it "should handle an emtpy array (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <posts type="array"></posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    Hash.from_xml(blog_xml).should == expected_blog_hash
  end

  it "should handle empty array with whitespace from xml (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    Hash.from_xml(blog_xml).should == expected_blog_hash
  end

  it "should handle array with one entry from_xml (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post"]}}
    Hash.from_xml(blog_xml).should == expected_blog_hash
  end

  it "should handle array with multiple entries from xml (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
          <post>another post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post", "another post"]}}
    Hash.from_xml(blog_xml).should == expected_blog_hash
  end

  it "should handle file types (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <logo type="file" name="logo.png" content_type="image/png">
        </logo>
      </blog>
    XML
    hash = Hash.from_xml(blog_xml)
    hash.should have_key('blog')
    hash['blog'].should have_key('logo')

    file = hash['blog']['logo']
    file.original_filename.should == 'logo.png'
    file.content_type.should == 'image/png'
  end

  it "should handle file from xml with defaults (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <logo type="file">
        </logo>
      </blog>
    XML
    file = Hash.from_xml(blog_xml)['blog']['logo']
    file.original_filename.should == 'untitled'
    file.content_type.should == 'application/octet-stream'
  end

  it "should handle xsd like types from xml (ActiveSupport Compatible)" do
    bacon_xml = <<-EOT
    <bacon>
      <weight type="double">0.5</weight>
      <price type="decimal">12.50</price>
      <chunky type="boolean"> 1 </chunky>
      <expires-at type="dateTime">2007-12-25T12:34:56+0000</expires-at>
      <notes type="string"></notes>
      <illustration type="base64Binary">YmFiZS5wbmc=</illustration>
    </bacon>
    EOT

    expected_bacon_hash = {
      'weight' => 0.5,
      'chunky' => true,
      'price' => BigDecimal("12.50"),
      'expires_at' => Time.utc(2007,12,25,12,34,56),
      'notes' => "",
      'illustration' => "babe.png"
    }

    Hash.from_xml(bacon_xml)["bacon"].should == expected_bacon_hash
  end

  it "should let type trickle through when unknown (ActiveSupport Compatible)" do
    product_xml = <<-EOT
    <product>
      <weight type="double">0.5</weight>
      <image type="ProductImage"><filename>image.gif</filename></image>

    </product>
    EOT

    expected_product_hash = {
      'weight' => 0.5,
      'image' => {'type' => 'ProductImage', 'filename' => 'image.gif' },
    }

    Hash.from_xml(product_xml)["product"].should == expected_product_hash
  end

  it "should handle unescaping from xml (ActiveResource Compatible)" do
    xml_string = '<person><bare-string>First &amp; Last Name</bare-string><pre-escaped-string>First &amp;amp; Last Name</pre-escaped-string></person>'
    expected_hash = {
      'bare_string'        => 'First & Last Name',
      'pre_escaped_string' => 'First &amp; Last Name'
    }

    Hash.from_xml(xml_string)['person'].should == expected_hash
  end
end

describe Hash, 'to_params' do
  {
    { "foo" => "bar", "baz" => "bat" } => "foo=bar&baz=bat",
    { "foo" => [ "bar", "baz" ] } => "foo[]=bar&foo[]=baz",
    { "foo" => [ {"bar" => "1"}, {"bar" => 2} ] } => "foo[][bar]=1&foo[][bar]=2",
    { "foo" => { "bar" => [ {"baz" => 1}, {"baz" => "2"}  ] } } => "foo[bar][][baz]=1&foo[bar][][baz]=2",
    { "foo" => {"1" => "bar", "2" => "baz"} } => "foo[1]=bar&foo[2]=baz"
  }.each do |hash, params|
    it "should covert hash: #{hash.inspect} to params: #{params.inspect}" do
      hash.to_params.split('&').sort.should == params.split('&').sort
    end
  end

  it 'should not leave a trailing &' do
    { :name => 'Bob', :address => { :street => '111 Ruby Ave.', :city => 'Ruby Central', :phones => ['111-111-1111', '222-222-2222'] } }.to_params.should_not match(/&$/)
  end
end

describe Hash, 'to_mash' do
  before :each do
    @hash = Hash.new(10)
  end

  it "copies default Hash value to Mash" do
    @mash = @hash.to_mash
    @mash[:merb].should == 10
  end
end
