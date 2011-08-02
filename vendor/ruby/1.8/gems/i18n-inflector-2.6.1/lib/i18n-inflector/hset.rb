# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
# 
# This file contains more intuitive version of Set.

require 'set'

module I18n
  module Inflector

    # This class keeps sets of data
    class HSet < Set

      # This method performs a fast check
      # if an element exists in a set.
      # 
      # @return [Boolean]
      def [](k)
        @hash[k] == true
      end

    end

  end
end
