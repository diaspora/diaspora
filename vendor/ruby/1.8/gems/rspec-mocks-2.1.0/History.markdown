## rspec-mocks release history (incomplete)

### 2.1.0 / 2010-11-07

[full changelog](http://github.com/rspec/rspec-mocks/compare/v2.0.1...v2.1.0)

* Bug fixes
  * Fix serialization of stubbed object (Josep M Bach)

### 2.0.0 / 2010-10-10

[full changelog](http://github.com/rspec/rspec-mocks/compare/v2.0.0.beta.22...v2.0.0)

### 2.0.0.rc / 2010-10-05

[full changelog](http://github.com/rspec/rspec-mocks/compare/v2.0.0.beta.22...v2.0.0.rc)

* Enhancements
  * support passing a block to an expecttation block (Nicolas Braem)
    * obj.should_receive(:msg) {|&block| ... }

* Bug fixes
  * Fix YAML serialization of stub (Myron Marston)
  * Fix rdoc rake task (Hans de Graaff)

### 2.0.0.beta.22 / 2010-09-12

[full changelog](http://github.com/rspec/rspec-mocks/compare/v2.0.0.beta.20...v2.0.0.beta.22)

* Bug fixes
  * fixed regression that broke obj.stub_chain(:a, :b => :c)
  * fixed regression that broke obj.stub_chain(:a, :b) { :c }
  * respond_to? always returns true when using as_null_object
