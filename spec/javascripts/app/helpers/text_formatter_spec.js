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
      var links = [
        "http://google.com",
        "https://joindiaspora.com",
        "http://www.yahooligans.com",
        "http://obama.com",
        "http://japan.co.jp",
        "www.mygreat-example-website.de",
        "www.jenseitsderfenster.de",  // from issue #3468
        "www.google.com"
      ];

      // The join that would make this particular test fail:
      //
      // var formattedText = this.formatter.markdownify(links.join(" "))

      var formattedText = this.formatter.markdownify(links.join(" and "));
      var wrapper = $("<div>").html(formattedText);

      _.each(links, function(link) {
        var linkElement = wrapper.find("a[href*='" + link + "']");
        expect(linkElement.text()).toContain(link);
        expect(linkElement.attr("target")).toContain("_blank");
      })
    });

    context("symbol conversion", function() {
      beforeEach(function() {
        this.input_strings = [
          "->", "<-", "<->",
          "(c)", "(r)", "(tm)",
          "<3"
        ];
        this.output_symbols = [
          "→", "←", "↔",
          "©", "®", "™",
          "♥"
        ];
      });

      it("correctly converts the input strings to their corresponding output symbol", function() {
        _.each(this.input_strings, function(str, idx) {
          var text = this.formatter.markdownify(str);
          expect(text).toContain(this.output_symbols[idx]);
        }, this);
      });

      it("converts all symbols at once", function() {
        var text = this.formatter.markdownify(this.input_strings.join(" "));
        _.each(this.output_symbols, function(sym) {
          expect(text).toContain(sym);
        });
      });
    });

    context("non-ascii url", function() {
      beforeEach(function() {
        this.evilUrls = [
          "http://www.bürgerentscheid-krankenhäuser.de", // example from issue #2665
          "http://bündnis-für-krankenhäuser.de/wp-content/uploads/2011/11/cropped-logohp.jpg",
          "http://موقع.وزارة-الاتصالات.مصر/", // example from #3082
          "http:///scholar.google.com/citations?view_op=top_venues",
          "http://lyricstranslate.com/en/someone-you-നിന്നെ-പോലൊരാള്‍.html", // example from #3063,
          "http://de.wikipedia.org/wiki/Liste_der_Abkürzungen_(Netzjargon)" // #3645
        ];
        this.asciiUrls = [
          "http://www.xn--brgerentscheid-krankenhuser-xkc78d.de",
          "http://xn--bndnis-fr-krankenhuser-i5b27cha.de/wp-content/uploads/2011/11/cropped-logohp.jpg",
          "http://xn--4gbrim.xn----ymcbaaajlc6dj7bxne2c.xn--wgbh1c/",
          "http:///scholar.google.com/citations?view_op=top_venues",
          "http://lyricstranslate.com/en/someone-you-%E0%B4%A8%E0%B4%BF%E0%B4%A8%E0%B5%8D%E0%B4%A8%E0%B5%86-%E0%B4%AA%E0%B5%8B%E0%B4%B2%E0%B5%8A%E0%B4%B0%E0%B4%BE%E0%B4%B3%E0%B5%8D%E2%80%8D.html",
          "http://de.wikipedia.org/wiki/Liste_der_Abk%C3%BCrzungen_%28Netzjargon%29"
        ];
      });

      it("correctly encodes to punycode", function() {
        _.each(this.evilUrls, function(url, num) {
          var text = this.formatter.markdownify( "<" + url + ">" );
          expect(text).toContain(this.asciiUrls[num]);
        }, this);
      });

      it("doesn't break link texts", function() {
        var linkText = "check out this awesome link!";
        var text = this.formatter.markdownify( "["+linkText+"]("+this.evilUrls[0]+")" );

        expect(text).toContain(this.asciiUrls[0]);
        expect(text).toContain(linkText);
      });

      it("doesn't break reference style links", function() {
        var postContent = "blabla blab [my special link][1] bla blabla\n\n[1]: "+this.evilUrls[0]+" and an optional title)";
        var text = this.formatter.markdownify(postContent);

        expect(text).not.toContain(this.evilUrls[0]);
        expect(text).toContain(this.asciiUrls[0]);
      });

      it("can be used as img src", function() {
        var postContent = "![logo]("+ this.evilUrls[1] +")";
        var niceImg = 'src="'+ this.asciiUrls[1] +'"'; // the "" are from src=""
        var text = this.formatter.markdownify(postContent);

        expect(text).toContain(niceImg);
      });

      it("doesn't break linked images", function() {
        var postContent = "I am linking an image here [![some-alt-text]("+this.evilUrls[1]+")]("+this.evilUrls[3]+")";
        var text = this.formatter.markdownify(postContent);
        var linked_image = 'src="'+this.asciiUrls[1]+'"';
        var image_link = 'href="'+this.asciiUrls[3]+'"';

        expect(text).toContain(linked_image);
        expect(text).toContain(image_link);
      });

    });

    context("misc breakage and/or other issues with weird urls", function(){
      it("doesn't crash Chromium - RUN ME WITH CHROMIUM! (issue #3553)", function() {

        var text_part = 'Revert "rails admin is conflicting with client side validations: see https://github.com/sferik/rails_admin/issues/985"';
        var link_part = 'https://github.com/diaspora/diaspora/commit/61f40fc6bfe6bb859c995023b5a17d22c9b5e6e5';
        var content = '['+text_part+']('+link_part+')';
        var parsed = this.formatter.markdownify(content);

        var link = 'href="' + link_part + '"';
        var text = '>'+ text_part +'<';

        expect(parsed).toContain(link);
        expect(parsed).toContain(text);
      });

      context("percent-encoded input url", function() {
        beforeEach(function() {
          this.input = "http://www.soilandhealth.org/01aglibrary/010175.tree%20crops.pdf"  // #4507
          this.correctHref = 'href="'+this.input+'"';
        });

        it("doesn't get double-encoded", function(){
          var parsed = this.formatter.markdownify(this.input);
          expect(parsed).toContain(this.correctHref);
        });

        it("gets correctly decoded, even when multiply encoded", function() {
          var uglyUrl = encodeURI(encodeURI(encodeURI(this.input)));
          var parsed = this.formatter.markdownify(uglyUrl);
          expect(parsed).toContain(this.correctHref);
        });
      });

      it("tests a bunch of benchmark urls", function(){
        var self = this;
        $.ajax({
          async: false,
          cache: false,
          url: '/spec/fixtures/good_urls.txt',
          success: function(data) { self.url_list = data.split("\n"); }
        });

        _.each(this.url_list, function(url) {
          // 'comments'
          if( url.match(/^#/) ) return;

          // regex.test is stupid, use match and boolean-ify it
          var result = !!url.match(Diaspora.url_regex);
          expect(result).toBeTruthy();
          if( !result && console && console.log ) {
            console.log(url);
          }
        });
      });

      // TODO: try to match the 'bad_urls.txt' and have as few matches as possible
    });

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

      it("and the resultant link has the tags name downcased", function(){
        var formattedText = this.formatter.hashtagify("#PARTIES, I love")

        expect(formattedText).toContain("/tags/parties")
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
