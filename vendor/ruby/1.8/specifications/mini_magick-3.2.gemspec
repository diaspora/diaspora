# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mini_magick}
  s.version = "3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Corey Johnson", "Hampton Catlin", "Peter Kieltyka"]
  s.date = %q{2011-01-11}
  s.description = %q{}
  s.email = ["probablycorey@gmail.com", "hcatlin@gmail.com", "peter@nulayer.com"]
  s.files = ["README.rdoc", "VERSION", "MIT-LICENSE", "Rakefile", "lib/mini_gmagick.rb", "lib/mini_magick.rb", "test/actually_a_gif.jpg", "test/animation.gif", "test/command_builder_test.rb", "test/composited.jpg", "test/image_test.rb", "test/leaves spaced.tiff", "test/not_an_image.php", "test/simple-minus.gif", "test/simple.gif", "test/trogdor.jpg"]
  s.homepage = %q{http://github.com/probablycorey/mini_magick}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Manipulate images with minimal use of memory via ImageMagick / GraphicsMagick}
  s.test_files = ["test/actually_a_gif.jpg", "test/animation.gif", "test/command_builder_test.rb", "test/composited.jpg", "test/image_test.rb", "test/leaves spaced.tiff", "test/not_an_image.php", "test/simple-minus.gif", "test/simple.gif", "test/trogdor.jpg"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<subexec>, ["~> 0.0.4"])
    else
      s.add_dependency(%q<subexec>, ["~> 0.0.4"])
    end
  else
    s.add_dependency(%q<subexec>, ["~> 0.0.4"])
  end
end
