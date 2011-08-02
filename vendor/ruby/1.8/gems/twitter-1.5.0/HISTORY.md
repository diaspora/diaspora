HISTORY
=======

1.5.0 - May 29, 2011
--------------------
* [Change interface to make <tt>Twitter</tt> module behave more like a class](https://github.com/jnunemaker/twitter/commit/df5247de490f7448c35c8f84112a9e7c14ce4057)

1.4.1 - April 28, 2011
----------------------
* [Update multi_json dependency to version 1.0.0](https://github.com/jnunemaker/twitter/commit/9ab51bc5536e5eebea10283d771cfe57e2fccbc7)

1.4.0 - April 20, 2011
----------------------
* [Update list methods to use new resources](https://github.com/jnunemaker/twitter/compare/v1.3.0...v1.4.0) ([@erebor](http://twitter.com/#!/erebor))
* [Fix copy/paste bug in <tt>Error#ratelimit_remaining</tt>](https://github.com/jnunemaker/twitter/commit/b74861e75f0cdf7eaafc37162e2f040ae27db002)

1.3.0 - April 6, 2011
---------------------
* [Update faraday dependency to version 0.6](https://github.com/jnunemaker/twitter/commit/2b29c2109d2ca95a699ebe3822b98091a96256d8)
* [Include response headers when raising an error](https://github.com/jnunemaker/twitter/commit/6db6fe2c2504f566333c6742979436580f5264d4)
* [Fix typo in README for accessing friends and followers](https://github.com/jnunemaker/twitter/commit/2043ab4a6b723cac2a8ed77e26a4b0e3f4f55b03) ([@surfacedamage](http://twitter.com/#!/surfacedamage))

1.2.0 - March 20, 2011
----------------------
* [Respect global load path](https://github.com/jnunemaker/twitter/commit/6a629a6a06e115388cce6f1de04f45a4b0707cac)
* [Use map and <tt>Hash[]</tt> instead of <tt>inject({})</tt>](https://github.com/jnunemaker/twitter/commit/a2b0b51618f40b526f554c019a6c83b0bf9a8cdf) ([@wtnelson](http://twitter.com/#!/wtnelson))
* [Check headers for <tt>Retry-After</tt> in absence of <tt>retry-after</tt>](https://github.com/jnunemaker/twitter/commit/924253214efcedfeb80b4c6fe57dcbb2a7470177) ([@wtnelson](http://twitter.com/#!/wtnelson))
* [Fix name of <tt>#list_add_members</tt> resource](https://github.com/jnunemaker/twitter/commit/3adcc1592240be2679f0a2c7d0c390b574abe8f1)
* [Don't strip @ signs from screen names](https://github.com/jnunemaker/twitter/commit/38c9dd0a720ea857ff6220b28f66db4c780a7fda)
* [Make <tt>#places_similar</tt> method return a token](https://github.com/jnunemaker/twitter/commit/351e2240717a34d6575a802078077a1681fa4616) ([@nicolassanta](http://twitter.com/#!/nicolassanta))

1.1.2 - February 2, 2011
------------------------
* [Opt-in for testing with rubygems-test](https://github.com/jnunemaker/twitter/commit/7d92afc138cac1b751b17682fd166b2603f804c6)
* [Add support for <tt>Twitter.respond_to?</tt>](https://github.com/jnunemaker/twitter/commit/ce64c7818f9b62cf91f1fa5dc2e76a9d4205cd2e) ([@fernandezpablo](http://twitter.com/#!/fernandezpablo))

1.1.1 - January 16, 2011
------------------------
* [Don't set cached <tt>screen_name</tt> when creating a new API client](https://github.com/jnunemaker/twitter/commit/ceeed993b16f95582c648e93de03738362ba1d7b)

1.1.0 - January 6, 2011
-----------------------
* [Overload all methods that require a <tt>screen_name</tt> parameter](https://github.com/jnunemaker/twitter/compare/ecd647e414ac0b0cae96...59cf052ca646a2b79446) ([@gabriel_somoza](http://twitter.com/#!/gabriel_somoza))
* [Rename <tt>user_screen_name</tt> to <tt>screen_name</tt>](https://github.com/jnunemaker/twitter/commit/4fb4f8a28c967f7d5a2cf295b34548a346900cfd) ([@jalada](http://twitter.com/#!/jalada))
* [Handle error returns from lookup](https://github.com/jnunemaker/twitter/commit/0553cdbe262f006fae149309ce51a03985ed8fd2) ([@leshill](http://twitter.com/#!/leshill))
* [Use 'tude' parameter for attitudes](https://github.com/jnunemaker/twitter/commit/8db1bf9dadec3a660a281c94cab2fc335891ce30) ([@ALindeman](http://twitter.com/#!/ALindeman))
* [Add Enumerable mixin to Twitter::Search](https://github.com/jnunemaker/twitter/commit/c175c15d320d10db542ebb4cc13c5f5d583c89c4) ([@ALindeman](http://twitter.com/#!/ALindeman))

1.0.0 - November 18, 2010
-------------------------
* [Fix conditional inclusion of jruby-openssl in Ruby 1.9](https://github.com/jnunemaker/twitter/commit/e8e9b1d7232bf69ac5e217e2e18dc9c8e75f2fc4)
* [Allow users to pass in screen names with leading '@'](https://github.com/jnunemaker/twitter/commit/fc3af84e0d7358ddacf49acefe7d950ac11983e0)
* [UTF-8 encode <tt>Utils</tt> module](https://github.com/jnunemaker/twitter/commit/4a62f181c2ae7b931e17fcfa6532b3a3f0ed0c8e)
* [Copy-edit documentation](https://github.com/jnunemaker/twitter/commit/7873b0306d5fb1f27e4061cd024ab43589441fa4) ([@dianakimball](http://twitter.com/#!/dianakimball))
* [Add methods to <tt>Search</tt> class](http://github.com/jnunemaker/twitter/commit/1871913342a5621edfebb9a7c8be705608e082d5)
* [Changes to <tt>Search</tt> class](http://github.com/jnunemaker/twitter/commit/e769fabc0232cbbcb9d0fa5a07277fb9f50b17c8)
* [Add proxy support](http://github.com/jnunemaker/twitter/commit/1df33b7495093bc1f136d61b8aac9c9038414bc5)
* [Make <tt>#suggestions</tt> method consistent with Twitter API documentation](http://github.com/jnunemaker/twitter/commit/8393a06a9e8ca03be9adffdbfd042c176e2f6597)
* [Rename default user agent](http://github.com/jnunemaker/twitter/commit/2929e533f441bea2313882c4e0ed5593fe999491)
* [Make all global settings overrideable at the class level](http://github.com/jnunemaker/twitter/commit/66f3ac223d6f0822c8b3acd4cdcd8c84c8dacfe0)
* [Expose a property in EnhanceYourCalm for HTTP header "Retry-After"](http://github.com/jnunemaker/twitter/commit/7ab91f9d26351f52d3c803bb191d33bdacff5094) ([@duylam](http://twitter.com/#!/duylam))
* [Merge <tt>Base</tt>, <tt>Geo</tt>, <tt>Trends</tt>, and <tt>Unauthenticated</tt> into <tt>Client</tt> class](http://github.com/jnunemaker/twitter/commit/eb53872249634ee1f0179982b091a1a0fd9c0973) ([@laserlemon](http://twitter.com/#!/laserlemon))
* [Move examples into README](http://github.com/jnunemaker/twitter/commit/96600cb5611965788c41b3788668188d37e16803)
* [Rename <tt>Twitter.scheme</tt> to <tt>Twitter.protocol</tt>](http://github.com/jnunemaker/twitter/commit/512fcdfc22b796d39dd07c2dcc712aa48131d7c6)
* [Map access key/secret names to SimpleOAuth correctly](http://github.com/jnunemaker/twitter/commit/9fa5be3a9e0b7f7dcb4046314d8c6bc41f4f063d)
* [Improved error handling by separating HTTP 4xx errors from HTTP 5xx errors, so HTTP 4xx errors can be parsed first](http://github.com/jnunemaker/twitter/commit/f26e7875980a7b2b16285c31198601b92ac5cbb6)
* [Add tests for XML response format](http://github.com/jnunemaker/twitter/commit/54c4b36b8f9a5a0ad7c741e53409a03a7ddaade7)
* [Switch from httparty to faraday HTTP client library](http://github.com/jnunemaker/twitter/commit/80aff88dae11d64673fe4e025cc8f065a6796345)
* [Switch from oauth to simple_oauth for authentication](http://github.com/jnunemaker/twitter/commit/76cfe3749e56b2b486f2b5ffc9aa7f437cb2db29) ([@laserlemon](http://twitter.com/#!/laserlemon))
* [Handle errors in faraday middleware](http://github.com/jnunemaker/twitter/commit/466a0d9942d1c0c0c35c6302951087076ddf4b82#diff-2)
* [Add #NewTwitter methods and tests](http://github.com/jnunemaker/twitter/commit/0bfbf6352de9bdda2b93ed053a358c0cb8e78e8f)
* [Fix tests that assume position in a <tt>Hash</tt>](http://github.com/jnunemaker/twitter/commit/c9f7ed1d9106807aa6fb27d48a92f4b92d0594a7) ([@duncan](http://twitter.com/#!/duncan))
* [Enable SSL by default (add option to disable SSL)](http://github.com/jnunemaker/twitter/commit/c4f8907d6595f93d63bc84d6575920a14774e656)
* [Use HTTP DELETE method instead of HTTP POST for all destructive methods](http://github.com/jnunemaker/twitter/commit/0bfbf6352de9bdda2b93ed053a358c0cb8e78e8f)
* [Change the method signature for <tt>Base#users</tt> and <tt>Base#friendships</tt> to accept an <tt>Array</tt> and an options <tt>Hash</tt>](http://github.com/jnunemaker/twitter/commit/0bfbf6352de9bdda2b93ed053a358c0cb8e78e8f)
* [Add <tt>Twitter.profile_image</tt> method](http://github.com/jnunemaker/twitter/commit/e6645022aefdc11860fe88b45725a08bb24adf55) ([@ratherchad](http://twitter.com/#!/ratherchad))
* [Improve website style](http://github.com/jnunemaker/twitter/commit/4cdf4e76b6d71d5d4760b46d1a894c00929c0ba3) ([@rodrigo3n](http://twitter.com/#!/rodrigo3n))
* [Make request format configurable](http://github.com/jnunemaker/twitter/commit/d35d6447b25fa84447ae97558958431fa9f6aa29)

0.9.12 - September 25, 2010
---------------------------
* [Rename parameters to be less confusing](http://github.com/rorra/twitter/commit/cd7ea8de6663d6ed5ea22b590d39adc72646fc1e) ([@rorra](http://twitter.com/#!/rorra))
* [Update <tt>user</tt> method to match the Twitter API docs](http://github.com/jnunemaker/twitter/commit/cb31e4a26b20d93006d568fab50ccce5c4d1626f) ([@nerdEd](http://twitter.com/#!/nerdEd))
* [Add aliases for search methods](http://github.com/jnunemaker/twitter/commit/05dd3e5a058ef69f874cfe33ae35b01f574e549b)
* [Add <tt>Twitter.user_agent</tt> and <tt>Twitter.user_agent=</tt> methods](http://github.com/jnunemaker/twitter/commit/0fc68f1c52e3b754194fe8a9cfbd9d4499eacbe1)
* [Add <tt>Search#locale</tt> method](http://github.com/jnunemaker/twitter/commit/584bcf9eb896530a87e4122fb1a020c35744f0cf)

0.9.11 - September 24, 2010
---------------------------
* [Add a <tt>Search#filter</tt> method](http://github.com/jnunemaker/twitter/commit/0b37998055158d4fed0e3c296d8d2a42ac77d5d9) ([@pjdavis](http://twitter.com/#!/pjdavis))
* [Add test to ensure <tt>Search#fetch</tt> doesn't overwrite <tt>@query(:q)</tt>](http://github.com/jnunemaker/twitter/commit/2e05847cf70692b760c45dd54b6bad820176c9bd) ([@pjdavis](http://twitter.com/#!/pjdavis))
* [Add <tt>Search#retweeted</tt> and <tt>Search#not_retweeted</tt> methods](http://github.com/jnunemaker/twitter/commit/9ef83acdcbe682a8b5a325f89d566f7ef97fffc2) ([@levycarneiro](http://twitter.com/#!/levycarneiro))
* [Switch from YAJL to MultiJson](http://github.com/jnunemaker/twitter/commit/60a7cb179e77319e03c595850119b63fb413a53d) ([@MichaelRykov](http://twitter.com/#!/MichaelRykov))

0.9.10 - September 23, 2010
---------------------------
* [Specify Twitter API version for all REST API calls](http://github.com/jnunemaker/twitter/commit/76b1fa31588bbc20166464313027f75e3771e385)
* [Parse all responses with YAJL JSON parser](http://github.com/jnunemaker/twitter/commit/c477f368fde6161dbae59ea7bc7c7d182b15721b)
* [Ensure that users are tested](http://github.com/jnunemaker/twitter/commit/108019e83d745c23ebc92fc8a3f9f8c605b2e884) ([@duncan](http://twitter.com/#!/duncan))
* [Remove redgreen due to Ruby 1.9 incompatibility](http://github.com/jnunemaker/twitter/commit/83e1ea168da2e38c3f393972bf1d8eb665df2510) ([@duncan](http://twitter.com/#!/duncan))
* [Make all tests pass in Ruby 1.9](http://github.com/jnunemaker/twitter/commit/7bead60774fb118ef63fb1557976194848af6754) ([@duncan](http://twitter.com/#!/duncan))

0.9.9 - September 22, 2010
--------------------------
* [Bump dependency versions](http://github.com/jnunemaker/twitter/commit/ac8114c1f6ba2da20c2267d3133252c2ffc6b6a3)
* [Remove Basic Auth](http://github.com/jnunemaker/twitter/pull/56) ([@rodrigo3n](http://twitter.com/#!/rodrigo3n))
* [Flatten <tt>ids_or_usernames</tt> before iterating](http://github.com/jnunemaker/twitter/commit/956fb23f82cc1f91f6beefb24cf052cf48475a3f) ([@jacqui](http://twitter.com/#!/jacqui))
* [Add an example to list followers and friends sorted by followers count](http://github.com/jnunemaker/twitter/commit/fb57b27e8a48abcc82810fe476413e8b506cebe6) ([@danicuki](http://twitter.com/#!/danicuki))
* [Add optional query parameter to <tt>list_subscribers</tt>](http://github.com/jnunemaker/twitter/commit/a608d4088edf8772a3549326bed1124c9a2a123d)
* [Change trends endpoint to api.twitter.com/1/trends](http://github.com/jnunemaker/twitter/commit/39ff888b243ba57098589d4e304dd6dec877d05f)
* [Use Bundler](http://github.com/jnunemaker/twitter/commit/ebcb1d2c76d45f691cc90c880d13d19bc69a6f32)

0.9.8 - June 22, 2010
---------------------
* [Geo API](http://github.com/jnunemaker/twitter/commit/0e5aa205f9e29db434d84452f59694d9b64877d2) ([@anno](http://twitter.com/#!/anno))
* [Set <tt>api_endpoint</tt> for unauthenticated calls](http://github.com/jnunemaker/twitter/commit/ff20ecb4f4fef12c58572fb31e5c06162f8659d7) ([@earth2marsh](http://twitter.com/#!/earth2marsh))

0.9.7 - May 25, 2010
--------------------
* [Add <tt>api_endpoint</tt> option for Search](http://github.com/jnunemaker/twitter/commit/3c3d73fb8eedb5d322aeb1e4431d9936226fef9b)

0.9.6 - May 25, 2010
--------------------
* [Deprecated Basic Auth](http://github.com/jnunemaker/twitter/commit/878c09527037ab8ec5ac11a48afece61f03861e1)
* [Add <tt>api_endpoint</tt> option for OAuth](http://github.com/jnunemaker/twitter/commit/be937cf93db35f60cd47288aeea45afd2ab42288)

0.9.5 - April 21, 2010
----------------------
* [Saved searches](http://github.com/jnunemaker/twitter/commit/d5f0b5846b24468f323cc4f96e583fd267240615) ([@zmoazeni](http://twitter.com/#!/zmoazeni))
* [Handle null result sets in search more gracefully](http://github.com/jnunemaker/twitter/commit/f6d1f995dc7757dda4f4ac71dda2487d56d51c85) ([@sferik](http://twitter.com/#!/sferik))
* [Add <tt>report_spam</tt>](http://github.com/jnunemaker/twitter/commit/91275b549ebdd1cad795dff9f7a1772a4ca37749) ([@chrisrbailey](http://twitter.com/#!/chrisrbailey))
* [Tests for <tt>friendship_exists?</tt> method](http://github.com/jnunemaker/twitter/commit/e778d7f5f2bed73428c854d5d788d4a2d58540cd) ([@sferik](http://twitter.com/#!/sferik))
* [Replace JSON parser with YAJL JSON parser](http://github.com/jnunemaker/twitter/commit/1f480a85925025aec1ac5c91cfb45b4e74e4c9c3) ([@sferik](http://twitter.com/#!/sferik))
* [Cursors for lists](http://github.com/jnunemaker/twitter/commit/d283cefdbcaeee6005b0ec747e8d6bded14911b2) ([@zmoazeni](http://twitter.com/#!/zmoazeni))

0.9.4 - March 30, 2010
----------------------
* [Rolled back search API endpoint to get around rate limiting issues](http://github.com/jnunemaker/twitter/commit/f9c7af99b4560f39b3542582934ae07955b6c9cc) ([@secobarbital](http://twitter.com/#!/secobarbital))

0.9.3 - March 23, 2010
----------------------
* [Restore Ruby 1.8.6 compatibility](http://github.com/jnunemaker/twitter/commit/b725b1b8a105fa3488783cef43b7db8b0dbb7c99) ([@raykrueger](http://twitter.com/#!/raykrueger))

0.9.2 - March 24, 2010
----------------------
* [Make error handling consistent between authenticated and unauthenticated method calls](http://github.com/jnunemaker/twitter/commit/f62a1502ba9c4a764d25a4179982fabd3bff2210) ([@sferik](http://twitter.com/#!/sferik))
* [Test error handling for unauthenticated methods](http://github.com/jnunemaker/twitter/commit/4de5c9212142ceb0206f979755e6e151280b16b9) ([@sferik](http://twitter.com/#!/sferik))

0.9.1 - March 23, 2010
----------------------
* [Add cursor to <tt>lists</tt> method](http://github.com/jnunemaker/twitter/commit/a16ad354be4fae3d3f86207d8c5ae8b4c2a11b52) ([@sferik](http://twitter.com/#!/sferik))
* [Add Twitter API version to trends method calls](http://github.com/jnunemaker/twitter/commit/6f23c5eb3ffdac6eac65fa2b6d36f08aa7b6e1fb) ([@sferik](http://twitter.com/#!/sferik))
* [Add Twitter API version to unauthenticated method calls](http://github.com/jnunemaker/twitter/commit/fb895cc7e645499826dcc96e2cf8727c94eac83f) ([@sferik](http://twitter.com/#!/sferik))
* [Remove rubygems dependencies](http://github.com/jnunemaker/twitter/commit/0f7a9ee4a1aee45bfb7136a0f6f48f9b7632e663) ([@sferik](http://twitter.com/#!/sferik))

0.9.0 - March 20, 2010
----------------------
* [Add <tt>Base#retweeters_of</tt> method](http://github.com/jnunemaker/twitter/commit/7de2d6204028b6741ce7a72b12efe868e074331c)
* [Add <tt>result_type</tt> to search for popular/recent results](http://github.com/jnunemaker/twitter/commit/c32fa818f8331a7ff02f04f6cba8739423902029)
* [Add <tt>users</tt> method for bulk user lookup](http://github.com/jnunemaker/twitter/commit/5723b60f042d98b630040fa076ac86e9b735dee8) ([@sferik](http://twitter.com/#!/sferik))
* [Add Twitter API version to authenticated method calls](http://github.com/jnunemaker/twitter/commit/69d4df515fe95f727221dad19b92665dc24f06d0) ([@sferik](http://twitter.com/#!/sferik))
* [Search exclusions](http://github.com/jnunemaker/twitter/commit/cb05e77adb2d771170d731ad2e55ba17bcb13766) ([@abozanich](http://twitter.com/#!/abozanich))

0.8.6 - March 11, 2010
----------------------
* [Bump httparty version](http://github.com/jnunemaker/twitter/commit/643517da3d12442883d90918b280e968809a4750) ([@dewski](http://twitter.com/#!/dewski))

0.8.5 - February 21, 2010
-------------------------
* [Add <tt>Search#next_page?</tt> and <tt>Search#fetch_next_page</tt> methods](http://github.com/jnunemaker/twitter/commit/767ddaa62e8fa9e3872ddd17323f323d9f1393e4) ([@cyu](http://twitter.com/#!/cyu))

0.8.4 - February 11, 2010
-------------------------
* [Add <tt>query</tt> parameter to <tt>membership</tt> method](http://github.com/jnunemaker/twitter/commit/f09b3121d4c721c34f40a11580a7a1d4ffc0df22) ([@mingyeow](http://twitter.com/#!/mingyeow))
* [Add <tt>Search#phrase</tt> method](http://github.com/jnunemaker/twitter/commit/e3e8f7e4b1ea8a315f935805e409a3fff6a5483d) ([@zagari](http://twitter.com/#!/zagari))
* [Add <tt>Trends#available</tt> and <tt>Trends#location</tt> methods](http://github.com/jnunemaker/twitter/commit/39b8d8dd3bb25cb5cd081cae23486fb47c25ec8f)

0.8.3 - January 29, 2010
------------------------
* [Add <tt>Twitter.list_timeline</tt> method](http://github.com/jnunemaker/twitter/commit/aed3a298b613a508bb9caf93afc7f12c50626ad7) ([@spastorino](http://twitter.com/#!/spastorino))

0.8.2 - January 21, 2010
------------------------
* [Add <tt>Base#update_profile_image</tt> method](http://github.com/jnunemaker/twitter/commit/10afe76daef3a2b8e10917b9550724cc9c3a6c19) ([@urajat](http://twitter.com/#!/urajat))

0.8.1 - January 12, 2010
------------------------
* [Add <tt>Twitter.timeline</tt> method](http://github.com/jnunemaker/twitter/commit/dc26a0c9b5a6a98aec4ca9c0a48333e665c9bf18)

0.8.0 - December 18, 2009
-------------------------
* [Make API endpoint configurable to use services like Tumblr](http://github.com/jnunemaker/twitter/commit/c5550f1317538638b754d6b0dbbb372e069b5580)

0.7.11 - December 16, 2009
--------------------------
* [Add list timeline paging](http://github.com/jnunemaker/twitter/commit/591d31a45b1a360d5743d2bf3966e7e9b563b9b7) ([@kchen1](http://twitter.com/#!/kchen1))

0.7.10 - December 12, 2009
--------------------------
* [Add <tt>Base#blocks</tt> and <tt>Base#blocking</tt> methods](http://github.com/jnunemaker/twitter/commit/0eb099001f060431c56c1884d86abb2e53a09c6d)

0.7.9 - December 1, 2009
-----------------------
* [Add <tt>Base#retweets</tt> method](http://github.com/jnunemaker/twitter/commit/a1a834575000bbb8fb430632b6bf88e19daeb8fb) ([@ivey](http://twitter.com/#!/ivey))

0.7.8 - November 30, 2009
------------------------
* [Use <tt>cursor</tt> parameter to <tt>list_members</tt> method](http://github.com/jnunemaker/twitter/commit/9f393f05c127623f4c58a68e2246a3553f225349) ([@ivey](http://twitter.com/#!/ivey))

0.7.7 - November 29, 2009
------------------------
* [Fix bug in <tt>list_remove_member</tt> when using OAuth](http://github.com/jnunemaker/twitter/commit/b20b770af3d6594f8e551cade3cfbd58a0647c2d)
* [Bump oauth dependency to version 0.3.6](http://github.com/jnunemaker/twitter/commit/3eeed693180d15ba4ca2370c41bd5547f715fc88)
* [Add <tt>Base#update_profile_background</tt> method](http://github.com/jnunemaker/twitter/commit/3eeed693180d15ba4ca2370c41bd5547f715fc88) ([@kev_in](http://twitter.com/#!/kev_in))
* [Add <tt>Base#blocked_ids</tt> method](http://github.com/jnunemaker/twitter/commit/2a5046500eb30141f55552d9b151857d08a1436a) ([@rizwanreza](http://twitter.com/#!/rizwanreza))
* [Add <tt>Search#since_date</tt> and <tt>Search#until_date</tt> methods](http://github.com/jnunemaker/twitter/commit/9dcd340817224fa34fcb515f79a846886ffa1427) ([@jschairb](http://twitter.com/#!/jschairb))

0.7.6 - November 25, 2009
------------------------
* [Add <tt>Base#home_timeline</tt> method](http://github.com/jnunemaker/twitter/commit/2de3786e75e6a1725572d3f08f6886f64e507851) ([@coderifous](http://twitter.com/#!/coderifous))

0.7.5 - November 17, 2009
------------------------
* [Use Hashie instead of Mash to avoid conflicts with extlib](http://github.com/jnunemaker/twitter/commit/365f8378b45c93ed6219ac49afec5c7f7eb85fe6) ([@hassox](http://twitter.com/#!/hassox))

0.7.4 - November 16, 2009
-------------------------
* [Support for user search](http://github.com/jnunemaker/twitter/commit/54e046924431a08e3dfce06f571f71ebb76f7bbd)

0.7.3 - November 5, 2009
------------------------
* [Add <tt>Base#list_subscriptions</tt> method](http://github.com/jnunemaker/twitter/commit/2273c8a4e7c5d496922fc34551b46b22d30b68aa) ([@christospappas](http://twitter.com/#!/christospappas))

0.7.2 - November 5, 2009
------------------------
* [Add <tt>Base#friendship_show</tt> method](http://github.com/jnunemaker/twitter/commit/693f95a6a19dd51c047078ef969e14357930bcd7) ([@dcrec1](http://twitter.com/#!/dcrec1))

0.7.1 - November 4, 2009
------------------------
* [Bump dependency versions](http://github.com/jnunemaker/twitter/commit/d6bf8c5693f0ec4eedd641b97a7e6f0fdce75e2c)

0.7.0 - October 31, 2009
------------------------
* [Add support for lists](http://github.com/jnunemaker/twitter/commit/be4bffd79c2bdcfd2988ef6a65cbca8a8f6abd6d)

0.6.14 - August 16, 2009
------------------------
* [Lower oauth dependency to version 0.3.4 as people are complaining about 0.3.5](http://github.com/jnunemaker/twitter/commit/dd144c377bc888388099e029a0e1505a66392bb1)

0.6.13 - July 27, 2009
----------------------
* [Bump oauth dependency to version >= 0.3.5](http://github.com/jnunemaker/twitter/commit/555ae1fc13146b74b8df0346caea1a6b065b344f)

0.6.12 - June 26, 2009
----------------------
* [Fix <tt>fakeweb</tt> test issue](http://github.com/jnunemaker/twitter/commit/cdd9dba19f6edc21f1b7eefb66db133dec682423) ([@obie](http://twitter.com/#!/obie))
* [Add <tt>Search#user_agent</tt> method](http://github.com/jnunemaker/twitter/commit/e8fbad6a9cfdcfaad4938f7243fc971a1ea8ac8c)

0.6.11 - May 18, 2009
---------------------
* [Add the ability to sign in with Twitter instead of authorizing](http://github.com/jnunemaker/twitter/commit/68b6252a21e7e773d108027f693b8378593e21ad)

0.6.10 - May 18, 2009
---------------------
* [Add <tt>Trends#current</tt>](http://github.com/jnunemaker/twitter/commit/549f34903be38232c24044d9972629a86a0503a4), [<tt>Trends#daily</tt>, and <tt>Trends#weekly</tt> methods](http://github.com/jnunemaker/twitter/commit/dc8046aea5794303f6f36622221a412a4e80f9a8)

0.6.9 - May 17, 2009
--------------------
* [Bump oauth dependency to version 0.3.4](http://github.com/jnunemaker/twitter/commit/88d4612b50d2be7cc300120278d53c80265e8780)

0.6.8 - April 23, 2009
----------------------
* [Fix httparty dependency](http://github.com/jnunemaker/twitter/commit/44aa418a22233c84cea1dae74b158cd490589b10)

0.6.7 - April 23, 2009
----------------------
* [Bump httparty dependency to version 0.4.3 which allows <tt>response.message</tt> and fixes errors that the lack of <tt>response.message</tt> was causing](http://github.com/jnunemaker/twitter/commit/a630b1c77792641794745d2f3cbba6c64d168d62)

0.6.6 - April 16, 2009
----------------------
* [Add <tt>query</tt> parameter to <tt>user</tt> method](http://github.com/jnunemaker/twitter/commit/33ae7dbd7593235efb8ea1df13638891b621244f)
* [Add <tt>ssl</tt> optional parameter to use HTTPS instead of HTTP for <tt>HTTPAuth</tt>](http://github.com/jnunemaker/twitter/commit/f46cdf9ce957b03539bd4dc76a83ce439535d349)
* [Add <tt>Twitter.status</tt>, <tt>Twitter.friend_ids</tt>, and <tt>Twitter.follower_ids</tt> methods](http://github.com/jnunemaker/twitter/commit/55813617c5b4cf672800bf7f9e7473904e3c3194)

0.6.5 - April 15, 2009
----------------------
* [Fix <tt>friend_ids</tt> and <tt>follower_ids</tt> bombing on mashing](http://github.com/jnunemaker/twitter/commit/f01c2878033cd6afc1e718f2140c82b9708e5603)

0.6.4 - April 14, 2009
----------------------
* [More explicit about dependency versions in gemspec and when requiring](http://github.com/jnunemaker/twitter/commit/5ce3eeb25c5b8bcd8caa8704c5d125174781781d)

0.6.3 - April 14, 2009
----------------------
* [Add <tt>Twitter.user</tt> method](http://github.com/jnunemaker/twitter/commit/cb46975eaa8aa7e02ad798ba8b7b62017f15604c)

0.6.2 - April 14, 2009
----------------------
* [Add <tt>Search#max</tt> method](http://github.com/jnunemaker/twitter/commit/e79cc1fdb306da24462c6617b118e03ccbead9f1)

0.6.1 - April 12, 2009
----------------------
* [Rename one of the two <tt>friend_ids</tt> methods to <tt>follower_ids</tt>](http://github.com/jnunemaker/twitter/commit/051d19db49dce2422d06181c5a3b595e3a9b85b3)

0.6.0 - April 11, 2009
----------------------
* [Add HTTP authentication](http://github.com/jnunemaker/twitter/commit/d713ecfbe80edde688009fa6bfbf32a2de687a39)

0.5.3 - April 10, 2009
----------------------
* [Only send <tt>follow</tt> parameter to Twitter if <tt>follow</tt> is true for calls to <tt>friendship_create</tt>](http://github.com/jnunemaker/twitter/commit/5ebf39c0538a3dfd48c6a1dbdf8558305737ce69)

0.5.2 - April 8, 2009
---------------------
* [Add mash as an install dependency](http://github.com/jnunemaker/twitter/commit/a8693b27791e966736415cb90335600d075f60dd)
* [Add options to <tt>search</tt>](http://github.com/jnunemaker/twitter/commit/096d56ed9a62a0ea53bfe3a8df588ddef71df1c9)
* [Add missing variables in exception raising](http://github.com/jnunemaker/twitter/commit/e21a4f69c68d28148045e7c98ce1841d72994e1e)
* [Add development dependencies to <tt>Rakefile</tt> to make that more explicit](http://github.com/jnunemaker/twitter/commit/de57b1c2834653ea4c336ed426ee8fbbebcd80b2) ([@technomancy](http://twitter.com/#!/technomancy))
* [Add workaround for <tt>Mash#hash</tt> that allows using return objects in sets and such](http://github.com/jnunemaker/twitter/commit/2da491308766e82c797c7801bdc3a440b7f8d719) ([@technomancy](http://twitter.com/#!/technomancy))

0.5.1 - April 5, 2009
---------------------
* [Add data error hash returned from Twitter to a few of the exceptions to help with debugging](http://github.com/jnunemaker/twitter/commit/72d46c4804a30b28ab351a5a0d37d6bc664e577e)
* [Fix bug with <tt>friendship_exists?</tt> throwing a stringify keys error because it was returning <tt>true</tt> or <tt>false</tt> instead of a <tt>Hash</tt> or <tt>Array</tt>](http://github.com/jnunemaker/twitter/commit/1e9def65277125f23739be034abd4059a42d2b87)

0.5.0 - April 3, 2009
---------------------
* [Proxy no longer supported (someone please add it back in, I never use proxies)](http://github.com/jnunemaker/twitter/commit/dd2445e3e2c97f38b28a3f32ea902536b3897adf)
* [Identica support killed with an axe (nothing against them but I don't use it)](http://github.com/jnunemaker/twitter/commit/dd2445e3e2c97f38b28a3f32ea902536b3897adf)
* [CLI shot to death (will be reborn at a later date using OAuth and its own gem)](http://github.com/jnunemaker/twitter/commit/dd2445e3e2c97f38b28a3f32ea902536b3897adf)

0.4.3 - February 21, 2009
-------------------------
* [Make <tt>verify_credentials</tt> return a <tt>Twitter::User</tt> rather than a Hpricot doc](http://github.com/jnunemaker/twitter/commit/6a8efc464dcb174e41b2eb0197a79e778dae1428)

0.4.2 - February 10, 2009
-------------------------
* [Add <tt>Base#friend_ids</tt> and <tt>Base#follower_ids</tt> methods](http://github.com/jnunemaker/twitter/commit/b70718cc31684af6ce2d1c2a11adaaba29ea7b92) ([@joshowens](http://twitter.com/#!/joshowens))

0.4.1 - January 1, 2009
-----------------------
* [Add better exception handling](http://github.com/jnunemaker/twitter/commit/2b85bed874902d184e5d53c0a0bd249fd1ed3b8b) ([@billymeltdown](http://twitter.com/#!/billymeltdown))
* [Add <tt>Search#page</tt> method](http://github.com/jnunemaker/twitter/commit/977023126fbe7fdf13af53d840ca3b6807cd2d85) ([@ivey](http://twitter.com/#!/ivey))
* [Add an option to display tweets on CLI in reverse chronological order](http://github.com/jnunemaker/twitter/commit/40d2f1ae631dce3c31c6a13d295989e945b22622) ([@coderdaddy](http://twitter.com/#!/coderdaddy))
* [Add <tt>in_reply_to_status_id</tt> option for replying to statuses](http://github.com/jnunemaker/twitter/commit/2ecceda9fa74d486e3ba62edba7fa42a443191fa) ([@anthonycrumley](http://twitter.com/#!/anthonycrumley))
* [Fix a bug where the [@config was improperly set](http://github.com/jnunemaker/twitter/commit/9c5fd0f0a0186638aae189e28a3a0d0d20e7d3d5) ([@pope](http://twitter.com/#!/pope))
* [Fix <tt>verify_credentials</tt> to include a format](http://github.com/jnunemaker/twitter/commit/bf6f783e8867148a056d130f00a03679ea9b414b) ([@dlsspy](http://twitter.com/#!/dlsspy))

0.4.0 - December 23, 2008
-------------------------
* [Remove Active Support dependency and switched to echoe for gem management](http://github.com/jnunemaker/twitter/commit/fbb792561ea2aba8c8e7abb946d2a5e6e3d64fb0)
* [Remove CLI dependencies](http://github.com/jnunemaker/twitter/commit/906d34db1a81314bb8929d9b5ee61519ed6dc080)

0.3.7 - August 26, 2008
-----------------------
* [Fix <tt>source</tt> parameter not getting through](http://github.com/jnunemaker/twitter/commit/e3743cf22df3ad9406bf8c2e4425f30680606283)

0.3.6 - August 11, 2008
-----------------------
* [Refactor the remaining methods that were not using <tt>request</tt> to use it](http://github.com/jnunemaker/twitter/commit/8a802c4b461be0d4d7f374888591a9af6ef8b8d2)

0.3.5 - August 4, 2008
----------------------
* [Remove sqlite-ruby dependency](http://github.com/jnunemaker/twitter/commit/9277e832daf9539e70f446b8b4f7093d8eb98484)

0.3.4 - August 3, 2008
----------------------
* [Add <tt>Search</tt> class](http://github.com/jnunemaker/twitter/commit/538a5d4b1a72ed2bf97404704699f498ab082ca9)

0.3.3 - August 3, 2008
----------------------
* [Add Identica support](http://github.com/jnunemaker/twitter/commit/ed06aaf27eea8852198200eb3db510d56508e727) ([@dlsspy](http://twitter.com/#!/dlsspy))
* [Update methods to <tt>POST</tt> instead of <tt>GET</tt>](http://github.com/jnunemaker/twitter/commit/ed06aaf27eea8852198200eb3db510d56508e727)

0.3.2 - July 26, 2008
----------------------
* [Add the CLI gems as dependencies until it is separated from the API wrapper](http://github.com/jnunemaker/twitter/commit/52af6fd83bb2e72b90abd6114e264a88431cfb34)
* [Add cleaner CLI errors for no active account or no accounts at all](http://github.com/jnunemaker/twitter/commit/dbc9e57d0a66ee585893b0b5955078575effc616)
* [Add <tt>username</tt> and <tt>password</tt> parameters to <tt>add</tt> method](http://github.com/jnunemaker/twitter/commit/013b48229786c1080ee79a490e731f4b1811a7e4)

0.3.1 - July 23, 2008
---------------------
* [Add <tt>open</tt> method to CLI](http://github.com/jnunemaker/twitter/commit/84e77a1d515f762d7a24f697786f5959d4f1cc2e)
* [Add <tt>-f</tt> option to timeline and replies which ignores the <tt>since_id</tt> and shows all results](http://github.com/jnunemaker/twitter/commit/84e77a1d515f762d7a24f697786f5959d4f1cc2e)
* [Add <tt>clear_config</tt> to remove all cached values](http://github.com/jnunemaker/twitter/commit/84e77a1d515f762d7a24f697786f5959d4f1cc2e)
* [Improved the output of <tt>timelines</tt> and <tt>replies</tt>](http://github.com/jnunemaker/twitter/commit/84e77a1d515f762d7a24f697786f5959d4f1cc2e)

0.3.0 - July 22, 2008
---------------------
* [Support multiple accounts in CLI and switching between them](http://github.com/jnunemaker/twitter/commit/35eddef783492990bf0bebcae1f5891a556988e4)
* [Make <tt>d</tt> method accept stdin](http://github.com/jnunemaker/twitter/commit/25ddfe33a10a252ff7d9ba74d4d16e3e25719661)
* [Add <tt>Status#source</tt>, <tt>Status#truncated</tt>, <tt>Status#in_reply_to_status_id</tt>, <tt>Status#in_reply_to_user_id</tt>, <tt>Status#favorited</tt>, and <tt>User#protected</tt> methods](http://github.com/jnunemaker/twitter/commit/d02d233000667c74101571f9362532a57715ae4e)
* [Add <tt>Base#friendship_exists?</tt>, <tt>Base#update_location</tt>, <tt>Base#update_delivery_device</tt>, <tt>Base#favorites</tt>, <tt>Base#create_favorite</tt>, <tt>Base#destroy_favorite</tt>, <tt>Base#block</tt>, and <tt>Base#unblock</tt> methods](http://github.com/jnunemaker/twitter/commit/eeca67c5693dc175cf1990c2657a6efd8c4cbd6d)
* [Rewrite methods that had <tt>since</tt> or <tt>lite</tt> parameters to use a <tt>Hash</tt>](http://github.com/jnunemaker/twitter/commit/eeca67c5693dc175cf1990c2657a6efd8c4cbd6d)

0.2.7 - June 29, 2008
---------------------
* [Add <tt>Base#rate_limit_status</tt> method](http://github.com/jnunemaker/twitter/commit/2b5325b1875574805fde77f30d0df84e423272e5) ([@danielmorrison](http://twitter.com/#!/danielmorrison))
* [Add <tt>source</tt> parameter to <tt>Base#post</tt>](http://github.com/jnunemaker/twitter/commit/215b2ca687014e042f991192281ea1dfbe100665)
* [Add <tt>twittergem</tt> as the source when posting from the command-line interface](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176)
* [Raise <tt>Twitter::RateExceeded</tt> when you hit your limit](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176) ([@jimoleary](http://twitter.com/#!/jimoleary))
* [Raise <tt>Twitter::Unavailable</tt> when Twitter returns 503](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176)
* [Make <tt>Twitter::CantConnect</tt> messages more descriptive](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176)
* [Make quoting your message optional when posting from the command-line interface](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176) ([@bcaccinolo](http://twitter.com/#!/bcaccinolo))
* [Alias <tt>post</tt> to <tt>p</tt> on the command-line interface](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176) ([@bcaccinolo](http://twitter.com/#!/bcaccinolo))
* [Unescape HTML and add color to the command-line interface](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176) ([@mileszs](http://twitter.com/#!/mileszs))
* [Add gemspec](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176) ([@technoweenie](http://twitter.com/#!/technoweenie), [@mileszs(http://twitter.com/#!/mileszs))
* [Fix stack trace error on first command-line operation](http://github.com/jnunemaker/twitter/commit/d94b6bdb23dd27ff25cf170cd7ceb5610187d176) ([@mrose2n](http://twitter.com/#!/mrose2n))

0.2.6 - April 2, 2008
---------------------
* [Found a simpler way of doing <tt>stdin</tt> without any extra gem dependencies](http://github.com/jnunemaker/twitter/commit/2ef6c3e7280b64d5d4a956ca245e631b126001b0)

0.2.5 - April 2, 2008
---------------------
* [Command-line interface can use <tt>stdin</tt> for posting](http://github.com/jnunemaker/twitter/commit/d4e710bd3184f33775bf969b0993cbc9dff0ed50) ([@reclusive_geek](http://twitter.com/#!/reclusive_geek))
        $ twitter post 'test without stdin' # => twitters: test without stdin
        $ echo 'test with stdin' | twitter post 'and an argv(1)' # => twitters: test with stdin and an argv(1)
        $ echo 'test with stdin without any argv(1)' | twitter post # => twitters: test with stdin without any argv(1)

0.2.4 - March 31, 2008
----------------------
* [Add <tt>lite</tt> parameter to <tt>friends</tt> and <tt>followers</tt> methods, which doesn't include the user's current status](http://github.com/jnunemaker/twitter/commit/0de3901258de5b2a4a3fda308e495ee373d07ea6) ([@danielmorrison](http://twitter.com/#!/danielmorrison))
* [Update <tt>since</tt> parameter to use HTTP header](http://github.com/jnunemaker/twitter/commit/90b5b5ebb2a7d94a278e3ff374e4fde4cf850234) ([@danielmorrison](http://twitter.com/#!/danielmorrison))
* [Add <tt>since</tt> parameter on <tt>timeline</tt> and <tt>replies</tt> methods](http://github.com/jnunemaker/twitter/commit/90b5b5ebb2a7d94a278e3ff374e4fde4cf850234) ([@danielmorrison](http://twitter.com/#!/danielmorrison))

0.2.3 - January 16, 2008
------------------------
* [Add <tt>d</tt> to the command-line interface](http://github.com/jnunemaker/twitter/commit/a9ecddd3323ef202248dae59d049b00b88b76b4e) ([@humbucker](http://twitter.com/#!/humbucker))
* [Add progress dots while waiting for confirmation when Twitter is being slow](http://github.com/jnunemaker/twitter/commit/02a24d9042f3fa0235759fbbd6f34ea639a01578) ([@HendyIrawan](http://twitter.com/#!/HendyIrawan))

0.2.2 - January 16, 2008
------------------------
* [Add <tt>Base#leave</tt> and <tt>Base#follow</tt> methods](http://github.com/jnunemaker/twitter/commit/4878689063574ad88ea76343387094fc634ccead)

0.2.1 - October 23, 2007
------------------------

0.2.0 - August 4, 2007
------------------------
* [Alias <tt>direct_messages</tt> to <tt>received_messages</tt>](http://github.com/jnunemaker/twitter/commit/c2d8c55516747627452224af8faecc15ee6b5fd4)
* [Add <tt>Base#sent_messages</tt>, <tt>Base#create_friendship</tt>, <tt>Base#destroy_friendship</tt>, <tt>Base#featured</tt>, <tt>Base#replies</tt>, <tt>Base#destroy</tt>, and <tt>Base#status</tt> methods](http://github.com/jnunemaker/twitter/commit/c2d8c55516747627452224af8faecc15ee6b5fd4)
* [Add Active Support dependency](http://github.com/jnunemaker/twitter/commit/c2d8c55516747627452224af8faecc15ee6b5fd4)
* [Add <tt>Base#d</tt> method](http://github.com/jnunemaker/twitter/commit/139a820de0bcc97ece7e33435535985555231bc8) ([@jnewland](http://twitter.com/#!/jnewland))
* [Fix <tt>since</tt> parameter in <tt>Base#direct_messages</tt> method](http://github.com/jnunemaker/twitter/commit/41a9006be9221d7305752639ac4440b3a8859cd0) ([@jnewland](http://twitter.com/#!/jnewland))

0.1.1 - May 20, 2007
--------------------
* [Add support for Hpricot 0.5+](http://github.com/jnunemaker/twitter/commit/4aa2fabaa62c60e9f11f29510db10b6ed406e510) ([@erebor](http://twitter.com/#!/erebor))

0.1.0 - March 31, 2007
----------------------
* [Add <tt>Base#d</tt> method](http://github.com/jnunemaker/twitter/commit/13e031f8d2e8db6ca8ace18a25886fb690d580d2)
* [Add <tt>Base#direct_messages</tt> method](http://github.com/jnunemaker/twitter/commit/0f4d699a5310dc8a4e2997b82853f5466292b320)
* [Add <tt>Base#featured</tt> and <tt>Base#friends_for</tt> methods](http://github.com/jnunemaker/twitter/commit/21ca95ffa3f42aaf7728c3d5c2aa5f1f9ed84fe7)
* [Add tests](http://github.com/jnunemaker/twitter/commit/ff1ae65766109c75f80c4b15797e12a69d7c29ad)
* [Remove <tt>relative_created_at</tt>](http://github.com/jnunemaker/twitter/commit/ff1ae65766109c75f80c4b15797e12a69d7c29ad)

0.0.5 - March 12, 2007
----------------------
* [Code cleanup](http://github.com/jnunemaker/twitter/commit/abd6eb31089975e3dc65f7e0bb4156feacc97a1c)

0.0.4 - January 20, 2007
------------------------
* [Add <tt>User#location</tt>, <tt>User#description</tt>, <tt>User#url</tt>, and <tt>User#profile_image_url</tt> methods](http://github.com/jnunemaker/twitter/commit/e6737ec8b07b9fd1ffd96a21074a100a6fb3cf7e) ([@al3x](http://twitter.com/#!/al3x))

0.0.3 - December 17, 2006
-------------------------
* [Make error message more informative](http://github.com/jnunemaker/twitter/commit/1763cd85c4fd85cde6815cc7c1b74937dd7aeeaf)

0.0.2 - November 26, 2006
-------------------------
* Add command-line options for <tt>friend</tt> and <tt>follower</tt>
* Improved docs

0.0.1 - November 26, 2006
-------------------------
* [Initial release](http://github.com/jnunemaker/twitter/commit/cd7aecde450157ae2ec0c07a2171d7149bebb74a)
