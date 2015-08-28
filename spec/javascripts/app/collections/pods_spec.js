
describe("app.collections.Pods", function() {
  describe("#comparator", function() {
    it("should handle empty hostnames", function() {
      var collection = new app.collections.Pods([
        {id: 1},
        {id: 2, host: "zzz.zz"},
        {id: 3, host: "aaa.aa"},
        {id: 4, host: ""}
      ]);
      expect(collection.length).toBe(4);
      expect(collection.first().get("host")).toBeFalsy(); // also empty string
      expect(collection.last().get("host")).toBe("zzz.zz");
    });
  });
});
