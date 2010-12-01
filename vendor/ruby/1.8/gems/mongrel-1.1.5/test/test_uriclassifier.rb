# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'test/testhelp'

include Mongrel

class URIClassifierTest < Test::Unit::TestCase

  def test_uri_finding
    uri_classifier = URIClassifier.new
    uri_classifier.register("/test", 1)
    
    script_name, path_info, value = uri_classifier.resolve("/test")
    assert_equal 1, value
    assert_equal "/test", script_name
  end
  
  def test_root_handler_only
    uri_classifier = URIClassifier.new
    uri_classifier.register("/", 1)
    
    script_name, path_info, value = uri_classifier.resolve("/test")
    assert_equal 1, value
    assert_equal "/", script_name 
    assert_equal "/test", path_info
  end

  def test_uri_prefix_ops
    test = "/pre/fix/test"
    prefix = "/pre"

    uri_classifier = URIClassifier.new
    uri_classifier.register(prefix,1)

    script_name, path_info, value = uri_classifier.resolve(prefix)
    script_name, path_info, value = uri_classifier.resolve(test)
    assert_equal 1, value
    assert_equal prefix, script_name
    assert_equal test[script_name.length .. -1], path_info

    assert uri_classifier.inspect
    assert_equal prefix, uri_classifier.uris[0]
  end

  def test_not_finding
    test = "/cant/find/me"
    uri_classifier = URIClassifier.new
    uri_classifier.register(test, 1)

    script_name, path_info, value = uri_classifier.resolve("/nope/not/here")
    assert_nil script_name
    assert_nil path_info
    assert_nil value
  end

  def test_exceptions
    uri_classifier = URIClassifier.new

    uri_classifier.register("/test", 1)
    
    failed = false
    begin 
      uri_classifier.register("/test", 1)
    rescue => e
      failed = true
    end

    assert failed

    failed = false
    begin
      uri_classifier.register("", 1)
    rescue => e
      failed = true
    end

    assert failed
  end


  def test_register_unregister
    uri_classifier = URIClassifier.new
    
    100.times do
      uri_classifier.register("/stuff", 1)
      value = uri_classifier.unregister("/stuff")
      assert_equal 1, value
    end

    uri_classifier.register("/things",1)
    script_name, path_info, value = uri_classifier.resolve("/things")
    assert_equal 1, value

    uri_classifier.unregister("/things")
    script_name, path_info, value = uri_classifier.resolve("/things")
    assert_nil value

  end


  def test_uri_branching
    uri_classifier = URIClassifier.new
    uri_classifier.register("/test", 1)
    uri_classifier.register("/test/this",2)
  
    script_name, path_info, handler = uri_classifier.resolve("/test")
    script_name, path_info, handler = uri_classifier.resolve("/test/that")
    assert_equal "/test", script_name, "failed to properly find script off branch portion of uri"
    assert_equal "/that", path_info
    assert_equal 1, handler, "wrong result for branching uri"
  end

  def test_all_prefixing
    tests = ["/test","/test/that","/test/this"]
    uri = "/test/this/that"
    uri_classifier = URIClassifier.new
    
    current = ""
    uri.each_byte do |c|
      current << c.chr
      uri_classifier.register(current, c)
    end
    

    # Try to resolve everything with no asserts as a fuzzing
    tests.each do |prefix|
      current = ""
      prefix.each_byte do |c|
        current << c.chr
        script_name, path_info, handler = uri_classifier.resolve(current)
        assert script_name
        assert path_info
        assert handler
      end
    end

    # Assert that we find stuff
    tests.each do |t|
      script_name, path_info, handler = uri_classifier.resolve(t)
      assert handler
    end

    # Assert we don't find stuff
    script_name, path_info, handler = uri_classifier.resolve("chicken")
    assert_nil handler
    assert_nil script_name
    assert_nil path_info
  end


  # Verifies that a root mounted ("/") handler resolves
  # such that path info matches the original URI.
  # This is needed to accommodate real usage of handlers.
  def test_root_mounted
    uri_classifier = URIClassifier.new
    root = "/"
    path = "/this/is/a/test"

    uri_classifier.register(root, 1)

    script_name, path_info, handler = uri_classifier.resolve(root)
    assert_equal 1, handler
    assert_equal root, path_info
    assert_equal root, script_name

    script_name, path_info, handler = uri_classifier.resolve(path)
    assert_equal path, path_info
    assert_equal root, script_name
    assert_equal 1, handler
  end

  # Verifies that a root mounted ("/") handler
  # is the default point, doesn't matter the order we use
  # to register the URIs
  def test_classifier_order
    tests = ["/before", "/way_past"]
    root = "/"
    path = "/path"

    uri_classifier = URIClassifier.new
    uri_classifier.register(path, 1)
    uri_classifier.register(root, 2)

    tests.each do |uri|
      script_name, path_info, handler = uri_classifier.resolve(uri)
      assert_equal root, script_name, "#{uri} did not resolve to #{root}"
      assert_equal uri, path_info
      assert_equal 2, handler
    end
  end
  
  if ENV['BENCHMARK']
    # Eventually we will have a suite of benchmarks instead of lamely installing a test
    
    def test_benchmark    

      # This URI set should favor a TST. Both versions increase linearly until you hit 14 
      # URIs, then the TST flattens out.
      @uris = %w(
        / 
        /dag /dig /digbark /dog /dogbark /dog/bark /dug /dugbarking /puppy 
        /c /cat /cat/tree /cat/tree/mulberry /cats /cot /cot/tree/mulberry /kitty /kittycat
#        /eag /eig /eigbark /eog /eogbark /eog/bark /eug /eugbarking /iuppy 
#        /f /fat /fat/tree /fat/tree/mulberry /fats /fot /fot/tree/mulberry /jitty /jittyfat
#        /gag /gig /gigbark /gog /gogbark /gog/bark /gug /gugbarking /kuppy 
#        /h /hat /hat/tree /hat/tree/mulberry /hats /hot /hot/tree/mulberry /litty /littyhat
#        /ceag /ceig /ceigbark /ceog /ceogbark /ceog/cbark /ceug /ceugbarking /ciuppy 
#        /cf /cfat /cfat/ctree /cfat/ctree/cmulberry /cfats /cfot /cfot/ctree/cmulberry /cjitty /cjittyfat
#        /cgag /cgig /cgigbark /cgog /cgogbark /cgog/cbark /cgug /cgugbarking /ckuppy 
#        /ch /chat /chat/ctree /chat/ctree/cmulberry /chats /chot /chot/ctree/cmulberry /citty /cittyhat
      )
      
      @requests = %w(
        /
        /dig
        /digging
        /dogging
        /dogbarking/
        /puppy/barking
        /c
        /cat
        /cat/shrub
        /cat/tree
        /cat/tree/maple
        /cat/tree/mulberry/tree
        /cat/tree/oak
        /cats/
        /cats/tree
        /cod
        /zebra
      )
    
      @classifier = URIClassifier.new
      @uris.each do |uri|
        @classifier.register(uri, 1)
      end
      
      puts "#{@uris.size} URIs / #{@requests.size * 10000} requests"
  
      Benchmark.bm do |x|
        x.report do
  #        require 'ruby-prof'
  #        profile = RubyProf.profile do
            10000.times do
              @requests.each do |request|
                @classifier.resolve(request)
              end
            end
  #        end
  #        File.open("profile.html", 'w') { |file| RubyProf::GraphHtmlPrinter.new(profile).print(file, 0) }
        end
      end          
    end
  end
  
end

