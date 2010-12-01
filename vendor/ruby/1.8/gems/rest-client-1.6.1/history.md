# 1.6.1

- add response body in Exception#inspect
- add support for RestClient.options
- fix tests for 1.9.2 (patch provided by Niko Dittmann)
- block passing in Resource#[] (patch provided by Niko Dittmann)
- cookies set in a response should be kept in a redirect
- HEAD requests should process parameters just like GET (patch provided by Rob Eanes)

# 1.6.0

- forgot to include rest-client.rb in the gem
- user, password and user-defined headers should survive a redirect
- added all missing status codes
- added parameter passing for get request using the :param key in header
- the warning about the logger when using a string was a bad idea
- multipart parameters names should not be escaped
- remove the cookie escaping introduced by migrating to CGI cookie parsing in 1.5.1
- add a streamed payload type (patch provided by Caleb Land)
- Exception#http_body works even when no response

# 1.5.1

- only converts headers keys which are Symbols
- use CGI for cookie parsing instead of custom code
- unescape user and password before using them (patch provided by Lars Gierth)
- expand ~ in ~/.restclientrc (patch provided by Mike Fletcher)
- ssl verification raise an exception when the ca certificate is incorrect (patch provided by Braintree)

# 1.5.0

- the response is now a String with the Response module a.k.a. the change in 1.4.0 was a mistake (Response.body is returning self for compatability)
- added AbstractResponse.to_i to improve semantic
- multipart Payloads ignores the name attribute if it's not set (patch provided by Tekin Suleyman)
- correctly takes into account user headers whose keys are strings (path provided by Cyril Rohr)
- use binary mode for payload temp file
- concatenate cookies with ';'
- fixed deeper parameter handling
- do not quote the boundary in the Content-Type header (patch provided by W. Andrew Loe III)

# 1.4.2

- fixed RestClient.add_before_execution_proc (patch provided by Nicholas Wieland)
- fixed error when an exception is raised without a response (patch provided by Caleb Land)

# 1.4.1

- fixed parameters managment when using hash

# 1.4.0

- Response is no more a String, and the mixin is replaced by an abstract_response, existing calls are redirected to response body with a warning.
- enable repeated parameters  RestClient.post 'http://example.com/resource', :param1 => ['one', 'two', 'three'], => :param2 => 'foo' (patch provided by Rodrigo Panachi)
- fixed the redirect code concerning relative path and query string combination (patch provided by Kevin Read)
- redirection code moved to Response so redirection can be customized using the block syntax
- only get and head redirections are now followed by default, as stated in the specification
- added RestClient.add_before_execution_proc to hack the http request, like for oauth

The response change may be breaking in rare cases.

# 1.3.1

- added compatibility to enable responses in exception to act like Net::HTTPResponse

# 1.3.0

- a block can be used to process a request's result, this enable to handle custom error codes or paththrought (design by Cyril Rohr)
- cleaner log API, add a warning for some cases but should be compatible
- accept multiple "Set-Cookie" headers, see http://www.ietf.org/rfc/rfc2109.txt (patch provided by Cyril Rohr)
- remove "Content-Length" and "Content-Type" headers when following a redirection (patch provided by haarts)
- all http error codes have now a corresponding exception class and all of them contain the Reponse -> this means that the raised exception can be different
- changed "Content-Disposition: multipart/form-data" to "Content-Disposition: form-data" per RFC 2388 (patch provided by Kyle Crawford)

The only breaking change should be the exception classes, but as the new classes inherits from the existing ones, the breaking cases should be rare.

# 1.2.0

- formatting changed from tabs to spaces
- logged requests now include generated headers
- accept and content-type headers can now be specified using extentions: RestClient.post "http://example.com/resource", { 'x' => 1 }.to_json, :content_type => :json, :accept => :json
- should be 1.1.1 but renamed to 1.2.0 because 1.1.X versions has already been packaged on Debian

# 1.1.0

- new maintainer: Archiloque, the working repo is now at http://github.com/archiloque/rest-client
- a mailing list has been created at rest.client@librelist.com and an freenode irc channel #rest-client
- François Beausoleil' multipart code from http://github.com/francois/rest-client has been merged
- ability to use hash in hash as payload
- the mime-type code now rely on the mime-types gem http://mime-types.rubyforge.org/ instead of an internal partial list
- 204 response returns a Response instead of nil (patch provided by Elliott Draper)

All changes exept the last one should be fully compatible with the previous version.

NOTE: due to a dependency problem and to the last change, heroku users should update their heroku gem to >= 1.5.3 to be able to use this version.