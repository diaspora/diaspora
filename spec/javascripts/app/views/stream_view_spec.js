describe("app.views.Stream", function(){
  beforeEach(function(){
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    this.posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

    this.stream = new app.models.Stream()
    this.stream.add(this.posts);

    this.view = new app.views.Stream({model : this.stream});

    app.stream.bind("fetched", this.collectionFetched, this) //untested

    // do this manually because we've moved loadMore into render??
    this.view.render();
    _.each(this.view.collection.models, function(post){ this.view.addPost(post); }, this);
  })

  describe("initialize", function(){
    it("binds an infinite scroll listener", function(){
      spyOn($.fn, "scroll");
      new app.views.Stream({model : this.stream});
      expect($.fn.scroll).toHaveBeenCalled()
    })
  })

  describe("#render", function(){
    beforeEach(function(){
      this.statusMessage = this.stream.posts.models[0];
      this.reshare = this.stream.posts.models[1];
      this.statusElement = $(this.view.$("#" + this.statusMessage.get("guid")));
      this.reshareElement = $(this.view.$("#" + this.reshare.get("guid")));
    })

    context("when rendering a Status Mesasage", function(){
      it("shows the status message in the content area", function(){
        expect(this.statusElement.find(".post-content p").text()).toContain("you're gonna love this") //markdown'ed
      })
    })
  })

  describe("infScroll", function(){
    // NOTE: inf scroll happens at 500px

    it("calls render when the user is at the bottom of the page", function(){
      spyOn($.fn, "height").andReturn(0)
      spyOn($.fn, "scrollTop").andReturn(100)
      spyOn(this.view, "render")

      this.view.infScroll();
      expect(this.view.render).toHaveBeenCalled();
    })
  })

  describe("removeLoader", function() {
    it("emptys the pagination div when the stream is fetched", function(){
      $("#jasmine_content").append($('<div id="paginate">OMG</div>'))
      expect($("#paginate").text()).toBe("OMG")
      this.view.stream.trigger("fetched")
      expect($("#paginate")).toBeEmpty()
    })
  })

  describe("unbindInfScroll", function(){
    it("unbinds scroll", function() {
      spyOn($.fn, "unbind")
      this.view.unbindInfScroll()
      expect($.fn.unbind).toHaveBeenCalledWith("scroll")
    })
  })
})
