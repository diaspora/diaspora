describe('app.Router', function () {
  describe('followed_tags', function() {
    it('decodes name before passing it into TagFollowingAction', function () {
      var followed_tags = spyOn(app.router, 'followed_tags').andCallThrough();
      var tag_following_action = spyOn(app.views, 'TagFollowingAction').andCallFake(function(data) {
        return {render: function() { return {el: ""}}};
      });
      spyOn(window.history, 'pushState').andCallFake(function (data, title, url) {
        var route = app.router._routeToRegExp("tags/:name");
        var args = app.router._extractParameters(route, url.replace(/^\//, ""));
        app.router.followed_tags(args[0]);
      });
      window.preloads = {tagFollowings: []};
      app.router.navigate('/tags/'+encodeURIComponent('օբյեկտիվ'));
      expect(followed_tags).toHaveBeenCalled();
      expect(tag_following_action).toHaveBeenCalledWith({tagText: 'օբյեկտիվ'});
    });

    it('navigates to the downcase version of the corresponding tag', function () {
      var followed_tags = spyOn(app.router, 'followed_tags').andCallThrough();
      var tag_following_action = spyOn(app.views, 'TagFollowingAction').andCallFake(function(data) {
        return {render: function() { return {el: ""}}};
      });
      spyOn(window.history, 'pushState').andCallFake(function (data, title, url) {
        var route = app.router._routeToRegExp("tags/:name");
        var args = app.router._extractParameters(route, url.replace(/^\//, ""));
        app.router.followed_tags(args[0]);
      });
      window.preloads = {tagFollowings: []};
      app.router.navigate('/tags/'+encodeURIComponent('SomethingWithCapitalLetters'));
      expect(followed_tags).toHaveBeenCalled();
      expect(tag_following_action).toHaveBeenCalledWith({tagText: 'somethingwithcapitalletters'});
    });
  });

  describe("when routing to /stream and hiding inactive stream lists", function() {
    it('calls hideInactiveStreamLists', function () {
      var hideInactiveStreamLists = spyOn(app.router, 'hideInactiveStreamLists').andCallThrough();
      spyOn(window.history, 'pushState').andCallFake(function (data, title, url) {
        var route = app.router._routeToRegExp("stream");
        var args = app.router._extractParameters(route, url.replace(/^\//, ""));
        app.router.stream(args[0]);
      });
      app.router.navigate('/stream');
      expect(hideInactiveStreamLists).toHaveBeenCalled();
    });

    it('hides the aspects list', function(){
      var aspects = new app.collections.Aspects([{ name: 'Work', selected: true  }]);
      var aspectsListView = new app.views.AspectsList({collection: aspects});
      var hideAspectsList = spyOn(aspectsListView, 'hideAspectsList').andCallThrough();
      app.router.aspects_list = aspectsListView;
      spyOn(window.history, 'pushState').andCallFake(function (data, title, url) {
        var route = app.router._routeToRegExp("stream");
        var args = app.router._extractParameters(route, url.replace(/^\//, ""));
        app.router.stream(args[0]);
      });
      app.router.navigate('/stream');
      expect(hideAspectsList).toHaveBeenCalled();
    });

    it('hides the followed tags view', function(){
      var tagFollowings = new app.collections.TagFollowings();
      var followedTagsView = new app.views.TagFollowingList({collection: tagFollowings});
      var hideFollowedTags = spyOn(followedTagsView, 'hideFollowedTags').andCallThrough();
      app.router.followedTagsView = followedTagsView;
      spyOn(window.history, 'pushState').andCallFake(function (data, title, url) {
        var route = app.router._routeToRegExp("stream");
        var args = app.router._extractParameters(route, url.replace(/^\//, ""));
        app.router.stream(args[0]);
      });
      app.router.navigate('/stream');
      expect(hideFollowedTags).toHaveBeenCalled();
    });
  });
});
