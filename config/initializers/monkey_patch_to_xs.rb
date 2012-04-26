#see https://github.com/hpricot/hpricot/issues/53
if RUBY_VERSION < "1.9"
  module Builder
    class XmlBase
      unless ::String.method_defined?(:encode)
        def _escape(text)
          text.to_xs
        end
      end
    end
  end
end