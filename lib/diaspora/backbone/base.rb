
module Diaspora::Backbone
  class Base < ::Sinatra::Base

    set :show_exceptions, false

    before do
      content_type :json
    end

    helpers do
      def json(object)
        hash = if object.is_a?(Hash) || object.is_a?(Array)
                 object
               elsif object.respond_to?(:full_hash)
                 object.full_hash
               elsif object.respond_to?(:base_hash)
                 object.base_hash
               else
                 object.to_h
               end

        JSON.dump(hash)
      end
    end

    register AuthHelpers
    register ErrorHelpers
    register ParamHelpers
    register PaginationHelpers

    get "/" do
      json({message: "This is the internal diaspora* Backbone.js API\n"+
                     "It is SUBJECT TO CHANGE WITHOUT NOTICE and NOT INTENDED FOR USE WITH EXTERNAL PROGRAMS!"})
    end

    # add fallback routes
    get "/*" do
      halt_404_not_found
    end

    post "/*" do
      halt_404_not_found
    end

    put "/*" do
      halt_404_not_found
    end

    patch "/*" do
      halt_404_not_found
    end

    delete "/*" do
      halt_404_not_found
    end
  end
end
