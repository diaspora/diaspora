module FactoryMethods
  def create_from_table(model_name, table, extra = {})
    factory_name = model_name.gsub(/\W+/, '_').downcase.singularize.to_sym
    is_singular = model_name.to_s.singularize == model_name.to_s
    hashes = if is_singular
               if table.kind_of?(Hash)
                 [table]
               else
                 [table.rows_hash]
               end
             else
               table.hashes
             end
    klass = FactoryGirl.factories[factory_name].class_name.to_s.classify.constantize
    @they = hashes.map do |hash|
      hash = hash.merge(extra).inject({}) do |h,(k,v)|
        k = k.gsub(/\W+/,'_')
        v = v.split(/\s*,\s*/) if klass.serialized_attributes[k] == Array
        h.update(k.to_sym => v)
      end
      object = FactoryGirl.build(factory_name, hash)
      yield object if block_given?
      object.save!
      object
    end
    if is_singular
      @it = @they.last
      instance_variable_set("@#{factory_name}", @it)
    end
  end
end

World(FactoryMethods)

Given %r{^I have a (.+)$} do |model_name|
  create_from_table(model_name, {}, 'user' => @me)
end

Given %r{^I have the following (.+):$} do |child, table|
  step "that me has the following #{child}:", table
end

Given %r{^the following (.+):$} do |model_name, table|
  create_from_table(model_name, table)
end

Given %r{^that (.+) has the following (.+):$} do |parent, child, table|
  child= child.gsub(/\W+/,'_')
  parent = parent.gsub(/\W+/,'_').downcase.sub(/^_/, '')
  parent_instance = instance_variable_get("@#{parent}")
  parent_class = parent_instance.class
  if assoc = parent_class.reflect_on_association(child.to_sym) || parent_class.reflect_on_association(child.pluralize.to_sym)
    parent = (assoc.options[:as] || parent).to_s
    child = (assoc.options[:class_name] || child).to_s
  end
  if child.classify.constantize.method_defined?(parent.pluralize)
    create_from_table(child, table, parent.pluralize => [parent_instance])
  elsif child.classify.constantize.method_defined?(parent)
    create_from_table(child, table, parent => parent_instance)
  else
    create_from_table(child, table)
    if assoc.macro == :has_many
      parent_instance.send("#{assoc.name}=", @they)
    else
      parent_instance.send("#{assoc.name}=", @they.first)
    end
  end
end
