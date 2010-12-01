class Factory

  class << self
    attr_accessor :aliases #:nodoc:
  end
  self.aliases = [
    [/(.+)_id/, '\1'],
    [/(.*)/, '\1_id']
  ]

  # Defines a new alias for attributes.
  #
  # Arguments:
  # * pattern: +Regexp+
  #   A pattern that will be matched against attributes when looking for
  #   aliases. Contents captured in the pattern can be used in the alias.
  # * replace: +String+
  #   The alias that results from the matched pattern. Captured strings can
  #   be substituted like with +String#sub+.
  #
  # Example:
  #
  #   Factory.alias /(.*)_confirmation/, '\1'
  #
  # factory_girl starts with aliases for foreign keys, so that a :user
  # association can be overridden by a :user_id parameter:
  #
  #   Factory.define :post do |p|
  #     p.association :user
  #   end
  #
  #   # The user association will not be built in this example. The user_id
  #   # will be used instead.
  #   Factory(:post, :user_id => 1)
  def self.alias (pattern, replace)
    self.aliases << [pattern, replace]
  end

  def self.aliases_for (attribute) #:nodoc:
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
