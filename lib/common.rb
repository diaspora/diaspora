module CommonField

  def self.included(klass)
    klass.class_eval do
      include Mongoid::Document
      include ROXML
      include Mongoid::Timestamps

      xml_accessor :owner
      xml_accessor :snippet
      xml_accessor :source

      field :owner
      field :source
      field :snippet
    end
  end
end
