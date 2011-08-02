require File.expand_path('../../../oauth_case', __FILE__)

# See http://oauth.net/core/1.0/#anchor14
#
# 9.1.1.  Normalize Request Parameters
#
# The request parameters are collected, sorted and concatenated into a normalized string:
#
# Parameters in the OAuth HTTP Authorization header excluding the realm parameter.
# Parameters in the HTTP POST request body (with a content-type of application/x-www-form-urlencoded).
# HTTP GET parameters added to the URLs in the query part (as defined by [RFC3986] section 3).
# The oauth_signature parameter MUST be excluded.
#
# The parameters are normalized into a single string as follows:
#
# Parameters are sorted by name, using lexicographical byte value ordering.
# If two or more parameters share the same name, they are sorted by their value. For example:
#
#   a=1, c=hi%20there, f=25, f=50, f=a, z=p, z=t
# Parameters are concatenated in their sorted order into a single string. For each parameter,
# the name is separated from the corresponding value by an ‘=’ character (ASCII code 61), even
# if the value is empty. Each name-value pair is separated by an ‘&’ character (ASCII code 38). For example:
#   a=1&c=hi%20there&f=25&f=50&f=a&z=p&z=t
#


class NormalizeRequestParametersTest < OAuthCase

  def test_parameters_for_signature
    params={'a'=>1, 'c'=>'hi there', 'f'=>'25', 'f'=>'50', 'f'=>'a', 'z'=>'p', 'z'=>'t'}
    assert_equal params,request(params).parameters_for_signature
  end


  def test_parameters_for_signature_removes_oauth_signature
    params={'a'=>1, 'c'=>'hi there', 'f'=>'25', 'f'=>'50', 'f'=>'a', 'z'=>'p', 'z'=>'t'}
    assert_equal params,request(params.merge({'oauth_signature'=>'blalbla'})).parameters_for_signature
  end

  def test_spec_example
    assert_normalized 'a=1&c=hi%20there&f=25&f=50&f=a&z=p&z=t', { 'a' => 1, 'c' => 'hi there', 'f' => ['25', '50', 'a'], 'z' => ['p', 't'] }
  end

  def test_sorts_parameters_correctly
    # values for 'f' are scrambled
    assert_normalized 'a=1&c=hi%20there&f=5&f=70&f=a&z=p&z=t', { 'a' => 1, 'c' => 'hi there', 'f' => ['a', '70', '5'], 'z' => ['p', 't'] }
  end

  def test_empty
    assert_normalized "",{}
  end


  # These are from the wiki http://wiki.oauth.net/TestCases
  # in the section Normalize Request Parameters
  # Parameters have already been x-www-form-urlencoded (i.e. + = <space>)
  def test_wiki1
    assert_normalized "name=",{"name"=>nil}
  end

  def test_wiki2
    assert_normalized "a=b",{'a'=>'b'}
  end

  def test_wiki3
    assert_normalized "a=b&c=d",{'a'=>'b','c'=>'d'}
  end

  def test_wiki4
    assert_normalized "a=x%20y&a=x%21y",{'a'=>["x!y","x y"]}

  end

  def test_wiki5
    assert_normalized "x=a&x%21y=a",{"x!y"=>'a','x'=>'a'}
  end

  protected


  def assert_normalized(expected,params,message=nil)
    assert_equal expected, normalize_request_parameters(params), message
  end

  def normalize_request_parameters(params={})
    request(params).normalized_parameters
  end
end
