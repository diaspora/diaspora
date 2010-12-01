require 'will_paginate/deprecation'

module WillPaginate
  # = Will Paginate view helpers
  #
  # The main view helper is +will_paginate+. It renders the pagination links
  # for the given collection. The helper itself is lightweight and serves only
  # as a wrapper around LinkRenderer instantiation; the renderer then does
  # all the hard work of generating the HTML.
  # 
  # Read more in WillPaginate::ViewHelpers::Base
  module ViewHelpers
    # ==== Global options for helpers
    #
    # Options for pagination helpers are optional and get their default values
    # from the WillPaginate::ViewHelpers.pagination_options hash. You can write
    # to this hash to override default options on the global level:
    #
    #   WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Previous page'
    #
    # By putting this into your environment.rb you can easily translate link
    # texts to previous and next pages, as well as override some other defaults
    # to your liking.
    def self.pagination_options() @pagination_options; end
    # Overrides the default +pagination_options+
    def self.pagination_options=(value) @pagination_options = value; end
    
    self.pagination_options = {
      :class          => 'pagination',
      :previous_label => '&#8592; Previous',
      :next_label     => 'Next &#8594;',
      :inner_window   => 4, # links around the current page
      :outer_window   => 1, # links around beginning and end
      :separator      => ' ', # single space is friendly to spiders and non-graphic browsers
      :param_name     => :page,
      :params         => nil,
      :renderer       => 'WillPaginate::ViewHelpers::LinkRenderer',
      :page_links     => true,
      :container      => true
    }
  end
end
