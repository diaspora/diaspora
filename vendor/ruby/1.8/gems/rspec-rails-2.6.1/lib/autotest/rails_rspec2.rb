# (c) Copyright 2006 Nick Sieger <nicksieger@gmail.com>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

$:.push(*Dir["vendor/rails/*/lib"])

require 'active_support/core_ext'
require 'autotest/rspec2'

class Autotest::RailsRspec2 < Autotest::Rspec2

  def initialize
    super
    setup_rails_rspec2_mappings
  end

  def setup_rails_rspec2_mappings
    %w{config/ coverage/ db/ doc/ log/ public/ script/ tmp/ vendor/rails vendor/plugins vendor/gems}.each do |exception|
      add_exception(/^([\.\/]*)?#{exception}/)
    end

    clear_mappings

    add_mapping(%r%^(test|spec)/fixtures/(.*).yml$%) { |_, m|
      ["spec/models/#{m[2].singularize}_spec.rb"] + files_matching(%r%^spec\/views\/#{m[2]}/.*_spec\.rb$%)
    }
    add_mapping(%r%^spec/(models|controllers|routing|views|helpers|mailers|requests|lib)/.*rb$%) { |filename, _|
      filename
    }
    add_mapping(%r%^app/models/(.*)\.rb$%) { |_, m|
      ["spec/models/#{m[1]}_spec.rb"]
    }
    add_mapping(%r%^app/views/(.*)$%) { |_, m|
      files_matching %r%^spec/views/#{m[1]}_spec.rb$%
    }
    add_mapping(%r%^app/controllers/(.*)\.rb$%) { |_, m|
      if m[1] == "application"
        files_matching %r%^spec/controllers/.*_spec\.rb$%
      else
        ["spec/controllers/#{m[1]}_spec.rb"]
      end
    }
    add_mapping(%r%^app/helpers/(.*)_helper\.rb$%) { |_, m|
      if m[1] == "application" then
        files_matching(%r%^spec/(views|helpers)/.*_spec\.rb$%)
      else
        ["spec/helpers/#{m[1]}_helper_spec.rb"] + files_matching(%r%^spec\/views\/#{m[1]}/.*_spec\.rb$%)
      end
    }
    add_mapping(%r%^config/routes\.rb$%) {
      files_matching %r%^spec/(controllers|routing|views|helpers)/.*_spec\.rb$%
    }
    add_mapping(%r%^config/database\.yml$%) { |_, m|
      files_matching %r%^spec/models/.*_spec\.rb$%
    }
    add_mapping(%r%^(spec/(spec_helper|support/.*)|config/(boot|environment(s/test)?))\.rb$%) {
      files_matching %r%^spec/(models|controllers|routing|views|helpers)/.*_spec\.rb$%
    }
    add_mapping(%r%^lib/(.*)\.rb$%) { |_, m|
      ["spec/lib/#{m[1]}_spec.rb"]
    }
    add_mapping(%r%^app/mailers/(.*)\.rb$%) { |_, m|
      ["spec/mailers/#{m[1]}_spec.rb"]
    }
  end
end
