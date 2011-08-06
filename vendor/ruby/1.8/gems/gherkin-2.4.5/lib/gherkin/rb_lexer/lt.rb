
# line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
require 'gherkin/lexer/i18n_lexer'

module Gherkin
  module RbLexer
    class Lt #:nodoc:
      
# line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"

 
      def initialize(listener)
        @listener = listener
        
# line 16 "lib/gherkin/rb_lexer/lt.rb"
class << self
	attr_accessor :_lexer_actions
	private :_lexer_actions, :_lexer_actions=
end
self._lexer_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 10, 1, 
	11, 1, 14, 1, 15, 1, 16, 1, 
	17, 1, 18, 1, 19, 1, 20, 1, 
	21, 2, 2, 16, 2, 11, 0, 2, 
	12, 13, 2, 15, 0, 2, 15, 1, 
	2, 15, 14, 2, 15, 17, 2, 16, 
	4, 2, 16, 5, 2, 16, 6, 2, 
	16, 7, 2, 16, 8, 2, 16, 14, 
	2, 18, 19, 2, 20, 0, 2, 20, 
	1, 2, 20, 14, 2, 20, 17, 3, 
	3, 12, 13, 3, 9, 12, 13, 3, 
	10, 12, 13, 3, 11, 12, 13, 3, 
	12, 13, 16, 3, 15, 12, 13, 4, 
	2, 12, 13, 16, 4, 15, 0, 12, 
	13
]

class << self
	attr_accessor :_lexer_key_offsets
	private :_lexer_key_offsets, :_lexer_key_offsets=
end
self._lexer_key_offsets = [
	0, 0, 19, 20, 21, 39, 40, 41, 
	45, 50, 55, 60, 65, 69, 73, 75, 
	76, 77, 78, 79, 80, 81, 82, 83, 
	84, 85, 86, 87, 88, 89, 90, 91, 
	92, 94, 99, 106, 111, 112, 113, 114, 
	115, 116, 117, 118, 120, 121, 122, 123, 
	124, 125, 126, 127, 128, 129, 130, 131, 
	132, 146, 148, 150, 152, 154, 156, 158, 
	160, 162, 164, 166, 168, 170, 172, 174, 
	176, 194, 195, 196, 197, 198, 199, 200, 
	201, 202, 203, 204, 205, 206, 207, 214, 
	216, 218, 220, 222, 224, 226, 228, 230, 
	231, 232, 233, 234, 235, 236, 237, 238, 
	249, 251, 253, 255, 257, 259, 261, 263, 
	265, 267, 269, 271, 273, 275, 277, 279, 
	281, 283, 285, 287, 289, 291, 293, 295, 
	297, 299, 301, 303, 305, 307, 309, 311, 
	313, 315, 317, 320, 322, 324, 326, 328, 
	330, 332, 334, 336, 338, 340, 342, 345, 
	348, 350, 352, 354, 356, 358, 360, 362, 
	364, 366, 368, 370, 372, 374, 376, 378, 
	379, 380, 381, 382, 383, 384, 386, 388, 
	389, 390, 391, 392, 393, 394, 395, 396, 
	397, 398, 399, 400, 401, 402, 416, 418, 
	420, 422, 424, 426, 428, 430, 432, 434, 
	436, 438, 440, 442, 444, 446, 448, 450, 
	452, 454, 456, 458, 460, 462, 464, 467, 
	469, 471, 473, 475, 477, 479, 481, 483, 
	485, 487, 489, 491, 493, 495, 497, 499, 
	500, 501, 502, 503, 517, 519, 521, 523, 
	525, 527, 529, 531, 533, 535, 537, 539, 
	541, 543, 545, 547, 549, 551, 553, 555, 
	557, 559, 561, 564, 566, 568, 570, 572, 
	574, 576, 578, 580, 582, 584, 587, 589, 
	591, 593, 595, 597, 599, 601, 603, 605, 
	607, 609, 612, 614, 616, 618, 620, 622, 
	624, 626, 628, 630, 632, 634, 636, 637, 
	638, 639, 640, 641, 642, 643, 644, 648, 
	654, 657, 659, 665, 683, 685, 687, 689, 
	691, 693, 695, 697, 699, 701, 704, 706, 
	708, 710, 712, 714, 716, 718, 720, 722, 
	724, 726, 728, 731, 733, 735, 737, 739, 
	741, 743, 745, 747, 749, 751, 753, 755, 
	757, 759
]

class << self
	attr_accessor :_lexer_trans_keys
	private :_lexer_trans_keys, :_lexer_trans_keys=
end
self._lexer_trans_keys = [
	-17, 10, 32, 34, 35, 37, 42, 64, 
	66, 68, 73, 75, 80, 83, 84, 86, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 66, 68, 73, 75, 
	80, 83, 84, 86, 124, 9, 13, 34, 
	34, 10, 32, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 10, 13, 13, 32, 
	64, 9, 10, 9, 10, 13, 32, 64, 
	11, 12, 10, 32, 64, 9, 13, 101, 
	116, 117, 111, 116, 97, 114, 97, 111, 
	105, 110, 116, 101, 107, 115, 116, 97, 
	115, 58, 10, 10, 10, 32, 35, 37, 
	42, 64, 66, 68, 73, 75, 83, 84, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 32, 34, 35, 37, 42, 64, 66, 
	68, 73, 75, 80, 83, 84, 86, 124, 
	9, 13, 97, 118, 121, 122, 100, -59, 
	-66, 105, 97, 105, 58, 10, 10, 10, 
	32, 35, 83, 124, 9, 13, 10, 97, 
	10, 118, 10, 121, 10, 98, -60, 10, 
	-105, 10, 10, 58, 97, 99, 118, 121, 
	98, -60, -105, 58, 10, 10, 10, 32, 
	35, 37, 64, 75, 80, 83, 86, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 111, 10, 
	110, 10, 116, 10, 101, 10, 107, 10, 
	115, 10, 116, 10, 97, 10, 115, 10, 
	58, 10, 97, 10, 118, 10, 121, 10, 
	122, 10, 100, -59, 10, -66, 10, 10, 
	105, 10, 97, 10, 105, 10, 97, 99, 
	10, 118, 10, 121, 10, 98, -60, 10, 
	-105, 10, 10, 101, 10, 110, 10, 97, 
	10, 114, 10, 105, 10, 106, 10, 97, 
	117, 10, 105, 117, 10, 115, 10, 32, 
	-59, 10, -95, 10, 10, 97, 10, 98, 
	10, 108, 10, 111, 10, 110, 10, 97, 
	10, 114, 10, 105, 10, 97, 10, 110, 
	10, 116, 101, 110, 97, 114, 105, 106, 
	97, 117, 105, 117, 115, 32, -59, -95, 
	97, 98, 108, 111, 110, 97, 115, 58, 
	10, 10, 10, 32, 35, 37, 42, 64, 
	66, 68, 73, 75, 83, 84, 9, 13, 
	10, 95, 10, 70, 10, 69, 10, 65, 
	10, 84, 10, 85, 10, 82, 10, 69, 
	10, 95, 10, 69, 10, 78, 10, 68, 
	10, 95, 10, 37, 10, 32, 10, 101, 
	10, 116, 10, 117, 10, 111, 10, 116, 
	10, 97, 10, 114, 10, 97, 10, 105, 
	10, 97, 99, 10, 118, 10, 121, 10, 
	98, -60, 10, -105, 10, 10, 58, 10, 
	101, 10, 110, 10, 97, 10, 114, 10, 
	105, 10, 106, 10, 117, 10, 115, 10, 
	97, 10, 100, 115, 58, 10, 10, 10, 
	32, 35, 37, 42, 64, 66, 68, 73, 
	75, 83, 84, 9, 13, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, 10, 32, 10, 101, 10, 116, 10, 
	117, 10, 111, 10, 116, 10, 97, 10, 
	114, 10, 97, 111, 10, 105, 10, 110, 
	10, 116, 10, 101, 10, 107, 10, 115, 
	10, 116, 10, 97, 10, 115, 10, 58, 
	10, 97, 99, 10, 118, 10, 121, 10, 
	98, -60, 10, -105, 10, 10, 101, 10, 
	110, 10, 97, 10, 114, 10, 105, 10, 
	106, 10, 97, 117, 10, 117, 10, 115, 
	10, 32, -59, 10, -95, 10, 10, 97, 
	10, 98, 10, 108, 10, 111, 10, 110, 
	10, 97, 10, 100, 97, 100, 97, 114, 
	105, 97, 110, 116, 32, 124, 9, 13, 
	10, 32, 92, 124, 9, 13, 10, 92, 
	124, 10, 92, 10, 32, 92, 124, 9, 
	13, 10, 32, 34, 35, 37, 42, 64, 
	66, 68, 73, 75, 80, 83, 84, 86, 
	124, 9, 13, 10, 101, 10, 116, 10, 
	117, 10, 111, 10, 116, 10, 97, 10, 
	114, 10, 97, 10, 105, 10, 97, 99, 
	10, 118, 10, 121, 10, 98, -60, 10, 
	-105, 10, 10, 58, 10, 101, 10, 110, 
	10, 97, 10, 114, 10, 105, 10, 106, 
	10, 97, 117, 10, 117, 10, 115, 10, 
	32, -59, 10, -95, 10, 10, 97, 10, 
	98, 10, 108, 10, 111, 10, 110, 10, 
	97, 10, 115, 10, 97, 10, 100, 0
]

class << self
	attr_accessor :_lexer_single_lengths
	private :_lexer_single_lengths, :_lexer_single_lengths=
end
self._lexer_single_lengths = [
	0, 17, 1, 1, 16, 1, 1, 2, 
	3, 3, 3, 3, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 3, 5, 3, 1, 1, 1, 1, 
	1, 1, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	12, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	16, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 5, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 9, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 12, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 12, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 2, 4, 
	3, 2, 4, 16, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 0
]

class << self
	attr_accessor :_lexer_range_lengths
	private :_lexer_range_lengths, :_lexer_range_lengths=
end
self._lexer_range_lengths = [
	0, 1, 0, 0, 1, 0, 0, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
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
	0, 0, 0, 0, 0, 1, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	0, 0, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0
]

class << self
	attr_accessor :_lexer_index_offsets
	private :_lexer_index_offsets, :_lexer_index_offsets=
end
self._lexer_index_offsets = [
	0, 0, 19, 21, 23, 41, 43, 45, 
	49, 54, 59, 64, 69, 73, 77, 80, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 122, 129, 134, 136, 138, 140, 
	142, 144, 146, 148, 151, 153, 155, 157, 
	159, 161, 163, 165, 167, 169, 171, 173, 
	175, 189, 192, 195, 198, 201, 204, 207, 
	210, 213, 216, 219, 222, 225, 228, 231, 
	234, 252, 254, 256, 258, 260, 262, 264, 
	266, 268, 270, 272, 274, 276, 278, 285, 
	288, 291, 294, 297, 300, 303, 306, 309, 
	311, 313, 315, 317, 319, 321, 323, 325, 
	336, 339, 342, 345, 348, 351, 354, 357, 
	360, 363, 366, 369, 372, 375, 378, 381, 
	384, 387, 390, 393, 396, 399, 402, 405, 
	408, 411, 414, 417, 420, 423, 426, 429, 
	432, 435, 438, 442, 445, 448, 451, 454, 
	457, 460, 463, 466, 469, 472, 475, 479, 
	483, 486, 489, 492, 495, 498, 501, 504, 
	507, 510, 513, 516, 519, 522, 525, 528, 
	530, 532, 534, 536, 538, 540, 543, 546, 
	548, 550, 552, 554, 556, 558, 560, 562, 
	564, 566, 568, 570, 572, 574, 588, 591, 
	594, 597, 600, 603, 606, 609, 612, 615, 
	618, 621, 624, 627, 630, 633, 636, 639, 
	642, 645, 648, 651, 654, 657, 660, 664, 
	667, 670, 673, 676, 679, 682, 685, 688, 
	691, 694, 697, 700, 703, 706, 709, 712, 
	714, 716, 718, 720, 734, 737, 740, 743, 
	746, 749, 752, 755, 758, 761, 764, 767, 
	770, 773, 776, 779, 782, 785, 788, 791, 
	794, 797, 800, 804, 807, 810, 813, 816, 
	819, 822, 825, 828, 831, 834, 838, 841, 
	844, 847, 850, 853, 856, 859, 862, 865, 
	868, 871, 875, 878, 881, 884, 887, 890, 
	893, 896, 899, 902, 905, 908, 911, 913, 
	915, 917, 919, 921, 923, 925, 927, 931, 
	937, 941, 944, 950, 968, 971, 974, 977, 
	980, 983, 986, 989, 992, 995, 999, 1002, 
	1005, 1008, 1011, 1014, 1017, 1020, 1023, 1026, 
	1029, 1032, 1035, 1039, 1042, 1045, 1048, 1051, 
	1054, 1057, 1060, 1063, 1066, 1069, 1072, 1075, 
	1078, 1081
]

class << self
	attr_accessor :_lexer_trans_targs
	private :_lexer_trans_targs, :_lexer_trans_targs=
end
self._lexer_trans_targs = [
	2, 4, 4, 5, 14, 16, 30, 33, 
	36, 38, 42, 43, 73, 94, 294, 296, 
	302, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 14, 16, 30, 33, 36, 38, 
	42, 43, 73, 94, 294, 296, 302, 4, 
	0, 6, 0, 7, 0, 8, 7, 7, 
	0, 9, 9, 10, 9, 9, 9, 9, 
	10, 9, 9, 9, 9, 11, 9, 9, 
	9, 9, 12, 9, 9, 4, 13, 13, 
	0, 4, 13, 13, 0, 4, 15, 14, 
	4, 0, 17, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 345, 0, 31, 0, 
	0, 32, 4, 15, 32, 0, 0, 0, 
	0, 34, 35, 4, 35, 35, 33, 34, 
	34, 4, 35, 33, 35, 0, 37, 0, 
	30, 0, 39, 0, 40, 0, 41, 0, 
	30, 0, 30, 0, 44, 45, 0, 30, 
	0, 46, 0, 47, 0, 48, 0, 49, 
	0, 50, 0, 51, 0, 52, 0, 53, 
	0, 54, 0, 56, 55, 56, 55, 56, 
	56, 4, 57, 71, 4, 308, 310, 314, 
	315, 317, 343, 56, 55, 56, 58, 55, 
	56, 59, 55, 56, 60, 55, 56, 61, 
	55, 56, 62, 55, 56, 63, 55, 56, 
	64, 55, 56, 65, 55, 56, 66, 55, 
	56, 67, 55, 56, 68, 55, 56, 69, 
	55, 56, 70, 55, 56, 4, 55, 56, 
	72, 55, 4, 4, 5, 14, 16, 30, 
	33, 36, 38, 42, 43, 73, 94, 294, 
	296, 302, 4, 0, 74, 0, 75, 0, 
	76, 0, 77, 0, 78, 0, 79, 0, 
	80, 0, 81, 0, 82, 0, 83, 0, 
	84, 0, 86, 85, 86, 85, 86, 86, 
	4, 87, 4, 86, 85, 86, 88, 85, 
	86, 89, 85, 86, 90, 85, 86, 91, 
	85, 92, 86, 85, 93, 86, 85, 86, 
	72, 85, 95, 167, 0, 96, 0, 97, 
	0, 98, 0, 99, 0, 100, 0, 101, 
	0, 103, 102, 103, 102, 103, 103, 4, 
	104, 4, 118, 128, 138, 161, 103, 102, 
	103, 105, 102, 103, 106, 102, 103, 107, 
	102, 103, 108, 102, 103, 109, 102, 103, 
	110, 102, 103, 111, 102, 103, 112, 102, 
	103, 113, 102, 103, 114, 102, 103, 115, 
	102, 103, 116, 102, 103, 117, 102, 103, 
	4, 102, 103, 119, 102, 103, 120, 102, 
	103, 121, 102, 103, 122, 102, 103, 123, 
	102, 103, 124, 102, 103, 125, 102, 103, 
	126, 102, 103, 127, 102, 103, 72, 102, 
	103, 129, 102, 103, 130, 102, 103, 131, 
	102, 103, 132, 102, 103, 133, 102, 134, 
	103, 102, 135, 103, 102, 103, 136, 102, 
	103, 137, 102, 103, 127, 102, 103, 139, 
	144, 102, 103, 140, 102, 103, 141, 102, 
	103, 142, 102, 143, 103, 102, 127, 103, 
	102, 103, 145, 102, 103, 146, 102, 103, 
	147, 102, 103, 148, 102, 103, 149, 102, 
	103, 150, 102, 103, 151, 126, 102, 103, 
	127, 152, 102, 103, 153, 102, 103, 154, 
	102, 155, 103, 102, 156, 103, 102, 103, 
	157, 102, 103, 158, 102, 103, 159, 102, 
	103, 160, 102, 103, 125, 102, 103, 162, 
	102, 103, 163, 102, 103, 164, 102, 103, 
	165, 102, 103, 166, 102, 103, 136, 102, 
	168, 0, 169, 0, 170, 0, 171, 0, 
	172, 0, 173, 0, 174, 231, 0, 83, 
	175, 0, 176, 0, 177, 0, 178, 0, 
	179, 0, 180, 0, 181, 0, 182, 0, 
	183, 0, 184, 0, 185, 0, 186, 0, 
	187, 0, 189, 188, 189, 188, 189, 189, 
	4, 190, 204, 4, 205, 207, 211, 212, 
	214, 229, 189, 188, 189, 191, 188, 189, 
	192, 188, 189, 193, 188, 189, 194, 188, 
	189, 195, 188, 189, 196, 188, 189, 197, 
	188, 189, 198, 188, 189, 199, 188, 189, 
	200, 188, 189, 201, 188, 189, 202, 188, 
	189, 203, 188, 189, 4, 188, 189, 72, 
	188, 189, 206, 188, 189, 204, 188, 189, 
	208, 188, 189, 209, 188, 189, 210, 188, 
	189, 204, 188, 189, 204, 188, 189, 213, 
	188, 189, 204, 188, 189, 215, 221, 188, 
	189, 216, 188, 189, 217, 188, 189, 218, 
	188, 219, 189, 188, 220, 189, 188, 189, 
	72, 188, 189, 222, 188, 189, 223, 188, 
	189, 224, 188, 189, 225, 188, 189, 226, 
	188, 189, 227, 188, 189, 228, 188, 189, 
	220, 188, 189, 230, 188, 189, 210, 188, 
	232, 0, 233, 0, 235, 234, 235, 234, 
	235, 235, 4, 236, 250, 4, 251, 253, 
	257, 258, 269, 292, 235, 234, 235, 237, 
	234, 235, 238, 234, 235, 239, 234, 235, 
	240, 234, 235, 241, 234, 235, 242, 234, 
	235, 243, 234, 235, 244, 234, 235, 245, 
	234, 235, 246, 234, 235, 247, 234, 235, 
	248, 234, 235, 249, 234, 235, 4, 234, 
	235, 72, 234, 235, 252, 234, 235, 250, 
	234, 235, 254, 234, 235, 255, 234, 235, 
	256, 234, 235, 250, 234, 235, 250, 234, 
	235, 259, 260, 234, 235, 250, 234, 235, 
	261, 234, 235, 262, 234, 235, 263, 234, 
	235, 264, 234, 235, 265, 234, 235, 266, 
	234, 235, 267, 234, 235, 268, 234, 235, 
	72, 234, 235, 270, 275, 234, 235, 271, 
	234, 235, 272, 234, 235, 273, 234, 274, 
	235, 234, 268, 235, 234, 235, 276, 234, 
	235, 277, 234, 235, 278, 234, 235, 279, 
	234, 235, 280, 234, 235, 281, 234, 235, 
	282, 267, 234, 235, 283, 234, 235, 284, 
	234, 235, 285, 234, 286, 235, 234, 287, 
	235, 234, 235, 288, 234, 235, 289, 234, 
	235, 290, 234, 235, 291, 234, 235, 266, 
	234, 235, 293, 234, 235, 256, 234, 295, 
	0, 41, 0, 297, 0, 298, 0, 299, 
	0, 300, 0, 301, 0, 81, 0, 302, 
	303, 302, 0, 307, 306, 305, 303, 306, 
	304, 0, 305, 303, 304, 0, 305, 304, 
	307, 306, 305, 303, 306, 304, 307, 307, 
	5, 14, 16, 30, 33, 36, 38, 42, 
	43, 73, 94, 294, 296, 302, 307, 0, 
	56, 309, 55, 56, 71, 55, 56, 311, 
	55, 56, 312, 55, 56, 313, 55, 56, 
	71, 55, 56, 71, 55, 56, 316, 55, 
	56, 71, 55, 56, 318, 324, 55, 56, 
	319, 55, 56, 320, 55, 56, 321, 55, 
	322, 56, 55, 323, 56, 55, 56, 72, 
	55, 56, 325, 55, 56, 326, 55, 56, 
	327, 55, 56, 328, 55, 56, 329, 55, 
	56, 330, 55, 56, 331, 342, 55, 56, 
	332, 55, 56, 333, 55, 56, 334, 55, 
	335, 56, 55, 336, 56, 55, 56, 337, 
	55, 56, 338, 55, 56, 339, 55, 56, 
	340, 55, 56, 341, 55, 56, 342, 55, 
	56, 323, 55, 56, 344, 55, 56, 313, 
	55, 0, 0
]

class << self
	attr_accessor :_lexer_trans_actions
	private :_lexer_trans_actions, :_lexer_trans_actions=
end
self._lexer_trans_actions = [
	0, 47, 0, 3, 1, 0, 25, 1, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	31, 0, 39, 0, 39, 0, 39, 47, 
	0, 3, 1, 0, 25, 1, 25, 25, 
	25, 25, 25, 25, 25, 25, 31, 0, 
	39, 0, 39, 0, 39, 47, 0, 0, 
	39, 119, 41, 41, 41, 5, 111, 29, 
	29, 29, 0, 111, 29, 29, 29, 0, 
	111, 29, 0, 29, 0, 95, 7, 7, 
	39, 47, 0, 0, 39, 103, 21, 0, 
	47, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	39, 50, 99, 19, 0, 39, 39, 39, 
	39, 0, 23, 107, 23, 23, 44, 23, 
	0, 47, 0, 1, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 124, 50, 47, 0, 47, 
	0, 65, 29, 77, 65, 77, 77, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 11, 0, 47, 
	11, 0, 115, 27, 53, 50, 27, 56, 
	50, 56, 56, 56, 56, 56, 56, 56, 
	56, 59, 27, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 124, 50, 47, 0, 47, 0, 
	74, 77, 74, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	17, 0, 0, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 124, 50, 47, 0, 47, 0, 62, 
	29, 62, 77, 77, 77, 77, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	9, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 9, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 0, 39, 0, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 124, 50, 47, 0, 47, 0, 
	71, 29, 77, 71, 77, 77, 77, 77, 
	77, 77, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 15, 0, 47, 15, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	15, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 39, 0, 39, 124, 50, 47, 0, 
	47, 0, 68, 29, 77, 68, 77, 77, 
	77, 77, 77, 77, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 13, 0, 
	47, 13, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	13, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	0, 0, 39, 47, 33, 33, 80, 33, 
	33, 39, 0, 35, 0, 39, 0, 0, 
	47, 0, 0, 35, 0, 0, 47, 0, 
	86, 83, 37, 89, 83, 89, 89, 89, 
	89, 89, 89, 89, 89, 92, 0, 39, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 47, 0, 0, 47, 0, 47, 11, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 47, 0, 0, 47, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 0
]

class << self
	attr_accessor :_lexer_eof_actions
	private :_lexer_eof_actions, :_lexer_eof_actions=
end
self._lexer_eof_actions = [
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
	39, 39
]

class << self
	attr_accessor :lexer_start
end
self.lexer_start = 1;
class << self
	attr_accessor :lexer_first_final
end
self.lexer_first_final = 345;
class << self
	attr_accessor :lexer_error
end
self.lexer_error = 0;

class << self
	attr_accessor :lexer_en_main
end
self.lexer_en_main = 1;


# line 121 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
      end
 
      def scan(data)
        data = (data + "\n%_FEATURE_END_%").unpack("c*") # Explicit EOF simplifies things considerably
        eof = pe = data.length
 
        @line_number = 1
        @last_newline = 0
 
        
# line 714 "lib/gherkin/rb_lexer/lt.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = lexer_start
end

# line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
        
# line 723 "lib/gherkin/rb_lexer/lt.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _lexer_key_offsets[cs]
	_trans = _lexer_index_offsets[cs]
	_klen = _lexer_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _lexer_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _lexer_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _lexer_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _lexer_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _lexer_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	cs = _lexer_trans_targs[_trans]
	if _lexer_trans_actions[_trans] != 0
		_acts = _lexer_trans_actions[_trans]
		_nacts = _lexer_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _lexer_actions[_acts - 1]
when 0 then
# line 9 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @content_start = p
          @current_line = @line_number
          @start_col = p - @last_newline - "#{@keyword}:".length
        		end
when 1 then
# line 15 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @current_line = @line_number
          @start_col = p - @last_newline
        		end
when 2 then
# line 20 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @content_start = p
        		end
when 3 then
# line 24 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          con = unindent(@start_col, utf8_pack(data[@content_start...@next_keyword_start-1]).sub(/(\r?\n)?([\t ])*\Z/, '').gsub(/\\"\\"\\"/, '"""'))
          @listener.doc_string(con, @current_line) 
        		end
when 4 then
# line 29 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          p = store_keyword_content(:feature, data, p, eof)
        		end
when 5 then
# line 33 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          p = store_keyword_content(:background, data, p, eof)
        		end
when 6 then
# line 37 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          p = store_keyword_content(:scenario, data, p, eof)
        		end
when 7 then
# line 41 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          p = store_keyword_content(:scenario_outline, data, p, eof)
        		end
when 8 then
# line 45 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          p = store_keyword_content(:examples, data, p, eof)
        		end
when 9 then
# line 49 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.step(@keyword, con, @current_line)
        		end
when 10 then
# line 54 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.comment(con, @line_number)
          @keyword_start = nil
        		end
when 11 then
# line 60 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.tag(con, @current_line)
          @keyword_start = nil
        		end
when 12 then
# line 66 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @line_number += 1
        		end
when 13 then
# line 70 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @last_newline = p + 1
        		end
when 14 then
# line 74 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @keyword_start ||= p
        		end
when 15 then
# line 78 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @keyword = utf8_pack(data[@keyword_start...p]).sub(/:$/,'')
          @keyword_start = nil
        		end
when 16 then
# line 83 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @next_keyword_start = p
        		end
when 17 then
# line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          p = p - 1
          current_row = []
          @current_line = @line_number
        		end
when 18 then
# line 93 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @content_start = p
        		end
when 19 then
# line 97 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          current_row << con.gsub(/\\\|/, "|").gsub(/\\n/, "\n").gsub(/\\\\/, "\\")
        		end
when 20 then
# line 102 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          @listener.row(current_row, @current_line)
        		end
when 21 then
# line 106 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          if cs < lexer_first_final
            content = current_line_content(data, p)
            raise Gherkin::Lexer::LexingError.new("Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information." % [@line_number, content])
          else
            @listener.eof
          end
        		end
# line 953 "lib/gherkin/rb_lexer/lt.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	__acts = _lexer_eof_actions[cs]
	__nacts =  _lexer_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _lexer_actions[__acts - 1]
when 21 then
# line 106 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
		begin

          if cs < lexer_first_final
            content = current_line_content(data, p)
            raise Gherkin::Lexer::LexingError.new("Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information." % [@line_number, content])
          else
            @listener.eof
          end
        		end
# line 992 "lib/gherkin/rb_lexer/lt.rb"
		end # eof action switch
	end
	if _trigger_goto
		next
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 132 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/lt.rb.rl"
      end

      def unindent(startcol, text)
        text.gsub(/^[\t ]{0,#{startcol}}/, "")
      end

      def store_keyword_content(event, data, p, eof)
        end_point = (!@next_keyword_start or (p == eof)) ? p : @next_keyword_start
        content = unindent(@start_col + 2, utf8_pack(data[@content_start...end_point])).rstrip
        content_lines = content.split("\n")
        name = content_lines.shift || ""
        name.strip!
        description = content_lines.join("\n")
        @listener.__send__(event, @keyword, name, description, @current_line)
        @next_keyword_start ? @next_keyword_start - 1 : p
      ensure
        @next_keyword_start = nil
      end
      
      def current_line_content(data, p)
        rest = data[@last_newline..-1]
        utf8_pack(rest[0..rest.index(10)||-1]).strip # 10 is \n
      end

      if (RUBY_VERSION =~ /^1\.9/)
        def utf8_pack(array)
          array.pack("c*").force_encoding("UTF-8")
        end
      else
        def utf8_pack(array)
          array.pack("c*")
        end
      end
    end
  end
end
