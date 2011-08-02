
#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
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


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
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
	0, 0, 19, 20, 21, 39, 40, 41, 
	45, 50, 55, 60, 65, 69, 73, 75, 
	76, 77, 78, 79, 80, 81, 82, 83, 
	84, 85, 86, 87, 88, 89, 90, 91, 
	92, 94, 99, 106, 111, 113, 114, 115, 
	116, 117, 118, 119, 120, 121, 122, 123, 
	124, 125, 126, 127, 128, 129, 130, 131, 
	132, 133, 134, 141, 143, 145, 147, 149, 
	151, 153, 155, 157, 159, 161, 163, 165, 
	167, 169, 171, 189, 190, 191, 192, 193, 
	194, 195, 196, 197, 198, 199, 200, 201, 
	202, 203, 204, 205, 206, 207, 208, 219, 
	221, 223, 225, 227, 229, 231, 233, 235, 
	237, 239, 241, 243, 245, 247, 249, 251, 
	253, 255, 257, 259, 261, 263, 265, 267, 
	269, 271, 273, 275, 277, 279, 281, 283, 
	285, 287, 289, 291, 293, 295, 297, 299, 
	301, 303, 305, 307, 309, 311, 313, 315, 
	317, 319, 321, 324, 326, 328, 330, 332, 
	334, 336, 338, 340, 342, 343, 344, 345, 
	346, 347, 348, 349, 350, 351, 352, 353, 
	354, 355, 356, 357, 358, 359, 360, 361, 
	376, 378, 380, 382, 384, 386, 388, 390, 
	392, 394, 396, 398, 400, 402, 404, 406, 
	409, 411, 413, 415, 417, 419, 421, 423, 
	425, 427, 429, 431, 433, 435, 437, 439, 
	441, 443, 445, 447, 449, 451, 453, 455, 
	457, 459, 461, 463, 465, 467, 469, 471, 
	473, 475, 477, 479, 481, 483, 485, 487, 
	489, 491, 493, 495, 497, 500, 502, 504, 
	506, 508, 510, 512, 514, 516, 518, 520, 
	522, 523, 524, 525, 526, 527, 528, 529, 
	531, 532, 533, 548, 550, 552, 554, 556, 
	558, 560, 562, 564, 566, 568, 570, 572, 
	574, 576, 578, 581, 583, 585, 587, 589, 
	591, 593, 595, 597, 599, 601, 603, 605, 
	607, 609, 611, 613, 615, 617, 619, 621, 
	623, 625, 627, 629, 631, 633, 635, 638, 
	640, 642, 644, 646, 648, 650, 652, 654, 
	656, 658, 660, 662, 664, 666, 668, 670, 
	672, 674, 676, 678, 680, 682, 684, 687, 
	689, 691, 693, 695, 697, 699, 701, 703, 
	705, 707, 709, 710, 711, 712, 713, 714, 
	715, 716, 717, 718, 719, 720, 735, 737, 
	739, 741, 743, 745, 747, 749, 751, 753, 
	755, 757, 759, 761, 763, 765, 768, 770, 
	772, 774, 776, 778, 780, 782, 784, 786, 
	788, 790, 792, 794, 796, 798, 800, 802, 
	804, 806, 808, 810, 812, 814, 816, 818, 
	820, 822, 824, 826, 828, 830, 832, 834, 
	836, 838, 840, 842, 844, 846, 848, 850, 
	852, 854, 856, 858, 860, 862, 863, 864, 
	865, 869, 875, 878, 880, 886, 904
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 66, 68, 70, 71, 83, 85, 87, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 66, 68, 70, 
	71, 83, 85, 87, 124, 9, 13, 34, 
	34, 10, 32, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 10, 13, 13, 32, 
	64, 9, 10, 9, 10, 13, 32, 64, 
	11, 12, 10, 32, 64, 9, 13, 98, 
	110, 101, 114, 103, 101, 110, 111, 109, 
	109, 101, 110, 101, 105, 115, 112, 105, 
	101, 108, 101, 58, 10, 10, 10, 32, 
	35, 70, 124, 9, 13, 10, 117, 10, 
	110, 10, 107, 10, 116, 10, 105, 10, 
	111, 10, 110, 10, 97, 10, 108, 10, 
	105, 10, 116, -61, 10, -92, 10, 10, 
	116, 10, 58, 10, 32, 34, 35, 37, 
	42, 64, 65, 66, 68, 70, 71, 83, 
	85, 87, 124, 9, 13, 97, 110, 117, 
	110, 107, 116, 105, 111, 110, 97, 108, 
	105, 116, -61, -92, 116, 58, 10, 10, 
	10, 32, 35, 37, 64, 66, 70, 71, 
	83, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	101, 10, 105, 10, 115, 10, 112, 10, 
	105, 10, 101, 10, 108, 10, 101, 10, 
	58, 10, 117, 10, 110, 10, 107, 10, 
	116, 10, 105, 10, 111, 10, 110, 10, 
	97, 10, 108, 10, 105, 10, 116, -61, 
	10, -92, 10, 10, 116, 10, 114, 10, 
	117, 10, 110, 10, 100, 10, 108, 10, 
	97, 10, 103, 10, 122, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	111, 10, 58, 103, 10, 114, 10, 117, 
	10, 110, 10, 100, 10, 114, 10, 105, 
	10, 115, 10, 115, 101, 114, 103, 101, 
	98, 101, 110, 32, 115, 101, 105, 117, 
	110, 100, 108, 97, 103, 101, 58, 10, 
	10, 10, 32, 35, 37, 42, 64, 65, 
	68, 70, 71, 83, 85, 87, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 98, 
	110, 10, 101, 10, 114, 10, 103, 10, 
	101, 10, 110, 10, 111, 10, 109, 10, 
	109, 10, 101, 10, 110, 10, 97, 10, 
	110, 10, 117, 10, 110, 10, 107, 10, 
	116, 10, 105, 10, 111, 10, 110, 10, 
	97, 10, 108, 10, 105, 10, 116, -61, 
	10, -92, 10, 10, 116, 10, 58, 10, 
	101, 10, 103, 10, 101, 10, 98, 10, 
	101, 10, 110, 10, 32, 10, 115, 10, 
	101, 10, 105, 10, 122, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	111, 10, 58, 103, 10, 114, 10, 117, 
	10, 110, 10, 100, 10, 114, 10, 105, 
	10, 115, 10, 115, 10, 110, 10, 100, 
	10, 101, 122, 101, 110, 97, 114, 105, 
	111, 58, 103, 10, 10, 10, 32, 35, 
	37, 42, 64, 65, 68, 70, 71, 83, 
	85, 87, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 98, 110, 10, 101, 10, 
	114, 10, 103, 10, 101, 10, 110, 10, 
	111, 10, 109, 10, 109, 10, 101, 10, 
	110, 10, 97, 10, 110, 10, 117, 10, 
	110, 10, 107, 10, 116, 10, 105, 10, 
	111, 10, 110, 10, 97, 10, 108, 10, 
	105, 10, 116, -61, 10, -92, 10, 10, 
	116, 10, 58, 10, 101, 114, 10, 103, 
	10, 101, 10, 98, 10, 101, 10, 110, 
	10, 32, 10, 115, 10, 101, 10, 105, 
	10, 117, 10, 110, 10, 100, 10, 108, 
	10, 97, 10, 103, 10, 101, 10, 122, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 105, 10, 111, 10, 58, 103, 10, 
	114, 10, 117, 10, 110, 10, 100, 10, 
	114, 10, 105, 10, 115, 10, 115, 10, 
	110, 10, 100, 10, 101, 114, 117, 110, 
	100, 114, 105, 115, 115, 58, 10, 10, 
	10, 32, 35, 37, 42, 64, 65, 68, 
	70, 71, 83, 85, 87, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 32, 10, 98, 110, 
	10, 101, 10, 114, 10, 103, 10, 101, 
	10, 110, 10, 111, 10, 109, 10, 109, 
	10, 101, 10, 110, 10, 97, 10, 110, 
	10, 117, 10, 110, 10, 107, 10, 116, 
	10, 105, 10, 111, 10, 110, 10, 97, 
	10, 108, 10, 105, 10, 116, -61, 10, 
	-92, 10, 10, 116, 10, 58, 10, 101, 
	10, 103, 10, 101, 10, 98, 10, 101, 
	10, 110, 10, 32, 10, 115, 10, 101, 
	10, 105, 10, 122, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 105, 10, 111, 
	10, 110, 10, 100, 10, 101, 110, 100, 
	101, 32, 124, 9, 13, 10, 32, 92, 
	124, 9, 13, 10, 92, 124, 10, 92, 
	10, 32, 92, 124, 9, 13, 10, 32, 
	34, 35, 37, 42, 64, 65, 66, 68, 
	70, 71, 83, 85, 87, 124, 9, 13, 
	0
};

static const char _lexer_single_lengths[] = {
	0, 17, 1, 1, 16, 1, 1, 2, 
	3, 3, 3, 3, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 3, 5, 3, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 5, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 16, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 9, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 13, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	1, 1, 13, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 13, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	2, 4, 3, 2, 4, 16, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 1, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 0, 0, 1, 1, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 19, 21, 23, 41, 43, 45, 
	49, 54, 59, 64, 69, 73, 77, 80, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 122, 129, 134, 137, 139, 141, 
	143, 145, 147, 149, 151, 153, 155, 157, 
	159, 161, 163, 165, 167, 169, 171, 173, 
	175, 177, 179, 186, 189, 192, 195, 198, 
	201, 204, 207, 210, 213, 216, 219, 222, 
	225, 228, 231, 249, 251, 253, 255, 257, 
	259, 261, 263, 265, 267, 269, 271, 273, 
	275, 277, 279, 281, 283, 285, 287, 298, 
	301, 304, 307, 310, 313, 316, 319, 322, 
	325, 328, 331, 334, 337, 340, 343, 346, 
	349, 352, 355, 358, 361, 364, 367, 370, 
	373, 376, 379, 382, 385, 388, 391, 394, 
	397, 400, 403, 406, 409, 412, 415, 418, 
	421, 424, 427, 430, 433, 436, 439, 442, 
	445, 448, 451, 455, 458, 461, 464, 467, 
	470, 473, 476, 479, 482, 484, 486, 488, 
	490, 492, 494, 496, 498, 500, 502, 504, 
	506, 508, 510, 512, 514, 516, 518, 520, 
	535, 538, 541, 544, 547, 550, 553, 556, 
	559, 562, 565, 568, 571, 574, 577, 580, 
	584, 587, 590, 593, 596, 599, 602, 605, 
	608, 611, 614, 617, 620, 623, 626, 629, 
	632, 635, 638, 641, 644, 647, 650, 653, 
	656, 659, 662, 665, 668, 671, 674, 677, 
	680, 683, 686, 689, 692, 695, 698, 701, 
	704, 707, 710, 713, 716, 720, 723, 726, 
	729, 732, 735, 738, 741, 744, 747, 750, 
	753, 755, 757, 759, 761, 763, 765, 767, 
	770, 772, 774, 789, 792, 795, 798, 801, 
	804, 807, 810, 813, 816, 819, 822, 825, 
	828, 831, 834, 838, 841, 844, 847, 850, 
	853, 856, 859, 862, 865, 868, 871, 874, 
	877, 880, 883, 886, 889, 892, 895, 898, 
	901, 904, 907, 910, 913, 916, 919, 923, 
	926, 929, 932, 935, 938, 941, 944, 947, 
	950, 953, 956, 959, 962, 965, 968, 971, 
	974, 977, 980, 983, 986, 989, 992, 996, 
	999, 1002, 1005, 1008, 1011, 1014, 1017, 1020, 
	1023, 1026, 1029, 1031, 1033, 1035, 1037, 1039, 
	1041, 1043, 1045, 1047, 1049, 1051, 1066, 1069, 
	1072, 1075, 1078, 1081, 1084, 1087, 1090, 1093, 
	1096, 1099, 1102, 1105, 1108, 1111, 1115, 1118, 
	1121, 1124, 1127, 1130, 1133, 1136, 1139, 1142, 
	1145, 1148, 1151, 1154, 1157, 1160, 1163, 1166, 
	1169, 1172, 1175, 1178, 1181, 1184, 1187, 1190, 
	1193, 1196, 1199, 1202, 1205, 1208, 1211, 1214, 
	1217, 1220, 1223, 1226, 1229, 1232, 1235, 1238, 
	1241, 1244, 1247, 1250, 1253, 1256, 1258, 1260, 
	1262, 1266, 1272, 1276, 1279, 1285, 1303
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 14, 16, 30, 33, 
	36, 47, 75, 77, 155, 248, 413, 415, 
	416, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 14, 16, 30, 33, 36, 47, 
	75, 77, 155, 248, 413, 415, 416, 4, 
	0, 6, 0, 7, 0, 8, 7, 7, 
	0, 9, 9, 10, 9, 9, 9, 9, 
	10, 9, 9, 9, 9, 11, 9, 9, 
	9, 9, 12, 9, 9, 4, 13, 13, 
	0, 4, 13, 13, 0, 4, 15, 14, 
	4, 0, 17, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 422, 0, 31, 0, 
	0, 32, 4, 15, 32, 0, 0, 0, 
	0, 34, 35, 4, 35, 35, 33, 34, 
	34, 4, 35, 33, 35, 0, 37, 39, 
	0, 38, 0, 30, 0, 40, 0, 41, 
	0, 42, 0, 43, 0, 44, 0, 45, 
	0, 46, 0, 30, 0, 48, 0, 49, 
	0, 50, 0, 51, 0, 52, 0, 53, 
	0, 54, 0, 55, 0, 56, 0, 58, 
	57, 58, 57, 58, 58, 4, 59, 4, 
	58, 57, 58, 60, 57, 58, 61, 57, 
	58, 62, 57, 58, 63, 57, 58, 64, 
	57, 58, 65, 57, 58, 66, 57, 58, 
	67, 57, 58, 68, 57, 58, 69, 57, 
	58, 70, 57, 71, 58, 57, 72, 58, 
	57, 58, 73, 57, 58, 74, 57, 4, 
	4, 5, 14, 16, 30, 33, 36, 47, 
	75, 77, 155, 248, 413, 415, 416, 4, 
	0, 76, 0, 46, 0, 78, 0, 79, 
	0, 80, 0, 81, 0, 82, 0, 83, 
	0, 84, 0, 85, 0, 86, 0, 87, 
	0, 88, 0, 89, 0, 90, 0, 91, 
	0, 92, 0, 94, 93, 94, 93, 94, 
	94, 4, 95, 4, 109, 118, 132, 139, 
	94, 93, 94, 96, 93, 94, 97, 93, 
	94, 98, 93, 94, 99, 93, 94, 100, 
	93, 94, 101, 93, 94, 102, 93, 94, 
	103, 93, 94, 104, 93, 94, 105, 93, 
	94, 106, 93, 94, 107, 93, 94, 108, 
	93, 94, 4, 93, 94, 110, 93, 94, 
	111, 93, 94, 112, 93, 94, 113, 93, 
	94, 114, 93, 94, 115, 93, 94, 116, 
	93, 94, 117, 93, 94, 74, 93, 94, 
	119, 93, 94, 120, 93, 94, 121, 93, 
	94, 122, 93, 94, 123, 93, 94, 124, 
	93, 94, 125, 93, 94, 126, 93, 94, 
	127, 93, 94, 128, 93, 94, 129, 93, 
	130, 94, 93, 131, 94, 93, 94, 117, 
	93, 94, 133, 93, 94, 134, 93, 94, 
	135, 93, 94, 136, 93, 94, 137, 93, 
	94, 138, 93, 94, 116, 93, 94, 140, 
	93, 94, 141, 93, 94, 142, 93, 94, 
	143, 93, 94, 144, 93, 94, 145, 93, 
	94, 146, 93, 94, 74, 147, 93, 94, 
	148, 93, 94, 149, 93, 94, 150, 93, 
	94, 151, 93, 94, 152, 93, 94, 153, 
	93, 94, 154, 93, 94, 117, 93, 156, 
	165, 0, 157, 0, 158, 0, 159, 0, 
	160, 0, 161, 0, 162, 0, 163, 0, 
	164, 0, 30, 0, 166, 0, 167, 0, 
	168, 0, 169, 0, 170, 0, 171, 0, 
	172, 0, 173, 0, 175, 174, 175, 174, 
	175, 175, 4, 176, 190, 4, 191, 202, 
	204, 219, 229, 245, 247, 175, 174, 175, 
	177, 174, 175, 178, 174, 175, 179, 174, 
	175, 180, 174, 175, 181, 174, 175, 182, 
	174, 175, 183, 174, 175, 184, 174, 175, 
	185, 174, 175, 186, 174, 175, 187, 174, 
	175, 188, 174, 175, 189, 174, 175, 4, 
	174, 175, 74, 174, 175, 192, 194, 174, 
	175, 193, 174, 175, 190, 174, 175, 195, 
	174, 175, 196, 174, 175, 197, 174, 175, 
	198, 174, 175, 199, 174, 175, 200, 174, 
	175, 201, 174, 175, 190, 174, 175, 203, 
	174, 175, 201, 174, 175, 205, 174, 175, 
	206, 174, 175, 207, 174, 175, 208, 174, 
	175, 209, 174, 175, 210, 174, 175, 211, 
	174, 175, 212, 174, 175, 213, 174, 175, 
	214, 174, 175, 215, 174, 216, 175, 174, 
	217, 175, 174, 175, 218, 174, 175, 74, 
	174, 175, 220, 174, 175, 221, 174, 175, 
	222, 174, 175, 223, 174, 175, 224, 174, 
	175, 225, 174, 175, 226, 174, 175, 227, 
	174, 175, 228, 174, 175, 190, 174, 175, 
	230, 174, 175, 231, 174, 175, 232, 174, 
	175, 233, 174, 175, 234, 174, 175, 235, 
	174, 175, 236, 174, 175, 74, 237, 174, 
	175, 238, 174, 175, 239, 174, 175, 240, 
	174, 175, 241, 174, 175, 242, 174, 175, 
	243, 174, 175, 244, 174, 175, 218, 174, 
	175, 246, 174, 175, 190, 174, 175, 203, 
	174, 249, 0, 250, 0, 251, 0, 252, 
	0, 253, 0, 254, 0, 255, 0, 256, 
	338, 0, 258, 257, 258, 257, 258, 258, 
	4, 259, 273, 4, 274, 285, 287, 302, 
	319, 335, 337, 258, 257, 258, 260, 257, 
	258, 261, 257, 258, 262, 257, 258, 263, 
	257, 258, 264, 257, 258, 265, 257, 258, 
	266, 257, 258, 267, 257, 258, 268, 257, 
	258, 269, 257, 258, 270, 257, 258, 271, 
	257, 258, 272, 257, 258, 4, 257, 258, 
	74, 257, 258, 275, 277, 257, 258, 276, 
	257, 258, 273, 257, 258, 278, 257, 258, 
	279, 257, 258, 280, 257, 258, 281, 257, 
	258, 282, 257, 258, 283, 257, 258, 284, 
	257, 258, 273, 257, 258, 286, 257, 258, 
	284, 257, 258, 288, 257, 258, 289, 257, 
	258, 290, 257, 258, 291, 257, 258, 292, 
	257, 258, 293, 257, 258, 294, 257, 258, 
	295, 257, 258, 296, 257, 258, 297, 257, 
	258, 298, 257, 299, 258, 257, 300, 258, 
	257, 258, 301, 257, 258, 74, 257, 258, 
	303, 312, 257, 258, 304, 257, 258, 305, 
	257, 258, 306, 257, 258, 307, 257, 258, 
	308, 257, 258, 309, 257, 258, 310, 257, 
	258, 311, 257, 258, 273, 257, 258, 313, 
	257, 258, 314, 257, 258, 315, 257, 258, 
	316, 257, 258, 317, 257, 258, 318, 257, 
	258, 301, 257, 258, 320, 257, 258, 321, 
	257, 258, 322, 257, 258, 323, 257, 258, 
	324, 257, 258, 325, 257, 258, 326, 257, 
	258, 74, 327, 257, 258, 328, 257, 258, 
	329, 257, 258, 330, 257, 258, 331, 257, 
	258, 332, 257, 258, 333, 257, 258, 334, 
	257, 258, 301, 257, 258, 336, 257, 258, 
	273, 257, 258, 286, 257, 339, 0, 340, 
	0, 341, 0, 342, 0, 343, 0, 344, 
	0, 345, 0, 346, 0, 347, 0, 349, 
	348, 349, 348, 349, 349, 4, 350, 364, 
	4, 365, 376, 378, 393, 403, 410, 412, 
	349, 348, 349, 351, 348, 349, 352, 348, 
	349, 353, 348, 349, 354, 348, 349, 355, 
	348, 349, 356, 348, 349, 357, 348, 349, 
	358, 348, 349, 359, 348, 349, 360, 348, 
	349, 361, 348, 349, 362, 348, 349, 363, 
	348, 349, 4, 348, 349, 74, 348, 349, 
	366, 368, 348, 349, 367, 348, 349, 364, 
	348, 349, 369, 348, 349, 370, 348, 349, 
	371, 348, 349, 372, 348, 349, 373, 348, 
	349, 374, 348, 349, 375, 348, 349, 364, 
	348, 349, 377, 348, 349, 375, 348, 349, 
	379, 348, 349, 380, 348, 349, 381, 348, 
	349, 382, 348, 349, 383, 348, 349, 384, 
	348, 349, 385, 348, 349, 386, 348, 349, 
	387, 348, 349, 388, 348, 349, 389, 348, 
	390, 349, 348, 391, 349, 348, 349, 392, 
	348, 349, 74, 348, 349, 394, 348, 349, 
	395, 348, 349, 396, 348, 349, 397, 348, 
	349, 398, 348, 349, 399, 348, 349, 400, 
	348, 349, 401, 348, 349, 402, 348, 349, 
	364, 348, 349, 404, 348, 349, 405, 348, 
	349, 406, 348, 349, 407, 348, 349, 408, 
	348, 349, 409, 348, 349, 392, 348, 349, 
	411, 348, 349, 364, 348, 349, 377, 348, 
	414, 0, 30, 0, 76, 0, 416, 417, 
	416, 0, 421, 420, 419, 417, 420, 418, 
	0, 419, 417, 418, 0, 419, 418, 421, 
	420, 419, 417, 420, 418, 421, 421, 5, 
	14, 16, 30, 33, 36, 47, 75, 77, 
	155, 248, 413, 415, 416, 421, 0, 0, 
	0
};

static const char _lexer_trans_actions[] = {
	0, 47, 0, 5, 1, 0, 25, 1, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	31, 0, 39, 0, 39, 0, 39, 47, 
	0, 5, 1, 0, 25, 1, 25, 25, 
	25, 25, 25, 25, 25, 25, 31, 0, 
	39, 0, 39, 0, 39, 47, 0, 0, 
	39, 119, 41, 41, 41, 3, 111, 29, 
	29, 29, 0, 111, 29, 29, 29, 0, 
	111, 29, 0, 29, 0, 95, 7, 7, 
	39, 47, 0, 0, 39, 103, 21, 0, 
	47, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	39, 50, 99, 19, 0, 39, 39, 39, 
	39, 0, 23, 107, 23, 23, 44, 23, 
	0, 47, 0, 1, 0, 39, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 47, 0, 74, 77, 74, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 47, 0, 0, 47, 17, 0, 115, 
	27, 53, 50, 27, 56, 50, 56, 56, 
	56, 56, 56, 56, 56, 56, 59, 27, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 124, 50, 47, 0, 47, 
	0, 62, 29, 62, 77, 77, 77, 77, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 9, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 9, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 47, 0, 0, 47, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 9, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 124, 50, 47, 0, 
	47, 0, 65, 29, 77, 65, 77, 77, 
	77, 77, 77, 77, 77, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 11, 
	0, 47, 11, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 0, 47, 11, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 11, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	0, 39, 124, 50, 47, 0, 47, 0, 
	68, 29, 77, 68, 77, 77, 77, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 13, 0, 47, 
	13, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 47, 0, 0, 47, 13, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 13, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 47, 0, 71, 29, 77, 
	71, 77, 77, 77, 77, 77, 77, 77, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 15, 0, 47, 15, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 47, 0, 0, 47, 0, 47, 0, 
	0, 47, 15, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 39, 0, 39, 0, 39, 0, 0, 
	0, 39, 47, 33, 33, 80, 33, 33, 
	39, 0, 35, 0, 39, 0, 0, 47, 
	0, 0, 35, 0, 0, 47, 0, 86, 
	83, 37, 89, 83, 89, 89, 89, 89, 
	89, 89, 89, 89, 92, 0, 39, 0, 
	0
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
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39
};

static const int lexer_start = 1;
static const int lexer_first_final = 422;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"

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
    
    
#line 1011 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
    
#line 1018 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
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
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
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
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
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
#line 1294 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
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
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"
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
#line 1357 "ext/gherkin_lexer_de/gherkin_lexer_de.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/de.c.rl"

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

void Init_gherkin_lexer_de()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "De", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

