describe("app.views.Photos", function() {
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    this.photos = $.parseJSON(spec.readFixture("photos_json"))["photos"];

    this.stream = new app.models.Stream([], {collection: app.collections.Photos});
    this.stream.add(this.photos);

    this.view = new app.views.Photos({model : this.stream});

    // do this manually because we've moved loadMore into render??
    this.view.render();
    _.each(this.view.collection.models, function(photo) {
      this.view.addPostView(photo);
    }, this);
  });

  describe("initialize", function() {
    it("binds an infinite scroll listener", function() {
      spyOn($.fn, "scroll");
      new app.views.Stream({model : this.stream});
      expect($.fn.scroll).toHaveBeenCalled();
    });
  });

  describe("#render", function() {
    beforeEach(function() {
      this.photo = this.stream.items.models[0];
      this.photoElement = $(this.view.$("#" + this.photo.get("guid")));
    });

    context("when rendering a photo message", function() {
      it("shows the photo in the content area", function() {
        expect(this.photoElement.length).toBeGreaterThan(0);
      });
    });
  });
});
