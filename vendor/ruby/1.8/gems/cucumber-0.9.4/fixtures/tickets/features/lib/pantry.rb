class Pantry

  def initialize
    @items = {}
  end

  def add(food_name, count)
    @items[food_name] ||= 0
    @items[food_name] += count.to_i
  end

  def remove(food_name, count)
    @items[food_name] -= count.to_i
  end

  def count(food_name)
    @items[food_name]
  end

end
