describe("app.views.Conversations", function(){
  describe('setupConversation', function() {
    context('for unread conversations', function() {
      beforeEach(function() {
        spec.loadFixture('conversations_unread');
      });

      it('removes the unread class from the conversation', function() {
        expect($('.conversation-wrapper > .conversation.selected')).toHaveClass('unread');
        new app.views.Conversations();
        expect($('.conversation-wrapper > .conversation.selected')).not.toHaveClass('unread');
      });

      it('removes the unread message counter from the conversation', function() {
        expect($('.conversation-wrapper > .conversation.selected .unread_message_count').length).toEqual(1);
        new app.views.Conversations();
        expect($('.conversation-wrapper > .conversation.selected .unread_message_count').length).toEqual(0);
      });

      it('decreases the unread message count in the header', function() {
        var badge = '<div id="conversations_badge"><div class="badge_count">3</div></div>';
        $('header').append(badge);
        expect($('#conversations_badge .badge_count').text().trim()).toEqual('3');
        expect($('.conversation-wrapper > .conversation.selected .unread_message_count').text().trim()).toEqual('2');
        new app.views.Conversations();
        expect($('#conversations_badge .badge_count').text().trim()).toEqual('1');
      });

      it('removes the badge_count in the header if there are no unread messages left', function() {
        var badge = '<div id="conversations_badge"><div class="badge_count">2</div></div>';
        $('header').append(badge);
        expect($('#conversations_badge .badge_count').text().trim()).toEqual('2');
        expect($('.conversation-wrapper > .conversation.selected .unread_message_count').text().trim()).toEqual('2');
        new app.views.Conversations();
        expect($('#conversations_badge .badge_count').text().trim()).toEqual('0');
        expect($('#conversations_badge .badge_count')).toHaveClass('hidden');
      });
    });

    context('for read conversations', function() {
      beforeEach(function() {
        spec.loadFixture('conversations_read');
      });

      it('does not change the badge_count in the header', function() {
        var badge = '<div id="conversations_badge"><div class="badge_count">3</div></div>';
        $('header').append(badge);
        expect($('#conversations_badge .badge_count').text().trim()).toEqual('3');
        new app.views.Conversations();
        expect($('#conversations_badge .badge_count').text().trim()).toEqual('3');
      });
    });
  });
});
