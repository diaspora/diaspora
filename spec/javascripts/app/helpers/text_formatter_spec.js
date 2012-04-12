describe("app.helpers.textFormatter", function(){

  beforeEach(function(){
    this.statusMessage = factory.post();
    this.formatter = app.helpers.textFormatter;
  })

  describe("main", function(){
    it("calls mentionify, hashtagify, and markdownify", function(){
      spyOn(app.helpers.textFormatter, "mentionify")
      spyOn(app.helpers.textFormatter, "hashtagify")
      spyOn(app.helpers.textFormatter, "markdownify")

      app.helpers.textFormatter(this.statusMessage.get("text"), this.statusMessage)
      expect(app.helpers.textFormatter.mentionify).toHaveBeenCalled()
      expect(app.helpers.textFormatter.hashtagify).toHaveBeenCalled()
      expect(app.helpers.textFormatter.markdownify).toHaveBeenCalled()
    })

    // A couple of complex (intergration) test cases here would be rad.
  })

  describe(".markdownify", function(){
    // NOTE: for some strange reason, links separated by just a whitespace character
    // will not be autolinked; thus we join our URLS here with (" and ").
    // This test will fail if our join is just (" ") -- an edge case that should be addressed.

    it("autolinks", function(){
      var links = ["http://google.com",
        "https://joindiaspora.com",
        "http://www.yahooligans.com",
        "http://obama.com",
        "http://japan.co.jp"]

      // The join that would make this particular test fail:
      //
      // var formattedText = this.formatter.markdownify(links.join(" "))

      var formattedText = this.formatter.markdownify(links.join(" and "))
      var wrapper = $("<div>").html(formattedText);

      _.each(links, function(link) {
        var linkElement = wrapper.find("a[href='" + link + "']");
        expect(linkElement.text()).toContain(link);
        expect(linkElement.attr("target")).toContain("_blank");
      })
    })
  })

  describe(".hashtagify", function(){
    context("changes hashtags to links", function(){
      it("creates links to hashtags", function(){
        var formattedText = this.formatter.hashtagify("I love #parties and #rockstars and #unicorns")
        var wrapper = $("<div>").html(formattedText);

        _.each(["parties", "rockstars", "unicorns"], function(tagName){
          expect(wrapper.find("a[href='/tags/" + tagName + "']").text()).toContain(tagName)
        })
      })

      it("requires hashtags to be preceeded with a space", function(){
        var formattedText = this.formatter.hashtagify("I love the#parties")
        expect(formattedText).not.toContain('/tags/parties')
      })

      // NOTE THIS DIVERGES FROM GRUBER'S ORIGINAL DIALECT OF MARKDOWN.
      // We had to edit Markdown.Converter.js line 747
      //
      //    text = text.replace(/^(\#{1,6})[ \t]+(.+?)[ \t]*\#*\n+/gm,
      //    [ \t]* changed to [ \t]+
      //
      it("doesn't create a header tag if the first word is a hashtag", function(){
        var formattedText = this.formatter.hashtagify("#parties, I love")
        var wrapper = $("<div>").html(formattedText);

        expect(wrapper.find("h1").length).toBe(0)
        expect(wrapper.find("a[href='/tags/parties']").text()).toContain("#parties")
      })
    })
  })

  describe(".mentionify", function(){
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

        this.statusMessage.set({text: "hey there @{Alice Smith; alice@example.com} and @{Bob Grimm; bob@example.com}"})
        this.statusMessage.set({mentioned_people : [this.alice, this.bob]})
      })

      it("matches mentions", function(){
        var formattedText = this.formatter.mentionify(this.statusMessage.get("text"), this.statusMessage.get("mentioned_people"))
        var wrapper = $("<div>").html(formattedText);

        _.each([this.alice, this.bob], function(person) {
          expect(wrapper.find("a[href='/people/" + person.guid + "']").text()).toContain(person.name)
        })
      });

      it("returns mentions for on posts that haven't been saved yet (framer posts)", function(){
        var freshBob = factory.author({
          name : "Bob Grimm",
          handle : "bob@example.com",
          url : 'googlebot.com',
          id : "666"
        })

        this.statusMessage.set({'mentioned_people' : [freshBob] })

        var formattedText = this.formatter.mentionify(this.statusMessage.get("text"), this.statusMessage.get("mentioned_people"))
        var wrapper = $("<div>").html(formattedText);
        expect(wrapper.find("a[href='googlebot.com']").text()).toContain(freshBob.name)
      })

      it('returns the name of the mention if the mention does not exist in the array', function(){
        var text = "hey there @{Chris Smith; chris@example.com}"
        var formattedText = this.formatter.mentionify(text, [])
        expect(formattedText.match(/\<a/)).toBeNull();
      });
    })
  })
})
