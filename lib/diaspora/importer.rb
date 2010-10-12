#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora

  class Importer
    def initialize(strategy)
      self.class.send(:include, strategy)
    end
  end

  module Importers
    module XML
      def execute(user)

      end
    end
  end

end
