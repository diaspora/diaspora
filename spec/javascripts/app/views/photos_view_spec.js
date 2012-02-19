describe("app.views.Photos", function() {
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    this._photos = $.parseJSON(spec.readFixture("photos_json"))["photos"];

    this.photos = new app.models.Photos();
    this.photos.add(this._photos);

    this.view = new app.views.Photos({model : this.photos});

    // do this manually because we've moved loadMore into render??
    this.view.render();
    _.each(this.view.collection.models, function(photo) {
      this.view.addPhoto(photo);
    }, this);
  });

  describe("initialize", function() {
    // nothing there yet
  });

  describe("#render", function() {
    beforeEach(function() {
      this.photo = this.photos.photos.models[0];
      this.photoElement = $(this.view.$("#" + this.photo.get("guid")));
    });

    context("when rendering a photo message", function() {
      it("shows the photo in the content area", function() {
        expect(this.photoElement.length).toBeGreaterThan(0); //markdown'ed
      });
    });
  });

  describe("removeLoader", function() {
    it("emptys the pagination div when the stream is fetched", function() {
      $("#jasmine_content").append($('<div id="paginate">OMG</div>'));
      expect($("#paginate").text()).toBe("OMG");
      this.view.photos.trigger("fetched");
      expect($("#paginate")).toBeEmpty();
    });
  });
  
});
