describe("app.helpers.dateFormatter", function(){
  beforeEach(function(){
    this.statusMessage = factory.post();
    this.formatter = app.helpers.dateFormatter;
  });

  describe("parse", function(){
    context("modern web browsers", function(){
      it ("supports ISO 8601 UTC dates", function(){
        var timestamp = new Date(this.statusMessage.get("created_at")).getTime(); 
        expect(this.formatter.parse(this.statusMessage.get("created_at"))).toEqual(timestamp);
      });
    });

    context("legacy web browsers", function(){
      it("supports ISO 8601 UTC dates", function(){
        var timestamp = new Date(this.statusMessage.get("created_at")).getTime(); 

        expect(this.formatter.parseISO8601UTC(this.statusMessage.get("created_at"))).toEqual(timestamp);
      });
    });

    context("status messages", function(){
      it("uses ISO 8601 UTC dates", function(){
        var iso8601_utc_pattern = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(.(\d{3}))?Z$/;

        expect(iso8601_utc_pattern.test(this.statusMessage.get("created_at"))).toBe(true);
      });
    });
  });
});
