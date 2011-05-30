// Developed by Robert Nyman/DOMAssistant team, code/licensing: http://domassistant.googlecode.com/, documentation: http://www.domassistant.com/documentation, version 2.8
var DOMAssistant = function () {
	var HTMLArray = function () {
		// Constructor
	},
	w = window, _$ = w.$, _$$ = w.$$,
	isIE = /*@cc_on!@*/false,
	isIE5 = isIE && parseFloat(navigator.appVersion) < 6,
	sort, tagCache = {}, lastCache = {}, useCache = true,
	slice = Array.prototype.slice,
	camel = {
		"accesskey": "accessKey",
		"class": "className",
		"colspan": "colSpan",
		"for": "htmlFor",
		"maxlength": "maxLength",
		"readonly": "readOnly",
		"rowspan": "rowSpan",
		"tabindex": "tabIndex",
		"valign": "vAlign",
		"cellspacing": "cellSpacing",
		"cellpadding": "cellPadding"
	},
	regex = {
		rules: /\s*,\s*/g,
		selector: /^(\w+|\*)?(#[\w\u00C0-\uFFFF\-=$]+)?((\.[\w\u00C0-\uFFFF\-]+)*)?((\[\w+\s*([~^$*|])?(=\s*([-\w\u00C0-\uFFFF\s.]+|"[^"]*"|'[^']*'))?\]+)*)?((:\w[-\w]*(\((odd|even|\-?\d*n?([-+]\d+)?|[:#]?[-\w\u00C0-\uFFFF.]+|"[^"]*"|'[^']*'|((\w*\.[-\w\u00C0-\uFFFF]+)*)?|(\[#?\w+([~^$*|])?=?[-\w\u00C0-\uFFFF\s.'"]+\]+)|(:\w[-\w]*\(.+\)))\))?)*)?([+>~])?/,
		selectorSplit: /(?:\[.*\]|\(.*\)|[^\s+>~[(])+|[+>~]/g,
		id: /^#([-\w\u00C0-\uFFFF=$]+)$/,
		tag: /^\w+/,
		relation: /^[+>~]$/,
		pseudo: /^:(\w[-\w]*)(\((.+)\))?$/,
		pseudos: /:(\w[-\w]*)(\((([^(]+)|([^(]+\([^(]+)\))\))?/g,
		attribs: /\[(\w+)\s*([~^$*|])?(=)?\s*([^\[\]]*|"[^"]*"|'[^']*')?\](?=$|\[|:|\s)/g,
		classes: /\.([-\w\u00C0-\uFFFF]+)/g,
		quoted: /^["'](.*)["']$/,
		nth: /^((odd|even)|([1-9]\d*)|((([1-9]\d*)?)n([-+]\d+)?)|(-(([1-9]\d*)?)n\+(\d+)))$/,
		special: /(:check|:enabl|\bselect)ed\b/
	},
	navigate = function (node, direction, checkTagName) {
		var oldName = node.tagName;
		while ((node = node[direction + "Sibling"]) && (node.nodeType !== 1 || (checkTagName? node.tagName !== oldName : node.tagName === "!"))) {}
		return node;
	},
	def = function (obj) {
		return typeof obj !== "undefined";
	},
	sortDocumentOrder = function (elmArray) {
		return (sortDocumentOrder = elmArray[0].compareDocumentPosition? function (elmArray) { return elmArray.sort( function (a, b) { return 3 - (a.compareDocumentPosition(b) & 6); } ); } :
			isIE? function (elmArray) { return elmArray.sort( function (a, b) { return a.sourceIndex - b.sourceIndex; } ); } :
			function (elmArray) { return elmArray.sort( function (a, b) {
				var range1 = document.createRange(), range2 = document.createRange();
				range1.setStart(a, 0);
				range1.setEnd(a, 0);
				range2.setStart(b, 0);
				range2.setEnd(b, 0);
				return range1.compareBoundaryPoints(Range.START_TO_END, range2);
			} ); })(elmArray);
	};
	var pushAll = function (set1, set2) {
		set1.push.apply(set1, slice.apply(set2));
		return set1;
	};
	if (isIE) {
		pushAll = function (set1, set2) {
			if (set2.slice) {
				return set1.concat(set2);
			}
			var i=0, item;
			while ((item = set2[i++])) {
				set1[set1.length] = item;
			}
			return set1;
		};
	}
	return {
		isIE : isIE,
		camel : camel,
		def : def,
		allMethods : [],
		publicMethods : [
			"prev",
			"next",
			"hasChild",
			"cssSelect",
			"elmsByClass",
			"elmsByAttribute",
			"elmsByTag"
		],
		
		harmonize : function () {
			w.$ = _$;
			w.$$ = _$$;
			return this;
		},
		
		initCore : function () {
			this.applyMethod.call(w, "$", this.$);
			this.applyMethod.call(w, "$$", this.$$);
			w.DOMAssistant = this;
			if (isIE) {
				HTMLArray = Array;
			}
			HTMLArray.prototype = [];
			(function (H) {
				H.each = function (fn, context) {
					for (var i=0, il=this.length; i<il; i++) {
						if (fn.call(context || this[i], this[i], i, this) === false) {
							break;
						}
					}
					return this;
				};
				H.first = function () {
					return def(this[0])? DOMAssistant.addMethodsToElm(this[0]) : null;
				};
				H.end = function () {
					return this.previousSet;
				};
				H.indexOf = H.indexOf || function (elm) {
					for (var i=0, il=this.length; i<il; i++) {
						if (i in this && this[i] === elm) {
							return i;
						}
					}
					return -1;
				};
				H.map = function (fn, context) {
					var res = [];
					for (var i=0, il=this.length; i<il; i++) {
						if (i in this) {
							res[i] = fn.call(context || this[i], this[i], i, this);
						}
					}
					return res;
				};
				H.filter = function (fn, context) {
					var res = new HTMLArray();
					res.previousSet = this;
					for (var i=0, il=this.length; i<il; i++) {
						if (i in this && fn.call(context || this[i], this[i], i, this)) {
							res.push(this[i]);
						}
					}
					return res;
				};
				H.every = function (fn, context) {
					for (var i=0, il=this.length; i<il; i++) {
						if (i in this && !fn.call(context || this[i], this[i], i, this)) {
							return false;
						}
					}
					return true;
				};
				H.some = function (fn, context) {
					for (var i=0, il=this.length; i<il; i++) {
						if (i in this && fn.call(context || this[i], this[i], i, this)) {
							return true;
						}
					}
					return false;
				};
			})(HTMLArray.prototype);
			this.attach(this);
		},
		
		addMethods : function (name, method) {
			if (!def(this.allMethods[name])) {
				this.allMethods[name] = method;
				this.addHTMLArrayPrototype(name, method);
			}
		},
		
		addMethodsToElm : function (elm) {
			for (var method in this.allMethods) {
				if (def(this.allMethods[method])) {
					this.applyMethod.call(elm, method, this.allMethods[method]);
				}
			}
			return elm;
		},
		
		applyMethod : function (method, func) {
			if (typeof this[method] !== "function") {
				this[method] = func;
			}
		},
		
		attach : function (plugin) {
			var publicMethods = plugin.publicMethods;
			if (!def(publicMethods)) {
				for (var method in plugin) {
					if (method !== "init" && def(plugin[method])) {
						this.addMethods(method, plugin[method]);
					}
				}
			}
			else if (publicMethods.constructor === Array) {
				for (var i=0, current; (current=publicMethods[i]); i++) {
					this.addMethods(current, plugin[current]);
				}
			}
			if (typeof plugin.init === "function") {
				plugin.init();
			}
		},
		
		addHTMLArrayPrototype : function (name, method) {
			HTMLArray.prototype[name] = function () {
				var elmsToReturn = new HTMLArray();
				elmsToReturn.previousSet = this;
				for (var i=0, il=this.length; i<il; i++) {
					elmsToReturn.push(method.apply(DOMAssistant.$$(this[i]), arguments));
				}
				return elmsToReturn;
			};
		},
		
		cleanUp : function (elm) {
			var children = elm.all || elm.getElementsByTagName("*");
			for (var i=0, child; (child=children[i++]);) {
				if (child.hasData && child.hasData()) {
					if (child.removeEvent) { child.removeEvent(); }
					child.unstore();
				}
			}
			elm.innerHTML = "";
		},
		
		setCache : function (cache) {
			useCache = cache;
		},
		
		$ : function () {
			var obj = arguments[0];
			if (arguments.length === 1 && (typeof obj === "object" || (typeof obj === "function" && !!obj.nodeName))) {
				return DOMAssistant.$$(obj);
			}
			var elm = !!obj? new HTMLArray() : null;
			for (var i=0, arg, idMatch; (arg=arguments[i]); i++) {
				if (typeof arg === "string") {
					arg = arg.replace(/^[^#\(]*(#)/, "$1");
					if (regex.id.test(arg)) {
						if ((idMatch = DOMAssistant.$$(arg.substr(1), false))) {
							elm.push(idMatch);
						}
					}
					else {
						var doc = (document.all || document.getElementsByTagName("*")).length;
						elm = (!document.querySelectorAll && useCache && lastCache.rule && lastCache.rule === arg && lastCache.doc === doc)? lastCache.elms : pushAll(elm, DOMAssistant.cssSelection.call(document, arg));
						lastCache = { rule: arg, elms: elm, doc: doc };
					}
				}
			}
			return elm;
		},
		
		$$ : function (id, addMethods) {
			var elm = (typeof id === "object" || typeof id === "function" && !!id.nodeName)? id : document.getElementById(id),
				applyMethods = def(addMethods)? addMethods : true,
				getId = function(el) { var eid = el.id; return typeof eid !== "object"? eid : el.attributes.id.nodeValue; };
			if (typeof id === "string" && elm && getId(elm) !== id) {
				elm = null;
				for (var i=0, item; (item=document.all[i]); i++) {
					if (getId(item) === id) {
						elm = item;
						break;
					}
				}
			}
			if (elm && applyMethods && !elm.next) {
				DOMAssistant.addMethodsToElm(elm);
			}
			return elm;
		},
		
		prev : function () {
			return DOMAssistant.$$(navigate(this, "previous"));
		},

		next : function () {
			return DOMAssistant.$$(navigate(this, "next"));
		},
		
		hasChild: function (elm) {
			return this === document || this !== elm && (this.contains? this.contains(elm) : !!(this.compareDocumentPosition(elm) & 16));
		},

		getSequence : function (expression) {
			var start, add = 2, max = -1, modVal = -1,
				pseudoVal = regex.nth.exec(expression.replace(/^0n\+/, "").replace(/^2n$/, "even").replace(/^2n+1$/, "odd"));
			if (!pseudoVal) {
				return null;
			}
			if (pseudoVal[2]) {	// odd or even
				start = (pseudoVal[2] === "odd")? 1 : 2;
				modVal = (start === 1)? 1 : 0;
			}
			else if (pseudoVal[3]) {	// single digit
				start = max = parseInt(pseudoVal[3], 10);
				add = 0;
			}
			else if (pseudoVal[4]) {	// an+b
				add = pseudoVal[6]? parseInt(pseudoVal[6], 10) : 1;
				start = pseudoVal[7]? parseInt(pseudoVal[7], 10) : 0;
				while (start < 1) {
					start += add;
				}
				modVal = (start >= add)? (start - add) % add : start;
			}
			else if (pseudoVal[8]) {	// -an+b
				add = pseudoVal[10]? parseInt(pseudoVal[10], 10) : 1;
				start = max = parseInt(pseudoVal[11], 10);
				while (start > add) {
					start -= add;
				}
				modVal = (max >= add)? (max - add) % add : max;
			}
			return { start: start, add: add, max: max, modVal: modVal };
		},
		
		cssByDOM : function (cssRule) {
			var prevParents, currentRule, cssSelectors, childOrSiblingRef, nextTag, nextRegExp, current, previous, prevParent, notElm, addElm, iteratorNext, childElm, sequence, anyTag,
				elm = new HTMLArray(), index = elm.indexOf, prevElm = [], matchingElms = [], cssRules = cssRule.replace(regex.rules, ",").split(","), splitRule = {};
			function clearAdded (elm) {
				elm = elm || prevElm;
				for (var n=elm.length; n--;) {
					elm[n].added = null;
					elm[n].removeAttribute("added");
				}
			}
			function clearChildElms () {
				for (var n=prevParents.length; n--;) {
					prevParents[n].childElms = null;
				}
			}
			function subtractArray (arr1, arr2) {
				for (var i=0, src1; (src1=arr1[i]); i++) {
					var found = false;
					for (var j=0, src2; (src2=arr2[j]); j++) {
						if (src2 === src1) {
							found = true;
							arr2.splice(j, 1);
							break;
						}
					}
					if (found) {
						arr1.splice(i--, 1);
					}
				}
				return arr1;
			}
			function getAttr (elm, attr) {
				return (isIE || regex.special.test(attr))? elm[camel[attr.toLowerCase()] || attr] : elm.getAttribute(attr, 2);
			}
			function attrToRegExp (attrVal, substrOperator) {
				attrVal = attrVal? attrVal.replace(regex.quoted, "$1").replace(/(\.|\[|\])/g, "\\$1") : null;
				return {
					"^": "^" + attrVal,
					"$": attrVal + "$",
					"*": attrVal,
					"|": "^" + attrVal + "(\\-\\w+)*$",
					"~": "\\b" + attrVal + "\\b"
				}[substrOperator] || (attrVal !== null? "^" + attrVal + "$" : attrVal);
			}
			function notComment(el) {
				return (el || this).tagName !== "!";
			}
			function getTags (tag, context) {
				return isIE5? (tag === "*"? context.all : context.all.tags(tag)) : context.getElementsByTagName(tag);
			}
			function getElementsByTagName (tag, parent) {
				tag = tag || "*";
				parent = parent || document;
				return (parent === document || parent.lastModified)? tagCache[tag] || (tagCache[tag] = getTags(tag, document)) : getTags(tag, parent);
			}
			function getElementsByPseudo (previousMatch, pseudoClass, pseudoValue) {
				prevParents = [];
				var pseudo = pseudoClass.split("-"), matchingElms = [], idx = 0, checkNodeName = /\-of\-type$/.test(pseudoClass), recur,
				match = {
					first: function(el) { return !navigate(el, "previous", checkNodeName); },
					last: function(el) { return !navigate(el, "next", checkNodeName); },
					empty: function(el) { return !el.firstChild; },
					enabled: function(el) { return !el.disabled && el.type !== "hidden"; },
					disabled: function(el) { return el.disabled; },
					checked: function(el) { return el.checked; },
					contains: function(el) { return (el.innerText || el.textContent || "").indexOf(pseudoValue.replace(regex.quoted, "$1")) > -1; },
					other: function(el) { return getAttr(el, pseudoClass) === pseudoValue; }
				};
				function basicMatch(key) {
					while ((previous=previousMatch[idx++])) {
						if (notComment(previous) && match[key](previous)) {
							matchingElms[matchingElms.length] = previous;
						}
					}
					return matchingElms;
				}
				var word = pseudo[0] || null;
				if (word && match[word]) {
					return basicMatch(word);
				}
				switch (word) {
					case "only":
						var kParent, kTag;
						while ((previous=previousMatch[idx++])) {
							prevParent = previous.parentNode;
							var q = previous.nodeName;
							if (prevParent !== kParent || q !== kTag) {
								if (match.first(previous) && match.last(previous)) {
									matchingElms[matchingElms.length] = previous;
								}
								kParent = prevParent;
								kTag = q;
							}
						}
						break;
					case "nth":
						if (pseudoValue === "n") {
							matchingElms = previousMatch;
						}
						else {
							var direction = (pseudo[1] === "last")? ["lastChild", "previousSibling"] : ["firstChild", "nextSibling"];
							sequence = DOMAssistant.getSequence(pseudoValue);
							if (sequence) {
								while ((previous=previousMatch[idx++])) {
									prevParent = previous.parentNode;
									prevParent.childElms = prevParent.childElms || {};
									var p = previous.nodeName;
									if (!prevParent.childElms[p]) {
										var childCount = 0;
										iteratorNext = sequence.start;
										childElm = prevParent[direction[0]];
										while (childElm && (sequence.max < 0 || iteratorNext <= sequence.max)) {
											var c = childElm.nodeName;
											if ((checkNodeName && c === p) || (!checkNodeName && childElm.nodeType === 1 && c !== "!")) {
												if (++childCount === iteratorNext) {
													if (c === p) { matchingElms[matchingElms.length] = childElm; }
													iteratorNext += sequence.add;
												}
											}
											childElm = childElm[direction[1]];
										}
										if (anyTag) { sort++; }
										prevParent.childElms[p] = true;
										prevParents[prevParents.length] = prevParent;
									}
								}
								clearChildElms();
							}
						}
						break;
					case "target":
						var hash = document.location.hash.slice(1);
						if (hash) {
							while ((previous=previousMatch[idx++])) {
								if (getAttr(previous, "name") === hash || getAttr(previous, "id") === hash) {
									matchingElms[matchingElms.length] = previous;
									break;
								}
							}
						}
						break;
					case "not":
						if ((recur = regex.pseudo.exec(pseudoValue))) {
							matchingElms = subtractArray(previousMatch, getElementsByPseudo(previousMatch, recur[1]? recur[1].toLowerCase() : null, recur[3] || null));
						}
						else {
							for (var re in regex) {
								if (regex[re].lastIndex) {
									regex[re].lastIndex = 0;
								}
							}
							pseudoValue = pseudoValue.replace(regex.id, "[id=$1]");
							var notTag = regex.tag.exec(pseudoValue);
							var notClass = regex.classes.exec(pseudoValue);
							var notAttr = regex.attribs.exec(pseudoValue);
							var notRegExp = new RegExp(notAttr? attrToRegExp(notAttr[4], notAttr[2]) : "(^|\\s)" + (notTag? notTag[0] : notClass? notClass[1] : "") + "(\\s|$)", "i");
							while ((notElm=previousMatch[idx++])) {
								addElm = null;
								if (notTag && !notRegExp.test(notElm.nodeName) || notClass && !notRegExp.test(notElm.className)) {
									addElm = notElm;
								}
								else if (notAttr) {
									var att = getAttr(notElm, notAttr[1]);
									if (!def(att) || att === false || typeof att === "string" && !notRegExp.test(att)) {
										addElm = notElm;
									}
								}
								if (addElm && !addElm.added) {
									addElm.added = true;
									matchingElms[matchingElms.length] = addElm;
								}
							}
						}
						break;
					default: return basicMatch("other");
				}
				return matchingElms;
			}
			function pushUnique(set1, set2) {
				var i=0, s=set1, item;
				while ((item = set2[i++])) {
					if (!s.length || s.indexOf(item) < 0) {
						set1.push(item);
					}
				}
				return set1;
			}
			sort = -1;
			for (var a=0, tagBin=[]; (currentRule=cssRules[a]); a++) {
				if (!(cssSelectors = currentRule.match(regex.selectorSplit)) || a && index.call(cssRules.slice(0, a), currentRule) > -1) { continue; }
				prevElm = [this];
				for (var i=0, rule; (rule=cssSelectors[i]); i++) {
					matchingElms = [];
					if ((childOrSiblingRef = regex.relation.exec(rule))) {
						var idElm = null, nextWord = cssSelectors[i+1];
						if ((nextTag = regex.tag.exec(nextWord))) {
							nextTag = nextTag[0];
							nextRegExp = new RegExp("(^|\\s)" + nextTag + "(\\s|$)", "i");
						}
						else if (regex.id.test(nextWord)) {
							idElm = DOMAssistant.$(nextWord) || null;
						}
						for (var j=0, prevRef; (prevRef=prevElm[j]); j++) {
							switch (childOrSiblingRef[0]) {
								case ">":
									var children = idElm || getElementsByTagName(nextTag, prevRef);
									for (var k=0, child; (child=children[k]); k++) {
										if (child.parentNode === prevRef) {
											matchingElms[matchingElms.length] = child;
										}
									}
									break;
								case "+":
									if ((prevRef = navigate(prevRef, "next"))) {
										if ((idElm && idElm[0] === prevRef) || (!idElm && (!nextTag || nextRegExp.test(prevRef.nodeName)))) {
											matchingElms[matchingElms.length] = prevRef;
										}
									}
									break;
								case "~":
									while ((prevRef = prevRef.nextSibling) && !prevRef.added) {
										if ((idElm && idElm[0] === prevRef) || (!idElm && (!nextTag || nextRegExp.test(prevRef.nodeName)))) {
											prevRef.added = true;
											matchingElms[matchingElms.length] = prevRef;
										}
									}
									break;
							}
						}
						prevElm = matchingElms;
						clearAdded();
						rule = cssSelectors[++i];
						if (/^\w+$/.test(rule) || regex.id.test(rule)) {
							continue;
						}
						prevElm.skipTag = true;
					}
					var cssSelector = regex.selector.exec(rule);
					splitRule = {
						tag : cssSelector[1]? cssSelector[1] : "*",
						id : cssSelector[2],
						allClasses : cssSelector[3],
						allAttr : cssSelector[5],
						allPseudos : cssSelector[10]
					};
					anyTag = (splitRule.tag === "*");
					if (splitRule.id) {
						var u = 0, DOMElm = document.getElementById(splitRule.id.slice(1));
						if (DOMElm) {
							while (prevElm[u] && !DOMAssistant.hasChild.call(prevElm[u], DOMElm)) { u++; }
							matchingElms = (u < prevElm.length && (anyTag || splitRule.tag === DOMElm.tagName.toLowerCase()))? [DOMElm] : [];
						}
						prevElm = matchingElms;
					}
					else if (splitRule.tag && !prevElm.skipTag) {
						if (i===0 && !matchingElms.length && prevElm.length === 1) {
							prevElm = matchingElms = pushAll([], getElementsByTagName(splitRule.tag, prevElm[0]));
						}
						else {
							for (var l=0, ll=prevElm.length, tagCollectionMatches, tagMatch; l<ll; l++) {
								tagCollectionMatches = getElementsByTagName(splitRule.tag, prevElm[l]);
								for (var m=0; (tagMatch=tagCollectionMatches[m]); m++) {
									if (!tagMatch.added) {
										tagMatch.added = true;
										matchingElms[matchingElms.length] = tagMatch;
									}
								}
							}
							prevElm = matchingElms;
							clearAdded();
						}
					}
					if (!matchingElms.length) {
						break;
					}
					prevElm.skipTag = false;
					if (splitRule.allClasses) {
						var n = 0, matchingClassElms = [], allClasses = splitRule.allClasses.split(".").slice(1);
						while ((current = prevElm[n++])) {
							var matchCls = true, elmClass = current.className;
							if (elmClass && elmClass.length) {
								elmClass = elmClass.split(" ");
								for (var o=allClasses.length; o--;) {
									if (elmClass.indexOf(allClasses[o]) < 0) {
										matchCls = false;
										break;
									}
								}
								if (matchCls) {
									matchingClassElms[matchingClassElms.length] = current;
								}
							}
						}
						prevElm = matchingElms = matchingClassElms;
					}
					if (splitRule.allAttr) {
						var matchAttr, r = 0, regExpAttributes = [], matchingAttributeElms = [], allAttr = splitRule.allAttr.match(regex.attribs);
						for (var specialStrip = /^\[(selected|readonly)(\s*=.+)?\]$/, q=0, ql=allAttr.length, attributeMatch, attrVal; q<ql; q++) {
							regex.attribs.lastIndex = 0;
							attributeMatch = regex.attribs.exec(allAttr[q].replace(specialStrip, "[$1]"));
							attrVal = attrToRegExp(attributeMatch[4], attributeMatch[2] || null);
							regExpAttributes[q] = [(attrVal? new RegExp(attrVal) : null), attributeMatch[1]];
						}
						while ((current = matchingElms[r++])) {
							for (var s=0, sl=regExpAttributes.length; s<sl; s++) {
								var attributeRegExp = regExpAttributes[s][0], currentAttr = getAttr(current, regExpAttributes[s][1]);
								matchAttr = true;
								if (!attributeRegExp && currentAttr === true) { continue; }
								if ((!attributeRegExp && (!currentAttr || typeof currentAttr !== "string" || !currentAttr.length)) || (!!attributeRegExp && !attributeRegExp.test(currentAttr))) {
									matchAttr = false;
									break;
								}
							}
							if (matchAttr) {
								matchingAttributeElms[matchingAttributeElms.length] = current;
							}
						}
						prevElm = matchingElms = matchingAttributeElms;
					}
					if (splitRule.allPseudos) {
						var allPseudos = splitRule.allPseudos.match(regex.pseudos);
						for (var t=0, tl=allPseudos.length; t<tl; t++) {
							regex.pseudos.lastIndex = 0;
							var pseudo = regex.pseudos.exec(allPseudos[t]);
							var pseudoClass = pseudo[1]? pseudo[1].toLowerCase() : null;
							var pseudoValue = pseudo[3] || null;
							matchingElms = getElementsByPseudo(matchingElms, pseudoClass, pseudoValue);
							clearAdded(matchingElms);
						}
						prevElm = matchingElms;
					}
				}
				elm = ((tagBin.length && (anyTag || index.call(tagBin, splitRule.tag) >= 0 || index.call(tagBin, "*") >= 0))? pushUnique : pushAll)(elm, prevElm);
				tagBin.push(splitRule.tag);
				if (isIE && anyTag) { elm = elm.filter(notComment); }
			}
			return ((elm.length > 1 && cssRules.length > 1) || sort > 0)? sortDocumentOrder(elm) : elm;
		},
		
		cssByXpath : function (cssRule) {
			var ns = { xhtml: "http://www.w3.org/1999/xhtml" },
				prefix = (document.documentElement.namespaceURI === ns.xhtml)? "xhtml:" : "",
				nsResolver = function lookupNamespaceURI (prefix) {
					return ns[prefix] || null;
				};
			DOMAssistant.cssByXpath = function (cssRule) {
				var currentRule, cssSelectors, xPathExpression, cssSelector, splitRule, sequence,
					elm = new HTMLArray(), cssRules = cssRule.replace(regex.rules, ",").split(",");
				function attrToXPath (wrap) {
					var pre = wrap? "[" : "", post = wrap? "]" : "";
					return function (match, p1, p2, p3, p4) {
						p4 = (p4 || "").replace(regex.quoted, "$1");
						if (p1 === p4 && p1 === "readonly") { p3 = null; }
						return pre + ({
							"^": "starts-with(@" + p1 + ", \"" + p4 + "\")",
							"$": "substring(@" + p1 + ", (string-length(@" + p1 + ") - " + (p4.length - 1) + "), " + p4.length + ") = \"" + p4 + "\"",
							"*": "contains(concat(\" \", @" + p1 + ", \" \"), \"" + p4 + "\")",
							"|": "@" + p1 + "=\"" + p4 + "\" or starts-with(@" + p1 + ", \"" + p4 + "-\")",
							"~": "contains(concat(\" \", @" + p1 + ", \" \"), \" " + p4 + " \")"
						}[p2] || ("@" + p1 + (p3? "=\"" + p4 + "\"" : ""))) + post;
					};
				}
				function pseudoToXPath (tag, pseudoClass, pseudoValue) {
					tag = /\-child$/.test(pseudoClass)? "*" : tag;
					var pseudo = pseudoClass.split("-"), position = ((pseudo[1] === "last")? "(count(following-sibling::" : "(count(preceding-sibling::") + tag + ") + 1)", recur, hash;
					switch (pseudo[0]) {
						case "nth": return (pseudoValue !== "n" && (sequence = DOMAssistant.getSequence(pseudoValue)))? ((sequence.start === sequence.max)? position + " = " + sequence.start : position + " mod " + sequence.add + " = " + sequence.modVal + ((sequence.start > 1)? " and " + position + " >= " + sequence.start : "") + ((sequence.max > 0)? " and " + position + " <= " + sequence.max: "")) : "";
						case "not": return "not(" + ((recur = regex.pseudo.exec(pseudoValue))? pseudoToXPath(tag, recur[1]? recur[1].toLowerCase() : null, recur[3] || null) : pseudoValue.replace(regex.id, "[id=$1]").replace(regex.tag, "self::$0").replace(regex.classes, "contains(concat(\" \", @class, \" \"), \" $1 \")").replace(regex.attribs, attrToXPath())) + ")";
						case "first": return "not(preceding-sibling::" + tag + ")";
						case "last": return "not(following-sibling::" + tag + ")";
						case "only": return "not(preceding-sibling::" + tag + " or following-sibling::" + tag + ")";
						case "empty": return "not(child::*) and not(text())";
						case "contains": return "contains(., \"" + pseudoValue.replace(regex.quoted, "$1") + "\")";
						case "enabled": return "not(@disabled) and not(@type=\"hidden\")";
						case "disabled": return "@disabled";
						case "target": return "@name=\"" + (hash = document.location.hash.slice(1)) + "\" or @id=\"" + hash + "\"";
						default: return "@" + pseudoClass + "=\"" + pseudoValue + "\"";
					}
				}
				for (var i=0; (currentRule=cssRules[i]); i++) {
					if (!(cssSelectors = currentRule.match(regex.selectorSplit)) || i && elm.indexOf.call(cssRules.slice(0, i), currentRule) > -1) { continue; }
					xPathExpression = xPathExpression? xPathExpression + " | ." : ".";
					for (var j=0, jl=cssSelectors.length; j<jl; j++) {
						cssSelector = regex.selector.exec(cssSelectors[j]);
						splitRule = {
							tag: prefix + (cssSelector[1]? cssSelector[1] : "*"),
							id: cssSelector[2],
							allClasses: cssSelector[3],
							allAttr: cssSelector[5],
							allPseudos: cssSelector[10],
							tagRelation: cssSelector[20]
						};
						xPathExpression +=
							(splitRule.tagRelation? ({ ">": "/", "+": "/following-sibling::*[1]/self::", "~": "/following-sibling::" }[splitRule.tagRelation] || "") : ((j > 0 && regex.relation.test(cssSelectors[j-1]))? splitRule.tag : ("//" + splitRule.tag))) +
							(splitRule.id || "").replace(regex.id, "[@id = \"$1\"]") +
							(splitRule.allClasses || "").replace(regex.classes, "[contains(concat(\" \", @class, \" \"), \" $1 \")]") +
							(splitRule.allAttr || "").replace(regex.attribs, attrToXPath(true));
						if (splitRule.allPseudos) {
							var allPseudos = splitRule.allPseudos.match(regex.pseudos);
							for (var k=0, kl=allPseudos.length; k<kl; k++) {
								regex.pseudos.lastIndex = 0;
								var pseudo = regex.pseudos.exec(allPseudos[k]),
									pseudoClass = pseudo[1]? pseudo[1].toLowerCase() : null,
									pseudoValue = pseudo[3] || null,
									xpath = pseudoToXPath(splitRule.tag, pseudoClass, pseudoValue);
								if (xpath.length) {
									xPathExpression += "[" + xpath + "]";
								}
							}
						}
					}
				}
				try {
					var xPathNodes = document.evaluate(xPathExpression, this, nsResolver, 7, null), node, p=0;
					while ((node = xPathNodes.snapshotItem(p++))) { elm.push(node); }
				} catch (e) {}
				return elm;
			};
			return DOMAssistant.cssByXpath.call(this, cssRule);
		},
		
		cssSelection : function (cssRule) {
			if (!cssRule) { return null; }
			var special = regex.special.test(cssRule);
			try {
				if (document.querySelectorAll && !special) {
					return pushAll(new HTMLArray(), this.querySelectorAll(cssRule));
				}
			} catch (e) {}
			return ((document.evaluate && !special && !/-of-type/.test(cssRule))? DOMAssistant.cssByXpath : DOMAssistant.cssByDOM).call(this, cssRule);
		},
		
		cssSelect : function (cssRule) {
			return DOMAssistant.cssSelection.call(this, cssRule);
		},
		
		elmsByClass : function (className, tag) {
			var cssRule = (tag || "") + "." + className;
			return DOMAssistant.cssSelection.call(this, cssRule);
		},
		
		elmsByAttribute : function (attr, attrVal, tag, substrMatchSelector) {
			var cssRule = (tag || "") + "[" + attr + ((attrVal && attrVal !== "*")? ((substrMatchSelector || "") + "=" + attrVal + "]") : "]");
			return DOMAssistant.cssSelection.call(this, cssRule);
		},
		
		elmsByTag : function (tag) {
			return DOMAssistant.cssSelection.call(this, tag);
		}
	};
}();
DOMAssistant.initCore();
DOMAssistant.Storage = function () {
	var uniqueId = 1, data = [], expando = "_da" + +new Date();
	return {
		hasData : function () {
			var uid = this[expando];
			return !!uid && !!data[uid];
		},
		retrieve : function (key) {
			if (!DOMAssistant.def(key)) {
				return this[expando] || (this[expando] = uniqueId++);
			}
			if (!this[expando] || !data[this[expando]]) { return; }
			return data[this[expando]][key];
		},
		
		store : function (key, val) {
			var uid = this[expando] || (this[expando] = uniqueId++);
			data[uid] = data[uid] || {};
			if (typeof key === "object") {
				for (var i in key) {
					if (typeof i === "string") {
						data[uid][i] = key[i];
					}
				}
			}
			else {
				data[uid][key] = val;
			}
			return this;
		},
		
		unstore : function (key) {
			var uid = this[expando] || (this[expando] = uniqueId++);
			if (data[uid]) {
				if (DOMAssistant.def(key)) {
					delete data[uid][key];
				}
				else {
					data[uid] = null;
				}
			}
			return this;
		}
	};
}();
DOMAssistant.attach(DOMAssistant.Storage);
DOMAssistant.AJAX = function () {
	var globalXMLHttp = null,
	readyState = 0,
	status = -1,
	statusText = "",
	requestPool = [],
	createAjaxObj = function (url, method, callback, addToContent) {
		var params = null;
		if (/POST/i.test(method)) {
			url = url.split("?");
			params = url[1];
			url = url[0];
		}
		return {
			url : url,
			method : method,
			callback : callback,
			params : params,
			headers : {},
			responseType : "text",
			addToContent : addToContent || false
		};
	};
	return {
		publicMethods : [
			"ajax",
			"get",
			"post",
			"load"
		],
		
		initRequest : function () {
			var XMLHttp = null;
			if (!!window.XMLHttpRequest && !DOMAssistant.isIE) {
				XMLHttp = new XMLHttpRequest();
				DOMAssistant.AJAX.initRequest = function () {
					return requestPool.length? requestPool.pop() : new XMLHttpRequest();
				};
			}
			else if (!!window.ActiveXObject) {
				var XMLHttpMS = ["Msxml2.XMLHTTP.6.0", "Msxml2.XMLHTTP.3.0", "Msxml2.XMLHTTP", "Microsoft.XMLHTTP"];
				for (var i=0; i<XMLHttpMS.length; i++) {
					try {
						XMLHttp = new window.ActiveXObject(XMLHttpMS[i]);
						DOMAssistant.AJAX.initRequest = function () {
							return requestPool.length? requestPool.pop() : new window.ActiveXObject(XMLHttpMS[i]);
						};
						break;
					}
					catch (e) {
						XMLHttp = null;
					}
				}
			}
			return XMLHttp;
		},
		
		ajax : function (ajaxObj) {
			if (!ajaxObj.noParse && ajaxObj.url && /\?/.test(ajaxObj.url) && ajaxObj.method && /POST/i.test(ajaxObj.method)) {
				var url = ajaxObj.url.split("?");
				ajaxObj.url = url[0];
				ajaxObj.params = url[1] + ((url[1].length > 0 && ajaxObj.params)? ("&" + ajaxObj.params) : "");
			}
			return DOMAssistant.AJAX.makeCall.call(this, ajaxObj);
		},
		
		get : function (url, callback, addToContent) {
			return DOMAssistant.AJAX.makeCall.call(this, createAjaxObj(url, "GET", callback, addToContent));
		},
		
		post : function (url, callback) {
			return DOMAssistant.AJAX.makeCall.call(this, createAjaxObj(url, "POST", callback));
		},
		
		load : function (url, addToContent) {
			this.get(url, DOMAssistant.AJAX.replaceWithAJAXContent, addToContent);
		},
		
		makeCall : function (ajaxObj) {
			var XMLHttp = DOMAssistant.AJAX.initRequest();
			if (XMLHttp) {
				globalXMLHttp = XMLHttp;
				(function (elm) {
					var url = ajaxObj.url,
						method = ajaxObj.method || "GET",
						callback = ajaxObj.callback,
						params = ajaxObj.params,
						headers = ajaxObj.headers,
						responseType = ajaxObj.responseType || "text",
						addToContent = ajaxObj.addToContent,
						timeout = ajaxObj.timeout || null,
						ex = ajaxObj.exception,
						timeoutId = null,
						done = false;
					XMLHttp.open(method, url, true);
					XMLHttp.setRequestHeader("AJAX", "true");
					XMLHttp.setRequestHeader("X-Requested-With", "XMLHttpRequest");
					if (method === "POST") {
						XMLHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
						XMLHttp.setRequestHeader("Content-length", params? params.length : 0);
						if (XMLHttp.overrideMimeType) {
							XMLHttp.setRequestHeader("Connection", "close");
						}
					}
					if (responseType === "json") {
						XMLHttp.setRequestHeader("Accept", "application/json, text/javascript, */*");
					}
					for (var i in headers) {
						if (typeof i === "string") {
							XMLHttp.setRequestHeader(i, headers[i]);
						}
					}
					if (typeof callback === "function") {
						XMLHttp.onreadystatechange = function () {
							try {
								if (XMLHttp.readyState === 4 && !done) {
									window.clearTimeout(timeoutId);
									done = true;
									status = XMLHttp.status;
									statusText = XMLHttp.statusText;
									readyState = 4;
									if ((status || location.protocol !== "file:") && (status < 200 || status >= 300)) {
										throw new Error(statusText);
									}
									var response = /xml/i.test(responseType)? XMLHttp.responseXML : XMLHttp.responseText;
									if (/json/i.test(responseType) && !!response) {
										response = (typeof JSON === "object" && typeof JSON.parse === "function")? JSON.parse(response) : eval("(" + response + ")");
									}
									globalXMLHttp = null;
									XMLHttp.onreadystatechange = function () {};
									requestPool.push(XMLHttp);
									callback.call(elm, response, addToContent);
								}
							}
							catch (e) {
								globalXMLHttp = XMLHttp = null;
								if (typeof ex === "function") {
									ex.call(elm, e);
									ex = null;
								}
							}
						};
					}
					XMLHttp.send(params);
					if (timeout) {
						timeoutId = window.setTimeout( function () {
							if (!done) {
								XMLHttp.abort();
								done = true;
								if (typeof ex === "function") {
									readyState = 0;
									status = 408;
									statusText = "Request timeout";
									globalXMLHttp = XMLHttp = null;
									ex.call(elm, new Error(statusText));
									ex = null;
								}
							}
						}, timeout);
					}
				})(this);
			}
			return this;
		},
		
		replaceWithAJAXContent : function (content, add) {
			if (add) {
				this.innerHTML += content;
			}
			else {
				DOMAssistant.cleanUp(this);
				this.innerHTML = content;
			}
		},
		
		getReadyState : function () {
			return (globalXMLHttp && DOMAssistant.def(globalXMLHttp.readyState))? globalXMLHttp.readyState : readyState;
		},
		
		getStatus : function () {
			return status;
		},
		
		getStatusText : function () {
			return statusText;
		}
	};
}();
DOMAssistant.attach(DOMAssistant.AJAX);
DOMAssistant.CSS = function () {
	var def = DOMAssistant.def,
		direct = { display: true };
	return {
		addClass : function (className) {
			if (!this.hasClass(className)) {
				var currentClass = this.className;
				this.className = currentClass + (currentClass.length? " " : "") + className;
			}
			return this;
		},

		removeClass : function (className) {
			return this.replaceClass(className);
		},

		replaceClass : function (className, newClass) {
			var classToRemove = new RegExp(("(^|\\s)" + className + "(\\s|$)"), "i");
			this.className = this.className.replace(classToRemove, function (match, p1, p2) {
				return newClass? (p1 + newClass + p2) : " ";
			}).replace(/^\s+|\s+$/g, "");
			return this;
		},

		hasClass : function (className) {
			return (" " + this.className + " ").indexOf(" " + className + " ") > -1;
		},

		setStyle : function (style, value) {
			var css = this.style;
			if ("filters" in this && (typeof style === "string"? /opacity/i.test(style) : def(style.opacity))) {
				css.zoom = 1;
				css.filter = (css.filter || "").replace(/alpha\([^)]*\)/, "") + "alpha(opacity=" + (def(style.opacity)? style.opacity : value) * 100 + ")";
			}
			if (def(css.cssText)) {
				var styleToSet = css.cssText;
				if (typeof style === "object") {
					for (var i in style) {
						if (typeof i === "string") {
							if (direct[i]) { css[i] = style[i]; }
							styleToSet += ";" + i + ":" + style[i];
						}
					}
				}
				else {
					if (direct[style]) { css[style] = value; }
					styleToSet += ";" + style + ":" + value;
				}
				css.cssText = styleToSet;
			}
			return this;
		},

		getStyle : function (cssRule) {
			var val = "", f;
			cssRule = cssRule.toLowerCase();
			if (document.defaultView && document.defaultView.getComputedStyle) {
				val = document.defaultView.getComputedStyle(this, "").getPropertyValue(cssRule);
			}
			else if (this.currentStyle) {
				if ("filters" in this && cssRule === "opacity") {
					val = (f = this.style.filter || this.currentStyle.filter) && f.indexOf("opacity=") >= 0? parseFloat(f.match(/opacity=([^)]*)/)[1]) / 100 : 1;
				}
				else {
					cssRule = cssRule.replace(/^float$/, "styleFloat").replace(/\-(\w)/g, function (match, p1) {
						return p1.toUpperCase();
					});
					val = this.currentStyle[cssRule];
				}
				if (val === "auto" && /^(width|height)$/.test(cssRule) && this.currentStyle.display !== "none") {
					val = this["offset" + cssRule.charAt(0).toUpperCase() + cssRule.substr(1)] + "px";
				}
			}
			return val;
		}
	};
}();
DOMAssistant.attach(DOMAssistant.CSS);
DOMAssistant.Content = function () {
	var D$ = DOMAssistant.$$;
	return {
		init : function () {
			DOMAssistant.setCache(false);
		},

		create : function (name, attr, append, content) {
			var elm = D$(document.createElement(name));
			if (attr) {
				elm = elm.setAttributes(attr);
			}
			if (DOMAssistant.def(content)) {
				elm.addContent(content);
			}
			if (append) {
				this.appendChild(elm);
			}
			return elm;
		},

		setAttributes : function (attr) {
			if (DOMAssistant.isIE) {
				var setAttr = function (elm, att, val) {
					var attLower = att.toLowerCase();
					switch (attLower) {
						case "name":
						case "type":
						case "multiple":
							return D$(document.createElement(elm.outerHTML.replace(new RegExp(attLower + "(=[a-zA-Z]+)?"), " ").replace(">", " " + attLower + "=" + val + ">")));
						case "style":
							elm.style.cssText = val;
							return elm;
						default:
							elm[DOMAssistant.camel[attLower] || att] = val;
							return elm;
					}
				};
				DOMAssistant.Content.setAttributes = function (attr) {
					var elem = this;
					var parent = this.parentNode;
					for (var i in attr) {
						if (typeof attr[i] === "string" || typeof attr[i] === "number") {
							var newElem = setAttr(elem, i, attr[i]);
							if (parent && /(name|type)/i.test(i)) {
								if (elem.innerHTML) {
									newElem.innerHTML = elem.innerHTML;
								}
								parent.replaceChild(newElem, elem);
							}
							elem = newElem;
						}
					}
					return elem;
				};
			}
			else {
				DOMAssistant.Content.setAttributes = function (attr) {
					for (var i in attr) {
						if (/class/i.test(i)) {
							this.className = attr[i];
						}
						else {
							this.setAttribute(i, attr[i]);
						}
					}
					return this;
				};
			}
			return DOMAssistant.Content.setAttributes.call(this, attr); 
		},

		addContent : function (content) {
			var type = typeof content;
			if (type === "string" || type === "number") {
				if (!this.firstChild) {
					this.innerHTML = content;
				}
				else {
					var tmp = document.createElement("div");
					tmp.innerHTML = content;
					for (var i=tmp.childNodes.length-1, last=null; i>=0; i--) {
						last = this.insertBefore(tmp.childNodes[i], last);
					}
				}
			}
			else if (type === "object" || (type === "function" && !!content.nodeName)) {
				this.appendChild(content);
			}
			return this;
		},

		replaceContent : function (content) {
			DOMAssistant.cleanUp(this);
			return this.addContent(content);
		},

		replace : function (content, returnNew) {
			var type = typeof content;
			if (type === "string" || type === "number") {
				var parent = this.parentNode;
				var tmp = DOMAssistant.Content.create.call(parent, "div", null, false, content);
				for (var i=tmp.childNodes.length; i--;) {
					parent.insertBefore(tmp.childNodes[i], this.nextSibling);
				}
				content = this.nextSibling;
				parent.removeChild(this);
			}
			else if (type === "object" || (type === "function" && !!content.nodeName)) {
				this.parentNode.replaceChild(content, this);
			}
			return returnNew? content : this;
		},

		remove : function () {
			DOMAssistant.cleanUp(this);
			if (this.hasData()) {
				if (this.removeEvent) { this.removeEvent(); }
				this.unstore();
			}
			this.parentNode.removeChild(this);
			return null;
		}
	};
}();
DOMAssistant.attach(DOMAssistant.Content);
DOMAssistant.Events = function () {
	var handler,
		key = "_events",
		w3cMode = !!document.addEventListener,
		useCapture = { focus: true, blur: true },
		translate = DOMAssistant.isIE? { focus: "activate", blur: "deactivate", mouseenter: "mouseover", mouseleave: "mouseout" } : { mouseenter: "mouseover", mouseleave: "mouseout" },
		regex = {
			special: /^submit|reset|change|select$/i,
			mouseenterleave: /^mouse(enter|leave)$/i,
			dom: /^DOM/,
			on: /^on/i
		},
		special = function (e) {
			return DOMAssistant.isIE && regex.special.test(e);
		},
		fix = function (e) {
			return translate[e] || e;
		},
		createEvent = function (e, type, target) {
			e = e || window.event || {};
			if (e.event) { return e; }
			var event = {
				event: e,
				type: type || e.type,
				bubbles: e.bubbles || true,
				cancelable: e.cancelable || false,
				target: target || e.target || e.srcElement,
				clientX: e.clientX || 0,
				clientY: e.clientY || 0,
				altKey: e.altKey || false,
				ctrlKey: e.ctrlKey || false,
				shiftKey: e.shiftKey || false,
				button: e.button || null,
				timeStamp: +new Date(),
				preventDefault: function() {
					if (e.preventDefault) { e.preventDefault(); }
					this.returnValue = e.returnValue = false;
				},
				stopPropagation: function() {
					if (e.stopPropagation) { e.stopPropagation(); }
					this.cancelBubble = e.cancelBubble = true;
				}
			};
			if (event.target && 3 === event.target.nodeType) { // Safari textnode bug
				event.target = event.target.parentNode;	
			}
			event.currentTarget = event.target;
			event.relatedTarget = e.relatedTarget || (e.fromElement === event.target? e.toElement : e.fromElement) || null;
			var de = document.documentElement, b = document.body;
			event.pageX = DOMAssistant.def(e.pageX)? e.pageX : (event.clientX + (de.scrollLeft || b.scrollLeft) - (de.clientLeft || 0));
			event.pageY = DOMAssistant.def(e.pageY)? e.pageY : (event.clientY + (de.scrollTop || b.scrollTop) - (de.clientTop || 0));
			if ("number" === typeof e.which) {
				event.keyCode = e.keyCode;
				event.charCode = event.which = e.which;
			}
			else if (e.keyCode) {
				event.keyCode = event.charCode = e.keyCode;
			}
			return event;
		};

	return {
		publicMethods : [
			"triggerEvent",
			"addEvent",
			"removeEvent",
			"relayEvent",
			"unrelayEvent",
			"preventDefault",
			"cancelBubble"
		],

		init : function () {
			DOMAssistant.preventDefault = this.preventDefault;
			DOMAssistant.cancelBubble = this.cancelBubble;
			handler = this.handleEvent;
		},

		triggerEvent : function (evt, target, e) {
			var fevt = fix(evt),
				events = this.retrieve(key),
				event = e || createEvent(e, fevt, target || this);
			event.currentTarget = this;
			if (events && events[fevt]) {
				for (var i=0, iL=events[fevt].length; i<iL; i++) {
					if (events[fevt][i].call(this, event) === false) { event.stopPropagation(); }
				}
			}
			else if (typeof this["on" + fevt] === "function") {
				this["on" + fevt].call(this, event);
			}
			var p = DOMAssistant.$$(this.parentNode);
			if (!event.cancelBubble && p && p.nodeType === 1) {
				p.triggerEvent(fevt, target, event);
			}
			return this;
		},

		addEvent : function (evt, func, relay, proxy, selector) {
			var existingEvent,
				fevt = fix(evt),
				uid = fevt + this.retrieve(),
				onevt = "on" + fevt;
			if (!(func.attachedElements && func.attachedElements[uid])) {
				var events = this.retrieve(key) || {};
				if (!events[fevt]) {
					events[fevt] = [];
					existingEvent = this[onevt];
					this[onevt] = null;
				}
				if (typeof this.window === "object") { this.window[onevt] = handler; }
				else if (!events[fevt].length) {
					if (w3cMode) { this.addEventListener(fevt, handler, useCapture[fevt]); }
					else { this[onevt] = handler; }
				}
				if (existingEvent) {
					events[fevt].push(existingEvent);
				}
				if (fevt !== evt) { func.evt = evt; }
				func.relay = relay;
				func.proxy = proxy;
				func.selector = selector;
				func.attachedElements = func.attachedElements || {};
				func.attachedElements[uid] = true;
				events[fevt].push(func);
				this.store(key, events);
			}
			return this;
		},

		handleEvent : function (evt) {
			var currentEvt = (evt && regex.dom.test(evt.type) && w3cMode)? evt : createEvent(evt),
				type = fix(currentEvt.type),
				targ = currentEvt.target,
				relatedTarg = currentEvt.relatedTarget,
				eventColl = this.retrieve(key)[type].slice(0), eventCollLength, eventReturn, oevt;
			if ((eventCollLength = eventColl.length)) {
				for (var i=0; i<eventCollLength; i++) {
					if (typeof eventColl[i] === "function") {
						if ((oevt = eventColl[i].evt) && oevt !== type) {
							currentEvt.type = oevt;
							if (relatedTarg && regex.mouseenterleave.test(oevt)) {
								if (eventColl[i].relay) {
									var elms = eventColl[i].elms || (eventColl[i].elms = this.cssSelect(eventColl[i].selector));
									if (elms.indexOf(targ) < 0 || !DOMAssistant.hasChild.call(relatedTarg, targ)) { continue; }
								}
								else if (this === relatedTarg || this.hasChild(relatedTarg)) { continue; }
							}
						}
						eventReturn = eventColl[i].call(this, currentEvt);
					}
				}
				if (eventReturn === false) { currentEvt.stopPropagation(); }
				return eventReturn;
			}
		},

		removeEvent : function (evt, func, relay, proxy) {
			var uid = (evt = fix(evt)) + this.retrieve(),
				events = this.retrieve(key),
				onevt = "on" + evt;
			if (events && !evt) {
				for (var ev in events) {
					if (events[ev].length) { this.removeEvent(ev); }
				}
				var attr = this.attributes;
				for (var att, j=attr.length; j--;) {
					att = attr[j].nodeName.toLowerCase();
					if (regex.on.test(att) && typeof this[att] === "function") {
						this[att] = null;
					}
				}
			}
			else if (events && events[evt]) {
				var eventColl = events[evt];
				for (var fn, i=eventColl.length; i--;) {
					fn = func || eventColl[i];
					if (eventColl[i] === fn && relay === fn.relay && proxy === fn.proxy) {
						eventColl.splice(i, 1);
						if (!!proxy && fn.selector) {
							this.cssSelect(fn.selector).removeEvent(proxy);
						}
						if (fn.attachedElements) {
							fn.attachedElements[uid] = null;
						}
					}
				}
				if (!events[evt].length) {
					if (w3cMode) { this.removeEventListener(evt, handler, useCapture[evt]); }
					else { this[onevt] = null; }
				}
			}
			else if (this[onevt] && !func && !relay) {
				this[onevt] = null;
			}
			return this;
		},

		relayEvent: function (evt, selector, fn, proxy) {
			if (special(evt)) {
				this.relayEvent("focus", selector, function() {
					DOMAssistant.$$(this).removeEvent(evt).addEvent(evt, function(e) {
						return fn.call(this, createEvent(e));
					});
				}, evt).relayEvent("blur", selector, function() {
					DOMAssistant.$$(this).removeEvent(evt);
				}, evt);
				return this;
			}
			return this.addEvent(evt, function(e) {
				e = createEvent(e);
				var target = e.target, args = arguments, i = 0, elm, elms = this.cssSelect(selector);
				while ((elm = elms[i++])) {
					if ((elm === target || DOMAssistant.hasChild.call(elm, target)) && !elm.disabled) {
						e.currentTarget = elm;
						var retVal = fn.apply(elm, args);
						if (!retVal) { e.preventDefault(); }
						return retVal;
					}
				}
			}, true, proxy, selector);
		},

		unrelayEvent: function (evt) {
			if (special(evt)) {
				return this.removeEvent("focus", null, true, evt).removeEvent("blur", null, true, evt);
			}
			return this.removeEvent(evt, null, true);
		},

		preventDefault : function (evt) {
			if (evt.preventDefault) { evt.preventDefault(); }
			evt.returnValue = false;
		},

		cancelBubble : function (evt) {
			if (evt.stopPropagation) { evt.stopPropagation(); }
			evt.cancelBubble = true;
		}
	};
}();
DOMAssistant.attach(DOMAssistant.Events);
DOMAssistant.DOMLoad = function () {
	var DOMLoaded = false,
	DOMLoadTimer = null,
	functionsToCall = [],
	addedStrings = {},
	errorHandling = null,
	execFunctions = function () {
		for (var i=0, il=functionsToCall.length; i<il; i++) {
			try {
				functionsToCall[i]();
			}
			catch (e) {
				if (errorHandling && typeof errorHandling === "function") {
					errorHandling(e);
				}
			}
		}
		functionsToCall = [];
	},
	DOMHasLoaded = function () {
		if (DOMLoaded) {
			return;
		}
		DOMLoaded = true;
		execFunctions();
	};
	/* Internet Explorer */
	/*@cc_on
	@if (@_win32 || @_win64)
		document.write("<script id=\"ieScriptLoad\" defer src=\"//:\"><\/script>");
		document.getElementById("ieScriptLoad").onreadystatechange = function() {
			if (this.readyState === "complete") {
				DOMHasLoaded();
			}
		};
	@end @*/
	/* Mozilla, Chrome, Opera */
	if (document.addEventListener) {
		document.addEventListener("DOMContentLoaded", DOMHasLoaded, false);
	}
	/* Safari, iCab, Konqueror */
	if (/KHTML|WebKit|iCab/i.test(navigator.userAgent)) {
		DOMLoadTimer = setInterval(function () {
			if (/loaded|complete/i.test(document.readyState)) {
				DOMHasLoaded();
				clearInterval(DOMLoadTimer);
			}
		}, 10);
	}
	/* Other web browsers */
	window.onload = DOMHasLoaded;
	
	return {
		DOMReady : function () {
			for (var i=0, il=arguments.length, funcRef; i<il; i++) {
				funcRef = arguments[i];
				if (!funcRef.DOMReady && !addedStrings[funcRef]) {
					if (typeof funcRef === "string") {
						addedStrings[funcRef] = true;
						funcRef = new Function(funcRef);
					}
					funcRef.DOMReady = true;
					functionsToCall.push(funcRef);
				}
			}
			if (DOMLoaded) {
				execFunctions();
			}
		},
		
		setErrorHandling : function (funcRef) {
			errorHandling = funcRef;
		}
	};
}();
DOMAssistant.DOMReady = DOMAssistant.DOMLoad.DOMReady;