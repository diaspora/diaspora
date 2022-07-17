
# frozen_string_literal: true

# Inspired by https://github.com/route/errgent/blob/master/lib/errgent/renderer.rb
class ErrorPageRenderer
  def initialize options={}
    @codes    = options.fetch :codes, [404, 500]
    @output   = options.fetch :output, "public/%s.html"
    @template = options.fetch :template, "errors/error_%s"
    @layout   = options.fetch :layout, "layouts/error_page"
  end

  def render
    @codes.each do |code|
      path = Rails.root.join(@output % code)
      File.write path, ApplicationController.render(@template % code, layout: @layout, locals: {code: code})
    end
  end
end
