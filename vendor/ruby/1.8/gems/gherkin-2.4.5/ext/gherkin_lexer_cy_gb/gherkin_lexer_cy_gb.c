
#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
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


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_cy_gb/gherkin_lexer_cy_gb.c"
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
	0, 0, 18, 19, 20, 37, 38, 39, 
	43, 48, 53, 58, 63, 67, 71, 73, 
	74, 75, 76, 77, 78, 79, 80, 81, 
	82, 83, 84, 85, 86, 87, 88, 89, 
	90, 92, 97, 104, 109, 112, 113, 114, 
	115, 116, 117, 118, 119, 120, 121, 122, 
	123, 124, 125, 126, 127, 128, 129, 140, 
	142, 144, 146, 148, 150, 152, 154, 156, 
	158, 160, 162, 164, 166, 168, 170, 172, 
	174, 176, 178, 180, 197, 198, 199, 200, 
	201, 202, 203, 204, 205, 206, 219, 221, 
	223, 225, 227, 229, 231, 233, 235, 237, 
	239, 241, 243, 245, 247, 249, 253, 255, 
	257, 259, 261, 263, 265, 267, 269, 271, 
	273, 275, 277, 279, 281, 283, 285, 287, 
	289, 291, 293, 295, 297, 299, 301, 303, 
	305, 308, 310, 312, 314, 316, 318, 320, 
	322, 324, 326, 328, 330, 331, 332, 333, 
	334, 335, 336, 337, 338, 339, 340, 341, 
	342, 343, 344, 345, 352, 354, 356, 358, 
	360, 362, 364, 365, 366, 367, 368, 369, 
	370, 371, 372, 373, 374, 375, 377, 378, 
	379, 380, 381, 382, 383, 384, 385, 386, 
	387, 388, 389, 390, 403, 405, 407, 409, 
	411, 413, 415, 417, 419, 421, 423, 425, 
	427, 429, 431, 433, 437, 439, 441, 443, 
	445, 447, 449, 451, 453, 455, 457, 459, 
	461, 463, 465, 467, 469, 471, 473, 475, 
	477, 479, 481, 483, 485, 487, 489, 491, 
	492, 493, 507, 509, 511, 513, 515, 517, 
	519, 521, 523, 525, 527, 529, 531, 533, 
	535, 537, 541, 543, 545, 547, 549, 551, 
	553, 555, 557, 559, 561, 563, 565, 567, 
	569, 571, 573, 575, 577, 579, 581, 583, 
	585, 587, 589, 591, 593, 595, 597, 599, 
	601, 603, 605, 608, 610, 612, 614, 616, 
	618, 620, 622, 624, 626, 628, 630, 631, 
	635, 641, 644, 646, 652, 669, 671, 673, 
	675, 677, 679, 681, 683, 685, 687, 689, 
	691, 693, 695, 697, 699, 701, 703, 705, 
	707, 709, 711, 713, 715, 717, 719, 722, 
	724, 726, 728, 730, 732, 734, 736, 738, 
	740, 742
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 67, 69, 79, 80, 83, 89, 124, 
	9, 13, -69, -65, 10, 32, 34, 35, 
	37, 42, 64, 65, 67, 69, 79, 80, 
	83, 89, 124, 9, 13, 34, 34, 10, 
	32, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 9, 13, 10, 32, 9, 13, 10, 
	13, 10, 95, 70, 69, 65, 84, 85, 
	82, 69, 95, 69, 78, 68, 95, 37, 
	32, 10, 10, 13, 13, 32, 64, 9, 
	10, 9, 10, 13, 32, 64, 11, 12, 
	10, 32, 64, 9, 13, 32, 110, 114, 
	114, 104, 101, 103, 101, 100, 105, 103, 
	32, 97, 119, 101, 100, 100, 58, 10, 
	10, 10, 32, 35, 37, 64, 65, 67, 
	69, 83, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 114, 10, 119, 10, 101, 10, 100, 
	10, 100, 10, 58, 10, 32, 34, 35, 
	37, 42, 64, 65, 67, 69, 79, 80, 
	83, 89, 124, 9, 13, 101, 102, 110, 
	100, 105, 114, 58, 10, 10, 10, 32, 
	35, 37, 42, 64, 65, 79, 80, 83, 
	89, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 32, 110, 114, 10, 114, 10, 
	104, 10, 101, 10, 103, 10, 101, 10, 
	100, 10, 105, 10, 103, 10, 32, 10, 
	97, 10, 119, 10, 101, 10, 100, 10, 
	100, 10, 58, 10, 110, 10, 100, 10, 
	114, 10, 121, 10, 99, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	111, 10, 32, 58, 10, 65, 10, 109, 
	10, 108, 10, 105, 10, 110, 10, 101, 
	10, 108, 10, 108, 10, 111, 10, 108, 
	10, 110, 110, 103, 104, 114, 101, 105, 
	102, 102, 116, 105, 97, 117, 58, 10, 
	10, 10, 32, 35, 65, 124, 9, 13, 
	10, 114, 10, 119, 10, 101, 10, 100, 
	10, 100, 10, 58, 110, 100, 114, 121, 
	99, 101, 110, 97, 114, 105, 111, 32, 
	58, 65, 109, 108, 105, 110, 101, 108, 
	108, 111, 108, 58, 10, 10, 10, 32, 
	35, 37, 42, 64, 65, 79, 80, 83, 
	89, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 32, 110, 114, 10, 114, 10, 
	104, 10, 101, 10, 103, 10, 101, 10, 
	100, 10, 105, 10, 103, 10, 32, 10, 
	97, 10, 119, 10, 101, 10, 100, 10, 
	100, 10, 58, 10, 110, 10, 100, 10, 
	114, 10, 121, 10, 99, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	111, 10, 110, 10, 10, 10, 32, 35, 
	37, 42, 64, 65, 67, 79, 80, 83, 
	89, 9, 13, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, 10, 
	32, 10, 32, 110, 114, 10, 114, 10, 
	104, 10, 101, 10, 103, 10, 101, 10, 
	100, 10, 105, 10, 103, 10, 32, 10, 
	97, 10, 119, 10, 101, 10, 100, 10, 
	100, 10, 58, 10, 101, 10, 102, 10, 
	110, 10, 100, 10, 105, 10, 114, 10, 
	110, 10, 100, 10, 114, 10, 121, 10, 
	99, 10, 101, 10, 110, 10, 97, 10, 
	114, 10, 105, 10, 111, 10, 32, 58, 
	10, 65, 10, 109, 10, 108, 10, 105, 
	10, 110, 10, 101, 10, 108, 10, 108, 
	10, 111, 10, 108, 10, 110, 110, 32, 
	124, 9, 13, 10, 32, 92, 124, 9, 
	13, 10, 92, 124, 10, 92, 10, 32, 
	92, 124, 9, 13, 10, 32, 34, 35, 
	37, 42, 64, 65, 67, 69, 79, 80, 
	83, 89, 124, 9, 13, 10, 101, 10, 
	102, 10, 110, 10, 100, 10, 105, 10, 
	114, 10, 110, 10, 103, 10, 104, 10, 
	114, 10, 101, 10, 105, 10, 102, 10, 
	102, 10, 116, 10, 105, 10, 97, 10, 
	117, 10, 99, 10, 101, 10, 110, 10, 
	97, 10, 114, 10, 105, 10, 111, 10, 
	32, 58, 10, 65, 10, 109, 10, 108, 
	10, 105, 10, 110, 10, 101, 10, 108, 
	10, 108, 10, 111, 10, 108, 0
};

static const char _lexer_single_lengths[] = {
	0, 16, 1, 1, 15, 1, 1, 2, 
	3, 3, 3, 3, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 3, 5, 3, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 9, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 15, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 11, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 4, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 5, 2, 2, 2, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 11, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 4, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 12, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 4, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 2, 
	4, 3, 2, 4, 15, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
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
	0, 0, 0, 1, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 1, 
	1, 0, 0, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 18, 20, 22, 39, 41, 43, 
	47, 52, 57, 62, 67, 71, 75, 78, 
	80, 82, 84, 86, 88, 90, 92, 94, 
	96, 98, 100, 102, 104, 106, 108, 110, 
	112, 115, 120, 127, 132, 136, 138, 140, 
	142, 144, 146, 148, 150, 152, 154, 156, 
	158, 160, 162, 164, 166, 168, 170, 181, 
	184, 187, 190, 193, 196, 199, 202, 205, 
	208, 211, 214, 217, 220, 223, 226, 229, 
	232, 235, 238, 241, 258, 260, 262, 264, 
	266, 268, 270, 272, 274, 276, 289, 292, 
	295, 298, 301, 304, 307, 310, 313, 316, 
	319, 322, 325, 328, 331, 334, 339, 342, 
	345, 348, 351, 354, 357, 360, 363, 366, 
	369, 372, 375, 378, 381, 384, 387, 390, 
	393, 396, 399, 402, 405, 408, 411, 414, 
	417, 421, 424, 427, 430, 433, 436, 439, 
	442, 445, 448, 451, 454, 456, 458, 460, 
	462, 464, 466, 468, 470, 472, 474, 476, 
	478, 480, 482, 484, 491, 494, 497, 500, 
	503, 506, 509, 511, 513, 515, 517, 519, 
	521, 523, 525, 527, 529, 531, 534, 536, 
	538, 540, 542, 544, 546, 548, 550, 552, 
	554, 556, 558, 560, 573, 576, 579, 582, 
	585, 588, 591, 594, 597, 600, 603, 606, 
	609, 612, 615, 618, 623, 626, 629, 632, 
	635, 638, 641, 644, 647, 650, 653, 656, 
	659, 662, 665, 668, 671, 674, 677, 680, 
	683, 686, 689, 692, 695, 698, 701, 704, 
	706, 708, 722, 725, 728, 731, 734, 737, 
	740, 743, 746, 749, 752, 755, 758, 761, 
	764, 767, 772, 775, 778, 781, 784, 787, 
	790, 793, 796, 799, 802, 805, 808, 811, 
	814, 817, 820, 823, 826, 829, 832, 835, 
	838, 841, 844, 847, 850, 853, 856, 859, 
	862, 865, 868, 872, 875, 878, 881, 884, 
	887, 890, 893, 896, 899, 902, 905, 907, 
	911, 917, 921, 924, 930, 947, 950, 953, 
	956, 959, 962, 965, 968, 971, 974, 977, 
	980, 983, 986, 989, 992, 995, 998, 1001, 
	1004, 1007, 1010, 1013, 1016, 1019, 1022, 1026, 
	1029, 1032, 1035, 1038, 1041, 1044, 1047, 1050, 
	1053, 1056
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 14, 16, 30, 33, 
	36, 76, 140, 162, 164, 166, 294, 295, 
	4, 0, 3, 0, 4, 0, 4, 4, 
	5, 14, 16, 30, 33, 36, 76, 140, 
	162, 164, 166, 294, 295, 4, 0, 6, 
	0, 7, 0, 8, 7, 7, 0, 9, 
	9, 10, 9, 9, 9, 9, 10, 9, 
	9, 9, 9, 11, 9, 9, 9, 9, 
	12, 9, 9, 4, 13, 13, 0, 4, 
	13, 13, 0, 4, 15, 14, 4, 0, 
	17, 0, 18, 0, 19, 0, 20, 0, 
	21, 0, 22, 0, 23, 0, 24, 0, 
	25, 0, 26, 0, 27, 0, 28, 0, 
	29, 0, 337, 0, 31, 0, 0, 32, 
	4, 15, 32, 0, 0, 0, 0, 34, 
	35, 4, 35, 35, 33, 34, 34, 4, 
	35, 33, 35, 0, 31, 37, 47, 0, 
	38, 0, 39, 0, 40, 0, 41, 0, 
	42, 0, 43, 0, 44, 0, 45, 0, 
	46, 0, 30, 0, 48, 0, 49, 0, 
	50, 0, 51, 0, 52, 0, 54, 53, 
	54, 53, 54, 54, 4, 55, 4, 69, 
	301, 307, 319, 54, 53, 54, 56, 53, 
	54, 57, 53, 54, 58, 53, 54, 59, 
	53, 54, 60, 53, 54, 61, 53, 54, 
	62, 53, 54, 63, 53, 54, 64, 53, 
	54, 65, 53, 54, 66, 53, 54, 67, 
	53, 54, 68, 53, 54, 4, 53, 54, 
	70, 53, 54, 71, 53, 54, 72, 53, 
	54, 73, 53, 54, 74, 53, 54, 75, 
	53, 4, 4, 5, 14, 16, 30, 33, 
	36, 76, 140, 162, 164, 166, 294, 295, 
	4, 0, 77, 0, 78, 0, 79, 0, 
	80, 0, 81, 0, 82, 0, 83, 0, 
	85, 84, 85, 84, 85, 85, 4, 86, 
	100, 4, 101, 117, 119, 121, 139, 85, 
	84, 85, 87, 84, 85, 88, 84, 85, 
	89, 84, 85, 90, 84, 85, 91, 84, 
	85, 92, 84, 85, 93, 84, 85, 94, 
	84, 85, 95, 84, 85, 96, 84, 85, 
	97, 84, 85, 98, 84, 85, 99, 84, 
	85, 4, 84, 85, 75, 84, 85, 75, 
	102, 112, 84, 85, 103, 84, 85, 104, 
	84, 85, 105, 84, 85, 106, 84, 85, 
	107, 84, 85, 108, 84, 85, 109, 84, 
	85, 110, 84, 85, 111, 84, 85, 100, 
	84, 85, 113, 84, 85, 114, 84, 85, 
	115, 84, 85, 116, 84, 85, 75, 84, 
	85, 118, 84, 85, 100, 84, 85, 120, 
	84, 85, 118, 84, 85, 122, 84, 85, 
	123, 84, 85, 124, 84, 85, 125, 84, 
	85, 126, 84, 85, 127, 84, 85, 128, 
	84, 85, 129, 75, 84, 85, 130, 84, 
	85, 131, 84, 85, 132, 84, 85, 133, 
	84, 85, 134, 84, 85, 135, 84, 85, 
	136, 84, 85, 137, 84, 85, 138, 84, 
	85, 116, 84, 85, 111, 84, 141, 0, 
	142, 0, 143, 0, 144, 0, 145, 0, 
	146, 0, 147, 0, 148, 0, 149, 0, 
	150, 0, 151, 0, 152, 0, 153, 0, 
	155, 154, 155, 154, 155, 155, 4, 156, 
	4, 155, 154, 155, 157, 154, 155, 158, 
	154, 155, 159, 154, 155, 160, 154, 155, 
	161, 154, 155, 75, 154, 163, 0, 30, 
	0, 165, 0, 163, 0, 167, 0, 168, 
	0, 169, 0, 170, 0, 171, 0, 172, 
	0, 173, 0, 174, 231, 0, 175, 0, 
	176, 0, 177, 0, 178, 0, 179, 0, 
	180, 0, 181, 0, 182, 0, 183, 0, 
	184, 0, 185, 0, 187, 186, 187, 186, 
	187, 187, 4, 188, 202, 4, 203, 219, 
	221, 223, 230, 187, 186, 187, 189, 186, 
	187, 190, 186, 187, 191, 186, 187, 192, 
	186, 187, 193, 186, 187, 194, 186, 187, 
	195, 186, 187, 196, 186, 187, 197, 186, 
	187, 198, 186, 187, 199, 186, 187, 200, 
	186, 187, 201, 186, 187, 4, 186, 187, 
	75, 186, 187, 75, 204, 214, 186, 187, 
	205, 186, 187, 206, 186, 187, 207, 186, 
	187, 208, 186, 187, 209, 186, 187, 210, 
	186, 187, 211, 186, 187, 212, 186, 187, 
	213, 186, 187, 202, 186, 187, 215, 186, 
	187, 216, 186, 187, 217, 186, 187, 218, 
	186, 187, 75, 186, 187, 220, 186, 187, 
	202, 186, 187, 222, 186, 187, 220, 186, 
	187, 224, 186, 187, 225, 186, 187, 226, 
	186, 187, 227, 186, 187, 228, 186, 187, 
	229, 186, 187, 218, 186, 187, 213, 186, 
	233, 232, 233, 232, 233, 233, 4, 234, 
	248, 4, 249, 265, 271, 273, 275, 293, 
	233, 232, 233, 235, 232, 233, 236, 232, 
	233, 237, 232, 233, 238, 232, 233, 239, 
	232, 233, 240, 232, 233, 241, 232, 233, 
	242, 232, 233, 243, 232, 233, 244, 232, 
	233, 245, 232, 233, 246, 232, 233, 247, 
	232, 233, 4, 232, 233, 75, 232, 233, 
	75, 250, 260, 232, 233, 251, 232, 233, 
	252, 232, 233, 253, 232, 233, 254, 232, 
	233, 255, 232, 233, 256, 232, 233, 257, 
	232, 233, 258, 232, 233, 259, 232, 233, 
	248, 232, 233, 261, 232, 233, 262, 232, 
	233, 263, 232, 233, 264, 232, 233, 75, 
	232, 233, 266, 232, 233, 267, 232, 233, 
	268, 232, 233, 269, 232, 233, 270, 232, 
	233, 264, 232, 233, 272, 232, 233, 248, 
	232, 233, 274, 232, 233, 272, 232, 233, 
	276, 232, 233, 277, 232, 233, 278, 232, 
	233, 279, 232, 233, 280, 232, 233, 281, 
	232, 233, 282, 232, 233, 283, 75, 232, 
	233, 284, 232, 233, 285, 232, 233, 286, 
	232, 233, 287, 232, 233, 288, 232, 233, 
	289, 232, 233, 290, 232, 233, 291, 232, 
	233, 292, 232, 233, 264, 232, 233, 259, 
	232, 46, 0, 295, 296, 295, 0, 300, 
	299, 298, 296, 299, 297, 0, 298, 296, 
	297, 0, 298, 297, 300, 299, 298, 296, 
	299, 297, 300, 300, 5, 14, 16, 30, 
	33, 36, 76, 140, 162, 164, 166, 294, 
	295, 300, 0, 54, 302, 53, 54, 303, 
	53, 54, 304, 53, 54, 305, 53, 54, 
	306, 53, 54, 74, 53, 54, 308, 53, 
	54, 309, 53, 54, 310, 53, 54, 311, 
	53, 54, 312, 53, 54, 313, 53, 54, 
	314, 53, 54, 315, 53, 54, 316, 53, 
	54, 317, 53, 54, 318, 53, 54, 74, 
	53, 54, 320, 53, 54, 321, 53, 54, 
	322, 53, 54, 323, 53, 54, 324, 53, 
	54, 325, 53, 54, 326, 53, 54, 327, 
	75, 53, 54, 328, 53, 54, 329, 53, 
	54, 330, 53, 54, 331, 53, 54, 332, 
	53, 54, 333, 53, 54, 334, 53, 54, 
	335, 53, 54, 336, 53, 54, 74, 53, 
	0, 0
};

static const char _lexer_trans_actions[] = {
	0, 47, 0, 5, 1, 0, 25, 1, 
	25, 25, 25, 25, 25, 25, 25, 31, 
	0, 39, 0, 39, 0, 39, 47, 0, 
	5, 1, 0, 25, 1, 25, 25, 25, 
	25, 25, 25, 25, 31, 0, 39, 0, 
	39, 0, 39, 47, 0, 0, 39, 119, 
	41, 41, 41, 3, 111, 29, 29, 29, 
	0, 111, 29, 29, 29, 0, 111, 29, 
	0, 29, 0, 95, 7, 7, 39, 47, 
	0, 0, 39, 103, 21, 0, 47, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 39, 50, 
	99, 19, 0, 39, 39, 39, 39, 0, 
	23, 107, 23, 23, 44, 23, 0, 47, 
	0, 1, 0, 39, 0, 0, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 124, 50, 
	47, 0, 47, 0, 62, 29, 62, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 9, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 9, 
	0, 115, 27, 53, 50, 27, 56, 50, 
	56, 56, 56, 56, 56, 56, 56, 59, 
	27, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	124, 50, 47, 0, 47, 0, 65, 29, 
	77, 65, 77, 77, 77, 77, 77, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 11, 0, 47, 11, 0, 47, 11, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 11, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 11, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	124, 50, 47, 0, 47, 0, 74, 77, 
	74, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 17, 0, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 124, 50, 47, 0, 
	47, 0, 71, 29, 77, 71, 77, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 15, 0, 47, 
	15, 0, 47, 15, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 15, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	124, 50, 47, 0, 47, 0, 68, 29, 
	77, 68, 77, 77, 77, 77, 77, 77, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 13, 0, 47, 13, 0, 47, 
	13, 0, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 13, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 13, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 39, 0, 0, 0, 39, 47, 
	33, 33, 80, 33, 33, 39, 0, 35, 
	0, 39, 0, 0, 47, 0, 0, 35, 
	0, 0, 47, 0, 86, 83, 37, 89, 
	83, 89, 89, 89, 89, 89, 89, 89, 
	92, 0, 39, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	9, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 0
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
	39, 39
};

static const int lexer_start = 1;
static const int lexer_first_final = 337;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"

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
    
    
#line 878 "ext/gherkin_lexer_cy_gb/gherkin_lexer_cy_gb.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
    
#line 885 "ext/gherkin_lexer_cy_gb/gherkin_lexer_cy_gb.c"
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
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
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
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
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
#line 1161 "ext/gherkin_lexer_cy_gb/gherkin_lexer_cy_gb.c"
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
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"
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
#line 1224 "ext/gherkin_lexer_cy_gb/gherkin_lexer_cy_gb.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/cy_gb.c.rl"

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

void Init_gherkin_lexer_cy_gb()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Cy_gb", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}

