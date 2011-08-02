module Resque
  module Plugin
    extend self

    LintError = Class.new(RuntimeError)

    # Ensure that your plugin conforms to good hook naming conventions.
    #
    #   Resque::Plugin.lint(MyResquePlugin)
    def lint(plugin)
      hooks = before_hooks(plugin) + around_hooks(plugin) + after_hooks(plugin)

      hooks.each do |hook|
        if hook =~ /perform$/
          raise LintError, "#{plugin}.#{hook} is not namespaced"
        end
      end

      failure_hooks(plugin).each do |hook|
        if hook =~ /failure$/
          raise LintError, "#{plugin}.#{hook} is not namespaced"
        end
      end
    end

    # Given an object, returns a list `before_perform` hook names.
    def before_hooks(job)
      job.methods.grep(/^before_perform/).sort
    end

    # Given an object, returns a list `around_perform` hook names.
    def around_hooks(job)
      job.methods.grep(/^around_perform/).sort
    end

    # Given an object, returns a list `after_perform` hook names.
    def after_hooks(job)
      job.methods.grep(/^after_perform/).sort
    end

    # Given an object, returns a list `on_failure` hook names.
    def failure_hooks(job)
      job.methods.grep(/^on_failure/).sort
    end

    # Given an object, returns a list `after_enqueue` hook names.
    def after_enqueue_hooks(job)
      job.methods.grep(/^after_enqueue/).sort
    end
  end
end
