
#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
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


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
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
	0, 0, 20, 21, 23, 24, 25, 26, 
	27, 28, 29, 30, 31, 32, 39, 41, 
	43, 45, 47, 49, 51, 53, 55, 74, 
	93, 94, 95, 99, 104, 109, 114, 119, 
	123, 127, 129, 130, 131, 132, 133, 134, 
	135, 136, 137, 138, 139, 140, 141, 142, 
	143, 144, 145, 146, 148, 153, 160, 165, 
	166, 167, 168, 169, 170, 171, 172, 173, 
	174, 175, 176, 177, 178, 179, 180, 181, 
	182, 183, 184, 185, 186, 187, 188, 189, 
	190, 191, 192, 193, 194, 210, 212, 214, 
	216, 218, 220, 222, 224, 226, 228, 230, 
	232, 234, 236, 238, 240, 242, 244, 246, 
	248, 250, 252, 254, 256, 258, 260, 262, 
	264, 266, 268, 270, 272, 274, 276, 278, 
	280, 282, 284, 286, 288, 290, 292, 294, 
	296, 298, 300, 302, 304, 306, 308, 310, 
	312, 314, 316, 318, 321, 323, 325, 327, 
	329, 331, 333, 335, 337, 339, 341, 342, 
	343, 344, 345, 346, 347, 348, 349, 350, 
	351, 352, 353, 355, 356, 357, 358, 359, 
	360, 361, 362, 363, 364, 365, 366, 367, 
	383, 385, 387, 389, 391, 393, 395, 397, 
	399, 401, 403, 405, 407, 409, 411, 413, 
	415, 417, 419, 421, 423, 425, 427, 429, 
	431, 433, 435, 437, 439, 441, 443, 445, 
	447, 449, 451, 453, 455, 457, 459, 461, 
	463, 465, 467, 469, 471, 473, 475, 477, 
	479, 481, 483, 485, 487, 489, 491, 493, 
	494, 495, 512, 514, 516, 518, 520, 522, 
	524, 526, 528, 530, 532, 534, 536, 538, 
	540, 542, 544, 546, 548, 550, 552, 554, 
	556, 558, 560, 562, 564, 566, 568, 570, 
	572, 574, 576, 578, 580, 582, 584, 586, 
	588, 590, 592, 594, 596, 598, 600, 602, 
	604, 606, 608, 610, 612, 614, 616, 618, 
	620, 622, 624, 626, 628, 630, 632, 634, 
	637, 639, 641, 643, 645, 647, 649, 651, 
	653, 655, 657, 658, 662, 668, 671, 673, 
	679, 698, 699, 700, 701, 702, 703, 704, 
	705, 706, 716, 718, 721, 723, 725, 727, 
	729, 731, 733, 735, 737, 739, 741, 743, 
	745, 747, 749, 751, 753, 755, 757, 759, 
	761, 763, 765, 767, 769, 771, 773, 775, 
	777, 779, 781, 783, 785, 787, 789, 791, 
	793, 795, 797, 799, 802, 804, 806, 808, 
	810, 812, 814, 816, 818, 820, 821, 822
};

static const char _lexer_trans_keys[] = {
	-61, -17, 10, 32, 34, 35, 37, 42, 
	64, 65, 68, 69, 70, 71, 79, 83, 
	86, 124, 9, 13, -106, 114, 122, 110, 
	101, 107, 108, 101, 114, 58, 10, 10, 
	-61, 10, 32, 35, 124, 9, 13, -106, 
	10, 10, 122, 10, 101, 10, 108, 10, 
	108, 10, 105, 10, 107, 10, 58, -61, 
	10, 32, 34, 35, 37, 42, 64, 65, 
	68, 69, 70, 71, 79, 83, 86, 124, 
	9, 13, -61, 10, 32, 34, 35, 37, 
	42, 64, 65, 68, 69, 70, 71, 79, 
	83, 86, 124, 9, 13, 34, 34, 10, 
	32, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 9, 13, 10, 32, 9, 13, 10, 
	13, 10, 95, 70, 69, 65, 84, 85, 
	82, 69, 95, 69, 78, 68, 95, 37, 
	32, 10, 10, 13, 13, 32, 64, 9, 
	10, 9, 10, 13, 32, 64, 11, 12, 
	10, 32, 64, 9, 13, 109, 97, 105, 
	121, 101, 108, 105, 109, 32, 107, 105, 
	-60, -97, 101, 114, 97, 107, 97, 116, 
	101, -61, -89, 109, 105, -59, -97, 58, 
	10, 10, -61, 10, 32, 35, 37, 42, 
	64, 65, 68, 69, 70, 79, 83, 86, 
	9, 13, -106, 10, 10, 122, 10, 101, 
	10, 108, 10, 108, 10, 105, 10, 107, 
	10, 58, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 109, 10, 97, 10, 105, 10, 121, 
	10, 101, 10, 108, 10, 105, 10, 109, 
	10, 32, 10, 107, 10, 105, -60, 10, 
	-97, 10, 10, 101, 10, 114, 10, 97, 
	10, 107, 10, 97, 10, 116, 10, 32, 
	10, 122, 10, 97, 10, 109, 10, 97, 
	10, 110, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 121, 10, 111, 10, 32, 
	58, 10, 116, 10, 97, 10, 115, 10, 
	108, 10, 97, -60, 10, -97, 10, -60, 
	10, -79, 10, 10, 101, 32, 122, 97, 
	109, 97, 110, 101, 110, 97, 114, 121, 
	111, 32, 58, 116, 97, 115, 108, 97, 
	-60, -97, -60, -79, 58, 10, 10, -61, 
	10, 32, 35, 37, 42, 64, 65, 68, 
	69, 70, 79, 83, 86, 9, 13, -106, 
	10, 10, 122, 10, 101, 10, 108, 10, 
	108, 10, 105, 10, 107, 10, 58, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 32, 10, 109, 10, 
	97, 10, 105, 10, 121, 10, 101, 10, 
	108, 10, 105, 10, 109, 10, 32, 10, 
	107, 10, 105, -60, 10, -97, 10, 10, 
	101, 10, 114, 10, 97, 10, 107, 10, 
	97, 10, 116, 10, 32, 10, 122, 10, 
	97, 10, 109, 10, 97, 10, 110, 10, 
	101, 10, 110, 10, 97, 10, 114, 10, 
	121, 10, 111, 10, 101, 10, 10, -61, 
	10, 32, 35, 37, 42, 64, 65, 68, 
	69, 70, 71, 79, 83, 86, 9, 13, 
	-106, 10, 10, 122, 10, 101, 10, 108, 
	10, 108, 10, 105, 10, 107, 10, 58, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 109, 
	10, 97, 10, 105, 10, 121, 10, 101, 
	10, 108, 10, 105, 10, 109, 10, 32, 
	10, 107, 10, 105, -60, 10, -97, 10, 
	10, 101, 10, 114, 10, 97, 10, 107, 
	10, 97, 10, 116, 10, 101, -61, 10, 
	-89, 10, 10, 109, 10, 105, -59, 10, 
	-97, 10, 10, 32, 10, 122, 10, 97, 
	10, 109, 10, 97, 10, 110, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 121, 
	10, 111, 10, 32, 58, 10, 116, 10, 
	97, 10, 115, 10, 108, 10, 97, -60, 
	10, -97, 10, -60, 10, -79, 10, 10, 
	101, 101, 32, 124, 9, 13, 10, 32, 
	92, 124, 9, 13, 10, 92, 124, 10, 
	92, 10, 32, 92, 124, 9, 13, -61, 
	10, 32, 34, 35, 37, 42, 64, 65, 
	68, 69, 70, 71, 79, 83, 86, 124, 
	9, 13, 101, 108, 108, 105, 107, 58, 
	10, 10, -61, 10, 32, 35, 37, 64, 
	71, 83, 9, 13, -106, 10, 10, 114, 
	122, 10, 110, 10, 101, 10, 107, 10, 
	108, 10, 101, 10, 114, 10, 58, 10, 
	101, 10, 108, 10, 108, 10, 105, 10, 
	107, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 101, -61, 
	10, -89, 10, 10, 109, 10, 105, -59, 
	10, -97, 10, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 121, 10, 111, 10, 
	32, 58, 10, 116, 10, 97, 10, 115, 
	10, 108, 10, 97, -60, 10, -97, 10, 
	-60, 10, -79, 10, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 18, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 5, 2, 2, 
	2, 2, 2, 2, 2, 2, 17, 17, 
	1, 1, 2, 3, 3, 3, 3, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 2, 3, 5, 3, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 14, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 14, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 15, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 2, 4, 3, 2, 4, 
	17, 1, 1, 1, 1, 1, 1, 1, 
	1, 8, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	0, 0, 1, 1, 1, 1, 1, 1, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 1, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 1, 0, 0, 1, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 20, 22, 25, 27, 29, 31, 
	33, 35, 37, 39, 41, 43, 50, 53, 
	56, 59, 62, 65, 68, 71, 74, 93, 
	112, 114, 116, 120, 125, 130, 135, 140, 
	144, 148, 151, 153, 155, 157, 159, 161, 
	163, 165, 167, 169, 171, 173, 175, 177, 
	179, 181, 183, 185, 188, 193, 200, 205, 
	207, 209, 211, 213, 215, 217, 219, 221, 
	223, 225, 227, 229, 231, 233, 235, 237, 
	239, 241, 243, 245, 247, 249, 251, 253, 
	255, 257, 259, 261, 263, 279, 282, 285, 
	288, 291, 294, 297, 300, 303, 306, 309, 
	312, 315, 318, 321, 324, 327, 330, 333, 
	336, 339, 342, 345, 348, 351, 354, 357, 
	360, 363, 366, 369, 372, 375, 378, 381, 
	384, 387, 390, 393, 396, 399, 402, 405, 
	408, 411, 414, 417, 420, 423, 426, 429, 
	432, 435, 438, 441, 445, 448, 451, 454, 
	457, 460, 463, 466, 469, 472, 475, 477, 
	479, 481, 483, 485, 487, 489, 491, 493, 
	495, 497, 499, 502, 504, 506, 508, 510, 
	512, 514, 516, 518, 520, 522, 524, 526, 
	542, 545, 548, 551, 554, 557, 560, 563, 
	566, 569, 572, 575, 578, 581, 584, 587, 
	590, 593, 596, 599, 602, 605, 608, 611, 
	614, 617, 620, 623, 626, 629, 632, 635, 
	638, 641, 644, 647, 650, 653, 656, 659, 
	662, 665, 668, 671, 674, 677, 680, 683, 
	686, 689, 692, 695, 698, 701, 704, 707, 
	709, 711, 728, 731, 734, 737, 740, 743, 
	746, 749, 752, 755, 758, 761, 764, 767, 
	770, 773, 776, 779, 782, 785, 788, 791, 
	794, 797, 800, 803, 806, 809, 812, 815, 
	818, 821, 824, 827, 830, 833, 836, 839, 
	842, 845, 848, 851, 854, 857, 860, 863, 
	866, 869, 872, 875, 878, 881, 884, 887, 
	890, 893, 896, 899, 902, 905, 908, 911, 
	915, 918, 921, 924, 927, 930, 933, 936, 
	939, 942, 945, 947, 951, 957, 961, 964, 
	970, 989, 991, 993, 995, 997, 999, 1001, 
	1003, 1005, 1015, 1018, 1022, 1025, 1028, 1031, 
	1034, 1037, 1040, 1043, 1046, 1049, 1052, 1055, 
	1058, 1061, 1064, 1067, 1070, 1073, 1076, 1079, 
	1082, 1085, 1088, 1091, 1094, 1097, 1100, 1103, 
	1106, 1109, 1112, 1115, 1118, 1121, 1124, 1127, 
	1130, 1133, 1136, 1139, 1143, 1146, 1149, 1152, 
	1155, 1158, 1161, 1164, 1167, 1170, 1172, 1174
};

static const short _lexer_trans_targs[] = {
	2, 373, 23, 23, 24, 33, 35, 49, 
	52, 55, 57, 66, 70, 74, 150, 156, 
	306, 307, 23, 0, 3, 0, 4, 313, 
	0, 5, 0, 6, 0, 7, 0, 8, 
	0, 9, 0, 10, 0, 11, 0, 13, 
	12, 13, 12, 14, 13, 13, 23, 23, 
	13, 12, 15, 13, 12, 13, 16, 12, 
	13, 17, 12, 13, 18, 12, 13, 19, 
	12, 13, 20, 12, 13, 21, 12, 13, 
	22, 12, 2, 23, 23, 24, 33, 35, 
	49, 52, 55, 57, 66, 70, 74, 150, 
	156, 306, 307, 23, 0, 2, 23, 23, 
	24, 33, 35, 49, 52, 55, 57, 66, 
	70, 74, 150, 156, 306, 307, 23, 0, 
	25, 0, 26, 0, 27, 26, 26, 0, 
	28, 28, 29, 28, 28, 28, 28, 29, 
	28, 28, 28, 28, 30, 28, 28, 28, 
	28, 31, 28, 28, 23, 32, 32, 0, 
	23, 32, 32, 0, 23, 34, 33, 23, 
	0, 36, 0, 37, 0, 38, 0, 39, 
	0, 40, 0, 41, 0, 42, 0, 43, 
	0, 44, 0, 45, 0, 46, 0, 47, 
	0, 48, 0, 375, 0, 50, 0, 0, 
	51, 23, 34, 51, 0, 0, 0, 0, 
	53, 54, 23, 54, 54, 52, 53, 53, 
	23, 54, 52, 54, 0, 56, 0, 49, 
	0, 58, 0, 59, 0, 60, 0, 61, 
	0, 62, 0, 63, 0, 64, 0, 65, 
	0, 49, 0, 67, 0, 68, 0, 69, 
	0, 63, 0, 71, 0, 72, 0, 73, 
	0, 49, 0, 75, 0, 76, 0, 77, 
	0, 78, 0, 79, 0, 80, 0, 81, 
	0, 82, 0, 84, 83, 84, 83, 85, 
	84, 84, 23, 93, 107, 23, 108, 110, 
	119, 123, 127, 133, 149, 84, 83, 86, 
	84, 83, 84, 87, 83, 84, 88, 83, 
	84, 89, 83, 84, 90, 83, 84, 91, 
	83, 84, 92, 83, 84, 22, 83, 84, 
	94, 83, 84, 95, 83, 84, 96, 83, 
	84, 97, 83, 84, 98, 83, 84, 99, 
	83, 84, 100, 83, 84, 101, 83, 84, 
	102, 83, 84, 103, 83, 84, 104, 83, 
	84, 105, 83, 84, 106, 83, 84, 23, 
	83, 84, 22, 83, 84, 109, 83, 84, 
	107, 83, 84, 111, 83, 84, 112, 83, 
	84, 113, 83, 84, 114, 83, 84, 115, 
	83, 84, 116, 83, 84, 117, 83, 84, 
	118, 83, 84, 107, 83, 120, 84, 83, 
	121, 84, 83, 84, 122, 83, 84, 116, 
	83, 84, 124, 83, 84, 125, 83, 84, 
	126, 83, 84, 107, 83, 84, 128, 83, 
	84, 129, 83, 84, 130, 83, 84, 131, 
	83, 84, 132, 83, 84, 107, 83, 84, 
	134, 83, 84, 135, 83, 84, 136, 83, 
	84, 137, 83, 84, 138, 83, 84, 139, 
	83, 84, 140, 22, 83, 84, 141, 83, 
	84, 142, 83, 84, 143, 83, 84, 144, 
	83, 84, 145, 83, 146, 84, 83, 147, 
	84, 83, 148, 84, 83, 92, 84, 83, 
	84, 107, 83, 151, 0, 152, 0, 153, 
	0, 154, 0, 155, 0, 49, 0, 157, 
	0, 158, 0, 159, 0, 160, 0, 161, 
	0, 162, 0, 163, 231, 0, 164, 0, 
	165, 0, 166, 0, 167, 0, 168, 0, 
	169, 0, 170, 0, 171, 0, 172, 0, 
	173, 0, 175, 174, 175, 174, 176, 175, 
	175, 23, 184, 198, 23, 199, 201, 210, 
	214, 218, 224, 230, 175, 174, 177, 175, 
	174, 175, 178, 174, 175, 179, 174, 175, 
	180, 174, 175, 181, 174, 175, 182, 174, 
	175, 183, 174, 175, 22, 174, 175, 185, 
	174, 175, 186, 174, 175, 187, 174, 175, 
	188, 174, 175, 189, 174, 175, 190, 174, 
	175, 191, 174, 175, 192, 174, 175, 193, 
	174, 175, 194, 174, 175, 195, 174, 175, 
	196, 174, 175, 197, 174, 175, 23, 174, 
	175, 22, 174, 175, 200, 174, 175, 198, 
	174, 175, 202, 174, 175, 203, 174, 175, 
	204, 174, 175, 205, 174, 175, 206, 174, 
	175, 207, 174, 175, 208, 174, 175, 209, 
	174, 175, 198, 174, 211, 175, 174, 212, 
	175, 174, 175, 213, 174, 175, 207, 174, 
	175, 215, 174, 175, 216, 174, 175, 217, 
	174, 175, 198, 174, 175, 219, 174, 175, 
	220, 174, 175, 221, 174, 175, 222, 174, 
	175, 223, 174, 175, 198, 174, 175, 225, 
	174, 175, 226, 174, 175, 227, 174, 175, 
	228, 174, 175, 229, 174, 175, 183, 174, 
	175, 198, 174, 233, 232, 233, 232, 234, 
	233, 233, 23, 242, 256, 23, 257, 259, 
	268, 272, 276, 283, 289, 305, 233, 232, 
	235, 233, 232, 233, 236, 232, 233, 237, 
	232, 233, 238, 232, 233, 239, 232, 233, 
	240, 232, 233, 241, 232, 233, 22, 232, 
	233, 243, 232, 233, 244, 232, 233, 245, 
	232, 233, 246, 232, 233, 247, 232, 233, 
	248, 232, 233, 249, 232, 233, 250, 232, 
	233, 251, 232, 233, 252, 232, 233, 253, 
	232, 233, 254, 232, 233, 255, 232, 233, 
	23, 232, 233, 22, 232, 233, 258, 232, 
	233, 256, 232, 233, 260, 232, 233, 261, 
	232, 233, 262, 232, 233, 263, 232, 233, 
	264, 232, 233, 265, 232, 233, 266, 232, 
	233, 267, 232, 233, 256, 232, 269, 233, 
	232, 270, 233, 232, 233, 271, 232, 233, 
	265, 232, 233, 273, 232, 233, 274, 232, 
	233, 275, 232, 233, 256, 232, 233, 277, 
	232, 278, 233, 232, 279, 233, 232, 233, 
	280, 232, 233, 281, 232, 282, 233, 232, 
	241, 233, 232, 233, 284, 232, 233, 285, 
	232, 233, 286, 232, 233, 287, 232, 233, 
	288, 232, 233, 256, 232, 233, 290, 232, 
	233, 291, 232, 233, 292, 232, 233, 293, 
	232, 233, 294, 232, 233, 295, 232, 233, 
	296, 22, 232, 233, 297, 232, 233, 298, 
	232, 233, 299, 232, 233, 300, 232, 233, 
	301, 232, 302, 233, 232, 303, 233, 232, 
	304, 233, 232, 241, 233, 232, 233, 256, 
	232, 49, 0, 307, 308, 307, 0, 312, 
	311, 310, 308, 311, 309, 0, 310, 308, 
	309, 0, 310, 309, 312, 311, 310, 308, 
	311, 309, 2, 312, 312, 24, 33, 35, 
	49, 52, 55, 57, 66, 70, 74, 150, 
	156, 306, 307, 312, 0, 314, 0, 315, 
	0, 316, 0, 317, 0, 318, 0, 319, 
	0, 321, 320, 321, 320, 322, 321, 321, 
	23, 336, 23, 350, 357, 321, 320, 323, 
	321, 320, 321, 324, 331, 320, 321, 325, 
	320, 321, 326, 320, 321, 327, 320, 321, 
	328, 320, 321, 329, 320, 321, 330, 320, 
	321, 22, 320, 321, 332, 320, 321, 333, 
	320, 321, 334, 320, 321, 335, 320, 321, 
	330, 320, 321, 337, 320, 321, 338, 320, 
	321, 339, 320, 321, 340, 320, 321, 341, 
	320, 321, 342, 320, 321, 343, 320, 321, 
	344, 320, 321, 345, 320, 321, 346, 320, 
	321, 347, 320, 321, 348, 320, 321, 349, 
	320, 321, 23, 320, 321, 351, 320, 352, 
	321, 320, 353, 321, 320, 321, 354, 320, 
	321, 355, 320, 356, 321, 320, 330, 321, 
	320, 321, 358, 320, 321, 359, 320, 321, 
	360, 320, 321, 361, 320, 321, 362, 320, 
	321, 363, 320, 321, 364, 22, 320, 321, 
	365, 320, 321, 366, 320, 321, 367, 320, 
	321, 368, 320, 321, 369, 320, 370, 321, 
	320, 371, 321, 320, 372, 321, 320, 330, 
	321, 320, 374, 0, 23, 0, 0, 0
};

static const char _lexer_trans_actions[] = {
	25, 0, 47, 0, 5, 1, 0, 25, 
	1, 25, 25, 25, 25, 25, 25, 25, 
	25, 31, 0, 39, 0, 39, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 77, 47, 0, 74, 74, 
	0, 0, 0, 47, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	17, 0, 56, 115, 27, 53, 50, 27, 
	56, 50, 56, 56, 56, 56, 56, 56, 
	56, 56, 59, 27, 39, 25, 47, 0, 
	5, 1, 0, 25, 1, 25, 25, 25, 
	25, 25, 25, 25, 25, 31, 0, 39, 
	0, 39, 0, 39, 47, 0, 0, 39, 
	119, 41, 41, 41, 3, 111, 29, 29, 
	29, 0, 111, 29, 29, 29, 0, 111, 
	29, 0, 29, 0, 95, 7, 7, 39, 
	47, 0, 0, 39, 103, 21, 0, 47, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 39, 
	50, 99, 19, 0, 39, 39, 39, 39, 
	0, 23, 107, 23, 23, 44, 23, 0, 
	47, 0, 1, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 124, 50, 47, 0, 77, 
	47, 0, 65, 29, 77, 65, 77, 77, 
	77, 77, 77, 77, 77, 0, 0, 0, 
	47, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 11, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 11, 
	0, 47, 11, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 11, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	47, 0, 0, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 124, 50, 47, 0, 77, 47, 
	0, 71, 29, 77, 71, 77, 77, 77, 
	77, 77, 77, 77, 0, 0, 0, 47, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 15, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 15, 0, 
	47, 15, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 124, 50, 47, 0, 77, 
	47, 0, 68, 29, 77, 68, 77, 77, 
	77, 77, 77, 77, 77, 77, 0, 0, 
	0, 47, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 13, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	13, 0, 47, 13, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 13, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 47, 0, 
	0, 0, 39, 0, 0, 0, 39, 47, 
	33, 33, 80, 33, 33, 39, 0, 35, 
	0, 39, 0, 0, 47, 0, 0, 35, 
	0, 0, 89, 47, 0, 86, 83, 37, 
	89, 83, 89, 89, 89, 89, 89, 89, 
	89, 89, 92, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 124, 50, 47, 0, 77, 47, 0, 
	62, 29, 62, 77, 77, 0, 0, 0, 
	47, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 9, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 9, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 47, 0, 0, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 9, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 39, 0, 39, 0, 0
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
	39, 39, 39, 39, 39, 39, 39, 39
};

static const int lexer_start = 1;
static const int lexer_first_final = 375;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"

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
    
    
#line 936 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
    
#line 943 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
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
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
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
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
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
#line 1219 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
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
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"
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
#line 1282 "ext/gherkin_lexer_tr/gherkin_lexer_tr.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/tr.c.rl"

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

void Init_gherkin_lexer_tr()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Tr", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

