module IsGd
      require 'rubygems'
      require 'shrinker'
      def self.shorten(url)
        if !url or url =~ /is\.gd\//i
          return (url)
        else
          return Shrinker.shrink(url)
	end 
      end
      def self.expand(url)
        if !url or ! (url =~ /is\.gd\//i)
          return (url)
        else
          return Shrinker.expand(url)
	end 
      end
end
