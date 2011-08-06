
#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
#include <assert.h>
#include <ruby.h>

#if defined(_WIN32)
#include <stddef.h>
#endif

#ifdef HAVE_RUBY_RE_H
#include <ruby/re.h>
#else
#include <re.h>
#endif

#ifdef HAVE_RUBY_ENCODING_H
#include <ruby/encoding.h>
#define ENCODED_STR_NEW(ptr, len) \
    rb_enc_str_new(ptr, len, rb_utf8_encoding())
#else
#define ENCODED_STR_NEW(ptr, len) \
    rb_str_new(ptr, len)
#endif

#ifndef RSTRING_PTR
#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif

#ifndef RSTRING_LEN
#define RSTRING_LEN(s) (RSTRING(s)->len)
#endif

#define DATA_GET(FROM, TYPE, NAME) \
  Data_Get_Struct(FROM, TYPE, NAME); \
  if (NAME == NULL) { \
    rb_raise(rb_eArgError, "NULL found for " # NAME " when it shouldn't be."); \
  }
 
typedef struct lexer_state {
  int content_len;
  int line_number;
  int current_line;
  int start_col;
  size_t mark;
  size_t keyword_start;
  size_t keyword_end;
  size_t next_keyword_start;
  size_t content_start;
  size_t content_end;
  size_t query_start;
  size_t last_newline;
  size_t final_newline;
} lexer_state;

static VALUE mGherkin;
static VALUE mGherkinLexer;
static VALUE mCLexer;
static VALUE cI18nLexer;
static VALUE rb_eGherkinLexingError;

#define LEN(AT, P) (P - data - lexer->AT)
#define MARK(M, P) (lexer->M = (P) - data)
#define PTR_TO(P) (data + lexer->P)

#define STORE_KW_END_CON(EVENT) \
  store_multiline_kw_con(listener, # EVENT, \
    PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end - 1)), \
    PTR_TO(content_start), LEN(content_start, PTR_TO(content_end)), \
    lexer->current_line, lexer->start_col); \
    if (lexer->content_end != 0) { \
      p = PTR_TO(content_end - 1); \
    } \
    lexer->content_end = 0

#define STORE_ATTR(ATTR) \
    store_attr(listener, # ATTR, \
      PTR_TO(content_start), LEN(content_start, p), \
      lexer->line_number)


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
static const char _lexer_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 10, 1, 
	11, 1, 14, 1, 15, 1, 16, 1, 
	17, 1, 18, 1, 19, 1, 20, 1, 
	21, 2, 1, 16, 2, 11, 0, 2, 
	12, 13, 2, 15, 0, 2, 15, 2, 
	2, 15, 14, 2, 15, 17, 2, 16, 
	4, 2, 16, 5, 2, 16, 6, 2, 
	16, 7, 2, 16, 8, 2, 16, 14, 
	2, 18, 19, 2, 20, 0, 2, 20, 
	2, 2, 20, 14, 2, 20, 17, 3, 
	3, 12, 13, 3, 9, 12, 13, 3, 
	10, 12, 13, 3, 11, 12, 13, 3, 
	12, 13, 16, 3, 15, 12, 13, 4, 
	1, 12, 13, 16, 4, 15, 0, 12, 
	13
};

static const short _lexer_key_offsets[] = {
	0, 0, 15, 17, 18, 19, 21, 22, 
	23, 24, 25, 26, 28, 42, 46, 47, 
	48, 49, 51, 52, 53, 54, 55, 56, 
	57, 58, 59, 60, 61, 62, 63, 64, 
	76, 79, 81, 83, 86, 88, 90, 92, 
	94, 108, 111, 112, 113, 114, 115, 116, 
	117, 118, 119, 120, 121, 123, 124, 125, 
	126, 127, 128, 129, 130, 131, 132, 144, 
	147, 149, 151, 154, 156, 158, 160, 162, 
	164, 166, 168, 170, 172, 174, 176, 178, 
	180, 184, 186, 188, 190, 193, 195, 197, 
	199, 201, 203, 205, 208, 210, 212, 214, 
	216, 218, 220, 222, 224, 226, 228, 230, 
	232, 234, 236, 238, 240, 242, 244, 246, 
	248, 250, 252, 254, 256, 258, 260, 262, 
	264, 266, 268, 270, 272, 274, 276, 278, 
	280, 281, 282, 294, 297, 299, 301, 304, 
	306, 308, 310, 312, 314, 316, 318, 320, 
	322, 324, 326, 328, 330, 335, 337, 339, 
	341, 344, 346, 348, 350, 352, 354, 356, 
	358, 360, 362, 364, 367, 369, 371, 373, 
	375, 377, 379, 381, 383, 385, 387, 390, 
	392, 394, 396, 398, 400, 402, 404, 406, 
	408, 410, 412, 414, 416, 418, 420, 422, 
	424, 426, 428, 430, 432, 434, 436, 438, 
	440, 442, 444, 446, 448, 450, 452, 454, 
	455, 456, 457, 458, 465, 467, 469, 471, 
	473, 475, 477, 478, 479, 480, 481, 482, 
	483, 484, 485, 486, 487, 488, 489, 490, 
	494, 499, 504, 509, 514, 518, 522, 524, 
	525, 526, 527, 528, 529, 530, 531, 532, 
	533, 534, 535, 536, 537, 538, 539, 540, 
	545, 552, 557, 561, 567, 570, 572, 578, 
	592, 594, 596, 598, 600, 602, 604, 606, 
	608, 610, 614, 616, 618, 620, 623, 625, 
	627, 629, 631, 633, 635, 638, 640, 642, 
	644, 646, 648, 650, 652, 654, 656, 658, 
	661, 663, 665, 667, 669, 671, 673, 675, 
	677, 679, 681, 683, 685, 687, 689, 691, 
	693, 695, 697, 699, 701, 703, 705, 707, 
	709, 711, 713, 715, 717, 719, 721, 723, 
	725, 726, 727, 728, 729, 730, 731, 732, 
	733, 734, 735, 736, 746, 748, 750, 752, 
	754, 756, 758, 760, 762, 764, 766, 768, 
	771, 773, 775, 777, 779, 781, 783, 785, 
	787, 789, 791, 794, 796, 798, 800, 802, 
	804, 806, 808, 810, 812, 814, 816, 818, 
	820, 822, 824, 826, 828, 830, 832, 834, 
	836, 837, 838
};

static const char _lexer_trans_keys[] = {
	-22, -21, -20, -19, -17, 10, 32, 34, 
	35, 37, 42, 64, 124, 9, 13, -73, 
	-72, -72, -21, -97, -90, -84, -21, -87, 
	-76, 10, 10, 13, -22, -21, -20, -19, 
	10, 32, 34, 35, 37, 42, 64, 124, 
	9, 13, -117, -89, -88, -80, -88, -116, 
	-20, -107, -99, -67, -68, -68, -20, -96, 
	-128, -80, -22, -78, -67, 58, 10, 10, 
	-22, -21, -20, -19, 10, 32, 35, 37, 
	42, 64, 9, 13, -73, -72, 10, -72, 
	10, -21, 10, -97, -90, 10, -84, 10, 
	-21, 10, -87, 10, -76, 10, -22, -21, 
	-20, -19, 10, 32, 34, 35, 37, 42, 
	64, 124, 9, 13, -117, -104, -95, -100, 
	-21, -126, -104, -21, -90, -84, -20, -104, 
	-92, 32, 58, -22, -80, -100, -20, -102, 
	-108, 58, 10, 10, -22, -21, -20, -19, 
	10, 32, 35, 37, 42, 64, 9, 13, 
	-73, -72, 10, -72, 10, -21, 10, -97, 
	-90, 10, -84, 10, -21, 10, -87, 10, 
	-76, 10, -84, 10, -22, 10, -77, 10, 
	-96, 10, -80, 10, -21, 10, -118, 10, 
	-91, 10, 10, 58, -117, -89, -88, 10, 
	-88, 10, -116, 10, -20, 10, -107, -99, 
	10, -67, 10, -68, 10, -68, 10, -20, 
	10, -96, 10, -128, 10, -117, -95, 10, 
	-100, 10, -21, 10, -126, 10, -104, 10, 
	-21, 10, -90, 10, -84, 10, -20, 10, 
	-104, 10, -92, 10, -80, 10, -22, 10, 
	-79, 10, -107, 10, -104, 10, -20, 10, 
	-89, 10, -128, 10, -21, 10, -89, 10, 
	-116, 10, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 10, -22, -21, -20, -19, 10, 32, 
	35, 37, 42, 64, 9, 13, -73, -72, 
	10, -72, 10, -21, 10, -97, -90, 10, 
	-84, 10, -21, 10, -87, 10, -76, 10, 
	-84, 10, -22, 10, -77, 10, -96, 10, 
	-80, 10, -21, 10, -118, 10, -91, 10, 
	10, 58, -117, -89, -88, -80, 10, -88, 
	10, -116, 10, -20, 10, -107, -99, 10, 
	-67, 10, -68, 10, -68, 10, -20, 10, 
	-96, 10, -128, 10, -80, 10, -22, 10, 
	-78, 10, -67, 10, -117, -95, 10, -100, 
	10, -21, 10, -126, 10, -104, 10, -21, 
	10, -90, 10, -84, 10, -20, 10, -104, 
	10, -92, 10, 10, 32, 58, -22, 10, 
	-80, 10, -100, 10, -20, 10, -102, 10, 
	-108, 10, -80, 10, -22, 10, -79, 10, 
	-107, 10, -104, 10, -20, 10, -89, 10, 
	-128, 10, -21, 10, -89, 10, -116, 10, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, -120, 58, 
	10, 10, -22, 10, 32, 35, 124, 9, 
	13, -72, 10, -80, 10, -21, 10, -118, 
	10, -91, 10, 10, 58, -80, -22, -79, 
	-107, -104, -20, -89, -128, -21, -89, -116, 
	34, 34, 10, 32, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 9, 13, 10, 32, 
	9, 13, 10, 13, 10, 95, 70, 69, 
	65, 84, 85, 82, 69, 95, 69, 78, 
	68, 95, 37, 32, 13, 32, 64, 9, 
	10, 9, 10, 13, 32, 64, 11, 12, 
	10, 32, 64, 9, 13, 32, 124, 9, 
	13, 10, 32, 92, 124, 9, 13, 10, 
	92, 124, 10, 92, 10, 32, 92, 124, 
	9, 13, -22, -21, -20, -19, 10, 32, 
	34, 35, 37, 42, 64, 124, 9, 13, 
	-84, 10, -22, 10, -77, 10, -96, 10, 
	-80, 10, -21, 10, -118, 10, -91, 10, 
	10, 58, -117, -89, -88, 10, -88, 10, 
	-116, 10, -20, 10, -107, -99, 10, -67, 
	10, -68, 10, -68, 10, -20, 10, -96, 
	10, -128, 10, -117, -95, 10, -100, 10, 
	-21, 10, -126, 10, -104, 10, -21, 10, 
	-90, 10, -84, 10, -20, 10, -104, 10, 
	-92, 10, 10, 32, 58, -22, 10, -80, 
	10, -100, 10, -20, 10, -102, 10, -108, 
	10, -80, 10, -22, 10, -79, 10, -107, 
	10, -104, 10, -20, 10, -89, 10, -128, 
	10, -21, 10, -89, 10, -116, 10, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 32, -84, -22, -77, 
	-96, -80, -21, -118, -91, 58, 10, 10, 
	-22, -21, -20, 10, 32, 35, 37, 64, 
	9, 13, -72, 10, -80, 10, -21, 10, 
	-118, 10, -91, 10, 10, 58, -80, 10, 
	-80, 10, -22, 10, -78, 10, -67, 10, 
	-117, -104, 10, -100, 10, -21, 10, -126, 
	10, -104, 10, -21, 10, -90, 10, -84, 
	10, -20, 10, -104, 10, -92, 10, 10, 
	32, 58, -22, 10, -80, 10, -100, 10, 
	-20, 10, -102, 10, -108, 10, -120, 10, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 13, 2, 1, 1, 2, 1, 1, 
	1, 1, 1, 2, 12, 4, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 10, 
	3, 2, 2, 3, 2, 2, 2, 2, 
	12, 3, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 10, 3, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	4, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 10, 3, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 5, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 5, 2, 2, 2, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	3, 3, 3, 3, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 3, 
	5, 3, 2, 4, 3, 2, 4, 12, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 4, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 8, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	1, 1, 1, 1, 0, 0, 1, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 15, 18, 20, 22, 25, 27, 
	29, 31, 33, 35, 38, 52, 57, 59, 
	61, 63, 66, 68, 70, 72, 74, 76, 
	78, 80, 82, 84, 86, 88, 90, 92, 
	104, 108, 111, 114, 118, 121, 124, 127, 
	130, 144, 148, 150, 152, 154, 156, 158, 
	160, 162, 164, 166, 168, 171, 173, 175, 
	177, 179, 181, 183, 185, 187, 189, 201, 
	205, 208, 211, 215, 218, 221, 224, 227, 
	230, 233, 236, 239, 242, 245, 248, 251, 
	254, 259, 262, 265, 268, 272, 275, 278, 
	281, 284, 287, 290, 294, 297, 300, 303, 
	306, 309, 312, 315, 318, 321, 324, 327, 
	330, 333, 336, 339, 342, 345, 348, 351, 
	354, 357, 360, 363, 366, 369, 372, 375, 
	378, 381, 384, 387, 390, 393, 396, 399, 
	402, 404, 406, 418, 422, 425, 428, 432, 
	435, 438, 441, 444, 447, 450, 453, 456, 
	459, 462, 465, 468, 471, 477, 480, 483, 
	486, 490, 493, 496, 499, 502, 505, 508, 
	511, 514, 517, 520, 524, 527, 530, 533, 
	536, 539, 542, 545, 548, 551, 554, 558, 
	561, 564, 567, 570, 573, 576, 579, 582, 
	585, 588, 591, 594, 597, 600, 603, 606, 
	609, 612, 615, 618, 621, 624, 627, 630, 
	633, 636, 639, 642, 645, 648, 651, 654, 
	656, 658, 660, 662, 669, 672, 675, 678, 
	681, 684, 687, 689, 691, 693, 695, 697, 
	699, 701, 703, 705, 707, 709, 711, 713, 
	717, 722, 727, 732, 737, 741, 745, 748, 
	750, 752, 754, 756, 758, 760, 762, 764, 
	766, 768, 770, 772, 774, 776, 778, 780, 
	785, 792, 797, 801, 807, 811, 814, 820, 
	834, 837, 840, 843, 846, 849, 852, 855, 
	858, 861, 866, 869, 872, 875, 879, 882, 
	885, 888, 891, 894, 897, 901, 904, 907, 
	910, 913, 916, 919, 922, 925, 928, 931, 
	935, 938, 941, 944, 947, 950, 953, 956, 
	959, 962, 965, 968, 971, 974, 977, 980, 
	983, 986, 989, 992, 995, 998, 1001, 1004, 
	1007, 1010, 1013, 1016, 1019, 1022, 1025, 1028, 
	1031, 1033, 1035, 1037, 1039, 1041, 1043, 1045, 
	1047, 1049, 1051, 1053, 1063, 1066, 1069, 1072, 
	1075, 1078, 1081, 1084, 1087, 1090, 1093, 1096, 
	1100, 1103, 1106, 1109, 1112, 1115, 1118, 1121, 
	1124, 1127, 1130, 1134, 1137, 1140, 1143, 1146, 
	1149, 1152, 1155, 1158, 1161, 1164, 1167, 1170, 
	1173, 1176, 1179, 1182, 1185, 1188, 1191, 1194, 
	1197, 1199, 1201
};

static const short _lexer_trans_targs[] = {
	2, 13, 41, 221, 384, 12, 12, 229, 
	238, 240, 254, 255, 258, 12, 0, 3, 
	332, 0, 4, 0, 5, 0, 6, 328, 
	0, 7, 0, 8, 0, 9, 0, 10, 
	0, 0, 11, 12, 239, 11, 2, 13, 
	41, 221, 12, 12, 229, 238, 240, 254, 
	255, 258, 12, 0, 14, 15, 20, 24, 
	0, 10, 0, 16, 0, 17, 0, 18, 
	19, 0, 10, 0, 10, 0, 21, 0, 
	22, 0, 23, 0, 10, 0, 25, 0, 
	26, 0, 27, 0, 28, 0, 29, 0, 
	31, 30, 31, 30, 32, 273, 284, 305, 
	31, 31, 12, 313, 327, 12, 31, 30, 
	33, 268, 31, 30, 34, 31, 30, 35, 
	31, 30, 36, 264, 31, 30, 37, 31, 
	30, 38, 31, 30, 39, 31, 30, 40, 
	31, 30, 2, 13, 41, 221, 12, 12, 
	229, 238, 240, 254, 255, 258, 12, 0, 
	42, 207, 218, 0, 43, 0, 44, 0, 
	45, 0, 46, 0, 47, 0, 48, 0, 
	49, 0, 50, 0, 51, 0, 52, 0, 
	53, 128, 0, 54, 0, 55, 0, 56, 
	0, 57, 0, 58, 0, 59, 0, 60, 
	0, 62, 61, 62, 61, 63, 80, 91, 
	105, 62, 62, 12, 113, 127, 12, 62, 
	61, 64, 75, 62, 61, 65, 62, 61, 
	66, 62, 61, 67, 71, 62, 61, 68, 
	62, 61, 69, 62, 61, 70, 62, 61, 
	40, 62, 61, 72, 62, 61, 73, 62, 
	61, 74, 62, 61, 40, 62, 61, 76, 
	62, 61, 77, 62, 61, 78, 62, 61, 
	79, 62, 61, 62, 40, 61, 81, 82, 
	87, 62, 61, 40, 62, 61, 83, 62, 
	61, 84, 62, 61, 85, 86, 62, 61, 
	40, 62, 61, 40, 62, 61, 88, 62, 
	61, 89, 62, 61, 90, 62, 61, 40, 
	62, 61, 92, 102, 62, 61, 93, 62, 
	61, 94, 62, 61, 95, 62, 61, 96, 
	62, 61, 97, 62, 61, 98, 62, 61, 
	99, 62, 61, 100, 62, 61, 101, 62, 
	61, 79, 62, 61, 103, 62, 61, 104, 
	62, 61, 70, 62, 61, 106, 62, 61, 
	107, 62, 61, 108, 62, 61, 109, 62, 
	61, 110, 62, 61, 111, 62, 61, 112, 
	62, 61, 40, 62, 61, 62, 114, 61, 
	62, 115, 61, 62, 116, 61, 62, 117, 
	61, 62, 118, 61, 62, 119, 61, 62, 
	120, 61, 62, 121, 61, 62, 122, 61, 
	62, 123, 61, 62, 124, 61, 62, 125, 
	61, 62, 126, 61, 62, 12, 61, 62, 
	40, 61, 130, 129, 130, 129, 131, 148, 
	163, 184, 130, 130, 12, 192, 206, 12, 
	130, 129, 132, 143, 130, 129, 133, 130, 
	129, 134, 130, 129, 135, 139, 130, 129, 
	136, 130, 129, 137, 130, 129, 138, 130, 
	129, 40, 130, 129, 140, 130, 129, 141, 
	130, 129, 142, 130, 129, 40, 130, 129, 
	144, 130, 129, 145, 130, 129, 146, 130, 
	129, 147, 130, 129, 130, 40, 129, 149, 
	150, 155, 159, 130, 129, 40, 130, 129, 
	151, 130, 129, 152, 130, 129, 153, 154, 
	130, 129, 40, 130, 129, 40, 130, 129, 
	156, 130, 129, 157, 130, 129, 158, 130, 
	129, 40, 130, 129, 160, 130, 129, 161, 
	130, 129, 162, 130, 129, 147, 130, 129, 
	164, 181, 130, 129, 165, 130, 129, 166, 
	130, 129, 167, 130, 129, 168, 130, 129, 
	169, 130, 129, 170, 130, 129, 171, 130, 
	129, 172, 130, 129, 173, 130, 129, 174, 
	130, 129, 130, 175, 40, 129, 176, 130, 
	129, 177, 130, 129, 178, 130, 129, 179, 
	130, 129, 180, 130, 129, 147, 130, 129, 
	182, 130, 129, 183, 130, 129, 138, 130, 
	129, 185, 130, 129, 186, 130, 129, 187, 
	130, 129, 188, 130, 129, 189, 130, 129, 
	190, 130, 129, 191, 130, 129, 40, 130, 
	129, 130, 193, 129, 130, 194, 129, 130, 
	195, 129, 130, 196, 129, 130, 197, 129, 
	130, 198, 129, 130, 199, 129, 130, 200, 
	129, 130, 201, 129, 130, 202, 129, 130, 
	203, 129, 130, 204, 129, 130, 205, 129, 
	130, 12, 129, 130, 40, 129, 208, 0, 
	209, 0, 211, 210, 211, 210, 212, 211, 
	211, 12, 12, 211, 210, 213, 211, 210, 
	214, 211, 210, 215, 211, 210, 216, 211, 
	210, 217, 211, 210, 211, 40, 210, 219, 
	0, 220, 0, 9, 0, 222, 0, 223, 
	0, 224, 0, 225, 0, 226, 0, 227, 
	0, 228, 0, 10, 0, 230, 0, 231, 
	0, 232, 231, 231, 0, 233, 233, 234, 
	233, 233, 233, 233, 234, 233, 233, 233, 
	233, 235, 233, 233, 233, 233, 236, 233, 
	233, 12, 237, 237, 0, 12, 237, 237, 
	0, 12, 239, 238, 12, 0, 241, 0, 
	242, 0, 243, 0, 244, 0, 245, 0, 
	246, 0, 247, 0, 248, 0, 249, 0, 
	250, 0, 251, 0, 252, 0, 253, 0, 
	386, 0, 10, 0, 0, 0, 0, 0, 
	256, 257, 12, 257, 257, 255, 256, 256, 
	12, 257, 255, 257, 0, 258, 259, 258, 
	0, 263, 262, 261, 259, 262, 260, 0, 
	261, 259, 260, 0, 261, 260, 263, 262, 
	261, 259, 262, 260, 2, 13, 41, 221, 
	263, 263, 229, 238, 240, 254, 255, 258, 
	263, 0, 265, 31, 30, 266, 31, 30, 
	267, 31, 30, 40, 31, 30, 269, 31, 
	30, 270, 31, 30, 271, 31, 30, 272, 
	31, 30, 31, 40, 30, 274, 275, 280, 
	31, 30, 40, 31, 30, 276, 31, 30, 
	277, 31, 30, 278, 279, 31, 30, 40, 
	31, 30, 40, 31, 30, 281, 31, 30, 
	282, 31, 30, 283, 31, 30, 40, 31, 
	30, 285, 302, 31, 30, 286, 31, 30, 
	287, 31, 30, 288, 31, 30, 289, 31, 
	30, 290, 31, 30, 291, 31, 30, 292, 
	31, 30, 293, 31, 30, 294, 31, 30, 
	295, 31, 30, 31, 296, 40, 30, 297, 
	31, 30, 298, 31, 30, 299, 31, 30, 
	300, 31, 30, 301, 31, 30, 272, 31, 
	30, 303, 31, 30, 304, 31, 30, 39, 
	31, 30, 306, 31, 30, 307, 31, 30, 
	308, 31, 30, 309, 31, 30, 310, 31, 
	30, 311, 31, 30, 312, 31, 30, 40, 
	31, 30, 31, 314, 30, 31, 315, 30, 
	31, 316, 30, 31, 317, 30, 31, 318, 
	30, 31, 319, 30, 31, 320, 30, 31, 
	321, 30, 31, 322, 30, 31, 323, 30, 
	31, 324, 30, 31, 325, 30, 31, 326, 
	30, 31, 12, 30, 31, 40, 30, 329, 
	0, 330, 0, 331, 0, 10, 0, 333, 
	0, 334, 0, 335, 0, 336, 0, 337, 
	0, 339, 338, 339, 338, 340, 346, 351, 
	339, 339, 12, 370, 12, 339, 338, 341, 
	339, 338, 342, 339, 338, 343, 339, 338, 
	344, 339, 338, 345, 339, 338, 339, 40, 
	338, 347, 339, 338, 348, 339, 338, 349, 
	339, 338, 350, 339, 338, 345, 339, 338, 
	352, 369, 339, 338, 353, 339, 338, 354, 
	339, 338, 355, 339, 338, 356, 339, 338, 
	357, 339, 338, 358, 339, 338, 359, 339, 
	338, 360, 339, 338, 361, 339, 338, 362, 
	339, 338, 339, 363, 40, 338, 364, 339, 
	338, 365, 339, 338, 366, 339, 338, 367, 
	339, 338, 368, 339, 338, 345, 339, 338, 
	345, 339, 338, 339, 371, 338, 339, 372, 
	338, 339, 373, 338, 339, 374, 338, 339, 
	375, 338, 339, 376, 338, 339, 377, 338, 
	339, 378, 338, 339, 379, 338, 339, 380, 
	338, 339, 381, 338, 339, 382, 338, 339, 
	383, 338, 339, 12, 338, 385, 0, 12, 
	0, 0, 0
};

static const char _lexer_trans_actions[] = {
	25, 25, 25, 25, 0, 47, 0, 5, 
	1, 0, 25, 1, 31, 0, 39, 0, 
	0, 39, 0, 39, 0, 39, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 39, 50, 99, 19, 0, 25, 25, 
	25, 25, 47, 0, 5, 1, 0, 25, 
	1, 31, 0, 39, 0, 0, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	124, 50, 47, 0, 77, 77, 77, 77, 
	47, 0, 65, 29, 77, 65, 0, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 11, 
	47, 0, 56, 56, 56, 56, 115, 27, 
	53, 50, 27, 56, 50, 59, 27, 39, 
	0, 0, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 124, 50, 47, 0, 77, 77, 77, 
	77, 47, 0, 71, 29, 77, 71, 0, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	15, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 15, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 47, 15, 0, 0, 0, 
	0, 47, 0, 15, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	15, 47, 0, 15, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 15, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 15, 47, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 15, 0, 47, 
	15, 0, 124, 50, 47, 0, 77, 77, 
	77, 77, 47, 0, 68, 29, 77, 68, 
	0, 0, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 13, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 13, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 47, 13, 0, 0, 
	0, 0, 0, 47, 0, 13, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	47, 0, 13, 47, 0, 13, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 13, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 13, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 13, 47, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 13, 0, 47, 13, 0, 0, 39, 
	0, 39, 124, 50, 47, 0, 77, 47, 
	0, 74, 74, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 47, 17, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 47, 0, 0, 39, 119, 41, 41, 
	41, 3, 111, 29, 29, 29, 0, 111, 
	29, 29, 29, 0, 111, 29, 0, 29, 
	0, 95, 7, 7, 39, 47, 0, 0, 
	39, 103, 21, 0, 47, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 39, 39, 39, 39, 
	0, 23, 107, 23, 23, 44, 23, 0, 
	47, 0, 1, 0, 39, 0, 0, 0, 
	39, 47, 33, 33, 80, 33, 33, 39, 
	0, 35, 0, 39, 0, 0, 47, 0, 
	0, 35, 0, 0, 89, 89, 89, 89, 
	47, 0, 86, 83, 37, 89, 83, 92, 
	0, 39, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 11, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 47, 11, 0, 0, 0, 0, 
	47, 0, 11, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 47, 0, 11, 
	47, 0, 11, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 11, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 11, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 11, 
	47, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 11, 0, 47, 11, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 124, 50, 47, 0, 77, 77, 77, 
	47, 0, 62, 29, 62, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 47, 9, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 9, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 9, 0, 0, 39, 0, 
	39, 0, 0
};

static const char _lexer_eof_actions[] = {
	0, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39
};

static const int lexer_start = 1;
static const int lexer_first_final = 386;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"

static VALUE 
unindent(VALUE con, int start_col)
{
  VALUE re;
  // Gherkin will crash gracefully if the string representation of start_col pushes the pattern past 32 characters
  char pat[32]; 
  snprintf(pat, 32, "^[\t ]{0,%d}", start_col); 
  re = rb_reg_regcomp(rb_str_new2(pat));
  rb_funcall(con, rb_intern("gsub!"), 2, re, rb_str_new2(""));

  return Qnil;

}

static void 
store_kw_con(VALUE listener, const char * event_name, 
             const char * keyword_at, size_t keyword_length, 
             const char * at,         size_t length, 
             int current_line)
{
  VALUE con = Qnil, kw = Qnil;
  kw = ENCODED_STR_NEW(keyword_at, keyword_length);
  con = ENCODED_STR_NEW(at, length);
  rb_funcall(con, rb_intern("strip!"), 0);
  rb_funcall(listener, rb_intern(event_name), 3, kw, con, INT2FIX(current_line)); 
}

static void
store_multiline_kw_con(VALUE listener, const char * event_name,
                      const char * keyword_at, size_t keyword_length,
                      const char * at,         size_t length,
                      int current_line, int start_col)
{
  VALUE split;
  VALUE con = Qnil, kw = Qnil, name = Qnil, desc = Qnil;

  kw = ENCODED_STR_NEW(keyword_at, keyword_length);
  con = ENCODED_STR_NEW(at, length);

  unindent(con, start_col);
  
  split = rb_str_split(con, "\n");

  name = rb_funcall(split, rb_intern("shift"), 0);
  desc = rb_ary_join(split, rb_str_new2( "\n" ));

  if( name == Qnil ) 
  {
    name = rb_str_new2("");
  }
  if( rb_funcall(desc, rb_intern("size"), 0) == 0) 
  {
    desc = rb_str_new2("");
  }
  rb_funcall(name, rb_intern("strip!"), 0);
  rb_funcall(desc, rb_intern("rstrip!"), 0);
  rb_funcall(listener, rb_intern(event_name), 4, kw, name, desc, INT2FIX(current_line)); 
}

static void 
store_attr(VALUE listener, const char * attr_type,
           const char * at, size_t length, 
           int line)
{
  VALUE val = ENCODED_STR_NEW(at, length);
  rb_funcall(listener, rb_intern(attr_type), 2, val, INT2FIX(line));
}

static void 
store_pystring_content(VALUE listener, 
          int start_col, 
          const char *at, size_t length, 
          int current_line)
{
  VALUE re2;
  VALUE unescape_escaped_quotes;
  VALUE con = ENCODED_STR_NEW(at, length);

  unindent(con, start_col);

  re2 = rb_reg_regcomp(rb_str_new2("\r\\Z"));
  unescape_escaped_quotes = rb_reg_regcomp(rb_str_new2("\\\\\"\\\\\"\\\\\""));
  rb_funcall(con, rb_intern("sub!"), 2, re2, rb_str_new2(""));
  rb_funcall(con, rb_intern("gsub!"), 2, unescape_escaped_quotes, rb_str_new2("\"\"\""));
  rb_funcall(listener, rb_intern("doc_string"), 2, con, INT2FIX(current_line));
}

static void 
raise_lexer_error(const char * at, int line)
{ 
  rb_raise(rb_eGherkinLexingError, "Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information.", line, at);
}

static void lexer_init(lexer_state *lexer) {
  lexer->content_start = 0;
  lexer->content_end = 0;
  lexer->content_len = 0;
  lexer->mark = 0;
  lexer->keyword_start = 0;
  lexer->keyword_end = 0;
  lexer->next_keyword_start = 0;
  lexer->line_number = 1;
  lexer->last_newline = 0;
  lexer->final_newline = 0;
  lexer->start_col = 0;
}

static VALUE CLexer_alloc(VALUE klass)
{
  VALUE obj;
  lexer_state *lxr = ALLOC(lexer_state);
  lexer_init(lxr);

  obj = Data_Wrap_Struct(klass, NULL, -1, lxr);

  return obj;
}

static VALUE CLexer_init(VALUE self, VALUE listener)
{
  lexer_state *lxr; 
  rb_iv_set(self, "@listener", listener);
  
  lxr = NULL;
  DATA_GET(self, lexer_state, lxr);
  lexer_init(lxr);
  
  return self;
}

static VALUE CLexer_scan(VALUE self, VALUE input)
{
  VALUE input_copy;
  char *data;
  size_t len;
  VALUE listener = rb_iv_get(self, "@listener");

  lexer_state *lexer;
  lexer = NULL;
  DATA_GET(self, lexer_state, lexer);

  input_copy = rb_str_dup(input);

  rb_str_append(input_copy, rb_str_new2("\n%_FEATURE_END_%"));
  data = RSTRING_PTR(input_copy);
  len = RSTRING_LEN(input_copy);
  
  if (len == 0) { 
    rb_raise(rb_eGherkinLexingError, "No content to lex.");
  } else {

    const char *p, *pe, *eof;
    int cs = 0;
    
    VALUE current_row = Qnil;

    p = data;
    pe = data + len;
    eof = pe;
    
    assert(*pe == '\0' && "pointer does not end on NULL");
    
    
#line 956 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
    
#line 963 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	_keys = _lexer_trans_keys + _lexer_key_offsets[cs];
	_trans = _lexer_index_offsets[cs];

	_klen = _lexer_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _lexer_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += ((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	cs = _lexer_trans_targs[_trans];

	if ( _lexer_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _lexer_actions + _lexer_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    VALUE re_pipe, re_newline, re_backslash;
    VALUE con = ENCODED_STR_NEW(PTR_TO(content_start), LEN(content_start, p));
    rb_funcall(con, rb_intern("strip!"), 0);
    re_pipe      = rb_reg_regcomp(rb_str_new2("\\\\\\|"));
    re_newline   = rb_reg_regcomp(rb_str_new2("\\\\n"));
    re_backslash = rb_reg_regcomp(rb_str_new2("\\\\\\\\"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_pipe,      rb_str_new2("|"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_newline,   rb_str_new2("\n"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_backslash, rb_str_new2("\\"));

    rb_ary_push(current_row, con);
  }
	break;
	case 20:
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    int line;
    if (cs < lexer_first_final) {
      size_t count = 0;
      VALUE newstr_val;
      char *newstr;
      int newstr_count = 0;        
      size_t len;
      const char *buff;
      if (lexer->last_newline != 0) {
        len = LEN(last_newline, eof);
        buff = PTR_TO(last_newline);
      } else {
        len = strlen(data);
        buff = data;
      }

      // Allocate as a ruby string so that it gets cleaned up by GC
      newstr_val = rb_str_new(buff, len);
      newstr = RSTRING_PTR(newstr_val);


      for (count = 0; count < len; count++) {
        if(buff[count] == 10) {
          newstr[newstr_count] = '\0'; // terminate new string at first newline found
          break;
        } else {
          if (buff[count] == '%') {
            newstr[newstr_count++] = buff[count];
            newstr[newstr_count] = buff[count];
          } else {
            newstr[newstr_count] = buff[count];
          }
        }
        newstr_count++;
      }

      line = lexer->line_number;
      lexer_init(lexer); // Re-initialize so we can scan again with the same lexer
      raise_lexer_error(newstr, line);
    } else {
      rb_funcall(listener, rb_intern("eof"), 0);
    }
  }
	break;
#line 1239 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
		}
	}

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	if ( p == eof )
	{
	const char *__acts = _lexer_actions + _lexer_eof_actions[cs];
	unsigned int __nacts = (unsigned int) *__acts++;
	while ( __nacts-- > 0 ) {
		switch ( *__acts++ ) {
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"
	{
    int line;
    if (cs < lexer_first_final) {
      size_t count = 0;
      VALUE newstr_val;
      char *newstr;
      int newstr_count = 0;        
      size_t len;
      const char *buff;
      if (lexer->last_newline != 0) {
        len = LEN(last_newline, eof);
        buff = PTR_TO(last_newline);
      } else {
        len = strlen(data);
        buff = data;
      }

      // Allocate as a ruby string so that it gets cleaned up by GC
      newstr_val = rb_str_new(buff, len);
      newstr = RSTRING_PTR(newstr_val);


      for (count = 0; count < len; count++) {
        if(buff[count] == 10) {
          newstr[newstr_count] = '\0'; // terminate new string at first newline found
          break;
        } else {
          if (buff[count] == '%') {
            newstr[newstr_count++] = buff[count];
            newstr[newstr_count] = buff[count];
          } else {
            newstr[newstr_count] = buff[count];
          }
        }
        newstr_count++;
      }

      line = lexer->line_number;
      lexer_init(lexer); // Re-initialize so we can scan again with the same lexer
      raise_lexer_error(newstr, line);
    } else {
      rb_funcall(listener, rb_intern("eof"), 0);
    }
  }
	break;
#line 1302 "ext/gherkin_lexer_ko/gherkin_lexer_ko.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/ko.c.rl"

    assert(p <= pe && "data overflow after parsing execute");
    assert(lexer->content_start <= len && "content starts after data end");
    assert(lexer->mark < len && "mark is after data end");
    
    // Reset lexer by re-initializing the whole thing
    lexer_init(lexer);

    if (cs == lexer_error) {
      rb_raise(rb_eGherkinLexingError, "Invalid format, lexing fails.");
    } else {
      return Qtrue;
    }
  }
}

void Init_gherkin_lexer_ko()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Ko", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

