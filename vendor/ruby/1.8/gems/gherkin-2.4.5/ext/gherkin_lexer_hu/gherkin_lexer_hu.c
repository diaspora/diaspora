
#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
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


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
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
	0, 0, 19, 20, 21, 22, 23, 25, 
	43, 44, 45, 49, 54, 59, 64, 69, 
	73, 77, 79, 80, 81, 82, 83, 84, 
	85, 86, 87, 88, 89, 90, 91, 92, 
	93, 94, 99, 106, 111, 114, 115, 116, 
	117, 118, 119, 120, 122, 123, 124, 125, 
	126, 127, 128, 129, 130, 131, 132, 133, 
	134, 135, 136, 137, 138, 139, 140, 141, 
	142, 143, 145, 146, 147, 148, 149, 150, 
	151, 152, 153, 154, 155, 170, 172, 174, 
	176, 194, 196, 197, 198, 199, 200, 201, 
	202, 203, 204, 205, 220, 222, 224, 226, 
	228, 230, 232, 234, 236, 238, 240, 242, 
	244, 246, 248, 250, 252, 254, 258, 260, 
	262, 264, 266, 268, 270, 273, 275, 277, 
	279, 281, 283, 285, 287, 289, 291, 293, 
	295, 297, 299, 301, 303, 305, 307, 309, 
	311, 313, 315, 318, 320, 322, 324, 326, 
	328, 330, 332, 334, 336, 338, 340, 342, 
	344, 346, 348, 350, 352, 354, 356, 358, 
	359, 360, 361, 362, 363, 364, 365, 366, 
	367, 368, 369, 380, 382, 384, 386, 388, 
	390, 392, 394, 396, 398, 400, 402, 404, 
	406, 408, 410, 412, 414, 416, 418, 420, 
	422, 424, 426, 428, 430, 432, 434, 437, 
	439, 441, 443, 445, 447, 449, 451, 453, 
	455, 457, 459, 461, 463, 465, 467, 469, 
	471, 473, 475, 477, 479, 481, 483, 485, 
	487, 489, 491, 493, 495, 497, 498, 499, 
	500, 501, 502, 503, 504, 505, 506, 507, 
	508, 509, 510, 517, 519, 521, 523, 525, 
	527, 529, 531, 533, 535, 539, 545, 548, 
	550, 556, 574, 576, 578, 580, 582, 584, 
	586, 588, 590, 592, 594, 596, 598, 600, 
	602, 606, 608, 610, 612, 614, 616, 618, 
	621, 623, 625, 627, 629, 631, 633, 635, 
	637, 639, 641, 643, 645, 647, 649, 651, 
	653, 655, 657, 659, 661, 663, 665, 667, 
	669, 671, 673, 675, 677, 679, 681, 683, 
	685, 687, 689, 690, 691, 706, 708, 710, 
	712, 714, 716, 718, 720, 722, 724, 726, 
	728, 730, 732, 734, 736, 738, 740, 744, 
	746, 748, 750, 752, 754, 756, 759, 761, 
	763, 765, 767, 769, 771, 773, 775, 777, 
	779, 781, 783, 785, 787, 789, 791, 793, 
	795, 797, 799, 801, 804, 806, 808, 810, 
	812, 814, 816, 818, 820, 823, 825, 827, 
	829, 831, 833, 835, 837, 839, 841, 843, 
	845, 847, 849, 851, 853, 855, 857, 858, 
	859
};

static const char _lexer_trans_keys[] = {
	-61, -17, 10, 32, 34, 35, 37, 42, 
	64, 65, 68, 70, 72, 74, 77, 80, 
	124, 9, 13, -119, 115, 32, 10, 10, 
	13, -61, 10, 32, 34, 35, 37, 42, 
	64, 65, 68, 70, 72, 74, 77, 80, 
	124, 9, 13, 34, 34, 10, 32, 9, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 9, 
	13, 10, 32, 9, 13, 10, 13, 10, 
	95, 70, 69, 65, 84, 85, 82, 69, 
	95, 69, 78, 68, 95, 37, 13, 32, 
	64, 9, 10, 9, 10, 13, 32, 64, 
	11, 12, 10, 32, 64, 9, 13, 100, 
	107, 109, 111, 116, 116, 107, 111, 114, 
	101, 105, 110, 110, 121, 105, 98, 101, 
	110, 101, 111, 114, 103, 97, 116, -61, 
	-77, 107, -61, -74, 110, 121, 118, 32, 
	58, 118, -61, -95, 122, 108, 97, 116, 
	58, 10, 10, -61, 10, 32, 35, 37, 
	42, 64, 65, 68, 70, 72, 74, 77, 
	9, 13, -119, 10, 10, 115, 10, 32, 
	-61, 10, 32, 34, 35, 37, 42, 64, 
	65, 68, 70, 72, 74, 77, 80, 124, 
	9, 13, -61, 97, -95, 116, 116, -61, 
	-87, 114, 58, 10, 10, -61, 10, 32, 
	35, 37, 42, 64, 65, 68, 70, 72, 
	74, 77, 9, 13, -119, 10, 10, 115, 
	10, 32, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 100, 
	107, 109, 10, 111, 10, 116, 10, 116, 
	10, 107, 10, 111, 10, 114, 10, 101, 
	105, 10, 110, 10, 110, 10, 121, 10, 
	105, 10, 98, 10, 101, 10, 110, 10, 
	101, 10, 111, 10, 114, 10, 103, 10, 
	97, 10, 116, -61, 10, -77, 10, 10, 
	107, -61, 10, -74, 10, 10, 110, 10, 
	121, 10, 118, 10, 32, 58, 10, 118, 
	-61, 10, -95, 10, 10, 122, 10, 108, 
	10, 97, 10, 116, 10, 58, 10, 97, 
	10, 101, 10, 108, 10, 108, 10, 101, 
	10, 109, 10, 122, -59, 10, -111, 10, 
	10, 97, 10, 106, 10, 100, 101, 108, 
	108, 101, 109, 122, -59, -111, 58, 10, 
	10, 10, 32, 35, 37, 64, 70, 72, 
	74, 80, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 111, 10, 114, 10, 103, 10, 97, 
	10, 116, -61, 10, -77, 10, 10, 107, 
	-61, 10, -74, 10, 10, 110, 10, 121, 
	10, 118, 10, 32, 58, 10, 118, -61, 
	10, -95, 10, 10, 122, 10, 108, 10, 
	97, 10, 116, 10, 58, -61, 10, -95, 
	10, 10, 116, 10, 116, -61, 10, -87, 
	10, 10, 114, 10, 101, 10, 108, 10, 
	108, 10, 101, 10, 109, 10, 122, -59, 
	10, -111, 10, -61, 10, -87, 10, 10, 
	108, 10, 100, -61, 10, -95, 10, 10, 
	107, 97, 106, 100, -61, -87, 108, 100, 
	-61, -95, 107, 58, 10, 10, 10, 32, 
	35, 74, 124, 9, 13, 10, 101, 10, 
	108, 10, 108, 10, 101, 10, 109, 10, 
	122, -59, 10, -111, 10, 10, 58, 32, 
	124, 9, 13, 10, 32, 92, 124, 9, 
	13, 10, 92, 124, 10, 92, 10, 32, 
	92, 124, 9, 13, -61, 10, 32, 34, 
	35, 37, 42, 64, 65, 68, 70, 72, 
	74, 77, 80, 124, 9, 13, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 100, 107, 109, 10, 111, 
	10, 116, 10, 116, 10, 107, 10, 111, 
	10, 114, 10, 101, 105, 10, 110, 10, 
	110, 10, 121, 10, 105, 10, 98, 10, 
	101, 10, 110, 10, 101, 10, 111, 10, 
	114, 10, 103, 10, 97, 10, 116, -61, 
	10, -77, 10, 10, 107, -61, 10, -74, 
	10, 10, 110, 10, 121, 10, 118, 10, 
	58, 10, 97, 10, 101, 10, 108, 10, 
	108, 10, 101, 10, 109, 10, 122, -59, 
	10, -111, 10, 10, 97, 10, 106, 10, 
	100, 10, 10, -61, 10, 32, 35, 37, 
	42, 64, 65, 68, 70, 72, 74, 77, 
	9, 13, -119, 10, 10, 115, 10, 32, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 100, 107, 109, 
	10, 111, 10, 116, 10, 116, 10, 107, 
	10, 111, 10, 114, 10, 101, 105, 10, 
	110, 10, 110, 10, 121, 10, 105, 10, 
	98, 10, 101, 10, 110, 10, 101, 10, 
	111, 10, 114, 10, 103, 10, 97, 10, 
	116, -61, 10, -77, 10, 10, 107, -61, 
	10, -74, 10, 10, 110, 10, 121, 10, 
	118, 10, 32, 58, 10, 118, -61, 10, 
	-95, 10, 10, 122, 10, 108, 10, 97, 
	10, 116, 10, 58, -61, 10, 97, -95, 
	10, 10, 116, 10, 116, -61, 10, -87, 
	10, 10, 114, 10, 101, 10, 108, 10, 
	108, 10, 101, 10, 109, 10, 122, -59, 
	10, -111, 10, 10, 97, 10, 106, 10, 
	100, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 1, 1, 2, 16, 
	1, 1, 2, 3, 3, 3, 3, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 3, 5, 3, 3, 1, 1, 1, 
	1, 1, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 13, 2, 2, 2, 
	16, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 13, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 4, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 9, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 5, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 4, 3, 2, 
	4, 16, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	4, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 1, 13, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 4, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 1, 
	0, 0, 1, 1, 1, 1, 1, 1, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
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
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 0, 0, 
	1, 1, 0, 0, 0, 0, 0, 0, 
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
	0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 25, 27, 30, 
	48, 50, 52, 56, 61, 66, 71, 76, 
	80, 84, 87, 89, 91, 93, 95, 97, 
	99, 101, 103, 105, 107, 109, 111, 113, 
	115, 117, 122, 129, 134, 138, 140, 142, 
	144, 146, 148, 150, 153, 155, 157, 159, 
	161, 163, 165, 167, 169, 171, 173, 175, 
	177, 179, 181, 183, 185, 187, 189, 191, 
	193, 195, 198, 200, 202, 204, 206, 208, 
	210, 212, 214, 216, 218, 233, 236, 239, 
	242, 260, 263, 265, 267, 269, 271, 273, 
	275, 277, 279, 281, 296, 299, 302, 305, 
	308, 311, 314, 317, 320, 323, 326, 329, 
	332, 335, 338, 341, 344, 347, 352, 355, 
	358, 361, 364, 367, 370, 374, 377, 380, 
	383, 386, 389, 392, 395, 398, 401, 404, 
	407, 410, 413, 416, 419, 422, 425, 428, 
	431, 434, 437, 441, 444, 447, 450, 453, 
	456, 459, 462, 465, 468, 471, 474, 477, 
	480, 483, 486, 489, 492, 495, 498, 501, 
	503, 505, 507, 509, 511, 513, 515, 517, 
	519, 521, 523, 534, 537, 540, 543, 546, 
	549, 552, 555, 558, 561, 564, 567, 570, 
	573, 576, 579, 582, 585, 588, 591, 594, 
	597, 600, 603, 606, 609, 612, 615, 619, 
	622, 625, 628, 631, 634, 637, 640, 643, 
	646, 649, 652, 655, 658, 661, 664, 667, 
	670, 673, 676, 679, 682, 685, 688, 691, 
	694, 697, 700, 703, 706, 709, 711, 713, 
	715, 717, 719, 721, 723, 725, 727, 729, 
	731, 733, 735, 742, 745, 748, 751, 754, 
	757, 760, 763, 766, 769, 773, 779, 783, 
	786, 792, 810, 813, 816, 819, 822, 825, 
	828, 831, 834, 837, 840, 843, 846, 849, 
	852, 857, 860, 863, 866, 869, 872, 875, 
	879, 882, 885, 888, 891, 894, 897, 900, 
	903, 906, 909, 912, 915, 918, 921, 924, 
	927, 930, 933, 936, 939, 942, 945, 948, 
	951, 954, 957, 960, 963, 966, 969, 972, 
	975, 978, 981, 983, 985, 1000, 1003, 1006, 
	1009, 1012, 1015, 1018, 1021, 1024, 1027, 1030, 
	1033, 1036, 1039, 1042, 1045, 1048, 1051, 1056, 
	1059, 1062, 1065, 1068, 1071, 1074, 1078, 1081, 
	1084, 1087, 1090, 1093, 1096, 1099, 1102, 1105, 
	1108, 1111, 1114, 1117, 1120, 1123, 1126, 1129, 
	1132, 1135, 1138, 1141, 1145, 1148, 1151, 1154, 
	1157, 1160, 1163, 1166, 1169, 1173, 1176, 1179, 
	1182, 1185, 1188, 1191, 1194, 1197, 1200, 1203, 
	1206, 1209, 1212, 1215, 1218, 1221, 1224, 1226, 
	1228
};

static const short _lexer_trans_targs[] = {
	2, 390, 7, 7, 8, 17, 19, 4, 
	33, 36, 51, 52, 81, 159, 229, 232, 
	252, 7, 0, 3, 0, 4, 0, 5, 
	0, 0, 6, 7, 18, 6, 2, 7, 
	7, 8, 17, 19, 4, 33, 36, 51, 
	52, 81, 159, 229, 232, 252, 7, 0, 
	9, 0, 10, 0, 11, 10, 10, 0, 
	12, 12, 13, 12, 12, 12, 12, 13, 
	12, 12, 12, 12, 14, 12, 12, 12, 
	12, 15, 12, 12, 7, 16, 16, 0, 
	7, 16, 16, 0, 7, 18, 17, 7, 
	0, 20, 0, 21, 0, 22, 0, 23, 
	0, 24, 0, 25, 0, 26, 0, 27, 
	0, 28, 0, 29, 0, 30, 0, 31, 
	0, 32, 0, 392, 0, 0, 0, 0, 
	0, 34, 35, 7, 35, 35, 33, 34, 
	34, 7, 35, 33, 35, 0, 37, 40, 
	43, 0, 38, 0, 39, 0, 4, 0, 
	41, 0, 42, 0, 4, 0, 44, 40, 
	0, 45, 0, 46, 0, 47, 0, 48, 
	0, 49, 0, 50, 0, 4, 0, 4, 
	0, 53, 0, 54, 0, 55, 0, 56, 
	0, 57, 0, 58, 0, 59, 0, 60, 
	0, 61, 0, 62, 0, 63, 0, 64, 
	0, 65, 0, 66, 314, 0, 67, 0, 
	68, 0, 69, 0, 70, 0, 71, 0, 
	72, 0, 73, 0, 74, 0, 76, 75, 
	76, 75, 77, 76, 76, 7, 258, 79, 
	7, 272, 287, 288, 302, 303, 311, 76, 
	75, 78, 76, 75, 76, 79, 75, 76, 
	80, 75, 2, 7, 7, 8, 17, 19, 
	4, 33, 36, 51, 52, 81, 159, 229, 
	232, 252, 7, 0, 82, 4, 0, 83, 
	0, 84, 0, 85, 0, 86, 0, 87, 
	0, 88, 0, 89, 0, 91, 90, 91, 
	90, 92, 91, 91, 7, 95, 94, 7, 
	109, 124, 125, 147, 148, 156, 91, 90, 
	93, 91, 90, 91, 94, 90, 91, 80, 
	90, 91, 96, 90, 91, 97, 90, 91, 
	98, 90, 91, 99, 90, 91, 100, 90, 
	91, 101, 90, 91, 102, 90, 91, 103, 
	90, 91, 104, 90, 91, 105, 90, 91, 
	106, 90, 91, 107, 90, 91, 108, 90, 
	91, 7, 90, 91, 110, 113, 116, 90, 
	91, 111, 90, 91, 112, 90, 91, 94, 
	90, 91, 114, 90, 91, 115, 90, 91, 
	94, 90, 91, 117, 113, 90, 91, 118, 
	90, 91, 119, 90, 91, 120, 90, 91, 
	121, 90, 91, 122, 90, 91, 123, 90, 
	91, 94, 90, 91, 94, 90, 91, 126, 
	90, 91, 127, 90, 91, 128, 90, 91, 
	129, 90, 91, 130, 90, 131, 91, 90, 
	132, 91, 90, 91, 133, 90, 134, 91, 
	90, 135, 91, 90, 91, 136, 90, 91, 
	137, 90, 91, 138, 90, 91, 139, 80, 
	90, 91, 140, 90, 141, 91, 90, 142, 
	91, 90, 91, 143, 90, 91, 144, 90, 
	91, 145, 90, 91, 146, 90, 91, 80, 
	90, 91, 94, 90, 91, 149, 90, 91, 
	150, 90, 91, 151, 90, 91, 152, 90, 
	91, 153, 90, 91, 154, 90, 155, 91, 
	90, 146, 91, 90, 91, 157, 90, 91, 
	158, 90, 91, 94, 90, 160, 0, 161, 
	0, 162, 0, 163, 0, 164, 0, 165, 
	0, 166, 0, 167, 0, 168, 0, 170, 
	169, 170, 169, 170, 170, 7, 171, 7, 
	185, 207, 214, 222, 170, 169, 170, 172, 
	169, 170, 173, 169, 170, 174, 169, 170, 
	175, 169, 170, 176, 169, 170, 177, 169, 
	170, 178, 169, 170, 179, 169, 170, 180, 
	169, 170, 181, 169, 170, 182, 169, 170, 
	183, 169, 170, 184, 169, 170, 7, 169, 
	170, 186, 169, 170, 187, 169, 170, 188, 
	169, 170, 189, 169, 170, 190, 169, 191, 
	170, 169, 192, 170, 169, 170, 193, 169, 
	194, 170, 169, 195, 170, 169, 170, 196, 
	169, 170, 197, 169, 170, 198, 169, 170, 
	199, 80, 169, 170, 200, 169, 201, 170, 
	169, 202, 170, 169, 170, 203, 169, 170, 
	204, 169, 170, 205, 169, 170, 206, 169, 
	170, 80, 169, 208, 170, 169, 209, 170, 
	169, 170, 210, 169, 170, 211, 169, 212, 
	170, 169, 213, 170, 169, 170, 206, 169, 
	170, 215, 169, 170, 216, 169, 170, 217, 
	169, 170, 218, 169, 170, 219, 169, 170, 
	220, 169, 221, 170, 169, 206, 170, 169, 
	223, 170, 169, 224, 170, 169, 170, 225, 
	169, 170, 226, 169, 227, 170, 169, 228, 
	170, 169, 170, 206, 169, 230, 0, 231, 
	0, 4, 0, 233, 0, 234, 0, 235, 
	0, 236, 0, 237, 0, 238, 0, 239, 
	0, 240, 0, 242, 241, 242, 241, 242, 
	242, 7, 243, 7, 242, 241, 242, 244, 
	241, 242, 245, 241, 242, 246, 241, 242, 
	247, 241, 242, 248, 241, 242, 249, 241, 
	250, 242, 241, 251, 242, 241, 242, 80, 
	241, 252, 253, 252, 0, 257, 256, 255, 
	253, 256, 254, 0, 255, 253, 254, 0, 
	255, 254, 257, 256, 255, 253, 256, 254, 
	2, 257, 257, 8, 17, 19, 4, 33, 
	36, 51, 52, 81, 159, 229, 232, 252, 
	257, 0, 76, 259, 75, 76, 260, 75, 
	76, 261, 75, 76, 262, 75, 76, 263, 
	75, 76, 264, 75, 76, 265, 75, 76, 
	266, 75, 76, 267, 75, 76, 268, 75, 
	76, 269, 75, 76, 270, 75, 76, 271, 
	75, 76, 7, 75, 76, 273, 276, 279, 
	75, 76, 274, 75, 76, 275, 75, 76, 
	79, 75, 76, 277, 75, 76, 278, 75, 
	76, 79, 75, 76, 280, 276, 75, 76, 
	281, 75, 76, 282, 75, 76, 283, 75, 
	76, 284, 75, 76, 285, 75, 76, 286, 
	75, 76, 79, 75, 76, 79, 75, 76, 
	289, 75, 76, 290, 75, 76, 291, 75, 
	76, 292, 75, 76, 293, 75, 294, 76, 
	75, 295, 76, 75, 76, 296, 75, 297, 
	76, 75, 298, 76, 75, 76, 299, 75, 
	76, 300, 75, 76, 301, 75, 76, 80, 
	75, 76, 79, 75, 76, 304, 75, 76, 
	305, 75, 76, 306, 75, 76, 307, 75, 
	76, 308, 75, 76, 309, 75, 310, 76, 
	75, 301, 76, 75, 76, 312, 75, 76, 
	313, 75, 76, 79, 75, 316, 315, 316, 
	315, 317, 316, 316, 7, 320, 319, 7, 
	334, 349, 350, 372, 379, 387, 316, 315, 
	318, 316, 315, 316, 319, 315, 316, 80, 
	315, 316, 321, 315, 316, 322, 315, 316, 
	323, 315, 316, 324, 315, 316, 325, 315, 
	316, 326, 315, 316, 327, 315, 316, 328, 
	315, 316, 329, 315, 316, 330, 315, 316, 
	331, 315, 316, 332, 315, 316, 333, 315, 
	316, 7, 315, 316, 335, 338, 341, 315, 
	316, 336, 315, 316, 337, 315, 316, 319, 
	315, 316, 339, 315, 316, 340, 315, 316, 
	319, 315, 316, 342, 338, 315, 316, 343, 
	315, 316, 344, 315, 316, 345, 315, 316, 
	346, 315, 316, 347, 315, 316, 348, 315, 
	316, 319, 315, 316, 319, 315, 316, 351, 
	315, 316, 352, 315, 316, 353, 315, 316, 
	354, 315, 316, 355, 315, 356, 316, 315, 
	357, 316, 315, 316, 358, 315, 359, 316, 
	315, 360, 316, 315, 316, 361, 315, 316, 
	362, 315, 316, 363, 315, 316, 364, 80, 
	315, 316, 365, 315, 366, 316, 315, 367, 
	316, 315, 316, 368, 315, 316, 369, 315, 
	316, 370, 315, 316, 371, 315, 316, 80, 
	315, 373, 316, 319, 315, 374, 316, 315, 
	316, 375, 315, 316, 376, 315, 377, 316, 
	315, 378, 316, 315, 316, 371, 315, 316, 
	380, 315, 316, 381, 315, 316, 382, 315, 
	316, 383, 315, 316, 384, 315, 316, 385, 
	315, 386, 316, 315, 371, 316, 315, 316, 
	388, 315, 316, 389, 315, 316, 319, 315, 
	391, 0, 7, 0, 0, 0
};

static const char _lexer_trans_actions[] = {
	25, 0, 47, 0, 5, 1, 0, 25, 
	1, 25, 25, 25, 25, 25, 25, 25, 
	31, 0, 39, 0, 39, 0, 39, 0, 
	39, 39, 50, 99, 19, 0, 25, 47, 
	0, 5, 1, 0, 25, 1, 25, 25, 
	25, 25, 25, 25, 25, 31, 0, 39, 
	0, 39, 0, 39, 47, 0, 0, 39, 
	119, 41, 41, 41, 3, 111, 29, 29, 
	29, 0, 111, 29, 29, 29, 0, 111, 
	29, 0, 29, 0, 95, 7, 7, 39, 
	47, 0, 0, 39, 103, 21, 0, 47, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 39, 39, 39, 
	39, 0, 23, 107, 23, 23, 44, 23, 
	0, 47, 0, 1, 0, 39, 0, 0, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 124, 50, 
	47, 0, 77, 47, 0, 71, 29, 77, 
	71, 77, 77, 77, 77, 77, 77, 0, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	15, 0, 56, 115, 27, 53, 50, 27, 
	56, 50, 56, 56, 56, 56, 56, 56, 
	56, 59, 27, 39, 0, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 124, 50, 47, 
	0, 77, 47, 0, 65, 29, 77, 65, 
	77, 77, 77, 77, 77, 77, 0, 0, 
	0, 47, 0, 47, 0, 0, 47, 11, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 11, 0, 47, 0, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 11, 
	0, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 11, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 47, 0, 62, 29, 62, 
	77, 77, 77, 77, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 9, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 47, 0, 0, 
	0, 47, 0, 0, 47, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 9, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 9, 0, 0, 47, 0, 0, 47, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 47, 0, 
	0, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 0, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 124, 50, 47, 0, 47, 
	0, 74, 77, 74, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 47, 0, 0, 47, 0, 47, 17, 
	0, 0, 0, 0, 39, 47, 33, 33, 
	80, 33, 33, 39, 0, 35, 0, 39, 
	0, 0, 47, 0, 0, 35, 0, 0, 
	89, 47, 0, 86, 83, 37, 89, 83, 
	89, 89, 89, 89, 89, 89, 89, 92, 
	0, 39, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 15, 0, 47, 0, 0, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 15, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 124, 50, 47, 
	0, 77, 47, 0, 68, 29, 77, 68, 
	77, 77, 77, 77, 77, 77, 0, 0, 
	0, 47, 0, 47, 0, 0, 47, 13, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 13, 0, 47, 0, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 13, 
	0, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 13, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 39, 0, 39, 0, 0
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
	39
};

static const int lexer_start = 1;
static const int lexer_first_final = 392;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"

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
    
    
#line 970 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
    
#line 977 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
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
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
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
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
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
#line 1253 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
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
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"
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
#line 1316 "ext/gherkin_lexer_hu/gherkin_lexer_hu.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/hu.c.rl"

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

void Init_gherkin_lexer_hu()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Hu", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

