require 'extlib/try_dup'

class LazyArray  # borrowed partially from StrokeDB
  include Enumerable

  attr_reader :head, :tail

  def first(*args)
    if lazy_possible?(@head, *args)
      @head.first(*args)
    else
      lazy_load
      @array.first(*args)
    end
  end

  def last(*args)
    if lazy_possible?(@tail, *args)
      @tail.last(*args)
    else
      lazy_load
      @array.last(*args)
    end
  end

  def at(index)
    if index >= 0 && lazy_possible?(@head, index + 1)
      @head.at(index)
    elsif index < 0 && lazy_possible?(@tail, index.abs)
      @tail.at(index)
    else
      lazy_load
      @array.at(index)
    end
  end

  def fetch(*args, &block)
    index = args.first

    if index >= 0 && lazy_possible?(@head, index + 1)
      @head.fetch(*args, &block)
    elsif index < 0 && lazy_possible?(@tail, index.abs)
      @tail.fetch(*args, &block)
    else
      lazy_load
      @array.fetch(*args, &block)
    end
  end

  def values_at(*args)
    accumulator = []

    lazy_possible = args.all? do |arg|
      index, length = extract_slice_arguments(arg)

      if index >= 0 && lazy_possible?(@head, index + length)
        accumulator.concat(head.values_at(*arg))
      elsif index < 0 && lazy_possible?(@tail, index.abs)
        accumulator.concat(tail.values_at(*arg))
      end
    end

    if lazy_possible
      accumulator
    else
      lazy_load
      @array.values_at(*args)
    end
  end

  def index(entry)
    (lazy_possible?(@head) && @head.index(entry)) || begin
      lazy_load
      @array.index(entry)
    end
  end

  def include?(entry)
    (lazy_possible?(@tail) && @tail.include?(entry)) ||
    (lazy_possible?(@head) && @head.include?(entry)) || begin
      lazy_load
      @array.include?(entry)
    end
  end

  def empty?
    (@tail.nil? || @tail.empty?) &&
    (@head.nil? || @head.empty?) && begin
      lazy_load
      @array.empty?
    end
  end

  def any?(&block)
    (lazy_possible?(@tail) && @tail.any?(&block)) ||
    (lazy_possible?(@head) && @head.any?(&block)) || begin
      lazy_load
      @array.any?(&block)
    end
  end

  def [](*args)
    index, length = extract_slice_arguments(*args)

    if length == 1 && args.size == 1 && args.first.kind_of?(Integer)
      return at(index)
    end

    if index >= 0 && lazy_possible?(@head, index + length)
      @head[*args]
    elsif index < 0 && lazy_possible?(@tail, index.abs - 1 + length)
      @tail[*args]
    else
      lazy_load
      @array[*args]
    end
  end

  alias slice []

  def slice!(*args)
    index, length = extract_slice_arguments(*args)

    if index >= 0 && lazy_possible?(@head, index + length)
      @head.slice!(*args)
    elsif index < 0 && lazy_possible?(@tail, index.abs - 1 + length)
      @tail.slice!(*args)
    else
      lazy_load
      @array.slice!(*args)
    end
  end

  def []=(*args)
    index, length = extract_slice_arguments(*args[0..-2])

    if index >= 0 && lazy_possible?(@head, index + length)
      @head.[]=(*args)
    elsif index < 0 && lazy_possible?(@tail, index.abs - 1 + length)
      @tail.[]=(*args)
    else
      lazy_load
      @array.[]=(*args)
    end
  end

  alias splice []=

  def reverse
    dup.reverse!
  end

  def reverse!
    # reverse without kicking if possible
    if loaded?
      @array = @array.reverse
    else
      @head, @tail = @tail.reverse, @head.reverse

      proc = @load_with_proc

      @load_with_proc = lambda do |v|
        proc.call(v)
        v.instance_variable_get(:@array).reverse!
      end
    end

    self
  end

  def <<(entry)
    if loaded?
      lazy_load
      @array << entry
    else
      @tail << entry
    end
    self
  end

  def concat(other)
    if loaded?
      lazy_load
      @array.concat(other)
    else
      @tail.concat(other)
    end
    self
  end

  def push(*entries)
    if loaded?
      lazy_load
      @array.push(*entries)
    else
      @tail.push(*entries)
    end
    self
  end

  def unshift(*entries)
    if loaded?
      lazy_load
      @array.unshift(*entries)
    else
      @head.unshift(*entries)
    end
    self
  end

  def insert(index, *entries)
    if index >= 0 && lazy_possible?(@head, index)
      @head.insert(index, *entries)
    elsif index < 0 && lazy_possible?(@tail, index.abs - 1)
      @tail.insert(index, *entries)
    else
      lazy_load
      @array.insert(index, *entries)
    end
    self
  end

  def pop(*args)
    if lazy_possible?(@tail, *args)
      @tail.pop(*args)
    else
      lazy_load
      @array.pop(*args)
    end
  end

  def shift(*args)
    if lazy_possible?(@head, *args)
      @head.shift(*args)
    else
      lazy_load
      @array.shift(*args)
    end
  end

  def delete_at(index)
    if index >= 0 && lazy_possible?(@head, index + 1)
      @head.delete_at(index)
    elsif index < 0 && lazy_possible?(@tail, index.abs)
      @tail.delete_at(index)
    else
      lazy_load
      @array.delete_at(index)
    end
  end

  def delete_if(&block)
    if loaded?
      lazy_load
      @array.delete_if(&block)
    else
      @reapers << block
      @head.delete_if(&block)
      @tail.delete_if(&block)
    end
    self
  end

  def replace(other)
    mark_loaded
    @array.replace(other)
    self
  end

  def clear
    mark_loaded
    @array.clear
    self
  end

  def to_a
    lazy_load
    @array.to_a
  end

  alias to_ary to_a

  def load_with(&block)
    @load_with_proc = block
    self
  end

  def loaded?
    @loaded == true
  end

  def kind_of?(klass)
    super || @array.kind_of?(klass)
  end

  alias is_a? kind_of?

  def respond_to?(method, include_private = false)
    super || @array.respond_to?(method)
  end

  def freeze
    if loaded?
      @array.freeze
    else
      @head.freeze
      @tail.freeze
    end
    @frozen = true
    self
  end

  def frozen?
    @frozen == true
  end

  def ==(other)
    if equal?(other)
      return true
    end

    unless other.respond_to?(:to_ary)
      return false
    end

    # if necessary, convert to something that can be compared
    other = other.to_ary unless other.respond_to?(:[])

    cmp?(other, :==)
  end

  def eql?(other)
    if equal?(other)
      return true
    end

    unless other.class.equal?(self.class)
      return false
    end

    cmp?(other, :eql?)
  end

  def lazy_possible?(list, need_length = 1)
    !loaded? && need_length <= list.size
  end

  private

  def initialize
    @frozen         = false
    @loaded         = false
    @load_with_proc = lambda { |v| v }
    @head           = []
    @tail           = []
    @array          = []
    @reapers        = []
  end

  def initialize_copy(original)
    @head  = @head.try_dup
    @tail  = @tail.try_dup
    @array = @array.try_dup
  end

  def lazy_load
    return if loaded?
    mark_loaded
    @load_with_proc[self]
    @array.unshift(*@head)
    @array.concat(@tail)
    @head = @tail = nil
    @reapers.each { |r| @array.delete_if(&r) } if @reapers
    @array.freeze if frozen?
  end

  def mark_loaded
    @loaded = true
  end

  ##
  # Extract arguments for #slice an #slice! and return index and length
  #
  # @param [Integer, Array(Integer), Range] *args the index,
  #   index and length, or range indicating first and last position
  #
  # @return [Integer] the index
  # @return [Integer,NilClass] the length, if any
  #
  # @api private
  def extract_slice_arguments(*args)
    first_arg, second_arg = args

    if args.size == 2 && first_arg.kind_of?(Integer) && second_arg.kind_of?(Integer)
      return first_arg, second_arg
    elsif args.size == 1
      if first_arg.kind_of?(Integer)
        return first_arg, 1
      elsif first_arg.kind_of?(Range)
        index = first_arg.first
        length  = first_arg.last - index
        length += 1 unless first_arg.exclude_end?
        return index, length
      end
    end

    raise ArgumentError, "arguments may be 1 or 2 Integers, or 1 Range object, was: #{args.inspect}", caller(1)
  end

  def each
    lazy_load
    if block_given?
      @array.each { |entry| yield entry }
      self
    else
      @array.each
    end
  end

  # delegate any not-explicitly-handled methods to @array, if possible.
  # this is handy for handling methods mixed-into Array like group_by
  def method_missing(method, *args, &block)
    if @array.respond_to?(method)
      lazy_load
      results = @array.send(method, *args, &block)
      results.equal?(@array) ? self : results
    else
      super
    end
  end

  def cmp?(other, operator)
    unless loaded?
      # compare the head against the beginning of other.  start at index
      # 0 and incrementally compare each entry. if other is a LazyArray
      # this has a lesser likelyhood of triggering a lazy load
      0.upto(@head.size - 1) do |i|
        return false unless @head[i].__send__(operator, other[i])
      end

      # compare the tail against the end of other.  start at index
      # -1 and decrementally compare each entry. if other is a LazyArray
      # this has a lesser likelyhood of triggering a lazy load
      -1.downto(@tail.size * -1) do |i|
        return false unless @tail[i].__send__(operator, other[i])
      end

      lazy_load
    end

    @array.send(operator, other.to_ary)
  end
end
