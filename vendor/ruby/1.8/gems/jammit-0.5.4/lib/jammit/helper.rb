module Jammit

  # The Jammit::Helper module, which is made available to every view, provides
  # helpers for writing out HTML tags for asset packages. In development you
  # get the ordered list of source files -- in any other environment, a link
  # to the cached packages.
  module Helper

    DATA_URI_START = "<!--[if (!IE)|(gte IE 8)]><!-->" unless defined?(DATA_URI_START)
    DATA_URI_END   = "<!--<![endif]-->"                unless defined?(DATA_URI_END)
    MHTML_START    = "<!--[if lte IE 7]>"              unless defined?(MHTML_START)
    MHTML_END      = "<![endif]-->"                    unless defined?(MHTML_END)

    # If embed_assets is turned on, writes out links to the Data-URI and MHTML
    # versions of the stylesheet package, otherwise the package is regular
    # compressed CSS, and in development the stylesheet URLs are passed verbatim.
    def include_stylesheets(*packages)
      options = packages.extract_options!
      return individual_stylesheets(packages, options) unless Jammit.package_assets
      disabled = (options.delete(:embed_assets) == false) || (options.delete(:embed_images) == false)
      return html_safe(packaged_stylesheets(packages, options)) if disabled || !Jammit.embed_assets
      return html_safe(embedded_image_stylesheets(packages, options))
    end

    # Writes out the URL to the bundled and compressed javascript package,
    # except in development, where it references the individual scripts.
    def include_javascripts(*packages)
      tags = packages.map do |pack|
        Jammit.package_assets ? Jammit.asset_url(pack, :js) : Jammit.packager.individual_urls(pack.to_sym, :js)
      end
      html_safe(javascript_include_tag(tags.flatten))
    end

    # Writes out the URL to the concatenated and compiled JST file -- we always
    # have to pre-process it, even in development.
    def include_templates(*packages)
      raise DeprecationError, "Jammit 0.5+ no longer supports separate packages for templates.\nYou can include your JST alongside your JS, and use include_javascripts."
    end


    private

    def html_safe(string)
      string.respond_to?(:html_safe) ? string.html_safe : string
    end

    # HTML tags, in order, for all of the individual stylesheets.
    def individual_stylesheets(packages, options)
      tags_with_options(packages, options) {|p| Jammit.packager.individual_urls(p.to_sym, :css) }
    end

    # HTML tags for the stylesheet packages.
    def packaged_stylesheets(packages, options)
      tags_with_options(packages, options) {|p| Jammit.asset_url(p, :css) }
    end

    # HTML tags for the 'datauri', and 'mhtml' versions of the packaged
    # stylesheets, using conditional comments to load the correct variant.
    def embedded_image_stylesheets(packages, options)
      datauri_tags = tags_with_options(packages, options) {|p| Jammit.asset_url(p, :css, :datauri) }
      ie_tags = Jammit.mhtml_enabled ?
                tags_with_options(packages, options) {|p| Jammit.asset_url(p, :css, :mhtml) } :
                packaged_stylesheets(packages, options)
      [DATA_URI_START, datauri_tags, DATA_URI_END, MHTML_START, ie_tags, MHTML_END].join("\n")
    end

    # Generate the stylesheet tags for a batch of packages, with options, by
    # yielding each package to a block.
    def tags_with_options(packages, options)
      packages = packages.dup
      packages.map! {|package| yield package }.flatten!
      packages.push(options) unless options.empty?
      stylesheet_link_tag(*packages)
    end

  end

end

# Include the Jammit asset helpers in all views, a-la ApplicationHelper.
::ActionView::Base.send(:include, Jammit::Helper)
