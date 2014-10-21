// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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

      var charCode = this._fixedCharCodeAt(str, 0);
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

      else if(charCode>=68096 && charCode<=68184)  // Kharoshthi
                return true;

      else if(charCode>=67840 && charCode<=67871)  // Phoenician
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
    },

    // source: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/charCodeAt
    _fixedCharCodeAt: function(str, idx) {
      str += '';
      var code,
          end = str.length;

      var surrogatePairs = /[\uD800-\uDBFF][\uDC00-\uDFFF]/g;
      while ((surrogatePairs.exec(str)) != null) {
        var li = surrogatePairs.lastIndex;
        if (li - 2 < idx) {
          idx++;
        }
        else {
          break;
        }
      }

      if (idx >= end || idx < 0) {
        return NaN;
      }

      code = str.charCodeAt(idx);

      var hi, low;
      if (0xD800 <= code && code <= 0xDBFF) {
        hi = code;
        low = str.charCodeAt(idx+1);
        // Go one further, since one of the "characters" is part of a surrogate pair
        return ((hi - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
      }
      return code;
    }
  };
})();
// @license-end

