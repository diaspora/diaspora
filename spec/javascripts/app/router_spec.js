describe('app.Router', function () {
  describe('followed_tags', function() {
    beforeEach(function() {
      factory.preloads({tagFollowings: []});
    });

    it('decodes name before passing it into TagFollowingAction', function () {
      var followed_tags = spyOn(app.router, 'followed_tags').and.callThrough();
      var tag_following_action = spyOn(app.views, 'TagFollowingAction').and.callFake(function() {
        return {render: function() { return {el: ""}}};
      });

      app.router.followed_tags(encodeURIComponent('օբյեկտիվ'));
      expect(followed_tags).toHaveBeenCalled();
      expect(tag_following_action).toHaveBeenCalledWith({tagText: 'օբյեկտիվ'});
    });

    it('navigates to the downcase version of the corresponding tag', function () {
      var followed_tags = spyOn(app.router, 'followed_tags').and.callThrough();
      var tag_following_action = spyOn(app.views, 'TagFollowingAction').and.callFake(function() {
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
      router.aspectsList = aspectsListView;

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

  describe("aspects", function() {
    it("calls _initializeStreamView", function() {
      spyOn(app.router, "_initializeStreamView");
      app.router.aspects();
      expect(app.router._initializeStreamView).toHaveBeenCalled();
    });
  });

  describe("bookmarklet", function() {
    it('routes to bookmarklet even if params have linefeeds', function()  {
      var router = new app.Router();
      var route = jasmine.createSpy('bookmarklet route');
      router.on('route:bookmarklet', route);
      router.navigate("/bookmarklet?\n\nfeefwefwewef\n", {trigger: true});
      expect(route).toHaveBeenCalled();
    });
  });

  describe("stream", function() {
    it("calls _initializeStreamView", function() {
      spyOn(app.router, "_initializeStreamView");
      app.router.stream();
      expect(app.router._initializeStreamView).toHaveBeenCalled();
    });
  });

  describe("_initializeStreamView", function() {
    beforeEach(function() {
      delete app.page;
      delete app.publisher;
      delete app.shortcuts;
    });

    it("sets app.page", function() {
      expect(app.page).toBeUndefined();
      app.router._initializeStreamView();
      expect(app.page).toBeDefined();
    });

    it("sets app.publisher", function() {
      expect(app.publisher).toBeUndefined();
      app.router._initializeStreamView();
      expect(app.publisher).toBeDefined();
    });

    it("doesn't set app.publisher if already defined", function() {
      app.publisher = { jasmineTestValue: 42 };
      app.router._initializeStreamView();
      expect(app.publisher.jasmineTestValue).toEqual(42);
    });

    it("sets app.shortcuts", function() {
      expect(app.shortcuts).toBeUndefined();
      app.router._initializeStreamView();
      expect(app.shortcuts).toBeDefined();
    });

    it("doesn't set app.shortcuts if already defined", function() {
      app.shortcuts = { jasmineTestValue: 42 };
      app.router._initializeStreamView();
      expect(app.shortcuts.jasmineTestValue).toEqual(42);
    });

    it("unbinds inf scroll for old instances of app.page", function() {
      var pageSpy = jasmine.createSpyObj("page", ["remove", "unbindInfScroll"]);
      app.page = pageSpy;
      app.router._initializeStreamView();
      expect(pageSpy.unbindInfScroll).toHaveBeenCalled();
    });

    it("calls _hideInactiveStreamLists", function() {
      spyOn(app.router, "_hideInactiveStreamLists");
      app.router._initializeStreamView();
      expect(app.router._hideInactiveStreamLists).toHaveBeenCalled();
    });
  });
});
