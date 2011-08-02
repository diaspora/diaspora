major, minor, patch = RUBY_VERSION.split('.')

if major.to_i == 1 && minor.to_i == 8 && patch.to_i <= 6
  class Object
    def tap
      yield self
      self
    end
  end
end
