class Object
  def id
    if self.class.ancestors.include?(ActiveRecord::Base)
      super
    else
      raise "You are calling id on a non-ActiveRecord object. STOP IT."
    end
  end
end
