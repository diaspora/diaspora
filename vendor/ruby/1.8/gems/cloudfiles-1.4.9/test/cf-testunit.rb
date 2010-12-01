#!/usr/bin/env ruby
#
# Major's live tests that go against the real Cloud Files system.  Requires a valid username and API key to function.

require File.dirname(__FILE__) + '/../lib/cloudfiles'

username = "YOUR_USERNAME"
apikey = "YOUR_API_KEY"

def assert_test(testtext,bool)
  booltext = (bool)? " PASS" : "*FAIL*" ;
  (testtext+"... ").ljust(50)+booltext
end

filename = File.dirname(__FILE__) + '/../lib/cloudfiles.rb'

# Test initial connection
cf = CloudFiles::Connection.new(username,apikey)
puts assert_test("Connecting to CloudFiles",cf.class == CloudFiles::Connection)

# Test container creation
testingcontainer = "RubyCFTest"
cntnr = cf.create_container(testingcontainer)
puts assert_test("Creating test container",cntnr.class == CloudFiles::Container)

# Checking container size
bytes = cntnr.bytes
puts assert_test("  Checking container size",bytes == 0)

# Checking container count
count = cntnr.count
puts assert_test("  Checking container count",count == 0)

# Add a file to the container - standard method
cloudfilesfilesize = File.read(filename).length
cloudfilesmd5 = Digest::MD5.hexdigest(File.read(filename))
headers = { "ETag" => cloudfilesmd5, "Content-Type" => "text/ruby", "X-Object-Meta-Testmeta" => "value" }
myobj = cntnr.create_object("cloudfiles-standard.rb")
myobj.write(File.read(filename), headers)
puts assert_test("    Uploading object (read into memory)",myobj.class == CloudFiles::StorageObject)
cntnr.refresh

# Check if object exists
bool = cntnr.object_exists?("cloudfiles-standard.rb")
puts assert_test("    Checking for object existence",bool)

# Checking container size
bytes = cntnr.bytes
puts assert_test("  Checking container size with #{bytes} vs #{cloudfilesfilesize}",bytes == cloudfilesfilesize)

# Checking container count
count = cntnr.count
puts assert_test("  Checking container count",count == 1)

# Add a file to the container - stream method
headers = { "ETag" => cloudfilesmd5, "Content-Type" => "text/ruby", "X-Object-Meta-Testmeta" => "value" }
f = IO.read(filename)
myobj = cntnr.create_object("cloudfiles-stream.rb")
myobj.write(File.read(filename), headers)
puts assert_test("    Uploading object (read from stream)",myobj.class == CloudFiles::StorageObject)
cntnr.refresh

# Check if object exists
bool = cntnr.object_exists?("cloudfiles-stream.rb")
puts assert_test("    Checking for object existence",bool)

# Checking container size
bytes = cntnr.bytes
puts assert_test("  Checking container size",bytes == (cloudfilesfilesize*2))

# Checking container count
count = cntnr.count
puts assert_test("  Checking container count",count == 2)

# Check file size
bytes = myobj.bytes.to_i
puts assert_test("    Checking object size",bytes == cloudfilesfilesize)

# Check content type
content_type = myobj.content_type
puts assert_test("    Checking object content type",content_type == "text/ruby")

# Check metadata
metadata = myobj.metadata
puts assert_test("    Checking object metadata",metadata["testmeta"] == "value")

# Set new metadata
bool = myobj.set_metadata({ "testmeta2" => "differentvalue"})
puts assert_test("    Setting new object metadata",bool)

# Check new metadata
myobj.refresh
metadata = myobj.metadata
puts assert_test("    Checking new object metadata",metadata["testmeta2"] == "differentvalue")

# Get data via standard method
data = myobj.data
puts assert_test("    Retrieving object data (read into memory)",Digest::MD5.hexdigest(data) == cloudfilesmd5)

# Get data via stream
data = ""
myobj.data_stream { |chunk|
  data += chunk.to_s
}
puts assert_test("    Retrieving object data (read from stream)",Digest::MD5.hexdigest(data) == cloudfilesmd5)

# Check md5sum
etag = myobj.etag
puts assert_test("    Checking object's md5sum",etag == cloudfilesmd5)

# Make container public
bool = cntnr.make_public
puts assert_test("  Making container public",bool)

# Verify that container is public
bool = cntnr.public?
puts assert_test("  Verifying container is public",bool)

# Getting CDN URL
cdnurl = cntnr.cdn_url
puts assert_test("  Getting CDN URL",cdnurl)

# Setting CDN URL
bool = cntnr.make_public(:ttl => 7200)
puts assert_test("  Setting CDN TTL",bool)

# Make container private
bool = cntnr.make_private
puts assert_test("  Making container private",bool)

# Check if container is empty
bool = cntnr.empty?
puts assert_test("  Checking if container empty",bool == false)

# Remove standard object
bool = cntnr.delete_object("cloudfiles-standard.rb")
puts assert_test("    Deleting first object",bool)

# Remove stream object
bool = cntnr.delete_object("cloudfiles-stream.rb")
puts assert_test("    Deleting second object",bool)
cntnr.refresh

# Check if container is empty
bool = cntnr.empty?
puts assert_test("  Checking if container empty",bool)

# Remove testing container
bool = cf.delete_container(testingcontainer)
puts assert_test("Removing container",bool)

# Check to see if container exists
bool = cf.container_exists?(testingcontainer)
puts assert_test("Checking container existence",bool == false)



