describe("app.views.Post", function(){

  describe("#render", function(){
    beforeEach(function(){
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      Diaspora.I18n.loadLocale({stream : {
        reshares : {
          one : "<%= count %> reshare",
          few : "<%= count %> reshares"
        }
      }})

      var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

      this.collection = new app.collections.Stream(posts);
      this.statusMessage = this.collection.models[0];
      this.reshare = this.collection.models[1];
    })

    context("for a reshare", function(){
      it("should display ReshareFeedback", function(){
        spyOn(app.views, "ReshareFeedback").andReturn(stubView("these are special reshare actions"));
        var view = new app.views.Post({model : this.reshare}).render();
        expect(view.$(".feedback").text().trim()).toBe("these are special reshare actions");
      })
    })

    it("displays a reshare count", function(){
      this.statusMessage.set({reshares_count : 2})
      var view = new app.views.Post({model : this.statusMessage}).render();

      expect(view.$(".post_initial_info").html()).toContain(Diaspora.I18n.t('stream.reshares', {count: 2}))
    })

    it("does not display a reshare count for 'zero'", function(){
      this.statusMessage.set({reshares_count : 0})
      var view = new app.views.Post({model : this.statusMessage}).render();

      expect(view.$(".post_initial_info").html()).not.toContain("0 Reshares")
    })

    it("should markdownify the post's text", function(){
      this.statusMessage.set({text: "I have three Belly Buttons"})
      spyOn(window.markdown, "toHTML")
      new app.views.Post({model : this.statusMessage}).render();
      expect(window.markdown.toHTML).toHaveBeenCalledWith("I have three Belly Buttons")
    })

    context("changes hashtags to links", function(){
      it("links to a hashtag to the tag page", function(){
        this.statusMessage.set({text: "I love #parties"})
        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.$("a:contains('#parties')").attr('href')).toBe('/tags/parties')
      })

      it("changes all hashtags", function(){
        this.statusMessage.set({text: "I love #parties and #rockstars and #unicorns"})
        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.$("a.tag").length).toBe(3)
        expect(view.$("a:contains('#parties')")).toExist();
        expect(view.$("a:contains('#rockstars')")).toExist();
        expect(view.$("a:contains('#unicorns')")).toExist();
      })

      it("requires hashtags to be preceeded with a space", function(){
        this.statusMessage.set({text: "I love the#parties"})
        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.$(".tag").length).toBe(0)
      })

      // NOTE THIS DIVERGES FROM GRUBER'S ORIGINAL DIALECT OF MARKDOWN.
      // We had to edit markdown.js line 291 - good people would have made a new dialect.
      //
      //    original : var m = block.match( /^(#{1,6})\s*(.*?)\s*#*\s*(?:\n|$)/ );
      //    \s* changed to \s+
      //
      it("doesn't create a header tag if the first word is a hashtag", function(){
        this.statusMessage.set({text: "#parties, I love"})
        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.$("h1:contains(parties)")).not.toExist();
        expect(view.$("a:contains('#parties')")).toExist();
      })

      it("works on reshares", function(){
        this.statusMessage.set({text: "I love #parties"})
        var reshare = new app.models.Reshare(factory.post({
          text : this.statusMessage.get("text"),
          root : this.statusMessage
        }))

        var view = new app.views.Post({model : reshare}).render();
        expect(view.$("a:contains('#parties')").attr('href')).toBe('/tags/parties')
      })
    })

    context("changes mention markup to links", function(){
      beforeEach(function(){
        this.alice = factory.author({
          name : "Alice Smith",
          diaspora_id : "alice@example.com",
          id : "555"
        })

        this.bob = factory.author({
          name : "Bob Grimm",
          diaspora_id : "bob@example.com",
          id : "666"
        })

        this.statusMessage.set({mentioned_people : [this.alice, this.bob]})
        this.statusMessage.set({text: "hey there @{Alice Smith; alice@example.com} and @{Bob Grimm; bob@example.com}"})
      })

      it("links to the mentioned person's page", function(){
        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.$("a:contains('Alice Smith')").attr('href')).toBe('/people/555')
      })

      it("matches all mentions", function(){
        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.$("a.mention").length).toBe(2)
      })

      it("works on reshares", function(){
        var reshare = new app.models.Reshare(factory.post({
          text : this.statusMessage.get("text"),
          mentioned_people :  this.statusMessage.get("mentioned_people"),
          root : this.statusMessage
        }))

        var view = new app.views.Post({model : reshare}).render();
        expect(view.$("a.mention").length).toBe(2)
      })
    })

    context("generates urls from plaintext", function(){
      it("works", function(){
        links = ["http://google.com",
                 "https://joindiaspora.com",
                 "http://www.yahooligans.com",
                 "http://obama.com",
                 "http://japan.co.jp"]

        this.statusMessage.set({text : links.join(" ")})
        var view = new app.views.Post({model : this.statusMessage}).render();

        _.each(links, function(link) {
          expect(view.$("a[href='" + link + "']").text()).toContain(link)
        })
      })

      it("works with urls that use #! syntax (i'm looking at you, twitter)')", function(){
        link = "http://twitter.com/#!/hashbangs?gross=true"
        this.statusMessage.set({text : link})
        var view = new app.views.Post({model : this.statusMessage}).render();

        expect(view.$("a[href='" + link + "']").text()).toContain(link)
      })

      it("doesn't create link tags for links that are already in <a/> or <img/> tags", function(){
        link = "http://google.com"

        this.statusMessage.set({text : "![cats](http://google.com/cats)"})
        var view = new app.views.Content({model : this.statusMessage})
        expect(view.presenter().text).toNotContain('</a>')
      })
    })

    context("user not signed in", function(){
      it("does not provide a Feedback view", function(){
        logout()
        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.feedbackView()).toBeFalsy();
      })
    })

    context("NSFW", function(){
      it("contains a shield element", function(){
        this.statusMessage.set({text : "this is safe for work. #sfw"});

        var view = new app.views.Post({model : this.statusMessage}).render();
        var statusElement = $(view.el)

        expect(statusElement.find(".shield").html()).toBeNull();
      })

      it("does not contain a shield element", function(){
        this.statusMessage.set({text : "nudie magazine day! #nsfw"});

        var view = new app.views.Post({model : this.statusMessage}).render();
        var statusElement = $(view.el)

        expect(statusElement.find(".shield").html()).toNotBe(null);
      })
    })
  })
})
