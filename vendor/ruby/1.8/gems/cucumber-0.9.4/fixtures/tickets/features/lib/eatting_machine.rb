class EattingMachine
  
  attr_reader :fruit_total, :belly_count
  attr_accessor :belly_count
  
  def initialize(fruit_name, fruit_total)
    @fruit_name = fruit_name
    @fruit_total = fruit_total.to_i
    @belly_count = 0
  end
    
  def eat(count)
    count = count.to_i
    @fruit_total = @fruit_total - count
    @belly_count += count
  end
      
end
