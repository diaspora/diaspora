(function() {
  app.helpers.txtDirection = {
    setCssFor: function(str, on_element) {
      if( this.isRTL(str) ) {
        $(on_element).css('direction', 'rtl');
      } else {
        $(on_element).css('direction', 'ltr');
      }
    },

    classFor: function(str) {
      if( this.isRTL(str) ) return 'rtl';
      return 'ltr';
    },

    isRTL: function(str) {
      if(typeof str !== "string" || str.length < 1) {
                return false;
      }

      var charCode = str.charCodeAt(0);
      if(charCode >= 1536 && charCode <= 1791) // Sarabic, Persian, ...
                return true;

      else if(charCode >= 65136 && charCode <= 65279) // Arabic present 1
                return true;

      else if(charCode >= 64336 && charCode <= 65023) // Arabic present 2
                return true;

      else if(charCode>=1424 && charCode<=1535) // Hebrew
                return true;

      else if(charCode>=64256 && charCode<=64335) // Hebrew present
                return true;

      else if(charCode>=1792 && charCode<=1871) // Syriac
                return true;

      else if(charCode>=1920 && charCode<=1983) // Thaana
                return true;

      else if(charCode>=1984 && charCode<=2047) // NKo
                return true;

      else if(charCode>=11568 && charCode<=11647) // Tifinagh
                return true;

      return false;
    }
  };
})();
