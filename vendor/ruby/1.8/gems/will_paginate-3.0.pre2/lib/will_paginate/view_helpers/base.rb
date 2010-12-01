require 'will_paginate/core_ext'
require 'will_paginate/view_helpers'

module WillPaginate
  module ViewHelpers
    # = The main view helpers module
    #
    # This is the base module which provides the +will_paginate+ view helper.
    module Base
      # Renders Digg/Flickr-style pagination for a WillPaginate::Collection object. Nil is
      # returned if there is only one page in total; pagination links aren't needed in that case.
      # 
      # ==== Options
      # * <tt>:class</tt> -- CSS class name for the generated DIV (default: "pagination")
      # * <tt>:previous_label</tt> -- default: "« Previous"
      # * <tt>:next_label</tt> -- default: "Next »"
      # * <tt>:inner_window</tt> -- how many links are shown around the current page (default: 4)
      # * <tt>:outer_window</tt> -- how many links are around the first and the last page (default: 1)
      # * <tt>:separator</tt> -- string separator for page HTML elements (default: single space)
      # * <tt>:param_name</tt> -- parameter name for page number in URLs (default: <tt>:page</tt>)
      # * <tt>:params</tt> -- additional parameters when generating pagination links
      #   (eg. <tt>:controller => "foo", :action => nil</tt>)
      # * <tt>:renderer</tt> -- class name, class or instance of a link renderer (default:
      #   <tt>WillPaginate::LinkRenderer</tt>)
      # * <tt>:page_links</tt> -- when false, only previous/next links are rendered (default: true)
      # * <tt>:container</tt> -- toggles rendering of the DIV container for pagination links, set to
      #   false only when you are rendering your own pagination markup (default: true)
      # * <tt>:id</tt> -- HTML ID for the container (default: nil). Pass +true+ to have the ID
      #   automatically generated from the class name of objects in collection: for example, paginating
      #   ArticleComment models would yield an ID of "article_comments_pagination".
      #
      # All options beside listed ones are passed as HTML attributes to the container
      # element for pagination links (the DIV). For example:
      # 
      #   <%= will_paginate @posts, :id => 'wp_posts' %>
      #
      # ... will result in:
      #
      #   <div class="pagination" id="wp_posts"> ... </div>
      #
      def will_paginate(collection, options = {})
        # early exit if there is nothing to render
        return nil unless collection.total_pages > 1
        
        options = WillPaginate::ViewHelpers.pagination_options.merge(options)
        
        if options[:prev_label]
          WillPaginate::Deprecation::warn(":prev_label view parameter is now :previous_label; the old name has been deprecated.")
          options[:previous_label] = options.delete(:prev_label)
        end
        
        # get the renderer instance
        renderer = case options[:renderer]
        when String
          options[:renderer].constantize.new
        when Class
          options[:renderer].new
        else
          options[:renderer]
        end
        # render HTML for pagination
        renderer.prepare collection, options, self
        renderer.to_html
      end
      
      # Renders a helpful message with numbers of displayed vs. total entries.
      # You can use this as a blueprint for your own, similar helpers.
      #
      #   <%= page_entries_info @posts %>
      #   #-> Displaying posts 6 - 10 of 26 in total
      #
      # By default, the message will use the humanized class name of objects
      # in collection: for instance, "project types" for ProjectType models.
      # Override this to your liking with the <tt>:entry_name</tt> parameter:
      #
      #   <%= page_entries_info @posts, :entry_name => 'item' %>
      #   #-> Displaying items 6 - 10 of 26 in total
      #
      # Entry name is entered in singular and pluralized with
      # <tt>String#pluralize</tt> method from ActiveSupport. If it isn't
      # loaded, specify plural with <tt>:plural_name</tt> parameter:
      #
      #   <%= page_entries_info @posts, :entry_name => 'item', :plural_name => 'items' %>
      #
      # By default, this method produces HTML output. You can trigger plain
      # text output by passing <tt>:html => false</tt> in options.
      def page_entries_info(collection, options = {})
        entry_name = options[:entry_name] || (collection.empty?? 'entry' :
                     collection.first.class.name.underscore.gsub('_', ' '))
        
        plural_name = if options[:plural_name]
          options[:plural_name]
        elsif entry_name == 'entry'
          plural_name = 'entries'
        elsif entry_name.respond_to? :pluralize
          plural_name = entry_name.pluralize
        else
          entry_name + 's'
        end

        unless options[:html] == false
          b  = '<b>'
          eb = '</b>'
          sp = '&nbsp;'
        else
          b  = eb = ''
          sp = ' '
        end
        
        if collection.total_pages < 2
          case collection.size
          when 0; "No #{plural_name} found"
          when 1; "Displaying #{b}1#{eb} #{entry_name}"
          else;   "Displaying #{b}all #{collection.size}#{eb} #{plural_name}"
          end
        else
          %{Displaying #{plural_name} #{b}%d#{sp}-#{sp}%d#{eb} of #{b}%d#{eb} in total} % [
            collection.offset + 1,
            collection.offset + collection.length,
            collection.total_entries
          ]
        end
      end
    end
  end
end
