class Array
  unless public_instance_methods.map {|m| m.to_s}.include?('none?')
    def none?(&block)
      !any?(&block)
    end
  end
end
