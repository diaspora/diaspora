#include <xml_node_set.h>
#include <libxml/xpathInternals.h>

static ID decorate ;

/*
 * call-seq:
 *  dup
 *
 * Duplicate this node set
 */
static VALUE duplicate(VALUE self)
{
  xmlNodeSetPtr node_set;
  xmlNodeSetPtr dupl;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  dupl = xmlXPathNodeSetMerge(NULL, node_set);

  return Nokogiri_wrap_xml_node_set(dupl, rb_iv_get(self, "@document"));
}

/*
 * call-seq:
 *  length
 *
 * Get the length of the node set
 */
static VALUE length(VALUE self)
{
  xmlNodeSetPtr node_set;
  Data_Get_Struct(self, xmlNodeSet, node_set);

  if(node_set)
    return INT2NUM(node_set->nodeNr);

  return INT2NUM(0);
}

/*
 * call-seq:
 *  push(node)
 *
 * Append +node+ to the NodeSet.
 */
static VALUE push(VALUE self, VALUE rb_node)
{
  xmlNodeSetPtr node_set;
  xmlNodePtr node;

  if(!(rb_obj_is_kind_of(rb_node, cNokogiriXmlNode) || rb_obj_is_kind_of(rb_node, cNokogiriXmlNamespace)))
    rb_raise(rb_eArgError, "node must be a Nokogiri::XML::Node or Nokogiri::XML::Namespace");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_node, xmlNode, node);
  xmlXPathNodeSetAdd(node_set, node);
  return self;
}

/*
 *  call-seq:
 *    delete(node)
 *
 *  Delete +node+ from the Nodeset, if it is a member. Returns the deleted node
 *  if found, otherwise returns nil.
 */
static VALUE delete(VALUE self, VALUE rb_node)
{
  xmlNodeSetPtr node_set ;
  xmlNodePtr node ;

  if(!(rb_obj_is_kind_of(rb_node, cNokogiriXmlNode) || rb_obj_is_kind_of(rb_node, cNokogiriXmlNamespace)))
    rb_raise(rb_eArgError, "node must be a Nokogiri::XML::Node or Nokogiri::XML::Namespace");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_node, xmlNode, node);

  if (xmlXPathNodeSetContains(node_set, node)) {
    xmlXPathNodeSetDel(node_set, node);
    return rb_node ;
  }

  return Qnil ;
}


/*
 * call-seq:
 *  &(node_set)
 *
 * Set Intersection — Returns a new NodeSet containing nodes common to the two NodeSets.
 */
static VALUE intersection(VALUE self, VALUE rb_other)
{
  xmlNodeSetPtr node_set;
  xmlNodeSetPtr other;

  if(!rb_obj_is_kind_of(rb_other, cNokogiriXmlNodeSet))
    rb_raise(rb_eArgError, "node_set must be a Nokogiri::XML::NodeSet");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_other, xmlNodeSet, other);

  return Nokogiri_wrap_xml_node_set(xmlXPathIntersection(node_set, other), rb_iv_get(self, "@document"));
}


/*
 * call-seq:
 *  include?(node)
 *
 *  Returns true if any member of node set equals +node+.
 */
static VALUE include_eh(VALUE self, VALUE rb_node)
{
  xmlNodeSetPtr node_set;
  xmlNodePtr node;

  if(!(rb_obj_is_kind_of(rb_node, cNokogiriXmlNode) || rb_obj_is_kind_of(rb_node, cNokogiriXmlNamespace)))
    rb_raise(rb_eArgError, "node must be a Nokogiri::XML::Node or Nokogiri::XML::Namespace");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_node, xmlNode, node);

  return (xmlXPathNodeSetContains(node_set, node) ? Qtrue : Qfalse);
}


/*
 * call-seq:
 *  |(node_set)
 *
 * Returns a new set built by merging the set and the elements of the given
 * set.
 */
static VALUE set_union(VALUE self, VALUE rb_other)
{
  xmlNodeSetPtr node_set;
  xmlNodeSetPtr other;
  xmlNodeSetPtr new;

  if(!rb_obj_is_kind_of(rb_other, cNokogiriXmlNodeSet))
    rb_raise(rb_eArgError, "node_set must be a Nokogiri::XML::NodeSet");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_other, xmlNodeSet, other);

  new = xmlXPathNodeSetMerge(NULL, node_set);
  new = xmlXPathNodeSetMerge(new, other);

  return Nokogiri_wrap_xml_node_set(new, rb_iv_get(self, "@document"));
}

/*
 * call-seq:
 *  -(node_set)
 *
 *  Difference - returns a new NodeSet that is a copy of this NodeSet, removing
 *  each item that also appears in +node_set+
 */
static VALUE minus(VALUE self, VALUE rb_other)
{
  xmlNodeSetPtr node_set;
  xmlNodeSetPtr other;
  xmlNodeSetPtr new;
  int j ;

  if(!rb_obj_is_kind_of(rb_other, cNokogiriXmlNodeSet))
    rb_raise(rb_eArgError, "node_set must be a Nokogiri::XML::NodeSet");

  Data_Get_Struct(self, xmlNodeSet, node_set);
  Data_Get_Struct(rb_other, xmlNodeSet, other);

  new = xmlXPathNodeSetMerge(NULL, node_set);
  for (j = 0 ; j < other->nodeNr ; ++j) {
    xmlXPathNodeSetDel(new, other->nodeTab[j]);
  }

  return Nokogiri_wrap_xml_node_set(new, rb_iv_get(self, "@document"));
}


static VALUE index_at(VALUE self, long offset)
{
  xmlNodeSetPtr node_set;
  Data_Get_Struct(self, xmlNodeSet, node_set);

  if(offset >= node_set->nodeNr || abs((int)offset) > node_set->nodeNr) return Qnil;
  if(offset < 0) offset = offset + node_set->nodeNr;

  if (XML_NAMESPACE_DECL == node_set->nodeTab[offset]->type)
    return Nokogiri_wrap_xml_namespace2(rb_iv_get(self, "@document"), (xmlNsPtr)(node_set->nodeTab[offset]));
  return Nokogiri_wrap_xml_node(Qnil, node_set->nodeTab[offset]);
}

static VALUE subseq(VALUE self, long beg, long len)
{
  long j;
  xmlNodeSetPtr node_set;
  xmlNodeSetPtr new_set ;

  Data_Get_Struct(self, xmlNodeSet, node_set);

  if (beg > node_set->nodeNr) return Qnil ;
  if (beg < 0 || len < 0) return Qnil ;

  if ((beg + len) > node_set->nodeNr) {
    len = node_set->nodeNr - beg ;
  }

  new_set = xmlXPathNodeSetCreate(NULL);
  for (j = beg ; j < beg+len ; ++j) {
    xmlXPathNodeSetAddUnique(new_set, node_set->nodeTab[j]);
  }
  return Nokogiri_wrap_xml_node_set(new_set, rb_iv_get(self, "@document"));
}

/*
 * call-seq:
 *  [index] -> Node or nil
 *  [start, length] -> NodeSet or nil
 *  [range] -> NodeSet or nil
 *  slice(index) -> Node or nil
 *  slice(start, length) -> NodeSet or nil
 *  slice(range) -> NodeSet or nil
 *
 * Element reference - returns the node at +index+, or returns a NodeSet
 * containing nodes starting at +start+ and continuing for +length+ elements, or
 * returns a NodeSet containing nodes specified by +range+. Negative +indices+
 * count backward from the end of the +node_set+ (-1 is the last node). Returns
 * nil if the +index+ (or +start+) are out of range.
 */
static VALUE slice(int argc, VALUE *argv, VALUE self)
{
  VALUE arg ;
  long beg, len ;
  xmlNodeSetPtr node_set;
  Data_Get_Struct(self, xmlNodeSet, node_set);

  if (argc == 2) {
    beg = NUM2LONG(argv[0]);
    len = NUM2LONG(argv[1]);
    if (beg < 0) {
      beg += node_set->nodeNr ;
    }
    return subseq(self, beg, len);
  }

  if (argc != 1) {
    rb_scan_args(argc, argv, "11", NULL, NULL);
  }
  arg = argv[0];

  if (FIXNUM_P(arg)) {
    return index_at(self, FIX2LONG(arg));
  }
  
  /* if arg is Range */
  switch (rb_range_beg_len(arg, &beg, &len, node_set->nodeNr, 0)) {
  case Qfalse:
    break;
  case Qnil:
    return Qnil;
  default:
    return subseq(self, beg, len);
  }

  return index_at(self, NUM2LONG(arg));
}


/*
 * call-seq:
 *  to_a
 *
 * Return this list as an Array
 */
static VALUE to_array(VALUE self, VALUE rb_node)
{
  xmlNodeSetPtr set;
  VALUE *elts;
  VALUE list;
  int i;

  Data_Get_Struct(self, xmlNodeSet, set);

  elts = calloc((size_t)set->nodeNr, sizeof(VALUE *));
  for(i = 0; i < set->nodeNr; i++) {
    if (XML_NAMESPACE_DECL == set->nodeTab[i]->type) {
      elts[i] = Nokogiri_wrap_xml_namespace2(rb_iv_get(self, "@document"), (xmlNsPtr)(set->nodeTab[i]));
    } else {
      xmlNodePtr node = set->nodeTab[i];

      if(node->_private) {
        if(node->type == XML_DOCUMENT_NODE || node->type == XML_HTML_DOCUMENT_NODE)
          elts[i] = DOC_RUBY_OBJECT(node->doc);
        else
          elts[i] = (VALUE)node->_private;
      } else {
        elts[i] = Nokogiri_wrap_xml_node(Qnil, node);
      }
    }
  }

  list = rb_ary_new4((long)set->nodeNr, elts);

  /*free(elts); */

  return list;
}

/*
 *  call-seq:
 *    unlink
 *
 * Unlink this NodeSet and all Node objects it contains from their current context.
 */
static VALUE unlink_nodeset(VALUE self)
{
  xmlNodeSetPtr node_set;
  int j, nodeNr ;

  Data_Get_Struct(self, xmlNodeSet, node_set);
  nodeNr = node_set->nodeNr ;
  for (j = 0 ; j < nodeNr ; j++) {
    if (XML_NAMESPACE_DECL != node_set->nodeTab[j]->type) {
      VALUE node ;
      xmlNodePtr node_ptr;
      node = Nokogiri_wrap_xml_node(Qnil, node_set->nodeTab[j]);
      rb_funcall(node, rb_intern("unlink"), 0); /* modifies the C struct out from under the object */
      Data_Get_Struct(node, xmlNode, node_ptr);
      node_set->nodeTab[j] = node_ptr ;
    }
  }
  return self ;
}


static void deallocate(xmlNodeSetPtr node_set)
{
  /*
   *  xmlXPathFreeNodeSet() contains an implicit assumption that it is being
   *  called before any of its pointed-to nodes have been free()d. this
   *  assumption lies in the operation where it dereferences nodeTab pointers
   *  while searching for namespace nodes to free.
   *
   *  however, since Ruby's GC mechanism cannot guarantee the strict order in
   *  which ruby objects will be GC'd, nodes may be garbage collected before a
   *  nodeset containing pointers to those nodes. (this is true regardless of
   *  how we declare dependencies between objects with rb_gc_mark().)
   *
   *  as a result, xmlXPathFreeNodeSet() will perform unsafe memory operations,
   *  and calling it would be evil.
   *
   *  on the bright side, though, Nokogiri's API currently does not cause
   *  namespace nodes to be included in node sets, ever.
   *
   *  armed with that fact, we examined xmlXPathFreeNodeSet() and related libxml
   *  code and determined that, within the Nokogiri abstraction, we will not
   *  leak memory if we simply free the node set's memory directly. that's only
   *  quasi-evil!
   *
   *  there's probably a lesson in here somewhere about intermingling, within a
   *  single array, structs with different memory-ownership semantics. or more
   *  generally, a lesson about building an API in C/C++ that does not contain
   *  assumptions about the strict order in which memory will be released. hey,
   *  that sounds like a great idea for a blog post! get to it!
   *
   *  "In Valgrind We Trust." seriously.
   */
  NOKOGIRI_DEBUG_START(node_set) ;
  if (node_set->nodeTab != NULL)
    xmlFree(node_set->nodeTab);
  xmlFree(node_set);
  NOKOGIRI_DEBUG_END(node_set) ;
}

static VALUE allocate(VALUE klass)
{
  return Nokogiri_wrap_xml_node_set(xmlXPathNodeSetCreate(NULL), Qnil);
}

VALUE Nokogiri_wrap_xml_node_set(xmlNodeSetPtr node_set, VALUE document)
{
  VALUE new_set ;
  new_set = Data_Wrap_Struct(cNokogiriXmlNodeSet, 0, deallocate, node_set);
  if (document != Qnil) {
    rb_iv_set(new_set, "@document", document);
    rb_funcall(document, decorate, 1, new_set);
  }
  return new_set ;
}

VALUE cNokogiriXmlNodeSet ;
void init_xml_node_set(void)
{
  VALUE nokogiri  = rb_define_module("Nokogiri");
  VALUE xml       = rb_define_module_under(nokogiri, "XML");
  VALUE klass     = rb_define_class_under(xml, "NodeSet", rb_cObject);
  cNokogiriXmlNodeSet = klass;

  rb_define_alloc_func(klass, allocate);
  rb_define_method(klass, "length", length, 0);
  rb_define_method(klass, "[]", slice, -1);
  rb_define_method(klass, "slice", slice, -1);
  rb_define_method(klass, "push", push, 1);
  rb_define_method(klass, "|", set_union, 1);
  rb_define_method(klass, "-", minus, 1);
  rb_define_method(klass, "unlink", unlink_nodeset, 0);
  rb_define_method(klass, "to_a", to_array, 0);
  rb_define_method(klass, "dup", duplicate, 0);
  rb_define_method(klass, "delete", delete, 1);
  rb_define_method(klass, "&", intersection, 1);
  rb_define_method(klass, "include?", include_eh, 1);

  decorate      = rb_intern("decorate");
}
