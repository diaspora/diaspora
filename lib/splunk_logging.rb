module SplunkLogging
  def self.included(base)
    base.class_eval do
      alias_method_chain :add, :splunk
    end
  end
  def add_with_splunk(arg1, log_hash = nil, arg3 = nil, &block)
    add_without_splunk(arg1, format_hash(log_hash), arg3, &block)
  end
  def format_hash(hash)
    if hash.respond_to?(:keys)
      string = ''
      hash.each_pair do |key, value|
        if(value.instance_of?(Symbol)||value.instance_of?(Fixnum)||value.instance_of?(Float))
           string << "#{key}=#{value} "
        else
           string << "#{key}='#{value}' "
        end
      end
      string
    else
      hash
    end
  end
end
