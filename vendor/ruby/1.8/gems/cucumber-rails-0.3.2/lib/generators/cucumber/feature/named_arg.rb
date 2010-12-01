class NamedArg
  attr_reader :name
  attr_reader :type

  def initialize(s)
    @name, @type = *s.split(':')
  end

  def value(n)
    if @type == 'boolean'
      (n % 2) == 0
    else
      "#{@name} #{n}"
    end
  end
end

