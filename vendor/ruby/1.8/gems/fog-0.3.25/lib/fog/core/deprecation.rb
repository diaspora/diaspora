module Fog
  module Deprecation

    def deprecate(older, newer)
      class_eval <<-EOS, __FILE__, __LINE__
        def #{older}(*args)
          location = caller.first
          warning = "[yellow][WARN] #{self} => ##{older} is deprecated, use ##{newer} instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          send(:#{newer}, *args)
        end
      EOS
    end

  end
end
