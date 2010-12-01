require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../test_credentials.rb'

class TestS3Stubbed < Test::Unit::TestCase

  RIGHT_OBJECT_TEXT     = 'Right test message'
  
  def setup
      TestCredentials.get_credentials
    @s3     = Aws::S3Interface.new(TestCredentials.aws_access_key_id, TestCredentials.aws_secret_access_key)
    @bucket = 'right_s3_awesome_test_bucket'
    @key1   = 'test/woohoo1'
    @key2   = 'test1/key/woohoo2'
    @s      = Aws::S3.new(TestCredentials.aws_access_key_id, TestCredentials.aws_secret_access_key)
    Rightscale::HttpConnection.reset
  end

  # Non-remote tests: these use the stub version of Rightscale::HTTPConnection
  def test_101_create_bucket
    Rightscale::HttpConnection.push(409, 'The named bucket you tried to create already exists')
    Rightscale::HttpConnection.push(500, 'We encountered an internal error.  Please try again.')
    Rightscale::HttpConnection.push(500, 'We encountered an internal error.  Please try again.')
    assert_raise Aws::AwsError do
      @s3.create_bucket(@bucket)
    end
  end

  def test_102_list_all_my_buckets_failure
    Rightscale::HttpConnection.push(401, 'Unauthorized') 
    assert_raise Aws::AwsError do
      @s3.list_all_my_buckets
    end
  end

  def test_103_list_empty_bucket
    Rightscale::HttpConnection.push(403, 'Access Denied') 
    assert_raise Aws::AwsError do
      @s3.list_bucket(@bucket)
    end
  end
  
  def test_104_put
    Rightscale::HttpConnection.push(400, 'Your proposed upload exceeds the maximum allowed object size.') 
    Rightscale::HttpConnection.push(400, 'The Content-MD5 you specified was an invalid.') 
    Rightscale::HttpConnection.push(409, 'Please try again') 
    assert_raise Aws::AwsError do
      assert @s3.put(@bucket, @key1, RIGHT_OBJECT_TEXT, 'x-amz-meta-family'=>'Woohoo1!'), 'Put bucket fail'
    end
    assert_raise Aws::AwsError do
      assert @s3.put(@bucket, @key2, RIGHT_OBJECT_TEXT, 'x-amz-meta-family'=>'Woohoo2!'), 'Put bucket fail'
    end
  end
  
  def test_105_get_and_get_object
    Rightscale::HttpConnection.push(404, 'not found') 
    assert_raise(Rightscale::AwsError) { @s3.get(@bucket, 'undefined/key') }
  end
  
  def test_106_head
    Rightscale::HttpConnection.push(404, 'Good Luck!') 
    assert_raise Aws::AwsError do
      @s3.head(@bucket,@key1)
    end
  end


  def test_109_delete_bucket
    Rightscale::HttpConnection.push(403, 'Good Luck!') 
    assert_raise(Rightscale::AwsError) { @s3.delete_bucket(@bucket) }
  end
  
  def test_115_copy_key
    
    Rightscale::HttpConnection.push(500, 'not found') 
    #--- test COPY
    # copy a key
    assert_raise Aws::AwsError do
      @s3.copy(@bucket, @key1, @bucket, @key1_copy)
    end
    
  end

  def test_116_move_key
    # move a key
    Rightscale::HttpConnection.push(413, 'not found') 
    assert @s3.move(@bucket, @key1, @bucket, @key1_new_name)
    
  end

  def test_117_rename_key
    # rename a key
    Rightscale::HttpConnection.push(500, 'not found') 
    assert @s3.rename(@bucket, @key2, @key2_new_name)
    
  end

end
