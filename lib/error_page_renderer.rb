
# frozen_string_literal: true

# Inspired by https://github.com/route/errgent/blob/master/lib/errgent/renderer.rb
class ErrorPageRenderer
  def initialize options={}
    @codes    = options.fetch :codes, [404, 500]
    @output   = options.fetch :output, "public/%s.html"
    @vars     = options.fetch :vars, {}
    @template = options.fetch :template, "errors/error_%s"
    @layout   = options.fetch :layout, "layouts/error_page"
  end

  def render
    @codes.each do |code|
      view = build_action_view
      view.assign @vars.merge(code: code)
      path = Rails.root.join(@output % code)
      File.write path, view.render(template: @template % code, layout: @layout)
    end
  end

  def helpers(&block)
    @helpers = block
  end

  private

  def build_action_view
    paths = ::ActionController::Base.view_paths
    ::ActionView::Base.new(paths).tap do |view|
      view.class_eval do
        include Rails.application.helpers
        include Rails.application.routes.url_helpers
      end
      view.assets_manifest = build_manifest(Rails.application)
      view.class_eval(&@helpers) if @helpers
    end
  end

  # Internal API from the sprocket-rails railtie, if somebody finds a way to
  # call it, please replace it. Might need to be updated on sprocket-rails
  # updates.
  def build_manifest(app)
    config = app.config
    path = File.join(config.paths['public'].first, config.assets.prefix)
    Sprockets::Manifest.new(app.assets, path, config.assets.manifest)
  end
end
