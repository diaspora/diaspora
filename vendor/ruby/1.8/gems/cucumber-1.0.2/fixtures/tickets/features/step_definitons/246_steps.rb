Given /^no ([a-z]+(?: [a-z]+)*) exists in the system$/ do |resource|
  resource.should == "public holiday"
end