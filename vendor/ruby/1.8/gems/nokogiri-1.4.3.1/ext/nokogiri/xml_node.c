#include <xml_node.h>

static ID decorate, decorate_bang;

#ifdef DEBUG
static void debug_node_dealloc(xmlNodePtr x)
{
  NOKOGIRI_DEBUG_START(x)
  NOKOGIRI_DEBUG_END(x)
}
#else
#  define debug_node_dealloc 0
#endif

static void mark(xmlNodePtr node)
{
  /* it's OK if the document isn't fully realized (as in XML::Reader). */
  /* see http://github.com/tenderlove/nokogiri/issues/closed/#issue/95 */
  if (DOC_RUBY_OBJECT_TEST(node->doc) && DOC_RUBY_OBJECT(node->doc))
    rb_gc_mark(DOC_RUBY_OBJECT(node->doc));
}

/* :nodoc: */
typedef xmlNodePtr (*pivot_reparentee_func)(xmlNodePtr, xmlNodePtr);

/* :nodoc: */
static void relink_namespace(xmlNodePtr reparented)
{
  xmlNodePtr child;

  /* Avoid segv when relinking against unlinked nodes. */
  if(!reparented->parent) return;

  /* Make sure that our reparented node has the correct namespaces */
  if(!reparented->ns && reparented->doc != (xmlDocPtr)reparented->parent)
    xmlSetNs(reparented, reparented->parent->ns);

  /* Search our parents for an existing definition */
  if(reparented->nsDef) {
    xmlNsPtr curr = reparented->nsDef;
    xmlNsPtr prev = NULL;

    while(curr) {
      xmlNsPtr ns = xmlSearchNsByHref(
          reparented->doc,
          reparented->parent,
          curr->href
      );
      /* If we find the namespace is already declared, remove it from this
       * definition list. */
      if(ns && ns != curr) {
        if (prev) {
          prev->next = curr->next;
        } else {
          reparented->nsDef = curr->next;
        }
        NOKOGIRI_ROOT_NSDEF(curr, reparented->doc);
      } else {
        prev = curr;
      }
      curr = curr->next;
    }
  }

  /* Only walk all children if there actually is a namespace we need to */
  /* reparent. */
  if(NULL == reparented->ns) return;

  /* When a node gets reparented, walk it's children to make sure that */
  /* their namespaces are reparented as well. */
  child = reparented->children;
  while(NULL != child) {
    relink_namespace(child);
    child = child->next;
  }
}

/* :nodoc: */
static xmlNodePtr xmlReplaceNodeWrapper(xmlNodePtr pivot, xmlNodePtr new_node)
{
  xmlNodePtr retval ;

  retval = xmlReplaceNode(pivot, new_node) ;

  if (retval == pivot) {
    retval = new_node ; /* return semantics for reparent_node_with */
  }

  /* work around libxml2 issue: https://bugzilla.gnome.org/show_bug.cgi?id=615612 */
  if (retval->type == XML_TEXT_NODE) {
    if (retval->prev && retval->prev->type == XML_TEXT_NODE) {
      retval = xmlTextMerge(retval->prev, retval);
    }
    if (retval->next && retval->next->type == XML_TEXT_NODE) {
      retval = xmlTextMerge(retval, retval->next);
    }
  }

  return retval ;
}

/* :nodoc: */
static VALUE reparent_node_with(VALUE pivot_obj, VALUE reparentee_obj, pivot_reparentee_func prf)
{
  VALUE reparented_obj ;
  xmlNodePtr reparentee, pivot, reparented, next_text, new_next_text ;

  if(!rb_obj_is_kind_of(reparentee_obj, cNokogiriXmlNode))
    rb_raise(rb_eArgError, "node must be a Nokogiri::XML::Node");
  if(rb_obj_is_kind_of(reparentee_obj, cNokogiriXmlDocument))
    rb_raise(rb_eArgError, "node must be a Nokogiri::XML::Node");

  Data_Get_Struct(reparentee_obj, xmlNode, reparentee);
  Data_Get_Struct(pivot_obj, xmlNode, pivot);

  if(XML_DOCUMENT_NODE == reparentee->type || XML_HTML_DOCUMENT_NODE == reparentee->type)
    rb_raise(rb_eArgError, "cannot reparent a document node");

  xmlUnlinkNode(reparentee);

  if (reparentee->doc != pivot->doc || reparentee->type == XML_TEXT_NODE) {
    /*
     *  if the reparentee is a text node, there's a very good chance it will be
     *  merged with an adjacent text node after being reparented, and in that case
     *  libxml will free the underlying C struct.
     *
     *  since we clearly have a ruby object which references the underlying
     *  memory, we can't let the C struct get freed. let's pickle the original
     *  reparentee by rooting it; and then we'll reparent a duplicate of the
     *  node that we don't care about preserving.
     *
     *  alternatively, if the reparentee is from a different document than the
     *  pivot node, libxml2 is going to get confused about which document's
     *  "dictionary" the node's strings belong to (this is an otherwise
     *  uninteresting libxml2 implementation detail). as a result, we cannot
     *  reparent the actual reparentee, so we reparent a duplicate.
     */
    NOKOGIRI_ROOT_NODE(reparentee);
    if (!(reparentee = xmlDocCopyNode(reparentee, pivot->doc, 1))) {
      rb_raise(rb_eRuntimeError, "Could not reparent node (xmlDocCopyNode)");
    }
  }

  if (reparentee->type == XML_TEXT_NODE && pivot->next && pivot->next->type == XML_TEXT_NODE) {
    /*
     *  libxml merges text nodes in a right-to-left fashion, meaning that if
     *  there are two text nodes who would be adjacent, the right (or following,
     *  or next) node will be merged into the left (or preceding, or previous)
     *  node.
     *
     *  and by "merged" I mean the string contents will be concatenated onto the
     *  left node's contents, and then the node will be freed.
     *
     *  which means that if we have a ruby object wrapped around the right node,
     *  its memory would be freed out from under it.
     *
     *  so, we detect this edge case and unlink-and-root the text node before it gets
     *  merged. then we dup the node and insert that duplicate back into the
     *  document where the real node was.
     *
     *  yes, this is totally lame.
     */
    next_text     = pivot->next ;
    new_next_text = xmlDocCopyNode(next_text, pivot->doc, 1) ;

    xmlUnlinkNode(next_text);
    NOKOGIRI_ROOT_NODE(next_text);

    xmlAddNextSibling(pivot, new_next_text);
  }

  /* TODO: I really want to remove this.  We shouldn't support 2.6.16 anymore */
  if ( reparentee->type == XML_TEXT_NODE && pivot->type == XML_TEXT_NODE && is_2_6_16() ) {
    /* work around a string-handling bug in libxml 2.6.16. we'd rather leak than segfault. */
    pivot->content = xmlStrdup(pivot->content);
  }

  if(!(reparented = (*prf)(pivot, reparentee))) {
    rb_raise(rb_eRuntimeError, "Could not reparent node");
  }

  /*
   *  make sure the ruby object is pointed at the just-reparented node, which
   *  might be a duplicate (see above) or might be the result of merging
   *  adjacent text nodes.
   */
  DATA_PTR(reparentee_obj) = reparented ;

  relink_namespace(reparented);

  reparented_obj = Nokogiri_wrap_xml_node(Qnil, reparented);

  rb_funcall(reparented_obj, decorate_bang, 0);

  return reparented_obj ;
}


/*
 * call-seq:
 *  document
 *
 * Get the document for this Node
 */
static VALUE document(VALUE self)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);
  return DOC_RUBY_OBJECT(node->doc);
}

/*
 * call-seq:
 *  pointer_id
 *
 * Get the internal pointer number
 */
static VALUE pointer_id(VALUE self)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);

  return INT2NUM((long)(node));
}

/*
 * call-seq:
 *  encode_special_chars(string)
 *
 * Encode any special characters in +string+
 */
static VALUE encode_special_chars(VALUE self, VALUE string)
{
  xmlNodePtr node;
  xmlChar *encoded;
  VALUE encoded_str;

  Data_Get_Struct(self, xmlNode, node);
  encoded = xmlEncodeSpecialChars(
      node->doc,
      (const xmlChar *)StringValuePtr(string)
  );

  encoded_str = NOKOGIRI_STR_NEW2(encoded);
  xmlFree(encoded);

  return encoded_str;
}

/*
 * call-seq:
 *  create_internal_subset(name, external_id, system_id)
 *
 * Create an internal subset
 */
static VALUE create_internal_subset(VALUE self, VALUE name, VALUE external_id, VALUE system_id)
{
  xmlNodePtr node;
  xmlDocPtr doc;
  xmlDtdPtr dtd;

  Data_Get_Struct(self, xmlNode, node);

  doc = node->doc;

  if(xmlGetIntSubset(doc))
    rb_raise(rb_eRuntimeError, "Document already has an internal subset");

  dtd = xmlCreateIntSubset(
      doc,
      NIL_P(name)        ? NULL : (const xmlChar *)StringValuePtr(name),
      NIL_P(external_id) ? NULL : (const xmlChar *)StringValuePtr(external_id),
      NIL_P(system_id)   ? NULL : (const xmlChar *)StringValuePtr(system_id)
  );

  if(!dtd) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, (xmlNodePtr)dtd);
}

/*
 * call-seq:
 *  create_external_subset(name, external_id, system_id)
 *
 * Create an external subset
 */
static VALUE create_external_subset(VALUE self, VALUE name, VALUE external_id, VALUE system_id)
{
  xmlNodePtr node;
  xmlDocPtr doc;
  xmlDtdPtr dtd;

  Data_Get_Struct(self, xmlNode, node);

  doc = node->doc;

  if(doc->extSubset)
    rb_raise(rb_eRuntimeError, "Document already has an external subset");

  dtd = xmlNewDtd(
      doc,
      NIL_P(name)        ? NULL : (const xmlChar *)StringValuePtr(name),
      NIL_P(external_id) ? NULL : (const xmlChar *)StringValuePtr(external_id),
      NIL_P(system_id)   ? NULL : (const xmlChar *)StringValuePtr(system_id)
  );

  if(!dtd) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, (xmlNodePtr)dtd);
}

/*
 * call-seq:
 *  external_subset
 *
 * Get the external subset
 */
static VALUE external_subset(VALUE self)
{
  xmlNodePtr node;
  xmlDocPtr doc;
  xmlDtdPtr dtd;

  Data_Get_Struct(self, xmlNode, node);

  if(!node->doc) return Qnil;

  doc = node->doc;
  dtd = doc->extSubset;

  if(!dtd) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, (xmlNodePtr)dtd);
}

/*
 * call-seq:
 *  internal_subset
 *
 * Get the internal subset
 */
static VALUE internal_subset(VALUE self)
{
  xmlNodePtr node;
  xmlDocPtr doc;
  xmlDtdPtr dtd;

  Data_Get_Struct(self, xmlNode, node);

  if(!node->doc) return Qnil;

  doc = node->doc;
  dtd = xmlGetIntSubset(doc);

  if(!dtd) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, (xmlNodePtr)dtd);
}

/*
 * call-seq:
 *  dup
 *
 * Copy this node.  An optional depth may be passed in, but it defaults
 * to a deep copy.  0 is a shallow copy, 1 is a deep copy.
 */
static VALUE duplicate_node(int argc, VALUE *argv, VALUE self)
{
  VALUE level;
  xmlNodePtr node, dup;

  if(rb_scan_args(argc, argv, "01", &level) == 0)
    level = INT2NUM((long)1);

  Data_Get_Struct(self, xmlNode, node);

  dup = xmlDocCopyNode(node, node->doc, (int)NUM2INT(level));
  if(dup == NULL) return Qnil;

  return Nokogiri_wrap_xml_node(rb_obj_class(self), dup);
}

/*
 * call-seq:
 *  unlink
 *
 * Unlink this node from its current context.
 */
static VALUE unlink_node(VALUE self)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);
  xmlUnlinkNode(node);
  NOKOGIRI_ROOT_NODE(node);
  return self;
}

/*
 * call-seq:
 *  blank?
 *
 * Is this node blank?
 */
static VALUE blank_eh(VALUE self)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);
  return (1 == xmlIsBlankNode(node)) ? Qtrue : Qfalse ;
}

/*
 * call-seq:
 *  next_sibling
 *
 * Returns the next sibling node
 */
static VALUE next_sibling(VALUE self)
{
  xmlNodePtr node, sibling;
  Data_Get_Struct(self, xmlNode, node);

  sibling = node->next;
  if(!sibling) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, sibling) ;
}

/*
 * call-seq:
 *  previous_sibling
 *
 * Returns the previous sibling node
 */
static VALUE previous_sibling(VALUE self)
{
  xmlNodePtr node, sibling;
  Data_Get_Struct(self, xmlNode, node);

  sibling = node->prev;
  if(!sibling) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, sibling);
}

/*
 * call-seq:
 *  next_element
 *
 * Returns the next Nokogiri::XML::Element type sibling node.
 */
static VALUE next_element(VALUE self)
{
  xmlNodePtr node, sibling;
  Data_Get_Struct(self, xmlNode, node);

  sibling = xmlNextElementSibling(node);
  if(!sibling) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, sibling);
}

/*
 * call-seq:
 *  previous_element
 *
 * Returns the previous Nokogiri::XML::Element type sibling node.
 */
static VALUE previous_element(VALUE self)
{
  xmlNodePtr node, sibling;
  Data_Get_Struct(self, xmlNode, node);

  /*
   *  note that we don't use xmlPreviousElementSibling here because it's buggy pre-2.7.7.
   */
  sibling = node->prev;
  if(!sibling) return Qnil;

  while(sibling && sibling->type != XML_ELEMENT_NODE)
    sibling = sibling->prev;

  return sibling ? Nokogiri_wrap_xml_node(Qnil, sibling) : Qnil ;
}

/* :nodoc: */
static VALUE replace(VALUE self, VALUE new_node)
{
  return reparent_node_with(self, new_node, xmlReplaceNodeWrapper) ;
}

/*
 * call-seq:
 *  children
 *
 * Get the list of children for this node as a NodeSet
 */
static VALUE children(VALUE self)
{
  xmlNodePtr node;
  xmlNodePtr child;
  xmlNodeSetPtr set;
  VALUE document;
  VALUE node_set;

  Data_Get_Struct(self, xmlNode, node);

  child = node->children;
  set = xmlXPathNodeSetCreate(child);

  document = DOC_RUBY_OBJECT(node->doc);

  if(!child) return Nokogiri_wrap_xml_node_set(set, document);

  child = child->next;
  while(NULL != child) {
    xmlXPathNodeSetAddUnique(set, child);
    child = child->next;
  }

  node_set = Nokogiri_wrap_xml_node_set(set, document);

  return node_set;
}

/*
 * call-seq:
 *  element_children
 *
 * Get the list of children for this node as a NodeSet.  All nodes will be
 * element nodes.
 *
 * Example:
 *
 *   @doc.root.element_children.all? { |x| x.element? } # => true
 */
static VALUE element_children(VALUE self)
{
  xmlNodePtr node;
  xmlNodePtr child;
  xmlNodeSetPtr set;
  VALUE document;
  VALUE node_set;

  Data_Get_Struct(self, xmlNode, node);

  child = xmlFirstElementChild(node);
  set = xmlXPathNodeSetCreate(child);

  document = DOC_RUBY_OBJECT(node->doc);

  if(!child) return Nokogiri_wrap_xml_node_set(set, document);

  child = xmlNextElementSibling(child);
  while(NULL != child) {
    xmlXPathNodeSetAddUnique(set, child);
    child = xmlNextElementSibling(child);
  }

  node_set = Nokogiri_wrap_xml_node_set(set, document);

  return node_set;
}

/*
 * call-seq:
 *  child
 *
 * Returns the child node
 */
static VALUE child(VALUE self)
{
  xmlNodePtr node, child;
  Data_Get_Struct(self, xmlNode, node);

  child = node->children;
  if(!child) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, child);
}

/*
 * call-seq:
 *  first_element_child
 *
 * Returns the first child node of this node that is an element.
 *
 * Example:
 *
 *   @doc.root.first_element_child.element? # => true
 */
static VALUE first_element_child(VALUE self)
{
  xmlNodePtr node, child;
  Data_Get_Struct(self, xmlNode, node);

  child = xmlFirstElementChild(node);
  if(!child) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, child);
}

/*
 * call-seq:
 *  last_element_child
 *
 * Returns the last child node of this node that is an element.
 *
 * Example:
 *
 *   @doc.root.last_element_child.element? # => true
 */
static VALUE last_element_child(VALUE self)
{
  xmlNodePtr node, child;
  Data_Get_Struct(self, xmlNode, node);

  child = xmlLastElementChild(node);
  if(!child) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, child);
}

/*
 * call-seq:
 *  key?(attribute)
 *
 * Returns true if +attribute+ is set
 */
static VALUE key_eh(VALUE self, VALUE attribute)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);
  if(xmlHasProp(node, (xmlChar *)StringValuePtr(attribute)))
    return Qtrue;
  return Qfalse;
}

/*
 * call-seq:
 *  namespaced_key?(attribute, namespace)
 *
 * Returns true if +attribute+ is set with +namespace+
 */
static VALUE namespaced_key_eh(VALUE self, VALUE attribute, VALUE namespace)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);
  if(xmlHasNsProp(node, (xmlChar *)StringValuePtr(attribute),
        NIL_P(namespace) ? NULL : (xmlChar *)StringValuePtr(namespace)))
    return Qtrue;
  return Qfalse;
}

/*
 * call-seq:
 *  []=(property, value)
 *
 * Set the +property+ to +value+
 */
static VALUE set(VALUE self, VALUE property, VALUE value)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);

  xmlSetProp(node, (xmlChar *)StringValuePtr(property),
      (xmlChar *)StringValuePtr(value));

  return value;
}

/*
 * call-seq:
 *   get(attribute)
 *
 * Get the value for +attribute+
 */
static VALUE get(VALUE self, VALUE attribute)
{
  xmlNodePtr node;
  xmlChar* propstr ;
  VALUE rval ;
  Data_Get_Struct(self, xmlNode, node);

  if(NIL_P(attribute)) return Qnil;

  propstr = xmlGetProp(node, (xmlChar *)StringValuePtr(attribute));

  if(!propstr) return Qnil;

  rval = NOKOGIRI_STR_NEW2(propstr);

  xmlFree(propstr);
  return rval ;
}

/*
 * call-seq:
 *   set_namespace(namespace)
 *
 * Set the namespace to +namespace+
 */
static VALUE set_namespace(VALUE self, VALUE namespace)
{
  xmlNodePtr node;
  xmlNsPtr ns = NULL;

  Data_Get_Struct(self, xmlNode, node);

  if(!NIL_P(namespace))
    Data_Get_Struct(namespace, xmlNs, ns);

  xmlSetNs(node, ns);

  return self;
}

/*
 * call-seq:
 *   attribute(name)
 *
 * Get the attribute node with +name+
 */
static VALUE attr(VALUE self, VALUE name)
{
  xmlNodePtr node;
  xmlAttrPtr prop;
  Data_Get_Struct(self, xmlNode, node);
  prop = xmlHasProp(node, (xmlChar *)StringValuePtr(name));

  if(! prop) return Qnil;
  return Nokogiri_wrap_xml_node(Qnil, (xmlNodePtr)prop);
}

/*
 * call-seq:
 *   attribute_with_ns(name, namespace)
 *
 * Get the attribute node with +name+ and +namespace+
 */
static VALUE attribute_with_ns(VALUE self, VALUE name, VALUE namespace)
{
  xmlNodePtr node;
  xmlAttrPtr prop;
  Data_Get_Struct(self, xmlNode, node);
  prop = xmlHasNsProp(node, (xmlChar *)StringValuePtr(name),
      NIL_P(namespace) ? NULL : (xmlChar *)StringValuePtr(namespace));

  if(! prop) return Qnil;
  return Nokogiri_wrap_xml_node(Qnil, (xmlNodePtr)prop);
}

/*
 *  call-seq:
 *    attribute_nodes()
 *
 *  returns a list containing the Node attributes.
 */
static VALUE attribute_nodes(VALUE self)
{
    /* this code in the mode of xmlHasProp() */
    xmlNodePtr node;
    VALUE attr;

    Data_Get_Struct(self, xmlNode, node);

    attr = rb_ary_new();
    Nokogiri_xml_node_properties(node, attr);

    return attr ;
}


/*
 *  call-seq:
 *    namespace()
 *
 *  returns the Nokogiri::XML::Namespace for the node, if one exists.
 */
static VALUE namespace(VALUE self)
{
  xmlNodePtr node ;
  Data_Get_Struct(self, xmlNode, node);

  if (node->ns)
    return Nokogiri_wrap_xml_namespace(node->doc, node->ns);

  return Qnil ;
}

/*
 *  call-seq:
 *    namespace_definitions()
 *
 *  returns a list of Namespace nodes defined on _self_
 */
static VALUE namespace_definitions(VALUE self)
{
  /* this code in the mode of xmlHasProp() */
  xmlNodePtr node ;
  VALUE list;
  xmlNsPtr ns;

  Data_Get_Struct(self, xmlNode, node);

  list = rb_ary_new();

  ns = node->nsDef;

  if(!ns) return list;

  while(NULL != ns) {
    rb_ary_push(list, Nokogiri_wrap_xml_namespace(node->doc, ns));
    ns = ns->next;
  }

  return list;
}

/*
 *  call-seq:
 *    namespace_scopes()
 *
 *  returns a list of Namespace nodes in scope for _self_. this is all
 *  namespaces defined in the node, or in any ancestor node.
 */
static VALUE namespace_scopes(VALUE self)
{
  xmlNodePtr node ;
  VALUE list;
  xmlNsPtr *ns_list;
  int j;

  Data_Get_Struct(self, xmlNode, node);

  list = rb_ary_new();
  ns_list = xmlGetNsList(node->doc, node);

  if(!ns_list) return list;

  for (j = 0 ; ns_list[j] != NULL ; ++j) {
    rb_ary_push(list, Nokogiri_wrap_xml_namespace(node->doc, ns_list[j]));
  }

  xmlFree(ns_list);
  return list;
}

/*
 * call-seq:
 *  node_type
 *
 * Get the type for this Node
 */
static VALUE node_type(VALUE self)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);
  return INT2NUM((long)node->type);
}

/*
 * call-seq:
 *  content=
 *
 * Set the content for this Node
 */
static VALUE set_content(VALUE self, VALUE content)
{
  xmlNodePtr node, child, next ;
  Data_Get_Struct(self, xmlNode, node);

  child = node->children;
  while (NULL != child) {
    next = child->next ;
    xmlUnlinkNode(child) ;
    NOKOGIRI_ROOT_NODE(child) ;
    child = next ;
  }

  xmlNodeSetContent(node, (xmlChar *)StringValuePtr(content));
  return content;
}

/*
 * call-seq:
 *  content
 *
 * Returns the content for this Node
 */
static VALUE get_content(VALUE self)
{
  xmlNodePtr node;
  xmlChar * content;

  Data_Get_Struct(self, xmlNode, node);

  content = xmlNodeGetContent(node);
  if(content) {
    VALUE rval = NOKOGIRI_STR_NEW2(content);
    xmlFree(content);
    return rval;
  }
  return Qnil;
}

/* :nodoc: */
static VALUE add_child(VALUE self, VALUE new_child)
{
  return reparent_node_with(self, new_child, xmlAddChild);
}

/*
 * call-seq:
 *  parent
 *
 * Get the parent Node for this Node
 */
static VALUE get_parent(VALUE self)
{
  xmlNodePtr node, parent;
  Data_Get_Struct(self, xmlNode, node);

  parent = node->parent;
  if(!parent) return Qnil;

  return Nokogiri_wrap_xml_node(Qnil, parent) ;
}

/*
 * call-seq:
 *  name=(new_name)
 *
 * Set the name for this Node
 */
static VALUE set_name(VALUE self, VALUE new_name)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);
  xmlNodeSetName(node, (xmlChar*)StringValuePtr(new_name));
  return new_name;
}

/*
 * call-seq:
 *  name
 *
 * Returns the name for this Node
 */
static VALUE get_name(VALUE self)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);
  if(node->name)
    return NOKOGIRI_STR_NEW2(node->name);
  return Qnil;
}

/*
 * call-seq:
 *  path
 *
 * Returns the path associated with this Node
 */
static VALUE path(VALUE self)
{
  xmlNodePtr node;
  xmlChar *path ;
  VALUE rval;

  Data_Get_Struct(self, xmlNode, node);

  path = xmlGetNodePath(node);
  rval = NOKOGIRI_STR_NEW2(path);
  xmlFree(path);
  return rval ;
}

/* :nodoc: */
static VALUE add_next_sibling(VALUE self, VALUE new_sibling)
{
  return reparent_node_with(self, new_sibling, xmlAddNextSibling) ;
}

/* :nodoc: */
static VALUE add_previous_sibling(VALUE self, VALUE new_sibling)
{
  return reparent_node_with(self, new_sibling, xmlAddPrevSibling) ;
}

/*
 * call-seq:
 *  native_write_to(io, encoding, options)
 *
 * Write this Node to +io+ with +encoding+ and +options+
 */
static VALUE native_write_to(
    VALUE self,
    VALUE io,
    VALUE encoding,
    VALUE indent_string,
    VALUE options
) {
  xmlNodePtr node;
  const char * before_indent;
  xmlSaveCtxtPtr savectx;

  Data_Get_Struct(self, xmlNode, node);

  xmlIndentTreeOutput = 1;

  before_indent = xmlTreeIndentString;

  xmlTreeIndentString = StringValuePtr(indent_string);

  savectx = xmlSaveToIO(
      (xmlOutputWriteCallback)io_write_callback,
      (xmlOutputCloseCallback)io_close_callback,
      (void *)io,
      RTEST(encoding) ? StringValuePtr(encoding) : NULL,
      (int)NUM2INT(options)
  );

  xmlSaveTree(savectx, node);
  xmlSaveClose(savectx);

  xmlTreeIndentString = before_indent;
  return io;
}

/*
 * call-seq:
 *  line
 *
 * Returns the line for this Node
 */
static VALUE line(VALUE self)
{
  xmlNodePtr node;
  Data_Get_Struct(self, xmlNode, node);

  return INT2NUM(xmlGetLineNo(node));
}

/*
 * call-seq:
 *  add_namespace_definition(prefix, href)
 *
 * Adds a namespace definition with +prefix+ using +href+
 */
static VALUE add_namespace_definition(VALUE self, VALUE prefix, VALUE href)
{
  xmlNodePtr node, namespacee;
  xmlNsPtr ns;

  Data_Get_Struct(self, xmlNode, node);
  namespacee = node ;

  ns = xmlSearchNs(
      node->doc,
      node,
      (const xmlChar *)(NIL_P(prefix) ? NULL : StringValuePtr(prefix))
  );

  if(!ns) {
    if (node->type != XML_ELEMENT_NODE) {
      namespacee = node->parent;
    }
    ns = xmlNewNs(
        namespacee,
        (const xmlChar *)StringValuePtr(href),
        (const xmlChar *)(NIL_P(prefix) ? NULL : StringValuePtr(prefix))
    );
  }

  if (!ns) return Qnil ;

  if(NIL_P(prefix) || node != namespacee) xmlSetNs(node, ns);

  return Nokogiri_wrap_xml_namespace(node->doc, ns);
}

/*
 * call-seq:
 *   new(name, document)
 *
 * Create a new node with +name+ sharing GC lifecycle with +document+
 */
static VALUE new(int argc, VALUE *argv, VALUE klass)
{
  xmlDocPtr doc;
  xmlNodePtr node;
  VALUE name;
  VALUE document;
  VALUE rest;
  VALUE rb_node;

  rb_scan_args(argc, argv, "2*", &name, &document, &rest);

  Data_Get_Struct(document, xmlDoc, doc);

  node = xmlNewNode(NULL, (xmlChar *)StringValuePtr(name));
  node->doc = doc->doc;
  NOKOGIRI_ROOT_NODE(node);

  rb_node = Nokogiri_wrap_xml_node(
      klass == cNokogiriXmlNode ? (VALUE)NULL : klass,
      node
  );
  rb_obj_call_init(rb_node, argc, argv);

  if(rb_block_given_p()) rb_yield(rb_node);

  return rb_node;
}

/*
 * call-seq:
 *  dump_html
 *
 * Returns the Node as html.
 */
static VALUE dump_html(VALUE self)
{
  xmlBufferPtr buf ;
  xmlNodePtr node ;
  VALUE html;

  Data_Get_Struct(self, xmlNode, node);

  buf = xmlBufferCreate() ;
  htmlNodeDump(buf, node->doc, node);
  html = NOKOGIRI_STR_NEW2(buf->content);
  xmlBufferFree(buf);
  return html ;
}

/*
 * call-seq:
 *  compare(other)
 *
 * Compare this Node to +other+ with respect to their Document
 */
static VALUE compare(VALUE self, VALUE _other)
{
  xmlNodePtr node, other;
  Data_Get_Struct(self, xmlNode, node);
  Data_Get_Struct(_other, xmlNode, other);

  return INT2NUM((long)xmlXPathCmpNodes(other, node));
}


/* TODO: DOCUMENT ME */
static VALUE in_context(VALUE self, VALUE _str, VALUE _options)
{
  xmlNodePtr node;
  xmlNodePtr list;
  xmlNodeSetPtr set;
  xmlParserErrors error;
  VALUE doc, err;

  Data_Get_Struct(self, xmlNode, node);

  doc = DOC_RUBY_OBJECT(node->doc);
  err = rb_iv_get(doc, "@errors");

  xmlSetStructuredErrorFunc((void *)err, Nokogiri_error_array_pusher);

  /* Twiddle global variable because of a bug in libxml2.
   * http://git.gnome.org/browse/libxml2/commit/?id=e20fb5a72c83cbfc8e4a8aa3943c6be8febadab7
   */
#ifndef HTML_PARSE_NOIMPLIED
  htmlHandleOmittedElem(0);
#endif

  error = xmlParseInNodeContext(
      node,
      StringValuePtr(_str),
      (int)RSTRING_LEN(_str),
      (int)NUM2INT(_options),
      &list);

#ifndef HTML_PARSE_NOIMPLIED
  htmlHandleOmittedElem(1);
#endif

  xmlSetStructuredErrorFunc(NULL, NULL);

  /* FIXME: This probably needs to handle more constants... */
  switch(error) {
    case XML_ERR_OK:
      break;

    case XML_ERR_INTERNAL_ERROR:
    case XML_ERR_NO_MEMORY:
      rb_raise(rb_eRuntimeError, "error parsing fragment (%d)", error);
      break;

    default:
      break;
  }

  set = xmlXPathNodeSetCreate(NULL);

  while(list) {
    xmlXPathNodeSetAddUnique(set, list);
    list = list->next;
  }

  return Nokogiri_wrap_xml_node_set(set, doc);
}


VALUE Nokogiri_wrap_xml_node(VALUE klass, xmlNodePtr node)
{
  VALUE document = Qnil ;
  VALUE node_cache = Qnil ;
  VALUE rb_node = Qnil ;

  assert(node);

  if(node->type == XML_DOCUMENT_NODE || node->type == XML_HTML_DOCUMENT_NODE)
      return DOC_RUBY_OBJECT(node->doc);

  if(NULL != node->_private) return (VALUE)node->_private;

  if(RTEST(klass))
    rb_node = Data_Wrap_Struct(klass, mark, debug_node_dealloc, node) ;

  else switch(node->type)
  {
    case XML_ELEMENT_NODE:
      klass = cNokogiriXmlElement;
      break;
    case XML_TEXT_NODE:
      klass = cNokogiriXmlText;
      break;
    case XML_ATTRIBUTE_NODE:
      klass = cNokogiriXmlAttr;
      break;
    case XML_ENTITY_REF_NODE:
      klass = cNokogiriXmlEntityReference;
      break;
    case XML_COMMENT_NODE:
      klass = cNokogiriXmlComment;
      break;
    case XML_DOCUMENT_FRAG_NODE:
      klass = cNokogiriXmlDocumentFragment;
      break;
    case XML_PI_NODE:
      klass = cNokogiriXmlProcessingInstruction;
      break;
    case XML_ENTITY_DECL:
      klass = cNokogiriXmlEntityDecl;
      break;
    case XML_CDATA_SECTION_NODE:
      klass = cNokogiriXmlCData;
      break;
    case XML_DTD_NODE:
      klass = cNokogiriXmlDtd;
      break;
    case XML_ATTRIBUTE_DECL:
      klass = cNokogiriXmlAttributeDecl;
      break;
    case XML_ELEMENT_DECL:
      klass = cNokogiriXmlElementDecl;
      break;
    default:
      klass = cNokogiriXmlNode;
  }

  rb_node = Data_Wrap_Struct(klass, mark, debug_node_dealloc, node) ;

  node->_private = (void *)rb_node;

  if (DOC_RUBY_OBJECT_TEST(node->doc) && DOC_RUBY_OBJECT(node->doc)) {
    /* it's OK if the document isn't fully realized (as in XML::Reader). */
    /* see http://github.com/tenderlove/nokogiri/issues/closed/#issue/95 */
    document = DOC_RUBY_OBJECT(node->doc);
    node_cache = DOC_NODE_CACHE(node->doc);
    rb_ary_push(node_cache, rb_node);
    rb_funcall(document, decorate, 1, rb_node);
  }

  return rb_node ;
}


void Nokogiri_xml_node_properties(xmlNodePtr node, VALUE attr_list)
{
  xmlAttrPtr prop;
  prop = node->properties ;
  while (prop != NULL) {
    rb_ary_push(attr_list, Nokogiri_wrap_xml_node(Qnil, (xmlNodePtr)prop));
    prop = prop->next ;
  }
}

VALUE cNokogiriXmlNode ;
VALUE cNokogiriXmlElement ;

void init_xml_node()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE klass = rb_define_class_under(xml, "Node", rb_cObject);

  cNokogiriXmlNode = klass;

  cNokogiriXmlElement = rb_define_class_under(xml, "Element", klass);

  rb_define_singleton_method(klass, "new", new, -1);

  rb_define_method(klass, "add_namespace_definition", add_namespace_definition, 2);
  rb_define_method(klass, "node_name", get_name, 0);
  rb_define_method(klass, "document", document, 0);
  rb_define_method(klass, "node_name=", set_name, 1);
  rb_define_method(klass, "parent", get_parent, 0);
  rb_define_method(klass, "child", child, 0);
  rb_define_method(klass, "first_element_child", first_element_child, 0);
  rb_define_method(klass, "last_element_child", last_element_child, 0);
  rb_define_method(klass, "children", children, 0);
  rb_define_method(klass, "element_children", element_children, 0);
  rb_define_method(klass, "next_sibling", next_sibling, 0);
  rb_define_method(klass, "previous_sibling", previous_sibling, 0);
  rb_define_method(klass, "next_element", next_element, 0);
  rb_define_method(klass, "previous_element", previous_element, 0);
  rb_define_method(klass, "node_type", node_type, 0);
  rb_define_method(klass, "content", get_content, 0);
  rb_define_method(klass, "path", path, 0);
  rb_define_method(klass, "key?", key_eh, 1);
  rb_define_method(klass, "namespaced_key?", namespaced_key_eh, 2);
  rb_define_method(klass, "blank?", blank_eh, 0);
  rb_define_method(klass, "[]=", set, 2);
  rb_define_method(klass, "attribute_nodes", attribute_nodes, 0);
  rb_define_method(klass, "attribute", attr, 1);
  rb_define_method(klass, "attribute_with_ns", attribute_with_ns, 2);
  rb_define_method(klass, "namespace", namespace, 0);
  rb_define_method(klass, "namespace_definitions", namespace_definitions, 0);
  rb_define_method(klass, "namespace_scopes", namespace_scopes, 0);
  rb_define_method(klass, "encode_special_chars", encode_special_chars, 1);
  rb_define_method(klass, "dup", duplicate_node, -1);
  rb_define_method(klass, "unlink", unlink_node, 0);
  rb_define_method(klass, "internal_subset", internal_subset, 0);
  rb_define_method(klass, "external_subset", external_subset, 0);
  rb_define_method(klass, "create_internal_subset", create_internal_subset, 3);
  rb_define_method(klass, "create_external_subset", create_external_subset, 3);
  rb_define_method(klass, "pointer_id", pointer_id, 0);
  rb_define_method(klass, "line", line, 0);

  rb_define_private_method(klass, "in_context", in_context, 2);
  rb_define_private_method(klass, "add_child_node", add_child, 1);
  rb_define_private_method(klass, "add_previous_sibling_node", add_previous_sibling, 1);
  rb_define_private_method(klass, "add_next_sibling_node", add_next_sibling, 1);
  rb_define_private_method(klass, "replace_node", replace, 1);
  rb_define_private_method(klass, "dump_html", dump_html, 0);
  rb_define_private_method(klass, "native_write_to", native_write_to, 4);
  rb_define_private_method(klass, "native_content=", set_content, 1);
  rb_define_private_method(klass, "get", get, 1);
  rb_define_private_method(klass, "set_namespace", set_namespace, 1);
  rb_define_private_method(klass, "compare", compare, 1);

  decorate      = rb_intern("decorate");
  decorate_bang = rb_intern("decorate!");
}
