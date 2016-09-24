describe("app.views.Stream", function() {
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    this.posts = $.parseJSON(spec.readFixture("stream_json"));

    this.stream = new app.models.Stream();
    this.stream.add(this.posts);

    this.view = new app.views.Stream({model : this.stream});

    // do this manually because we've moved loadMore into render??
    this.view.render();
    _.each(this.view.collection.models, function(post) {
      this.view.addPostView(post);
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
      this.statusMessage = this.stream.items.models[0];
      this.statusElement = $(this.view.$(".stream-element")[0]);
    });

    context("when rendering a status message", function() {
      it("shows the message in the content area", function() {
        expect(this.statusElement.find(".post-content p").text()).toContain("LONG POST"); //markdown'ed
      });
    });
  });

  describe("infScroll", function() {
    // NOTE: inf scroll happens at 500px
    beforeEach(function(){
      spyOn($.fn, "height").and.returnValue(0);
      spyOn($.fn, "scrollTop").and.returnValue(100);
      spyOn(this.view.model, "fetch");

    });

    describe('fetching more', function() {
      beforeEach(function(done) {
        this.view.on('loadMore', function() {
          done();
        });
        this.view.infScroll();
      });

      it("fetches moar when the user is at the bottom of the page", function() {
        expect(this.view.model.fetch).toHaveBeenCalled();
      });
    });

    it("shows the loader while fetching new posts", function() {
      spyOn(this.view, "showLoader");
      this.view.infScroll();

      expect(this.view.showLoader).toHaveBeenCalled();
    });


    it("doesnt try to fetch more content if already fetched all", function() {
      spyOn($.fn, "unbind");

      this.stream.trigger("allItemsLoaded", this.view);

      expect($.fn.unbind).toHaveBeenCalledWith("scroll");
    });
  });

  describe("unbindInfScroll", function() {
    it("unbinds scroll", function() {
      spyOn($.fn, "unbind");
      this.view.unbindInfScroll();
      expect($.fn.unbind).toHaveBeenCalledWith("scroll");
    });
  });
});
