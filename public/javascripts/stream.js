/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Stream = {
  selector: "#main_stream",

  initialize: function() {
    Diaspora.page.directionDetector.updateBinds();
  }
};

$(document).ready(function() {
  if( Diaspora.backboneEnabled() ){ return }

  if( $(Stream.selector).length == 0 ) { return }
  Stream.initializeLives();
});
