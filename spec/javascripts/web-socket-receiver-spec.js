/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("WebSocketReceiver", function() {
  /* WSR should publish events that widgets hook into
   *  e.g. socket/message/CLASS
   * WSR should pass the message's data as an argument to the event.
   * downsides:
   *  - need to standardize notifications
   */

  describe("onMessage", function() {

  });

  it("sets a shortcut", function() {
    expect(WSR).toEqual(WebSocketReceiver);
  });
});
