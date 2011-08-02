Routing specs live in the `spec/routing` directory, or any example group with
`:type => :routing`.

Simple apps with nothing but standard RESTful routes won't get much value from
routing specs, but they can provide significant value when used to specify
customized routes, like vanity links, slugs, etc.

    { :get => "/articles/2012/11/when-to-use-routing-specs" }.
      should route_to(
        :controller => "articles",
        :month => "2012-11",
        :slug => "when-to-use-routing-specs"
      )

They are also valuable for routes that should not be available:

    { :delete => "/accounts/37" }.should_not be_routable
