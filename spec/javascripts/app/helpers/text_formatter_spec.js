describe("app.helpers.textFormatter", function(){

  beforeEach(function(){
    this.statusMessage = factory.post();
    this.formatter = app.helpers.textFormatter;
  });

  // Some basic specs. For more detailed specs see
  // https://github.com/svbergerem/markdown-it-hashtag/tree/master/test
  context("hashtags", function() {
    beforeEach(function() {
      this.goodTags = [
        "tag",
        "diaspora",
        "PARTIES",
        "<3",
        "diaspora-dev",
        "diaspora_dev",
        // issue #5765
        "മലയാണ്മ",
        // issue #5815
        "ինչո՞ւ",
        "այո՜ո",
        "սեւ֊սպիտակ",
        "գժանո՛ց"
      ];

      this.badTags = [
        "tag.tag",
        "hash:tag",
        "hash*tag"
      ];
    });

    it("renders good tags as links", function() {
      var self = this;
      this.goodTags.forEach(function(tag) {
        var formattedText = self.formatter("#newhashtag #" + tag + " test");
        var link = "<a href=\"/tags/" + tag.toLowerCase() + "\" class=\"tag\">#" + tag.replace("<", "&lt;") + "</a>";
        expect(formattedText).toContain(link);
      });
    });

    it("doesn't render bad tags as links", function() {
      var self = this;
      this.badTags.forEach(function(tag) {
        var formattedText = self.formatter("#newhashtag #" + tag + " test");
        var link = "<a href=\"/tags/" + tag.toLowerCase() + "\" class=\"tag\">#" + tag.replace("<", "&lt;") + "</a>";
        expect(formattedText).not.toContain(link);
      });
    });
  });

  // Some basic specs. For more detailed specs see
  // https://github.com/diaspora/markdown-it-diaspora-mention/tree/master/test
  context("mentions", function() {
    beforeEach(function(){
      this.alice = factory.author({
        name : "Alice Smith",
        diaspora_id : "alice@example.com",
        guid: "555",
        id : "555"
      });

      this.bob = factory.author({
        name : "Bob Grimm",
        diaspora_id : "bob@example.com",
        guid: "666",
        id : "666"
      });

      this.statusMessage.set({text: "hey there @{Alice Smith; alice@example.com} and @{Bob Grimm; bob@example.com}"});
      this.statusMessage.set({mentioned_people : [this.alice, this.bob]});
    });

    it("matches mentions", function(){
      var formattedText = this.formatter(this.statusMessage.get("text"), this.statusMessage.get("mentioned_people"));
      var wrapper = $("<div>").html(formattedText);

      _.each([this.alice, this.bob], function(person) {
        expect(wrapper.find("a[href='/people/" + person.guid + "']").text()).toContain(person.name);
      });
    });

    it("returns mentions for on posts that haven't been saved yet (framer posts)", function(){
      var freshBob = factory.author({
        name : "Bob Grimm",
        handle : "bob@example.com",
        url : 'googlebot.com',
        id : "666"
      });

      this.statusMessage.set({'mentioned_people' : [freshBob] });

      var formattedText = this.formatter(this.statusMessage.get("text"), this.statusMessage.get("mentioned_people"));
      var wrapper = $("<div>").html(formattedText);
      expect(wrapper.find("a[href='googlebot.com']").text()).toContain(freshBob.name);
    });

    it("returns the name of the mention if the mention does not exist in the array", function(){
      var text = "hey there @{Chris Smith; chris@example.com}";
      var formattedText = this.formatter(text, []);
      expect(formattedText.match(/<a/)).toBeNull();
      expect(formattedText).toContain('Chris Smith');
    });

    it("makes mentions hovercardable unless the current user has been mentioned", function() {
      app.currentUser.get = jasmine.createSpy().and.returnValue(this.alice.guid);
      var formattedText = this.formatter(this.statusMessage.get("text"), this.statusMessage.get("mentioned_people"));
      var wrapper = $("<div>").html(formattedText);
      expect(wrapper.find("a[href='/people/" + this.alice.guid + "']")).not.toHaveClass('hovercardable');
      expect(wrapper.find("a[href='/people/" + this.bob.guid + "']")).toHaveClass('hovercardable');
    });

    it("supports mentions without a given name", function() {
      this.statusMessage.set({text: "hey there @{alice@example.com} and @{bob@example.com}"});
      var formattedText = this.formatter(this.statusMessage.get("text"), this.statusMessage.get("mentioned_people"));
      var wrapper = $("<div>").html(formattedText);

      _.each([this.alice, this.bob], function(person) {
        expect(wrapper.find("a[href='/people/" + person.guid + "']").text()).toContain(person.name);
      });
    });

    it("it uses the name given in the mention if it exists", function() {
      this.statusMessage.set({text: "hey there @{Alice Awesome; alice@example.com} and @{bob@example.com}"});
      var formattedText = this.formatter(this.statusMessage.get("text"), this.statusMessage.get("mentioned_people"));
      var wrapper = $("<div>").html(formattedText);

      expect(wrapper.find("a[href='/people/" + this.alice.guid + "']").text()).toContain("Alice Awesome");
      expect(wrapper.find("a[href='/people/" + this.bob.guid + "']").text()).toContain(this.bob.name);
    });
  });

  context("highlight", function(){
    it("works with javascript code", function(){
      var code = "```js\nfunction test() { return; } //test\n```";
      expect(this.formatter(code)).toContain("<span class=\"hljs-function\">");
      expect(this.formatter(code)).toContain("<span class=\"hljs-comment\">");
    });

    it("works with markdown", function(){
      var code = "```markdown\n# header\n**strong**\n```";
      expect(this.formatter(code)).toContain("<span class=\"hljs-section\">");
      expect(this.formatter(code)).toContain("<span class=\"hljs-strong\">");
    });

    it("works with ruby code", function(){
      var code = "```ruby\n# comment\nmodule test\nend\n```";
      expect(this.formatter(code)).toContain("<span class=\"hljs-comment\">");
      expect(this.formatter(code)).toContain("<span class=\"hljs-class\">");
    });
  });

  context("markdown", function(){
    it("autolinks", function(){
      var links = [
        "http://google.com",
        "https://joindiaspora.com",
        "http://www.yahooligans.com",
        "http://obama.com",
        "http://japan.co.jp",
        "http://www.mygreat-example-website.de",
        "http://www.jenseitsderfenster.de",  // from issue #3468
        "mumble://mumble.coding4.coffee",
        "xmpp:podmin@pod.tld",
        "mailto:podmin@pod.tld"
      ];

      var formattedText = this.formatter(links.join(" "));
      var wrapper = $("<div>").html(formattedText);

      _.each(links, function(link) {
        var linkElement = wrapper.find("a[href*='" + link + "']");
        expect(linkElement.text()).toContain(link);
        expect(linkElement.attr("target")).toContain("_blank");
      });

      expect(this.formatter("<http://google.com>")).toContain("<a href");
      expect(this.formatter("<http://google.com>")).toContain("_blank");

      expect(this.formatter("<http://google.com>")).toContain("noopener");
      expect(this.formatter("<http://google.com>")).toContain("noreferrer");
    });

    it("adds a missing http://", function() {
      expect(this.formatter('[test](www.google.com)')).toContain('href="http://www.google.com"');
      expect(this.formatter('[test](http://www.google.com)')).toContain('href="http://www.google.com"');
    });

    it("respects code blocks", function() {
      var content = '`<unknown tag>`';
      var wrapper = $('<div>').html(this.formatter(content));
      expect(wrapper.find('code').text()).toEqual('<unknown tag>');
    });

    it("adds 'img-responsive' to the image class", function() {
      var content = "![alt](http://google.com)]";
      var wrapper = $("<div>").html(this.formatter(content));
      expect(wrapper.find("img")).toHaveClass("img-responsive");

      content = "<img src=\"http://google.com\">";
      wrapper = $("<div>").html(this.formatter(content));
      expect(wrapper.find("img")).toHaveClass("img-responsive");
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
          var text = this.formatter(str);
          expect(text).toContain(this.output_symbols[idx]);
        }, this);
      });

      it("converts all symbols at once", function() {
        var text = this.formatter(this.input_strings.join(" "));
        _.each(this.output_symbols, function(sym) {
          expect(text).toContain(sym);
        });
      });
    });

    context("non-ascii url", function() {
      beforeEach(function() {
        /* jshint -W100 */
        this.evilUrls = [
          "http://www.bürgerentscheid-krankenhäuser.de", // example from issue #2665
          "http://bündnis-für-krankenhäuser.de/wp-content/uploads/2011/11/cropped-logohp.jpg",
          "http://موقع.وزارة-الاتصالات.مصر/", // example from #3082
          "http://lyricstranslate.com/en/someone-you-നിന്നെ-പോലൊരാള്‍.html", // example from #3063,
          "http://de.wikipedia.org/wiki/Liste_der_Abkürzungen_(Netzjargon)", // #3645
          "http://wiki.com/?query=Kr%E4fte", // #4874
        ];
        /* jshint +W100 */
        this.asciiUrls = [
          "http://www.xn--brgerentscheid-krankenhuser-xkc78d.de",
          "http://xn--bndnis-fr-krankenhuser-i5b27cha.de/wp-content/uploads/2011/11/cropped-logohp.jpg",
          "http://xn--4gbrim.xn----ymcbaaajlc6dj7bxne2c.xn--wgbh1c/",
          "http://lyricstranslate.com/en/someone-you-%E0%B4%A8%E0%B4%BF%E0%B4%A8%E0%B5%8D%E0%B4%A8%E0%B5%86-%E0%B4%AA%E0%B5%8B%E0%B4%B2%E0%B5%8A%E0%B4%B0%E0%B4%BE%E0%B4%B3%E0%B5%8D%E2%80%8D.html",
          "http://de.wikipedia.org/wiki/Liste_der_Abk%C3%BCrzungen_(Netzjargon)",
          "http://wiki.com/?query=Kr%E4fte",
        ];
      });

      it("correctly encodes to punycode", function() {
        _.each(this.evilUrls, function(url, num) {
          var text = this.formatter(url);
          expect(text).toContain(this.asciiUrls[num]);
        }, this);
      });

      it("correctly encodes image src to punycode", function() {
        _.each(this.evilUrls, function(url, num) {
          var text = this.formatter("![](" + url + ")");
          expect(text).toContain(this.asciiUrls[num]);
        }, this);
      });

      it("doesn't break link texts", function() {
        var linkText = "check out this awesome link!";
        var text = this.formatter( "["+linkText+"]("+this.evilUrls[0]+")" );

        expect(text).toContain(this.asciiUrls[0]);
        expect(text).toContain(linkText);
      });

      it("doesn't break reference style links", function() {
        var postContent = "blabla blab [my special link][1] bla blabla\n\n[1]: "+this.evilUrls[0]+" and an optional title)";
        var text = this.formatter(postContent);

        expect(text).not.toContain('"'+this.evilUrls[0]+'"');
        expect(text).toContain(this.asciiUrls[0]);
      });

      it("can be used as img src", function() {
        var postContent = "![logo]("+ this.evilUrls[1] +")";
        var niceImg = 'src="'+ this.asciiUrls[1] +'"'; // the "" are from src=""
        var text = this.formatter(postContent);

        expect(text).toContain(niceImg);
      });

      it("doesn't break linked images", function() {
        var postContent = "I am linking an image here [![some-alt-text]("+this.evilUrls[1]+")]("+this.evilUrls[3]+")";
        var text = this.formatter(postContent);
        var linked_image = 'src="'+this.asciiUrls[1]+'"';
        var image_link = 'href="'+this.asciiUrls[3]+'"';

        expect(text).toContain(linked_image);
        expect(text).toContain(image_link);
      });
    });

    context("misc breakage and/or other issues with weird urls", function(){
      it("doesn't crash Firefox", function() {
        var content = "antifaschistisch-feministische ://";
        var parsed = this.formatter(content);
        expect(parsed).toContain(content);
      });

      it("doesn't crash Chromium - RUN ME WITH CHROMIUM! (issue #3553)", function() {

        var text_part = 'Revert "rails admin is conflicting with client side validations: see https://github.com/sferik/rails_admin/issues/985"';
        var link_part = 'https://github.com/diaspora/diaspora/commit/61f40fc6bfe6bb859c995023b5a17d22c9b5e6e5';
        var content = '['+text_part+']('+link_part+')';
        var parsed = this.formatter(content);

        var link = 'href="' + link_part + '"';
        var text = '>Revert “rails admin is conflicting with client side validations: see https://github.com/sferik/rails_admin/issues/985”<';

        expect(parsed).toContain(link);
        expect(parsed).toContain(text);
      });

      context("percent-encoded input url", function() {
        beforeEach(function() {
          this.input = "http://www.soilandhealth.org/01aglibrary/010175.tree%20crops.pdf";  // #4507
          this.correctHref = 'href="'+this.input+'"';
        });

        it("doesn't get double-encoded", function(){
          var parsed = this.formatter(this.input);
          expect(parsed).toContain(this.correctHref);
        });
      });

      it("doesn't fail for misc urls", function() {
        var contents = [
          'https://foo.com!',
          'ftp://example.org:8080'
        ];
        for (var i = 0; i < contents.length; i++) {
          expect(this.formatter(contents[i])).toContain("<a href");
        }
      });
    });

    context("media embed", function() {
      beforeEach(function() {
        spyOn(app.helpers, "allowedEmbedsMime").and.returnValue(true);
      });

      it("embeds audio", function() {
        var html =
          '<p><a href="https://example.org/file.mp3" target="_blank" rel="noopener noreferrer">title</a></p>\n' +
          '<div class="media-embed">\n' +
          "\n" +
          "    <audio controls preload=none>\n" +
          '      <source type="audio/mpeg" src="https://example.org/file.mp3" />\n' +
          "      title\n" +
          "    </audio>\n" +
          "\n" +
          "</div>\n";
        var content = "[title](https://example.org/file.mp3)";
        var parsed = this.formatter(content);

        expect(parsed).toContain(html);
      });

      it("embeds video", function() {
        var html =
          '<p><a href="https://example.org/file.mp4" target="_blank" rel="noopener noreferrer">title</a></p>\n' +
          '<div class="media-embed">\n' +
          '  <div class="thumb">\n' +
          "\n" +
          "    <video preload=none>\n" +
          '      <source type="video/mp4" src="https://example.org/file.mp4" />\n' +
          "      title\n" +
          "    </video>\n" +
          "\n" +
          '    <div class="video-overlay">\n' +
          '      <div class="video-info">\n' +
          '        <div class="title">title</div>\n' +
          "      </div>\n" +
          "    </div>\n" +
          "  </div>\n" +
          "</div>\n";

        var content = "[title](https://example.org/file.mp4)";
        var parsed = this.formatter(content);

        expect(parsed).toContain(html);
      });
    });
  });

  context("real world examples", function(){
    it("renders them as expected", function(){
      var contents = [
        'oh, cool, nginx 1.7.9 supports json autoindexes: http://nginx.org/en/docs/http/ngx_http_autoindex_module.html#autoindex_format'
      ];
      var results = [
        '<p>oh, cool, nginx 1.7.9 supports json autoindexes: <a href="http://nginx.org/en/docs/http/ngx_http_autoindex_module.html#autoindex_format" target="_blank" rel="noopener noreferrer">http://nginx.org/en/docs/http/ngx_http_autoindex_module.html#autoindex_format</a></p>'
      ];
      for (var i = 0; i < contents.length; i++) {
        expect(this.formatter(contents[i])).toContain(results[i]);
      }
    });
  });
});
