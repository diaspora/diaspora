module Nokogiri
  # :stopdoc:
  module LibXML
    class XmlSaxPushParserContext < FFI::ManagedStruct

      layout(
        :sax,           :pointer,       # struct _xmlSAXHandler *sax;       /* The SAX handler */
        :userData,      :pointer,       # void            *userData;        /* For SAX interface only, used by DOM build */
        :myDoc,         :pointer,       # xmlDocPtr           myDoc;        /* the document being built */
        :wellFormed,    :int,           # int            wellFormed;        /* is the document well formed */
        :replaceEntities, :int,         # int       replaceEntities;        /* shall we replace entities ? */
        :version,       :pointer,       # const xmlChar    *version;        /* the XML version string */
        :encoding,      :pointer,       # const xmlChar   *encoding;        /* the declared encoding, if any */
        :standalone,    :int,           # int            standalone;        /* standalone document */
        :html,          :int,           # int                  html;        /* an HTML(1)/Docbook(2) document

        :input,         :pointer,       # xmlParserInputPtr  input;         /* Current input stream */
        :inputNr,       :int,           # int                inputNr;       /* Number of current input streams */
        :inputMax,      :int,           # int                inputMax;      /* Max number of input streams */
        :inputTab,      :pointer,       # xmlParserInputPtr *inputTab;      /* stack of inputs */

        :node,          :pointer,       # xmlNodePtr         node;          /* Current parsed Node */
        :nodeNr,        :int,           # int                nodeNr;        /* Depth of the parsing stack */
        :nodeMax,       :int,           # int                nodeMax;       /* Max depth of the parsing stack */
        :nodeTab,       :pointer,       # xmlNodePtr        *nodeTab;       /* array of nodes */

        :record_info,   :int,           # int record_info;                  /* Whether node info should be kept */

        # xmlParserNodeInfoSeq node_seq;    /* info about each node parsed */
                :node_seq_maximum, :ulong,
                :node_seq_length,  :ulong,
                :node_seq_buffer,  :pointer,

        :errNo,         :int,           # int errNo;                        /* error code */

        :hasExternalSubset, :int,       # int     hasExternalSubset;        /* reference and external subset */
        :hasPErefs,     :int,           # int             hasPErefs;        /* the internal subset has PE refs */
        :external,      :int,           # int              external;        /* are we parsing an external entity */

        :valid,         :int,           # int                 valid;        /* is the document valid */
        :validate,      :int,           # int              validate;        /* shall we try to validate ? */

        # xmlValidCtxt        vctxt;        /* The validity context */
                :vctxt_userData,        :pointer,       # void *userData;			/* user specific data block */
                :vctxt_error,           :pointer,       # xmlValidityErrorFunc error;		/* the callback in case of errors */
                :vctxt_warning,         :pointer,       # xmlValidityWarningFunc warning;	/* the callback in case of warning */
                :vctxt_node,            :pointer,       # xmlNodePtr         node;          /* Current parsed Node */
                :vctxt_nodeNr,          :int,           # int                nodeNr;        /* Depth of the parsing stack */
                :vctxt_nodeMax,         :int,           # int                nodeMax;       /* Max depth of the parsing stack */
                :vctxt_nodeTab,         :pointer,       # xmlNodePtr        *nodeTab;       /* array of nodes */

                :vctxt_finishDtd,       :int,           # unsigned int     finishDtd;       /* finished validating the Dtd ? */
                :vctxt_doc,             :pointer,       # xmlDocPtr              doc;       /* the document */
                :vctxt_valid,           :int,           # int                  valid;       /* temporary validity check result */
                :vctxt_vstate,          :pointer,       # xmlValidState     *vstate;        /* current state */
                :vctxt_vstatNr,         :int,           # int                vstateNr;      /* Depth of the validation stack */
                :vctxt_vstateMax,       :int,           # int                vstateMax;     /* Max depth of the validation stack */
                :vctxt_vstateTab,       :pointer,       # xmlValidState     *vstateTab;     /* array of validation states */
                :vctxt_am,              :pointer,       # xmlAutomataPtr            am;     /* the automata */
                :vctxt_state,           :pointer,       # xmlAutomataStatePtr    state;     /* used to build the automata */

        :instate,       :int,           # xmlParserInputState instate;      /* current type of input */
        :token,         :int,           # int                 token;        /* next char look-ahead */    

        :directory,     :pointer,       # char           *directory;        /* the data directory */
        :name,          :pointer,       # const xmlChar     *name;          /* Current parsed Node */
        :nameNr,        :int,           # int                nameNr;        /* Depth of the parsing stack */
        :nameMax,       :int,           # int                nameMax;       /* Max depth of the parsing stack */
        :nameTab,       :pointer,       # const xmlChar *   *nameTab;       /* array of nodes */

        :nbChars,       :long,          # long               nbChars;       /* number of xmlChar processed */
        :checkIndex,    :long,          # long            checkIndex;       /* used by progressive parsing lookup */
        :keepBlanks,    :int,           # int             keepBlanks;       /* ugly but ... */
        :disableSAX,    :int,           # int             disableSAX;       /* SAX callbacks are disabled */
        :inSubset,      :int,           # int               inSubset;       /* Parsing is in int 1/ext 2 subset */
        :intSubName,    :pointer,       # const xmlChar *    intSubName;    /* name of subset */
        :extSubURI,     :pointer,       # xmlChar *          extSubURI;     /* URI of external subset */
        :extSubSystem,  :pointer,       # xmlChar *          extSubSystem;  /* SYSTEM ID of external subset */

        :space,         :pointer,       # int *              space;         /* Should the parser preserve spaces */
        :spaceNr,       :int,           # int                spaceNr;       /* Depth of the parsing stack */
        :spaceMax,      :int,           # int                spaceMax;      /* Max depth of the parsing stack */
        :spaceTab,      :pointer,       # int *              spaceTab;      /* array of space infos */
        :depth,         :int,           # int                depth;         /* to prevent entity substitution loops */
        :entity,        :pointer,       # xmlParserInputPtr  entity;        /* used to check entities boundaries */
        :charset,       :int,           # int                charset;       /* encoding of the in-memory content
        :nodelen,       :int,           # int                nodelen;       /* Those two fields are there to */
        :nodemem,       :int,           # int                nodemem;       /* Speed up large node parsing */
        :pedantic,      :int,           # int                pedantic;      /* signal pedantic warnings */
        :_private,      :pointer,       # void              *_private;      /* For user data, libxml won't touch it */

        :loadsubset,    :int,           # int                loadsubset;    /* should the external subset be loaded */
        :linenumbers,   :int,           # int                linenumbers;   /* set line number in element content */
        :catalogs,      :pointer,       # void              *catalogs;      /* document's own catalog */
        :recovery,      :int,           # int                recovery;      /* run in recovery mode */
        :progressive,   :int,           # int                progressive;   /* is this a progressive parsing */
        :dict,          :pointer,       # xmlDictPtr         dict;          /* dictionnary for the parser */
        :atts,          :pointer,       # const xmlChar *   *atts;          /* array for the attributes callbacks */
        :maxatts,       :int,           # int                maxatts;       /* the size of the array */
        :docdict,       :int,           # int                docdict;       /* use strings from dict to build tree */
        :str_xml,       :pointer,       # const xmlChar *str_xml;
        :str_xmlns,     :pointer,       # const xmlChar *str_xmlns;
        :str_xml_ns,    :pointer,       # const xmlChar *str_xml_ns;

        :sax2,          :int,           # int                sax2;          /* operating in the new SAX mode */
        :nsNr,          :int,           # int                nsNr;          /* the number of inherited namespaces */
        :nsMax,         :int,           # int                nsMax;         /* the size of the arrays */
        :nsTab,         :pointer,       # const xmlChar *   *nsTab;         /* the array of prefix/namespace name */
        :attallocs,     :pointer,       # int               *attallocs;     /* which attribute were allocated */
        :pushTab,       :pointer,       # void *            *pushTab;       /* array of data for push */
        :attsDefault,   :pointer,       # xmlHashTablePtr    attsDefault;   /* defaulted attributes if any */
        :attsSpecial,   :pointer,       # xmlHashTablePtr    attsSpecial;   /* non-CDATA attributes if any */
        :nsWellFormed,  :int,           # int                nsWellFormed;  /* is the document XML Nanespace okay */
        :options,       :int            # int                options;       /* Extra options */
        )

      def self.release ptr
        LibXML.xmlFreeParserCtxt(ptr)
      end
    end

  end
  # :startdoc:
end
