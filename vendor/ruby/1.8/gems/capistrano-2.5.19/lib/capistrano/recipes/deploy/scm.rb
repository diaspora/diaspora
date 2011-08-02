module Capistrano
  module Deploy
    module SCM
      def self.new(scm, config={})
        scm_file = "capistrano/recipes/deploy/scm/#{scm}"
        require(scm_file)

        scm_const = scm.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
        if const_defined?(scm_const)
          const_get(scm_const).new(config)
        else
          raise Capistrano::Error, "could not find `#{name}::#{scm_const}' in `#{scm_file}'"
        end
      rescue LoadError
        raise Capistrano::Error, "could not find any SCM named `#{scm}'"
      end
    end
  end
end