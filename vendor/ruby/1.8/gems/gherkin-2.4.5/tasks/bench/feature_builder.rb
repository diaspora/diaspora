class StepsBuilder
  def initialize
    @steps = []
  end

  def step(content, generator)
    @steps << "    Given #{content}"
    if(rand(5) == 0)
      cols = rand(8) + 1
      rows = rand(10)
      rows.times do
        row = "      |"
        cols.times do
          row << generator.table_cell << "|"
        end
        @steps << row
      end
    end
  end

  def to_s
    @steps.join("\n")
  end
end

class FeatureBuilder
  def initialize(name, &block)
    @name = name
    @scenarios = {}
    block.call(self)
  end

  def scenario(name, &block)
    @scenarios[name] = StepsBuilder.new
    block.call(@scenarios[name])
  end

  def to_s
    str = "Feature: #{@name}\n"
    @scenarios.each do |scenario, steps|
      str += "\n"
      str += "  Scenario: #{scenario}\n"
      str += steps.to_s
      str += "\n"
    end
    str
  end
end

