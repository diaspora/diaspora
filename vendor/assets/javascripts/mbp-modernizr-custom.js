/*!
 * Modernizr v1.8pre
 * http://www.modernizr.com
 *
 * Developed by: 
 * - Faruk Ates  http://farukat.es/
 * - Paul Irish  http://paulirish.com/
 *
 * Copyright (c) 2009-2011
 * Dual-licensed under the BSD or MIT licenses.
 * http://www.modernizr.com/license/
 */
window.Modernizr=(function(o,v,k){var 
e="1.8pre",H={},x=true,F=v.documentElement,h=v.head||v.getElementsByTagName("head")[0],G="modernizr",D=v.createElement(G),B=D.style,g=v.createElement("input"),E=":)",y=Object.prototype.toString,z=" 
-webkit- -moz- -o- -ms- -khtml- ".split(" "),q="Webkit Moz O ms 
Khtml".split(" 
"),I={svg:"http://www.w3.org/2000/svg"},j={},d={},w={},C=[],A,m=v.getElementsByTagName("script")[0],c=(function(L){var 
J={},M=v.createElement("body"),K=v.createElement("div");K.id=G+"-mqtest";M.appendChild(K);return 
function(O){if(J[O]==k){if(o.matchMedia){return(J[O]=matchMedia(O).matches)}var 
N=v.createElement("style"),P="@media "+O+" { #"+G+"-mqtest { position: 
absolute; } 
}";N.type="text/css";if(N.styleSheet){N.styleSheet.cssText=P}else{N.appendChild(v.createTextNode(P))}m.parentNode.insertBefore(M,m);m.parentNode.insertBefore(N,m);J[O]=(o.getComputedStyle?getComputedStyle(K,null):K.currentStyle)["position"]=="absolute";M.parentNode.removeChild(M);N.parentNode.removeChild(N)}return 
J[O]}})(),t=(function(){var 
K={select:"input",change:"input",submit:"form",reset:"form",error:"img",load:"img",abort:"img"};function 
J(L,N){N=N||v.createElement(K[L]||"div");L="on"+L;var M=(L in 
N);if(!M){if(!N.setAttribute){N=v.createElement("div")}if(N.setAttribute&&N.removeAttribute){N.setAttribute(L,"");M=l(N[L],"function");if(!l(N[L],k)){N[L]=k}N.removeAttribute(L)}}N=null;return 
M}return J})();var 
r=({}).hasOwnProperty,p;if(!l(r,k)&&!l(r.call,k)){p=function(J,K){return 
r.call(J,K)}}else{p=function(J,K){return((K in 
J)&&l(J.constructor.prototype[K],k))}}function u(J){B.cssText=J}function 
b(K,J){return u(z.join(K+";")+(J||""))}function l(K,J){return typeof 
K===J}function n(K,J){return !!~(""+K).indexOf(J)}function 
f(K,L){for(var J in K){if(B[K[J]]!==k&&(!L||L(K[J],D))){return 
true}}}function a(M,L){var 
K=M.charAt(0).toUpperCase()+M.substr(1),J=(M+" "+q.join(K+" 
")+K).split(" ");return !!f(J,L)}j.flexbox=function(){function 
K(P,R,Q,O){R+=":";P.style.cssText=(R+z.join(Q+";"+R)).slice(0,-R.length)+(O||"")}function 
M(P,R,Q,O){P.style.cssText=z.join(R+":"+Q+";")+(O||"")}var 
N=v.createElement("div"),L=v.createElement("div");K(N,"display","box","width:42px;padding:0;");M(L,"box-flex","1","width:10px;");N.appendChild(L);F.appendChild(N);var 
J=L.offsetWidth===42;N.removeChild(L);F.removeChild(N);return 
J};j.canvas=function(){var J=v.createElement("canvas");return 
!!(J.getContext&&J.getContext("2d"))};j.canvastext=function(){return 
!!(H.canvas&&l(v.createElement("canvas").getContext("2d").fillText,"function"))};j.webgl=function(){return 
!!o.WebGLRenderingContext};j.touch=function(){return("ontouchstart" in 
o)||c("("+z.join("touch-enabled),(")+"modernizr)")};j.geolocation=function(){return 
!!navigator.geolocation};j.postmessage=function(){return 
!!o.postMessage};j.websqldatabase=function(){var 
J=!!o.openDatabase;return J};j.indexedDB=function(){for(var 
K=-1,J=q.length;++K<J;){if(o[q[K].toLowerCase()+"IndexedDB"]){return 
true}}return !!o.indexedDB};j.hashchange=function(){return 
t("hashchange",o)&&(v.documentMode===k||v.documentMode>7)};j.history=function(){return 
!!(o.history&&history.pushState)};j.draganddrop=function(){return 
t("dragstart")&&t("drop")};j.websockets=function(){return("WebSocket" in 
o)};j.rgba=function(){u("background-color:rgba(150,255,150,.5)");return 
n(B.backgroundColor,"rgba")};j.hsla=function(){u("background-color:hsla(120,40%,100%,.5)");return 
n(B.backgroundColor,"rgba")||n(B.backgroundColor,"hsla")};j.multiplebgs=function(){u("background:url(//:),url(//:),red 
url(//:)");return new 
RegExp("(url\\s*\\(.*?){3}").test(B.background)};j.backgroundsize=function(){return 
a("backgroundSize")};j.borderimage=function(){return 
a("borderImage")};j.borderradius=function(){return 
a("borderRadius","",function(J){return 
n(J,"orderRadius")})};j.boxshadow=function(){return 
a("boxShadow")};j.textshadow=function(){return 
v.createElement("div").style.textShadow===""};j.opacity=function(){b("opacity:.55");return/^0.55$/.test(B.opacity)};j.cssanimations=function(){return 
a("animationName")};j.csscolumns=function(){return 
a("columnCount")};j.cssgradients=function(){var 
L="background-image:",K="gradient(linear,left top,right 
bottom,from(#9f9),to(white));",J="linear-gradient(left top,#9f9, 
white);";u((L+z.join(K+L)+z.join(J+L)).slice(0,-L.length));return 
n(B.backgroundImage,"gradient")};j.cssreflections=function(){return 
a("boxReflect")};j.csstransforms=function(){return 
!!f(["transformProperty","WebkitTransform","MozTransform","OTransform","msTransform"])};j.csstransforms3d=function(){var 
J=!!f(["perspectiveProperty","WebkitPerspective","MozPerspective","OPerspective","msPerspective"]);if(J&&"webkitPerspective" 
in F.style){J=c("("+z.join("transform-3d),(")+"modernizr)")}return 
J};j.csstransitions=function(){return 
a("transitionProperty")};j.fontface=function(){var 
N,K,M=h||F,O=v.createElement("style"),J=v.implementation||{hasFeature:function(){return 
false}};O.type="text/css";M.insertBefore(O,M.firstChild);N=O.sheet||O.styleSheet;var 
L=J.hasFeature("CSS2","")?function(R){if(!(N&&R)){return false}var 
P=false;try{N.insertRule(R,0);P=(/src/i).test(N.cssRules[0].cssText);N.deleteRule(N.cssRules.length-1)}catch(Q){}return 
P}:function(P){if(!(N&&P)){return false}N.cssText=P;return 
N.cssText.length!==0&&(/src/i).test(N.cssText)&&N.cssText.replace(/\r+|\n+/g,"").indexOf(P.split(" 
")[0])===0};K=L('@font-face { font-family: "font"; src: url("//:"); 
}');M.removeChild(O);return K};j.video=function(){var 
L=v.createElement("video"),J=!!L.canPlayType;if(J){J=new 
Boolean(J);J.ogg=L.canPlayType('video/ogg; codecs="theora"');var 
K='video/mp4; 
codecs="avc1.42E01E';J.h264=L.canPlayType(K+'"')||L.canPlayType(K+', 
mp4a.40.2"');J.webm=L.canPlayType('video/webm; codecs="vp8, 
vorbis"')}return J};j.audio=function(){var 
K=v.createElement("audio"),J=!!K.canPlayType;if(J){J=new 
Boolean(J);J.ogg=K.canPlayType('audio/ogg; 
codecs="vorbis"');J.mp3=K.canPlayType("audio/mpeg;");J.wav=K.canPlayType('audio/wav; 
codecs="1"');J.m4a=K.canPlayType("audio/x-m4a;")||K.canPlayType("audio/aac;")}return 
J};j.localstorage=function(){try{return 
!!localStorage.getItem}catch(J){return 
false}};j.sessionstorage=function(){try{return 
!!sessionStorage.getItem}catch(J){return 
false}};j.webWorkers=function(){return 
!!o.Worker};j.applicationcache=function(){return 
!!o.applicationCache};j.svg=function(){return 
!!v.createElementNS&&!!v.createElementNS(I.svg,"svg").createSVGRect};j.inlinesvg=function(){var 
J=v.createElement("div");J.innerHTML="<svg/>";return(J.firstChild&&J.firstChild.namespaceURI)==I.svg};j.smil=function(){return 
!!v.createElementNS&&/SVG/.test(y.call(v.createElementNS(I.svg,"animate")))};j.svgclippaths=function(){return 
!!v.createElementNS&&/SVG/.test(y.call(v.createElementNS(I.svg,"clipPath")))};function 
s(){H.input=(function(L){for(var K=0,J=L.length;K<J;K++){w[L[K]]=!!(L[K] 
in g)}return w})("autocomplete autofocus list placeholder max min 
multiple pattern required step".split(" 
"));H.inputtypes=(function(M){for(var 
L=0,K,O,N,J=M.length;L<J;L++){g.setAttribute("type",O=M[L]);K=g.type!=="text";if(K){g.value=E;g.style.cssText="position:absolute;visibility:hidden;";if(/^range$/.test(O)&&g.style.WebkitAppearance!==k){F.appendChild(g);N=v.defaultView;K=N.getComputedStyle&&N.getComputedStyle(g,null).WebkitAppearance!=="textfield"&&(g.offsetHeight!==0);F.removeChild(g)}else{if(/^(search|tel)$/.test(O)){}else{if(/^(url|email)$/.test(O)){K=g.checkValidity&&g.checkValidity()===false}else{if(/^color$/.test(O)){F.appendChild(g);F.offsetWidth;K=g.value!=E;F.removeChild(g)}else{K=g.value!=E}}}}}d[M[L]]=!!K}return 
d})("search tel url email datetime date month week time datetime-local 
number range color".split(" "))}for(var i in 
j){if(p(j,i)){A=i.toLowerCase();H[A]=j[i]();C.push((H[A]?"":"no-")+A)}}if(!H.input){s()}H.crosswindowmessaging=H.postmessage;H.historymanagement=H.history;H.addTest=function(J,K){J=J.toLowerCase();if(H[J]){return}K=!!(K());F.className+=" 
"+(K?"":"no-")+J;H[J]=K;return 
H};u("");D=g=null;if(x&&o.attachEvent&&(function(){var 
J=v.createElement("div");J.innerHTML="<elem></elem>";return 
J.childNodes.length!==1})()){(function(P,aa){P.iepp=P.iepp||{};var 
Q=P.iepp,Z=Q.html5elements||"abbr|article|aside|audio|canvas|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",K=Z.split("|"),Y=K.length,X=new 
RegExp("(^|\\s)("+Z+")","gi"),W=new 
RegExp("<(/*)("+Z+")","gi"),O=/^\s*[\{\}]\s*$/,J=new 
RegExp("(^|[^\\n]*?\\s)("+Z+")([^\\n]*)({[\\n\\w\\W]*?})","gi"),M=aa.createDocumentFragment(),U=aa.documentElement,R=U.firstChild,S=aa.createElement("body"),N=aa.createElement("style"),V=/print|all/,T;function 
L(ac){var 
ab=-1;while(++ab<Y){ac.createElement(K[ab])}}Q.getCSS=function(af,ad){if(af+""===k){return""}var 
ac=-1,ab=af.length,ag,ae=[];while(++ac<ab){ag=af[ac];if(ag.disabled){continue}ad=ag.media||ad;if(V.test(ad)){ae.push(Q.getCSS(ag.imports,ad),ag.cssText)}ad="all"}return 
ae.join("")};Q.parseCSS=function(ac){var 
ab=[],ad;while((ad=J.exec(ac))!=null){ab.push(((O.exec(ad[1])?"\n":ad[1])+ad[2]+ad[3]).replace(X,"$1.iepp_$2")+ad[4])}return 
ab.join("\n")};Q.writeHTML=function(){var 
ac=-1;T=T||aa.body;while(++ac<Y){var 
ad=aa.getElementsByTagName(K[ac]),ae=ad.length,ab=-1;while(++ab<ae){if(ad[ab].className.indexOf("iepp_")<0){ad[ab].className+=" 
iepp_"+K[ac]}}}M.appendChild(T);U.appendChild(S);S.className=T.className;S.id=T.id;S.innerHTML=T.innerHTML.replace(W,"<$1font")};Q._beforePrint=function(){N.styleSheet.cssText=Q.parseCSS(Q.getCSS(aa.styleSheets,"all"));Q.writeHTML()};Q.restoreHTML=function(){S.innerHTML="";U.removeChild(S);U.appendChild(T)};Q._afterPrint=function(){Q.restoreHTML();N.styleSheet.cssText=""};L(aa);L(M);if(Q.disablePP){return}R.insertBefore(N,R.firstChild);N.media="print";N.className="iepp-printshim";P.attachEvent("onbeforeprint",Q._beforePrint);P.attachEvent("onafterprint",Q._afterPrint)})(o,v)}H._enableHTML5=x;H._version=e;H.mq=c;H.isEventSupported=t;F.className=F.className.replace(/\bno-js\b/,"")+" 
js "+C.join(" ");return H})(this,this.document);
/*yepnope1.0.1|WTFPL*/(function(a,b,c){function H(){var 
a=z;a.loader={load:G,i:0};return a}function G(a,b,c){var 
e=b=="c"?r:q;i=0,b=b||"j",u(a)?F(e,a,b,this.i++,d,c):(h.splice(this.i++,0,a),h.length==1&&E());return 
this}function F(a,c,d,g,j,l){function 
q(){!o&&A(n.readyState)&&(p.r=o=1,!i&&B(),n.onload=n.onreadystatechange=null,e(function(){m.removeChild(n)},0))}var 
n=b.createElement(a),o=0,p={t:d,s:c,e:l};n.src=n.data=c,!k&&(n.style.display="none"),n.width=n.height="0",a!="object"&&(n.type=d),n.onload=n.onreadystatechange=q,a=="img"?n.onerror=q:a=="script"&&(n.onerror=function(){p.e=p.r=1,E()}),h.splice(g,0,p),m.insertBefore(n,k?null:f),e(function(){o||(m.removeChild(n),p.r=p.e=o=1,B())},z.errorTimeout)}function 
E(){var 
a=h.shift();i=1,a?a.t?e(function(){a.t=="c"?D(a):C(a)},0):(a(),B()):i=0}function 
D(a){var 
c=b.createElement("link"),d;c.href=a.s,c.rel="stylesheet",c.type="text/css",!a.e&&(o||j)?function 
g(a){e(function(){if(!d)try{a.sheet.cssRules.length?(d=1,B()):g(a)}catch(b){b.code==1e3||b.message=="security"||b.message=="denied"?(d=1,e(function(){B()},0)):g(a)}},0)}(c):(c.onload=function(){d||(d=1,e(function(){B()},0))},a.e&&c.onload()),e(function(){d||(d=1,B())},z.errorTimeout),!a.e&&f.parentNode.insertBefore(c,f)}function 
C(a){var 
c=b.createElement("script"),d;c.src=a.s,c.onreadystatechange=c.onload=function(){!d&&A(c.readyState)&&(d=1,B(),c.onload=c.onreadystatechange=null)},e(function(){d||(d=1,B())},z.errorTimeout),a.e?c.onload():f.parentNode.insertBefore(c,f)}function 
B(){var a=1,b=-1;while(h.length- 
++b)if(h[b].s&&!(a=h[b].r))break;a&&E()}function 
A(a){return!a||a=="loaded"||a=="complete"}var 
d=b.documentElement,e=a.setTimeout,f=b.getElementsByTagName("script")[0],g=({}).toString,h=[],i=0,j="MozAppearance"in 
d.style,k=j&&!!b.createRange().compareNode,l=j&&!k,m=k?d:f.parentNode,n=a.opera&&g.call(a.opera)=="[object 
Opera]",o="webkitAppearance"in d.style,p=o&&"async"in 
b.createElement("script"),q=j?"object":n||p?"img":"script",r=o?"img":q,s=Array.isArray||function(a){return 
g.call(a)=="[object Array]"},t=function(a){return typeof 
a=="object"},u=function(a){return typeof 
a=="string"},v=function(a){return g.call(a)=="[object 
Function]"},w=[],x={},y,z;z=function(a){function h(a,b){function 
i(a){if(u(a))g(a,f,b,0,c);else if(t(a))for(h in 
a)a.hasOwnProperty(h)&&g(a[h],f,b,h,c)}var 
c=!!a.test,d=c?a.yep:a.nope,e=a.load||a.both,f=a.callback,h;i(d),i(e),a.complete&&b.load(a.complete)}function 
g(a,b,d,e,g){var 
h=f(a),i=h.autoCallback;if(!h.bypass){b&&(b=v(b)?b:b[a]||b[e]||b[a.split("/").pop().split("?")[0]]);if(h.instead)return 
h.instead(a,b,d,e,g);d.load(h.url,h.forceCSS||!h.forceJS&&/css$/.test(h.url)?"c":c,h.noexec),(v(b)||v(i))&&d.load(function(){H(),b&&b(h.origUrl,g,e),i&&i(h.origUrl,g,e)})}}function 
f(a){var 
b=a.split("!"),c=w.length,d=b.pop(),e=b.length,f={url:d,origUrl:d,prefixes:b},g,h;for(h=0;h<e;h++)g=x[b[h]],g&&(f=g(f));for(h=0;h<c;h++)f=w[h](f);return 
f}var b,d,e=this.yepnope.loader;if(u(a))g(a,0,e,0);else 
if(s(a))for(b=0;b<a.length;b++)d=a[b],u(d)?g(d,0,e,0):s(d)?z(d):t(d)&&h(d,e);else 
t(a)&&h(a,e)},z.addPrefix=function(a,b){x[a]=b},z.addFilter=function(a){w.push(a)},z.errorTimeout=1e4,b.readyState==null&&b.addEventListener&&(b.readyState="loading",b.addEventListener("DOMContentLoaded",y=function(){b.removeEventListener("DOMContentLoaded",y,0),b.readyState="complete"},0)),a.yepnope=H()})(this,this.document);

