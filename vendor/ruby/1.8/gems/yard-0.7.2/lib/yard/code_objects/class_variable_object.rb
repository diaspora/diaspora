module YARD::CodeObjects
  # Represents a class variable inside a namespace. The path is expressed
  # in the form "A::B::@@classvariable"
  class ClassVariableObject < Base
    # @return [String] the class variable's value
    attr_accessor :value
  end
end