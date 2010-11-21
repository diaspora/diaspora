describe("WebSocketReceiver", function() {
    it("sets a shortcut", function() {
      expect(WebSocketReceiver).toEqual(WSR);
      expect(WSR).toEqual(WebSocketReceiver);
    });
});
