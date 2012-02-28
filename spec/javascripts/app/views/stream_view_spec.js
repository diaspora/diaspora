describe("app.views.Stream", function() {
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    this.posts = $.parseJSON(spec.readFixture("stream_json"))["posts"];

    this.stream = new app.models.Stream();
    this.stream.add(this.posts);

    this.view = new app.views.Stream({model : this.stream});

    app.stream.bind("fetched", this.collectionFetched, this); //untested

    // do this manually because we've moved loadMore into render??
    this.view.render();
    _.each(this.view.collection.models, function(post) {
      this.view.addPost(post);
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
      this.statusMessage = this.stream.posts.models[0];
      this.statusElement = $(this.view.$(".stream_element")[0]);
    });

    context("when rendering a status message", function() {
      it("shows the message in the content area", function() {
        expect(this.statusElement.find(".post-content p").text()).toContain("LONG POST"); //markdown'ed
      });
    });
  });

  describe('clicking read more', function() {
    var readMoreLink;

    beforeEach(function() {
      this.statusMessage = this.stream.posts.models[0];
      this.statusElement = $(this.view.$(".stream_element")[0]);
      readMoreLink = this.statusElement.find('.read-more a');
      readMoreLink.text("read more");
    });

    it('expands the post', function() {
      expect(this.statusElement.find('.collapsible .details').attr('style')).toContain('display: none;');
      readMoreLink.click();
      expect(this.statusElement.find('.collapsible .details').attr('style')).not.toContain('display: none;');
    });

    describe('differences between firefox and webkit/IE', function() {
      // Firefox creates 2 divs - one with the summary and one with the whole post.
      //   It hides the summary and shows the whole post when you click show more. Works great!
      // Webkit and IE also create 2 divs, but they split the post - the 1st has the summary and the 2nd has the rest
      //   of the post. When you click read more, it just shows the 2nd div. This leaves whitespace in odd places.
      //   So there's a callback that this is testing, that fixes the whitespace on webkit & IE.
      var weAreOnFirefox;

      beforeEach(function() {
        weAreOnFirefox = this.statusElement.find('.collapsible .summary').length > 0;
      });

      it('removes the read-more div on webkit/IE but leaves it on firefox', function() {
        expect(this.statusElement.find('.read-more').length).toEqual(1);
        readMoreLink.click();
        if (weAreOnFirefox === true) {
          expect(this.statusElement.find('.read-more').length).toEqual(1);
        } else {
          expect(this.statusElement.find('.read-more').length).toEqual(0);
        }
      });

      it('collapses p elements on webkit/IE but leaves them alone on firefox', function() {
        expect(this.statusElement.find('.collapsible p').length).toEqual(2);
        readMoreLink.click();
        if (weAreOnFirefox === true) {
          expect(this.statusElement.find('.collapsible p').length).toEqual(2);
        } else {
          expect(this.statusElement.find('.collapsible p').length).toEqual(1);
        }
      });

      it('collapses li elements on webkit/IE but leaves them alone on firefox', function() {
        this.statusMessage = this.stream.posts.models[3];
        this.statusElement = $(this.view.$(".stream_element")[3]);
        readMoreLink = this.statusElement.find('.read-more a');
        readMoreLink.text("read more");

        if (weAreOnFirefox === true) {
          expect(this.statusElement.find('.collapsible li').length).toEqual(12);
          readMoreLink.click();
          expect(this.statusElement.find('.collapsible li').length).toEqual(12);
        } else {
          expect(this.statusElement.find('.collapsible li').length).toEqual(9);
          readMoreLink.click();
          expect(this.statusElement.find('.collapsible li').length).toEqual(8);
        }
      });
    });
  });

  describe("infScroll", function() {
    // NOTE: inf scroll happens at 500px

    it("calls render when the user is at the bottom of the page", function() {
      spyOn($.fn, "height").andReturn(0);
      spyOn($.fn, "scrollTop").andReturn(100);
      spyOn(this.view, "render");

      this.view.infScroll();
      expect(this.view.render).toHaveBeenCalled();
    });
  });

  describe("removeLoader", function() {
    it("emptys the pagination div when the stream is fetched", function() {
      $("#jasmine_content").append($('<div id="paginate">OMG</div>'));
      expect($("#paginate").text()).toBe("OMG");
      this.view.stream.trigger("fetched");
      expect($("#paginate")).toBeEmpty();
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
