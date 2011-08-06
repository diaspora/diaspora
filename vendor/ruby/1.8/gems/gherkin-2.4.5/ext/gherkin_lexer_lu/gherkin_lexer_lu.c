
#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
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


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
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
	0, 0, 21, 22, 23, 43, 44, 45, 
	49, 54, 59, 64, 69, 73, 77, 79, 
	80, 81, 82, 83, 84, 85, 86, 87, 
	88, 89, 90, 91, 92, 93, 94, 95, 
	96, 98, 103, 110, 115, 116, 117, 118, 
	119, 120, 121, 122, 123, 124, 125, 126, 
	127, 134, 136, 138, 140, 142, 144, 146, 
	148, 150, 152, 154, 156, 158, 160, 162, 
	164, 166, 186, 187, 188, 189, 190, 191, 
	192, 193, 194, 195, 196, 197, 198, 199, 
	200, 201, 202, 203, 204, 216, 218, 220, 
	222, 224, 226, 228, 230, 232, 234, 236, 
	238, 240, 242, 244, 246, 248, 250, 252, 
	254, 256, 258, 260, 262, 264, 266, 268, 
	270, 272, 274, 276, 278, 280, 282, 284, 
	286, 288, 290, 292, 294, 296, 298, 300, 
	302, 304, 306, 308, 310, 312, 314, 316, 
	318, 320, 322, 324, 326, 328, 330, 332, 
	334, 336, 338, 340, 342, 344, 346, 348, 
	349, 350, 351, 352, 353, 354, 355, 356, 
	357, 358, 359, 360, 361, 377, 379, 381, 
	383, 385, 387, 389, 391, 393, 395, 397, 
	399, 401, 403, 405, 407, 409, 411, 413, 
	415, 417, 419, 421, 423, 425, 427, 429, 
	431, 433, 435, 437, 439, 441, 443, 445, 
	447, 449, 451, 453, 455, 457, 459, 461, 
	463, 465, 467, 469, 471, 473, 477, 479, 
	481, 483, 485, 487, 489, 491, 493, 495, 
	497, 499, 501, 503, 504, 505, 506, 507, 
	508, 509, 510, 511, 512, 513, 514, 515, 
	516, 517, 518, 519, 520, 521, 522, 523, 
	538, 540, 542, 544, 546, 548, 550, 552, 
	554, 556, 558, 560, 562, 564, 566, 568, 
	570, 572, 574, 576, 578, 580, 582, 584, 
	586, 588, 590, 592, 594, 596, 598, 600, 
	602, 604, 606, 608, 610, 612, 614, 618, 
	620, 622, 624, 626, 628, 630, 632, 634, 
	636, 638, 640, 642, 644, 645, 646, 647, 
	648, 649, 650, 651, 652, 653, 654, 671, 
	673, 675, 677, 679, 681, 683, 685, 687, 
	689, 691, 693, 695, 697, 699, 701, 703, 
	705, 707, 709, 711, 713, 715, 717, 719, 
	721, 723, 725, 727, 729, 731, 733, 735, 
	737, 739, 741, 743, 745, 747, 749, 751, 
	753, 755, 757, 759, 761, 763, 765, 767, 
	769, 771, 773, 775, 777, 779, 781, 783, 
	785, 787, 791, 793, 795, 797, 799, 801, 
	803, 805, 807, 809, 811, 813, 815, 817, 
	820, 821, 822, 823, 824, 825, 826, 827, 
	828, 829, 830, 831, 832, 833, 837, 843, 
	846, 848, 854, 874
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	66, 70, 72, 80, 83, 97, 100, 109, 
	117, 119, 124, 9, 13, -69, -65, 10, 
	32, 34, 35, 37, 42, 64, 66, 70, 
	72, 80, 83, 97, 100, 109, 117, 119, 
	124, 9, 13, 34, 34, 10, 32, 9, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 9, 
	13, 10, 32, 9, 13, 10, 13, 10, 
	95, 70, 69, 65, 84, 85, 82, 69, 
	95, 69, 78, 68, 95, 37, 32, 10, 
	10, 13, 13, 32, 64, 9, 10, 9, 
	10, 13, 32, 64, 11, 12, 10, 32, 
	64, 9, 13, 101, 105, 115, 112, 105, 
	108, 108, 101, 114, 58, 10, 10, 10, 
	32, 35, 70, 124, 9, 13, 10, 117, 
	10, 110, 10, 107, 10, 116, 10, 105, 
	10, 111, 10, 110, 10, 97, 10, 108, 
	10, 105, 10, 116, -61, 10, -87, 10, 
	10, 105, 10, 116, 10, 58, 10, 32, 
	34, 35, 37, 42, 64, 66, 70, 72, 
	80, 83, 97, 100, 109, 117, 119, 124, 
	9, 13, 117, 110, 107, 116, 105, 111, 
	110, 97, 108, 105, 116, -61, -87, 105, 
	116, 58, 10, 10, 10, 32, 35, 37, 
	64, 66, 70, 72, 80, 83, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 101, 10, 105, 
	10, 115, 10, 112, 10, 105, 10, 108, 
	10, 108, 10, 101, 10, 114, 10, 58, 
	10, 117, 10, 110, 10, 107, 10, 116, 
	10, 105, 10, 111, 10, 110, 10, 97, 
	10, 108, 10, 105, 10, 116, -61, 10, 
	-87, 10, 10, 105, 10, 116, 10, 97, 
	10, 110, 10, 110, 10, 101, 10, 114, 
	10, 103, 10, 114, 10, 111, 10, 110, 
	10, 100, 10, 108, 10, 97, 10, 110, 
	10, 103, 10, 32, 10, 118, 10, 117, 
	10, 109, 10, 32, 10, 83, 10, 122, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 105, 10, 111, 97, 110, 110, 101, 
	114, 103, 114, 111, 110, 100, 58, 10, 
	10, 10, 32, 35, 37, 42, 64, 70, 
	80, 83, 97, 100, 109, 117, 119, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	117, 10, 110, 10, 107, 10, 116, 10, 
	105, 10, 111, 10, 110, 10, 97, 10, 
	108, 10, 105, 10, 116, -61, 10, -87, 
	10, 10, 105, 10, 116, 10, 58, 10, 
	108, 10, 97, 10, 110, 10, 103, 10, 
	32, 10, 118, 10, 117, 10, 109, 10, 
	32, 10, 83, 10, 122, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	111, 10, 32, 110, 119, 10, 101, 10, 
	114, 10, 97, 10, 110, 10, 110, -61, 
	10, -92, 10, 10, 103, 10, 101, 10, 
	104, 10, 111, 10, 108, 10, 108, 108, 
	97, 110, 103, 32, 118, 117, 109, 32, 
	83, 122, 101, 110, 97, 114, 105, 111, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 70, 83, 97, 100, 109, 117, 119, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 117, 10, 110, 10, 107, 10, 116, 
	10, 105, 10, 111, 10, 110, 10, 97, 
	10, 108, 10, 105, 10, 116, -61, 10, 
	-87, 10, 10, 105, 10, 116, 10, 58, 
	10, 122, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 105, 10, 111, 10, 32, 
	110, 119, 10, 101, 10, 114, 10, 97, 
	10, 110, 10, 110, -61, 10, -92, 10, 
	10, 103, 10, 101, 10, 104, 10, 111, 
	10, 108, 10, 108, 122, 101, 110, 97, 
	114, 105, 111, 58, 10, 10, 10, 32, 
	35, 37, 42, 64, 70, 72, 80, 83, 
	97, 100, 109, 117, 119, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 32, 10, 117, 10, 
	110, 10, 107, 10, 116, 10, 105, 10, 
	111, 10, 110, 10, 97, 10, 108, 10, 
	105, 10, 116, -61, 10, -87, 10, 10, 
	105, 10, 116, 10, 58, 10, 97, 10, 
	110, 10, 110, 10, 101, 10, 114, 10, 
	103, 10, 114, 10, 111, 10, 110, 10, 
	100, 10, 108, 10, 97, 10, 110, 10, 
	103, 10, 32, 10, 118, 10, 117, 10, 
	109, 10, 32, 10, 83, 10, 122, 10, 
	101, 10, 110, 10, 97, 10, 114, 10, 
	105, 10, 111, 10, 32, 110, 119, 10, 
	101, 10, 114, 10, 97, 10, 110, 10, 
	110, -61, 10, -92, 10, 10, 103, 10, 
	101, 10, 104, 10, 111, 10, 108, 10, 
	108, 32, 110, 119, 101, 114, 97, 110, 
	110, -61, -92, 103, 101, 104, 111, 108, 
	108, 32, 124, 9, 13, 10, 32, 92, 
	124, 9, 13, 10, 92, 124, 10, 92, 
	10, 32, 92, 124, 9, 13, 10, 32, 
	34, 35, 37, 42, 64, 66, 70, 72, 
	80, 83, 97, 100, 109, 117, 119, 124, 
	9, 13, 0
};

static const char _lexer_single_lengths[] = {
	0, 19, 1, 1, 18, 1, 1, 2, 
	3, 3, 3, 3, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 3, 5, 3, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	5, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 18, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 10, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 14, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 4, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 13, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 4, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 15, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 4, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 4, 3, 
	2, 4, 18, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 1, 0, 
	0, 1, 1, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 21, 23, 25, 45, 47, 49, 
	53, 58, 63, 68, 73, 77, 81, 84, 
	86, 88, 90, 92, 94, 96, 98, 100, 
	102, 104, 106, 108, 110, 112, 114, 116, 
	118, 121, 126, 133, 138, 140, 142, 144, 
	146, 148, 150, 152, 154, 156, 158, 160, 
	162, 169, 172, 175, 178, 181, 184, 187, 
	190, 193, 196, 199, 202, 205, 208, 211, 
	214, 217, 237, 239, 241, 243, 245, 247, 
	249, 251, 253, 255, 257, 259, 261, 263, 
	265, 267, 269, 271, 273, 285, 288, 291, 
	294, 297, 300, 303, 306, 309, 312, 315, 
	318, 321, 324, 327, 330, 333, 336, 339, 
	342, 345, 348, 351, 354, 357, 360, 363, 
	366, 369, 372, 375, 378, 381, 384, 387, 
	390, 393, 396, 399, 402, 405, 408, 411, 
	414, 417, 420, 423, 426, 429, 432, 435, 
	438, 441, 444, 447, 450, 453, 456, 459, 
	462, 465, 468, 471, 474, 477, 480, 483, 
	485, 487, 489, 491, 493, 495, 497, 499, 
	501, 503, 505, 507, 509, 525, 528, 531, 
	534, 537, 540, 543, 546, 549, 552, 555, 
	558, 561, 564, 567, 570, 573, 576, 579, 
	582, 585, 588, 591, 594, 597, 600, 603, 
	606, 609, 612, 615, 618, 621, 624, 627, 
	630, 633, 636, 639, 642, 645, 648, 651, 
	654, 657, 660, 663, 666, 669, 674, 677, 
	680, 683, 686, 689, 692, 695, 698, 701, 
	704, 707, 710, 713, 715, 717, 719, 721, 
	723, 725, 727, 729, 731, 733, 735, 737, 
	739, 741, 743, 745, 747, 749, 751, 753, 
	768, 771, 774, 777, 780, 783, 786, 789, 
	792, 795, 798, 801, 804, 807, 810, 813, 
	816, 819, 822, 825, 828, 831, 834, 837, 
	840, 843, 846, 849, 852, 855, 858, 861, 
	864, 867, 870, 873, 876, 879, 882, 887, 
	890, 893, 896, 899, 902, 905, 908, 911, 
	914, 917, 920, 923, 926, 928, 930, 932, 
	934, 936, 938, 940, 942, 944, 946, 963, 
	966, 969, 972, 975, 978, 981, 984, 987, 
	990, 993, 996, 999, 1002, 1005, 1008, 1011, 
	1014, 1017, 1020, 1023, 1026, 1029, 1032, 1035, 
	1038, 1041, 1044, 1047, 1050, 1053, 1056, 1059, 
	1062, 1065, 1068, 1071, 1074, 1077, 1080, 1083, 
	1086, 1089, 1092, 1095, 1098, 1101, 1104, 1107, 
	1110, 1113, 1116, 1119, 1122, 1125, 1128, 1131, 
	1134, 1137, 1142, 1145, 1148, 1151, 1154, 1157, 
	1160, 1163, 1166, 1169, 1172, 1175, 1178, 1181, 
	1185, 1187, 1189, 1191, 1193, 1195, 1197, 1199, 
	1201, 1203, 1205, 1207, 1209, 1211, 1215, 1221, 
	1225, 1228, 1234, 1254
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 14, 16, 30, 33, 
	36, 66, 151, 227, 300, 383, 386, 389, 
	391, 386, 397, 4, 0, 3, 0, 4, 
	0, 4, 4, 5, 14, 16, 30, 33, 
	36, 66, 151, 227, 300, 383, 386, 389, 
	391, 386, 397, 4, 0, 6, 0, 7, 
	0, 8, 7, 7, 0, 9, 9, 10, 
	9, 9, 9, 9, 10, 9, 9, 9, 
	9, 11, 9, 9, 9, 9, 12, 9, 
	9, 4, 13, 13, 0, 4, 13, 13, 
	0, 4, 15, 14, 4, 0, 17, 0, 
	18, 0, 19, 0, 20, 0, 21, 0, 
	22, 0, 23, 0, 24, 0, 25, 0, 
	26, 0, 27, 0, 28, 0, 29, 0, 
	403, 0, 31, 0, 0, 32, 4, 15, 
	32, 0, 0, 0, 0, 34, 35, 4, 
	35, 35, 33, 34, 34, 4, 35, 33, 
	35, 0, 37, 0, 38, 0, 39, 0, 
	40, 0, 41, 0, 42, 0, 43, 0, 
	44, 0, 45, 0, 46, 0, 48, 47, 
	48, 47, 48, 48, 4, 49, 4, 48, 
	47, 48, 50, 47, 48, 51, 47, 48, 
	52, 47, 48, 53, 47, 48, 54, 47, 
	48, 55, 47, 48, 56, 47, 48, 57, 
	47, 48, 58, 47, 48, 59, 47, 48, 
	60, 47, 61, 48, 47, 62, 48, 47, 
	48, 63, 47, 48, 64, 47, 48, 65, 
	47, 4, 4, 5, 14, 16, 30, 33, 
	36, 66, 151, 227, 300, 383, 386, 389, 
	391, 386, 397, 4, 0, 67, 0, 68, 
	0, 69, 0, 70, 0, 71, 0, 72, 
	0, 73, 0, 74, 0, 75, 0, 76, 
	0, 77, 0, 78, 0, 79, 0, 80, 
	0, 81, 0, 82, 0, 84, 83, 84, 
	83, 84, 84, 4, 85, 4, 99, 109, 
	124, 134, 144, 84, 83, 84, 86, 83, 
	84, 87, 83, 84, 88, 83, 84, 89, 
	83, 84, 90, 83, 84, 91, 83, 84, 
	92, 83, 84, 93, 83, 84, 94, 83, 
	84, 95, 83, 84, 96, 83, 84, 97, 
	83, 84, 98, 83, 84, 4, 83, 84, 
	100, 83, 84, 101, 83, 84, 102, 83, 
	84, 103, 83, 84, 104, 83, 84, 105, 
	83, 84, 106, 83, 84, 107, 83, 84, 
	108, 83, 84, 65, 83, 84, 110, 83, 
	84, 111, 83, 84, 112, 83, 84, 113, 
	83, 84, 114, 83, 84, 115, 83, 84, 
	116, 83, 84, 117, 83, 84, 118, 83, 
	84, 119, 83, 84, 120, 83, 121, 84, 
	83, 122, 84, 83, 84, 123, 83, 84, 
	108, 83, 84, 125, 83, 84, 126, 83, 
	84, 127, 83, 84, 128, 83, 84, 129, 
	83, 84, 130, 83, 84, 131, 83, 84, 
	132, 83, 84, 133, 83, 84, 108, 83, 
	84, 135, 83, 84, 136, 83, 84, 137, 
	83, 84, 138, 83, 84, 139, 83, 84, 
	140, 83, 84, 141, 83, 84, 142, 83, 
	84, 143, 83, 84, 144, 83, 84, 145, 
	83, 84, 146, 83, 84, 147, 83, 84, 
	148, 83, 84, 149, 83, 84, 150, 83, 
	84, 108, 83, 152, 0, 153, 0, 154, 
	0, 155, 0, 156, 0, 157, 0, 158, 
	0, 159, 0, 160, 0, 161, 0, 162, 
	0, 164, 163, 164, 163, 164, 164, 4, 
	165, 179, 4, 180, 196, 206, 213, 216, 
	219, 221, 216, 164, 163, 164, 166, 163, 
	164, 167, 163, 164, 168, 163, 164, 169, 
	163, 164, 170, 163, 164, 171, 163, 164, 
	172, 163, 164, 173, 163, 164, 174, 163, 
	164, 175, 163, 164, 176, 163, 164, 177, 
	163, 164, 178, 163, 164, 4, 163, 164, 
	65, 163, 164, 181, 163, 164, 182, 163, 
	164, 183, 163, 164, 184, 163, 164, 185, 
	163, 164, 186, 163, 164, 187, 163, 164, 
	188, 163, 164, 189, 163, 164, 190, 163, 
	164, 191, 163, 192, 164, 163, 193, 164, 
	163, 164, 194, 163, 164, 195, 163, 164, 
	65, 163, 164, 197, 163, 164, 198, 163, 
	164, 199, 163, 164, 200, 163, 164, 201, 
	163, 164, 202, 163, 164, 203, 163, 164, 
	204, 163, 164, 205, 163, 164, 206, 163, 
	164, 207, 163, 164, 208, 163, 164, 209, 
	163, 164, 210, 163, 164, 211, 163, 164, 
	212, 163, 164, 195, 163, 164, 65, 179, 
	214, 163, 164, 215, 163, 164, 179, 163, 
	164, 217, 163, 164, 218, 163, 164, 179, 
	163, 220, 164, 163, 179, 164, 163, 164, 
	222, 163, 164, 223, 163, 164, 224, 163, 
	164, 225, 163, 164, 226, 163, 164, 179, 
	163, 228, 0, 229, 0, 230, 0, 231, 
	0, 232, 0, 233, 0, 234, 0, 235, 
	0, 236, 0, 237, 0, 238, 0, 239, 
	0, 240, 0, 241, 0, 242, 0, 243, 
	0, 244, 0, 245, 0, 247, 246, 247, 
	246, 247, 247, 4, 248, 262, 4, 263, 
	279, 286, 289, 292, 294, 289, 247, 246, 
	247, 249, 246, 247, 250, 246, 247, 251, 
	246, 247, 252, 246, 247, 253, 246, 247, 
	254, 246, 247, 255, 246, 247, 256, 246, 
	247, 257, 246, 247, 258, 246, 247, 259, 
	246, 247, 260, 246, 247, 261, 246, 247, 
	4, 246, 247, 65, 246, 247, 264, 246, 
	247, 265, 246, 247, 266, 246, 247, 267, 
	246, 247, 268, 246, 247, 269, 246, 247, 
	270, 246, 247, 271, 246, 247, 272, 246, 
	247, 273, 246, 247, 274, 246, 275, 247, 
	246, 276, 247, 246, 247, 277, 246, 247, 
	278, 246, 247, 65, 246, 247, 280, 246, 
	247, 281, 246, 247, 282, 246, 247, 283, 
	246, 247, 284, 246, 247, 285, 246, 247, 
	278, 246, 247, 65, 262, 287, 246, 247, 
	288, 246, 247, 262, 246, 247, 290, 246, 
	247, 291, 246, 247, 262, 246, 293, 247, 
	246, 262, 247, 246, 247, 295, 246, 247, 
	296, 246, 247, 297, 246, 247, 298, 246, 
	247, 299, 246, 247, 262, 246, 301, 0, 
	302, 0, 303, 0, 304, 0, 305, 0, 
	306, 0, 307, 0, 308, 0, 310, 309, 
	310, 309, 310, 310, 4, 311, 325, 4, 
	326, 342, 352, 362, 369, 372, 375, 377, 
	372, 310, 309, 310, 312, 309, 310, 313, 
	309, 310, 314, 309, 310, 315, 309, 310, 
	316, 309, 310, 317, 309, 310, 318, 309, 
	310, 319, 309, 310, 320, 309, 310, 321, 
	309, 310, 322, 309, 310, 323, 309, 310, 
	324, 309, 310, 4, 309, 310, 65, 309, 
	310, 327, 309, 310, 328, 309, 310, 329, 
	309, 310, 330, 309, 310, 331, 309, 310, 
	332, 309, 310, 333, 309, 310, 334, 309, 
	310, 335, 309, 310, 336, 309, 310, 337, 
	309, 338, 310, 309, 339, 310, 309, 310, 
	340, 309, 310, 341, 309, 310, 65, 309, 
	310, 343, 309, 310, 344, 309, 310, 345, 
	309, 310, 346, 309, 310, 347, 309, 310, 
	348, 309, 310, 349, 309, 310, 350, 309, 
	310, 351, 309, 310, 341, 309, 310, 353, 
	309, 310, 354, 309, 310, 355, 309, 310, 
	356, 309, 310, 357, 309, 310, 358, 309, 
	310, 359, 309, 310, 360, 309, 310, 361, 
	309, 310, 362, 309, 310, 363, 309, 310, 
	364, 309, 310, 365, 309, 310, 366, 309, 
	310, 367, 309, 310, 368, 309, 310, 341, 
	309, 310, 65, 325, 370, 309, 310, 371, 
	309, 310, 325, 309, 310, 373, 309, 310, 
	374, 309, 310, 325, 309, 376, 310, 309, 
	325, 310, 309, 310, 378, 309, 310, 379, 
	309, 310, 380, 309, 310, 381, 309, 310, 
	382, 309, 310, 325, 309, 31, 30, 384, 
	0, 385, 0, 30, 0, 387, 0, 388, 
	0, 30, 0, 390, 0, 30, 0, 392, 
	0, 393, 0, 394, 0, 395, 0, 396, 
	0, 30, 0, 397, 398, 397, 0, 402, 
	401, 400, 398, 401, 399, 0, 400, 398, 
	399, 0, 400, 399, 402, 401, 400, 398, 
	401, 399, 402, 402, 5, 14, 16, 30, 
	33, 36, 66, 151, 227, 300, 383, 386, 
	389, 391, 386, 397, 402, 0, 0, 0
};

static const char _lexer_trans_actions[] = {
	0, 47, 0, 5, 1, 0, 25, 1, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 31, 0, 39, 0, 39, 0, 
	39, 47, 0, 5, 1, 0, 25, 1, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 31, 0, 39, 0, 39, 0, 
	39, 47, 0, 0, 39, 119, 41, 41, 
	41, 3, 111, 29, 29, 29, 0, 111, 
	29, 29, 29, 0, 111, 29, 0, 29, 
	0, 95, 7, 7, 39, 47, 0, 0, 
	39, 103, 21, 0, 47, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 39, 50, 99, 19, 
	0, 39, 39, 39, 39, 0, 23, 107, 
	23, 23, 44, 23, 0, 47, 0, 1, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 124, 50, 
	47, 0, 47, 0, 74, 77, 74, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	47, 0, 0, 47, 0, 0, 47, 17, 
	0, 115, 27, 53, 50, 27, 56, 50, 
	56, 56, 56, 56, 56, 56, 56, 56, 
	56, 56, 59, 27, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 124, 50, 47, 
	0, 47, 0, 62, 29, 62, 77, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 9, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 9, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 124, 50, 47, 0, 47, 0, 65, 
	29, 77, 65, 77, 77, 77, 77, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 11, 0, 47, 
	11, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	11, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 11, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 124, 50, 47, 
	0, 47, 0, 71, 29, 77, 71, 77, 
	77, 77, 77, 77, 77, 77, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	15, 0, 47, 15, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 15, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 15, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 124, 50, 
	47, 0, 47, 0, 68, 29, 77, 68, 
	77, 77, 77, 77, 77, 77, 77, 77, 
	77, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 13, 0, 47, 13, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	0, 0, 47, 0, 0, 47, 13, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 13, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 0, 0, 39, 47, 
	33, 33, 80, 33, 33, 39, 0, 35, 
	0, 39, 0, 0, 47, 0, 0, 35, 
	0, 0, 47, 0, 86, 83, 37, 89, 
	83, 89, 89, 89, 89, 89, 89, 89, 
	89, 89, 89, 92, 0, 39, 0, 0
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
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39
};

static const int lexer_start = 1;
static const int lexer_first_final = 403;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"

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
    
    
#line 983 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
    
#line 990 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
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
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
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
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
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
#line 1266 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
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
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"
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
#line 1329 "ext/gherkin_lexer_lu/gherkin_lexer_lu.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lu.c.rl"

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

void Init_gherkin_lexer_lu()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Lu", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

