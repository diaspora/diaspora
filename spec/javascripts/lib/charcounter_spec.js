describe("$.fn.charCount", function() {
  beforeEach(function() {
    this.input = $("<textarea></textarea>");
    this.counter = $("<div class='charcounter'></div>");
    // See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/repeat
    this.repeat = function(str, count) {
      var rpt = "";
      for (;;) {
        if ((count & 1) === 1) {
          rpt += str;
        }
        count >>>= 1;
        if (count === 0) {
          break;
        }
        str += str;
      }
      return rpt;
    };
  });

  context("on initialization", function() {
    beforeEach(function() {
      this.input.val(this.repeat("a", 10));
    });

    it("shows the correct number of available chars", function() {
      this.input.charCount({allowed: 12, warning: 1, counter: this.counter});
      expect(this.counter.text()).toEqual("2");
    });

    it("shows the normal text if there are enough chars left", function() {
      this.input.charCount({allowed: 12, warning: 2, counter: this.counter});
      expect(this.counter).not.toHaveClass("text-warning");
      expect(this.counter).not.toHaveClass("text-danger");
    });

    it("shows a warning if there almost no chars left", function() {
      this.input.charCount({allowed: 12, warning: 3, counter: this.counter});
      expect(this.counter).toHaveClass("text-warning");
      expect(this.counter).not.toHaveClass("text-danger");
    });

    it("shows an error if the limit exceeded", function() {
      this.input.charCount({allowed: 9, warning: 3, counter: this.counter});
      expect(this.counter).not.toHaveClass("text-warning");
      expect(this.counter).toHaveClass("text-danger");
    });
  });

  context("on text changes", function() {
    it("updates the number of available chars", function() {
      this.input.val("a");
      this.input.charCount({allowed: 100, warning: 10, counter: this.counter});
      expect(this.counter.text()).toEqual("99");

      this.input.val(this.repeat("a", 99));
      this.input.trigger("textchange");
      expect(this.counter.text()).toEqual("1");

      this.input.val(this.repeat("a", 102));
      this.input.trigger("textchange");
      expect(this.counter.text()).toEqual("-2");

      this.input.val("");
      this.input.trigger("textchange");
      expect(this.counter.text()).toEqual("100");
    });

    it("updates the counter classes", function() {
      this.input.val("a");
      this.input.charCount({allowed: 100, warning: 10, counter: this.counter});
      expect(this.counter).not.toHaveClass("text-warning");
      expect(this.counter).not.toHaveClass("text-danger");

      this.input.val(this.repeat("a", 90));
      this.input.trigger("textchange");
      expect(this.counter).not.toHaveClass("text-warning");
      expect(this.counter).not.toHaveClass("text-danger");

      this.input.val(this.repeat("a", 91));
      this.input.trigger("textchange");
      expect(this.counter).toHaveClass("text-warning");
      expect(this.counter).not.toHaveClass("text-danger");

      this.input.val(this.repeat("a", 100));
      this.input.trigger("textchange");
      expect(this.counter).toHaveClass("text-warning");
      expect(this.counter).not.toHaveClass("text-danger");

      this.input.val(this.repeat("a", 101));
      this.input.trigger("textchange");
      expect(this.counter).not.toHaveClass("text-warning");
      expect(this.counter).toHaveClass("text-danger");

      this.input.val("");
      this.input.trigger("textchange");
      expect(this.counter).not.toHaveClass("text-warning");
      expect(this.counter).not.toHaveClass("text-danger");
    });
  });
});
