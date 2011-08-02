module Nokogiri
  module Decorators
    ###
    # The Slop decorator implements method missing such that a methods may be
    # used instead of XPath or CSS.  See Nokogiri.Slop
    module Slop
      ###
      # look for node with +name+.  See Nokogiri.Slop
      def method_missing name, *args, &block
        if args.empty?
          list = xpath("./#{name}")
        elsif args.first.is_a? Hash
          hash = args.first
          if hash[:css]
            list = css("#{name}#{hash[:css]}")
          elsif hash[:xpath]
            conds = Array(hash[:xpath]).join(' and ')
            list = xpath("./#{name}[#{conds}]")
          end
        else
          CSS::Parser.without_cache do
            list = xpath(
              *CSS.xpath_for("#{name}#{args.first}", :prefix => "./")
            )
          end
        end

        super if list.empty?
        list.length == 1 ? list.first : list
      end
    end
  end
end
