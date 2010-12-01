require 'rubygems'
require 'active_support'

dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'httparty')
require 'pp'
config = YAML::load(File.read(File.join(ENV['HOME'], '.aaws')))

module AAWS
  class Book
    include HTTParty
    base_uri 'http://ecs.amazonaws.com'
    default_params :Service => 'AWSECommerceService', :Operation => 'ItemSearch', :SearchIndex => 'Books'
    
    def initialize(key)
      self.class.default_params :AWSAccessKeyId => key
    end
    
    def search(options={})
      raise ArgumentError, 'You must search for something' if options[:query].blank?
      
      # amazon uses nasty camelized query params
      options[:query] = options[:query].inject({}) { |h, q| h[q[0].to_s.camelize] = q[1]; h }
      
      # make a request and return the items (NOTE: this doesn't handle errors at this point)
      self.class.get('/onca/xml', options)['ItemSearchResponse']['Items']
    end
  end
end

aaws = AAWS::Book.new(config[:access_key])
pp aaws.search(:query => {:title => 'Ruby On Rails'})
