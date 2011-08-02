require 'date'
require 'extlib/datetime'

class Time

  ##
  # Convert to ISO 8601 representation
  #
  #   Time.now.to_json        #=> "\"2008-03-28T17:54:20-05:00\""
  #
  # @return [String]
  #   ISO 8601 compatible representation of the Time object.
  #
  # @api public
  def to_json(*)
    self.xmlschema.to_json
  end

  ##
  # Return receiver (for DateTime/Time conversion protocol).
  #
  #   Time.now.to_time        #=> Wed Nov 19 20:08:28 -0800 2008
  #
  # @return [Time] Receiver
  #
  # @api public
  remove_method :to_time if instance_methods(false).any? { |m| m.to_sym == :to_time }
  def to_time
    self
  end

  ##
  # Convert to DateTime (for DateTime/Time conversion protocol).
  #
  #   Time.now.to_datetime    #=> #<DateTime: 106046956823/43200,-1/3,2299161>
  #
  # @return [DateTime] DateTime object representing the same moment as receiver
  #
  # @api public
  remove_method :to_datetime if instance_methods(false).any? { |m| m.to_sym == :to_datetime }
  def to_datetime
    DateTime.new(year, month, day, hour, min, sec, Rational(gmt_offset, 24 * 3600))
  end
end
