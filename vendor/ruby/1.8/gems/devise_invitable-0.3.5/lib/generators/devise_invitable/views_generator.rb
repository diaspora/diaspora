require 'generators/devise/views_generator'

module DeviseInvitable
  module Generators
    class ViewsGenerator < Devise::Generators::ViewsGenerator
      source_root File.expand_path("../../../../app/views", __FILE__)
      desc 'Copies all DeviseInvitable views to your application.'
    end
  end
end
