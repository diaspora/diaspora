###
### $Release: 2.6.6 $
### copyright(c) 2006-2010 kuwata-lab.com all rights reserved.
###

require  "#{File.dirname(__FILE__)}/test.rb"


class KwarkUsersGuideTest < Test::Unit::TestCase

  DIR = File.expand_path(File.dirname(__FILE__) + '/data/users-guide')
  CWD = Dir.pwd()


  def setup
    Dir.chdir DIR
  end


  def teardown
    Dir.chdir CWD
  end


  def _test
    @name = (caller()[0] =~ /`(.*?)'/) && $1
    s = File.read(@filename)
    s =~ /\A\$ (.*?)\n/
    command = $1
    expected = $'
    result = `#{command}`
    assert_text_equal(expected, result)
  end


  Dir.chdir DIR do
    filenames = []
    filenames += Dir.glob('*.result')
    filenames += Dir.glob('*.source')
    filenames.each do |filename|
      name = filename.gsub(/[^\w]/, '_')
      s = <<-END
        def test_#{name}
          # $stderr.puts "*** debug: test_#{name}"
          @name = '#{name}'
          @filename = '#{filename}'
          _test()
        end
      END
      eval s
    end
  end


  self.post_definition()

end
