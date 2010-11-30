/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("EditPane", function() {
    describe("setTranslations", function() {
      it("sets the translations object", function(){
        var input = {doneEditing: 'I am done editing'};
        EditPane.setTranslations(input);
        expect(EditPane.translations.doneEditing).toEqual('I am done editing');
      });
  });
});
