# this struct uniquely defines a metric, optionally inside
# the call scope of another metric
class NewRelic::MetricSpec
  attr_accessor   :name
  attr_accessor   :scope
  
  # the maximum length of a metric name or metric scope
  MAX_LENGTH = 255
  # Need a "zero-arg" constructor so it can be instantiated from java (using
  # jruby) for sending responses to ruby agents from the java collector.
  #
  def initialize(metric_name = '', metric_scope = '')
    self.name = (metric_name || '') && metric_name[0...MAX_LENGTH]
    self.scope = metric_scope && metric_scope[0...MAX_LENGTH]
  end
  
  # truncates the name and scope to the MAX_LENGTH
  def truncate!
    self.name = name[0...MAX_LENGTH] if name && name.size > MAX_LENGTH
    self.scope = scope[0...MAX_LENGTH] if scope && scope.size > MAX_LENGTH
  end
  
  def ==(o)
    self.eql?(o)
  end

  def eql? o
    self.class == o.class &&
    name.eql?(o.name) &&
    # coerce scope to a string and compare
     scope.to_s == o.scope.to_s
  end

  def hash
    h = name.hash
    h ^= scope.hash unless scope.nil?
    h
  end
  # return a new metric spec if the given regex
  # matches the name or scope.
  def sub(pattern, replacement, apply_to_scope = true)
    NewRelic::Control.instance.log.warn("The sub method on metric specs is deprecated") rescue nil
    return nil if name !~ pattern &&
     (!apply_to_scope || scope.nil? || scope !~ pattern)
    new_name = name.sub(pattern, replacement)[0...MAX_LENGTH]

    if apply_to_scope
      new_scope = (scope && scope.sub(pattern, replacement)[0...MAX_LENGTH])
    else
      new_scope = scope
    end

    self.class.new new_name, new_scope
  end

  def to_s
    return name if scope.empty?
    "#{name}:#{scope}"
  end

  def inspect
    "#<NewRelic::MetricSpec '#{name}':'#{scope}'>"
  end

  def to_json(*a)
    {'name' => name,
    'scope' => scope}.to_json(*a)
  end

  def <=>(o)
    namecmp = self.name <=> o.name
    return namecmp if namecmp != 0
    return (self.scope || '') <=> (o.scope || '')
  end
end
