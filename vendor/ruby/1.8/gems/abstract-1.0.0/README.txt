= README

revision::	$Rev: 1 $
release::	$Release: 1.0.0 $
copyright::	copyright(c) 2006 kuwata-lab.com all rights reserved.


== Introduction

'abstract.rb' is a library which enable you to define abstract method in Ruby.

The followings are examples:

  ## example1. (shorter notation)
  require 'rubygems'   # if installed with 'gem install'
  require 'abstract'
  class Foo
    abstract_method 'arg1, arg2=""', :method1, :method2, :method3
  end
  
  ## example2. (RDoc friendly notation)
  require 'rubygems'   # if installed with 'gem install'
  require 'abstract'
  class Bar
    # ... method1 description ...
    def method1(arg1, arg2="")
      not_implemented
    end
    # ... method2 description ...
    def method2(arg1, arg2="")
      not_implemented
    end
  end


Abstract method makes your code more descriptive.
It is useful even for dynamic language such as Ruby.


== Installation


* Type 'gem install -r abstract' with root account if you have installed RubyGems.

* Or type 'ruby setup.rb' with root account if you can be root account.

* Or copy lib/abstract.rb into proper directory such as '/usr/local/lib/ruby/site_ruby'.


== License

Ruby's


== Copyright

copyright(c) 2006 kuwata-lab.com all rights reserved.
