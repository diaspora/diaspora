require 'dependency_detection/version'
module DependencyDetection

  module_function
  @@items = []
  def defer(&block)
    item = Dependent.new
    item.instance_eval(&block)
    @@items << item
  end

  def detect!
    @@items.each do |item|
      if item.dependencies_satisfied?
        item.execute
      end
    end
  end

  class Dependent
    attr_reader :executed
    def executed!
      @executed = true
    end

    attr_reader :dependencies

    def initialize
      @dependencies = []
      @executes = []
    end

    def dependencies_satisfied?
      !executed and check_dependencies
    end

    def execute
      @executes.each do |x|
        x.call
      end
    ensure
      executed!
    end

    def check_dependencies
      dependencies && dependencies.all? { |d| d.call }
    end

    def depends_on
      @dependencies << Proc.new
    end

    def executes
      @executes << Proc.new
    end
  end
end
