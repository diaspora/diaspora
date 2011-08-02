module FactoryGirl

  class << self
    attr_accessor :aliases #:nodoc:
  end
  self.aliases = [
    [/(.+)_id/, '\1'],
    [/(.*)/, '\1_id']
  ]

  def self.aliases_for(attribute) #:nodoc:
    aliases.collect do |params|
      pattern, replace = *params
      if pattern.match(attribute.to_s)
        attribute.to_s.sub(pattern, replace).to_sym
      else
        nil
      end
    end.compact << attribute
  end
end
