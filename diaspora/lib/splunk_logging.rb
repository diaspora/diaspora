module SplunkLogging
  def self.included(base)
    base.class_eval do
      alias_method_chain :add, :splunk
    end
  end
  def add_with_splunk(arg1, log_hash = nil, arg3 = nil, &block)
    string = format_hash(log_hash).dup
    string << " pid=#{Process.pid} "
    string << " time=#{Time.now.to_i} "
    add_without_splunk(arg1, string, arg3, &block)
  end
  def format_hash(hash)
    if hash.respond_to?(:keys)
      string = ''
      hash.each_pair do |key, value|
        if [Symbol, Fixnum, Float, Class].include?(value.class)
           string << "#{key}=#{value} "
        else
           string << "#{key}=\"#{value.to_s.gsub('"', '\"')}\" "
        end
      end
      string
    else
      hash
    end
  end
end
