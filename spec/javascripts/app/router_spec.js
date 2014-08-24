describe('app.Router', function () {
  describe('followed_tags', function() {
    beforeEach(function() {
      factory.preloads({tagFollowings: []});
    });

    it('decodes name before passing it into TagFollowingAction', function () {
      var followed_tags = spyOn(app.router, 'followed_tags').and.callThrough();
      var tag_following_action = spyOn(app.views, 'TagFollowingAction').and.callFake(function(data) {
        return {render: function() { return {el: ""}}};
      });

      app.router.followed_tags(encodeURIComponent('օբյեկտիվ'));
      expect(followed_tags).toHaveBeenCalled();
      expect(tag_following_action).toHaveBeenCalledWith({tagText: 'օբյեկտիվ'});
    });

    it('navigates to the downcase version of the corresponding tag', function () {
      var followed_tags = spyOn(app.router, 'followed_tags').and.callThrough();
      var tag_following_action = spyOn(app.views, 'TagFollowingAction').and.callFake(function(data) {
        return {render: function() { return {el: ""}}};
      });

      app.router.followed_tags('SomethingWithCapitalLetters');
      expect(followed_tags).toHaveBeenCalled();
      expect(tag_following_action).toHaveBeenCalledWith({tagText: 'somethingwithcapitalletters'});
    });
  });

  describe("when routing to /stream and hiding inactive stream lists", function() {
    var router;
    var aspects;
    var tagFollowings;

    beforeEach(function() {
      router = new app.Router();
    });

    it('hides the aspects list', function(){
      setFixtures('<div id="aspects_list" />');
      aspects = new app.collections.Aspects([
        factory.aspectAttrs({selected:true}),
        factory.aspectAttrs()
      ]);
      var aspectsListView = new app.views.AspectsList({collection: aspects}).render();
      router.aspects_list = aspectsListView;

      expect(aspectsListView.$el.html()).not.toBe("");
      router.stream();
      expect(aspectsListView.$el.html()).toBe("");
    });

    it('hides the followed tags view', function(){
      tagFollowings = new app.collections.TagFollowings();
      var followedTagsView = new app.views.TagFollowingList({collection: tagFollowings}).render();
      router.followedTagsView = followedTagsView;

      expect(followedTagsView.$el.html()).not.toBe("");
      router.stream();
      expect(followedTagsView.$el.html()).toBe("");
    });
  });

  describe("bookmarklet", function() {
    it('routes to bookmarklet even if params have linefeeds', function()  {
      router = new app.Router();
      var route = jasmine.createSpy('bookmarklet route');
      router.on('route:bookmarklet', route);
      router.navigate("/bookmarklet?\n\nfeefwefwewef\n", {trigger: true});
      expect(route).toHaveBeenCalled();
    });
  });
});
