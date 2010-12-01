module Extlib
  module LocalObjectSpace
    def self.extended(klass)
      (class << klass; self; end).send :attr_accessor, :hook_scopes
      klass.hook_scopes = []
    end

    def object_by_id(object_id)
      self.hook_scopes.detect {|object| object.object_id == object_id}
    end
  end
end
