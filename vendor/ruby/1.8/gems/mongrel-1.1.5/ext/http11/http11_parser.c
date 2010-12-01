#line 1 "http11_parser.rl"
/**
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 */
#include "http11_parser.h"
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define LEN(AT, FPC) (FPC - buffer - parser->AT)
#define MARK(M,FPC) (parser->M = (FPC) - buffer)
#define PTR_TO(F) (buffer + parser->F)

/** Machine **/

#line 74 "http11_parser.rl"


/** Data **/

#line 25 "http11_parser.c"
static const int http_parser_start = 1;
static const int http_parser_first_final = 57;
static const int http_parser_error = 0;

static const int http_parser_en_main = 1;

#line 78 "http11_parser.rl"

int http_parser_init(http_parser *parser)  {
  int cs = 0;
  
#line 37 "http11_parser.c"
	{
	cs = http_parser_start;
	}
#line 82 "http11_parser.rl"
  parser->cs = cs;
  parser->body_start = 0;
  parser->content_len = 0;
  parser->mark = 0;
  parser->nread = 0;
  parser->field_len = 0;
  parser->field_start = 0;    

  return(1);
}


/** exec **/
size_t http_parser_execute(http_parser *parser, const char *buffer, size_t len, size_t off)  {
  const char *p, *pe;
  int cs = parser->cs;

  assert(off <= len && "offset past end of buffer");

  p = buffer+off;
  pe = buffer+len;

  assert(*pe == '\0' && "pointer does not end on NUL");
  assert(pe - p == len - off && "pointers aren't same distance");


  
#line 69 "http11_parser.c"
	{
	if ( p == pe )
		goto _out;
	switch ( cs )
	{
case 1:
	switch( (*p) ) {
		case 36: goto tr0;
		case 95: goto tr0;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto tr0;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto tr0;
	} else
		goto tr0;
	goto st0;
st0:
	goto _out0;
tr0:
#line 22 "http11_parser.rl"
	{MARK(mark, p); }
	goto st2;
st2:
	if ( ++p == pe )
		goto _out2;
case 2:
#line 99 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st38;
		case 95: goto st38;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st38;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st38;
	} else
		goto st38;
	goto st0;
tr2:
#line 36 "http11_parser.rl"
	{ 
    if(parser->request_method != NULL) 
      parser->request_method(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st3;
st3:
	if ( ++p == pe )
		goto _out3;
case 3:
#line 125 "http11_parser.c"
	switch( (*p) ) {
		case 42: goto tr4;
		case 43: goto tr5;
		case 47: goto tr6;
		case 58: goto tr7;
	}
	if ( (*p) < 65 ) {
		if ( 45 <= (*p) && (*p) <= 57 )
			goto tr5;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr5;
	} else
		goto tr5;
	goto st0;
tr4:
#line 22 "http11_parser.rl"
	{MARK(mark, p); }
	goto st4;
st4:
	if ( ++p == pe )
		goto _out4;
case 4:
#line 149 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr8;
		case 35: goto tr9;
	}
	goto st0;
tr8:
#line 40 "http11_parser.rl"
	{ 
    if(parser->request_uri != NULL)
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st5;
tr30:
#line 44 "http11_parser.rl"
	{ 
    if(parser->fragment != NULL)
      parser->fragment(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st5;
tr40:
#line 60 "http11_parser.rl"
	{
    if(parser->request_path != NULL)
      parser->request_path(parser->data, PTR_TO(mark), LEN(mark,p));
  }
#line 40 "http11_parser.rl"
	{ 
    if(parser->request_uri != NULL)
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st5;
tr51:
#line 49 "http11_parser.rl"
	{MARK(query_start, p); }
#line 50 "http11_parser.rl"
	{ 
    if(parser->query_string != NULL)
      parser->query_string(parser->data, PTR_TO(query_start), LEN(query_start, p));
  }
#line 40 "http11_parser.rl"
	{ 
    if(parser->request_uri != NULL)
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st5;
tr55:
#line 50 "http11_parser.rl"
	{ 
    if(parser->query_string != NULL)
      parser->query_string(parser->data, PTR_TO(query_start), LEN(query_start, p));
  }
#line 40 "http11_parser.rl"
	{ 
    if(parser->request_uri != NULL)
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st5;
st5:
	if ( ++p == pe )
		goto _out5;
case 5:
#line 211 "http11_parser.c"
	if ( (*p) == 72 )
		goto tr10;
	goto st0;
tr10:
#line 22 "http11_parser.rl"
	{MARK(mark, p); }
	goto st6;
st6:
	if ( ++p == pe )
		goto _out6;
case 6:
#line 223 "http11_parser.c"
	if ( (*p) == 84 )
		goto st7;
	goto st0;
st7:
	if ( ++p == pe )
		goto _out7;
case 7:
	if ( (*p) == 84 )
		goto st8;
	goto st0;
st8:
	if ( ++p == pe )
		goto _out8;
case 8:
	if ( (*p) == 80 )
		goto st9;
	goto st0;
st9:
	if ( ++p == pe )
		goto _out9;
case 9:
	if ( (*p) == 47 )
		goto st10;
	goto st0;
st10:
	if ( ++p == pe )
		goto _out10;
case 10:
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st11;
	goto st0;
st11:
	if ( ++p == pe )
		goto _out11;
case 11:
	if ( (*p) == 46 )
		goto st12;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st11;
	goto st0;
st12:
	if ( ++p == pe )
		goto _out12;
case 12:
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st13;
	goto st0;
st13:
	if ( ++p == pe )
		goto _out13;
case 13:
	if ( (*p) == 13 )
		goto tr18;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st13;
	goto st0;
tr18:
#line 55 "http11_parser.rl"
	{	
    if(parser->http_version != NULL)
      parser->http_version(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st14;
tr26:
#line 31 "http11_parser.rl"
	{ 
    if(parser->http_field != NULL) {
      parser->http_field(parser->data, PTR_TO(field_start), parser->field_len, PTR_TO(mark), LEN(mark, p));
    }
  }
	goto st14;
st14:
	if ( ++p == pe )
		goto _out14;
case 14:
#line 299 "http11_parser.c"
	if ( (*p) == 10 )
		goto st15;
	goto st0;
st15:
	if ( ++p == pe )
		goto _out15;
case 15:
	switch( (*p) ) {
		case 13: goto st16;
		case 33: goto tr21;
		case 124: goto tr21;
		case 126: goto tr21;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr21;
		} else if ( (*p) >= 35 )
			goto tr21;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr21;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr21;
		} else
			goto tr21;
	} else
		goto tr21;
	goto st0;
st16:
	if ( ++p == pe )
		goto _out16;
case 16:
	if ( (*p) == 10 )
		goto tr22;
	goto st0;
tr22:
#line 65 "http11_parser.rl"
	{ 
    parser->body_start = p - buffer + 1; 
    if(parser->header_done != NULL)
      parser->header_done(parser->data, p + 1, pe - p - 1);
    goto _out57;
  }
	goto st57;
st57:
	if ( ++p == pe )
		goto _out57;
case 57:
#line 351 "http11_parser.c"
	goto st0;
tr21:
#line 25 "http11_parser.rl"
	{ MARK(field_start, p); }
	goto st17;
st17:
	if ( ++p == pe )
		goto _out17;
case 17:
#line 361 "http11_parser.c"
	switch( (*p) ) {
		case 33: goto st17;
		case 58: goto tr24;
		case 124: goto st17;
		case 126: goto st17;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st17;
		} else if ( (*p) >= 35 )
			goto st17;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st17;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st17;
		} else
			goto st17;
	} else
		goto st17;
	goto st0;
tr24:
#line 26 "http11_parser.rl"
	{ 
    parser->field_len = LEN(field_start, p);
  }
	goto st18;
tr27:
#line 30 "http11_parser.rl"
	{ MARK(mark, p); }
	goto st18;
st18:
	if ( ++p == pe )
		goto _out18;
case 18:
#line 400 "http11_parser.c"
	switch( (*p) ) {
		case 13: goto tr26;
		case 32: goto tr27;
	}
	goto tr25;
tr25:
#line 30 "http11_parser.rl"
	{ MARK(mark, p); }
	goto st19;
st19:
	if ( ++p == pe )
		goto _out19;
case 19:
#line 414 "http11_parser.c"
	if ( (*p) == 13 )
		goto tr26;
	goto st19;
tr9:
#line 40 "http11_parser.rl"
	{ 
    if(parser->request_uri != NULL)
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st20;
tr41:
#line 60 "http11_parser.rl"
	{
    if(parser->request_path != NULL)
      parser->request_path(parser->data, PTR_TO(mark), LEN(mark,p));
  }
#line 40 "http11_parser.rl"
	{ 
    if(parser->request_uri != NULL)
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st20;
tr52:
#line 49 "http11_parser.rl"
	{MARK(query_start, p); }
#line 50 "http11_parser.rl"
	{ 
    if(parser->query_string != NULL)
      parser->query_string(parser->data, PTR_TO(query_start), LEN(query_start, p));
  }
#line 40 "http11_parser.rl"
	{ 
    if(parser->request_uri != NULL)
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st20;
tr56:
#line 50 "http11_parser.rl"
	{ 
    if(parser->query_string != NULL)
      parser->query_string(parser->data, PTR_TO(query_start), LEN(query_start, p));
  }
#line 40 "http11_parser.rl"
	{ 
    if(parser->request_uri != NULL)
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st20;
st20:
	if ( ++p == pe )
		goto _out20;
case 20:
#line 467 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr30;
		case 37: goto tr31;
		case 60: goto st0;
		case 62: goto st0;
		case 127: goto st0;
	}
	if ( (*p) > 31 ) {
		if ( 34 <= (*p) && (*p) <= 35 )
			goto st0;
	} else if ( (*p) >= 0 )
		goto st0;
	goto tr29;
tr29:
#line 22 "http11_parser.rl"
	{MARK(mark, p); }
	goto st21;
st21:
	if ( ++p == pe )
		goto _out21;
case 21:
#line 489 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr30;
		case 37: goto st22;
		case 60: goto st0;
		case 62: goto st0;
		case 127: goto st0;
	}
	if ( (*p) > 31 ) {
		if ( 34 <= (*p) && (*p) <= 35 )
			goto st0;
	} else if ( (*p) >= 0 )
		goto st0;
	goto st21;
tr31:
#line 22 "http11_parser.rl"
	{MARK(mark, p); }
	goto st22;
st22:
	if ( ++p == pe )
		goto _out22;
case 22:
#line 511 "http11_parser.c"
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st23;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st23;
	} else
		goto st23;
	goto st0;
st23:
	if ( ++p == pe )
		goto _out23;
case 23:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st21;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st21;
	} else
		goto st21;
	goto st0;
tr5:
#line 22 "http11_parser.rl"
	{MARK(mark, p); }
	goto st24;
st24:
	if ( ++p == pe )
		goto _out24;
case 24:
#line 542 "http11_parser.c"
	switch( (*p) ) {
		case 43: goto st24;
		case 58: goto st25;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st24;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto st24;
		} else if ( (*p) >= 65 )
			goto st24;
	} else
		goto st24;
	goto st0;
tr7:
#line 22 "http11_parser.rl"
	{MARK(mark, p); }
	goto st25;
st25:
	if ( ++p == pe )
		goto _out25;
case 25:
#line 567 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr8;
		case 34: goto st0;
		case 35: goto tr9;
		case 37: goto st26;
		case 60: goto st0;
		case 62: goto st0;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st25;
st26:
	if ( ++p == pe )
		goto _out26;
case 26:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st27;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st27;
	} else
		goto st27;
	goto st0;
st27:
	if ( ++p == pe )
		goto _out27;
case 27:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st25;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st25;
	} else
		goto st25;
	goto st0;
tr6:
#line 22 "http11_parser.rl"
	{MARK(mark, p); }
	goto st28;
st28:
	if ( ++p == pe )
		goto _out28;
case 28:
#line 614 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr40;
		case 34: goto st0;
		case 35: goto tr41;
		case 37: goto st29;
		case 59: goto tr43;
		case 60: goto st0;
		case 62: goto st0;
		case 63: goto tr44;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st28;
st29:
	if ( ++p == pe )
		goto _out29;
case 29:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st30;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st30;
	} else
		goto st30;
	goto st0;
st30:
	if ( ++p == pe )
		goto _out30;
case 30:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st28;
	} else
		goto st28;
	goto st0;
tr43:
#line 60 "http11_parser.rl"
	{
    if(parser->request_path != NULL)
      parser->request_path(parser->data, PTR_TO(mark), LEN(mark,p));
  }
	goto st31;
st31:
	if ( ++p == pe )
		goto _out31;
case 31:
#line 666 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr8;
		case 34: goto st0;
		case 35: goto tr9;
		case 37: goto st32;
		case 60: goto st0;
		case 62: goto st0;
		case 63: goto st34;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st31;
st32:
	if ( ++p == pe )
		goto _out32;
case 32:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st33;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st33;
	} else
		goto st33;
	goto st0;
st33:
	if ( ++p == pe )
		goto _out33;
case 33:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st31;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st31;
	} else
		goto st31;
	goto st0;
tr44:
#line 60 "http11_parser.rl"
	{
    if(parser->request_path != NULL)
      parser->request_path(parser->data, PTR_TO(mark), LEN(mark,p));
  }
	goto st34;
st34:
	if ( ++p == pe )
		goto _out34;
case 34:
#line 717 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr51;
		case 34: goto st0;
		case 35: goto tr52;
		case 37: goto tr53;
		case 60: goto st0;
		case 62: goto st0;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto tr50;
tr50:
#line 49 "http11_parser.rl"
	{MARK(query_start, p); }
	goto st35;
st35:
	if ( ++p == pe )
		goto _out35;
case 35:
#line 738 "http11_parser.c"
	switch( (*p) ) {
		case 32: goto tr55;
		case 34: goto st0;
		case 35: goto tr56;
		case 37: goto st36;
		case 60: goto st0;
		case 62: goto st0;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st35;
tr53:
#line 49 "http11_parser.rl"
	{MARK(query_start, p); }
	goto st36;
st36:
	if ( ++p == pe )
		goto _out36;
case 36:
#line 759 "http11_parser.c"
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st37;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st37;
	} else
		goto st37;
	goto st0;
st37:
	if ( ++p == pe )
		goto _out37;
case 37:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st35;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st35;
	} else
		goto st35;
	goto st0;
st38:
	if ( ++p == pe )
		goto _out38;
case 38:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st39;
		case 95: goto st39;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st39;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st39;
	} else
		goto st39;
	goto st0;
st39:
	if ( ++p == pe )
		goto _out39;
case 39:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st40;
		case 95: goto st40;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st40;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st40;
	} else
		goto st40;
	goto st0;
st40:
	if ( ++p == pe )
		goto _out40;
case 40:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st41;
		case 95: goto st41;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st41;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st41;
	} else
		goto st41;
	goto st0;
st41:
	if ( ++p == pe )
		goto _out41;
case 41:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st42;
		case 95: goto st42;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st42;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st42;
	} else
		goto st42;
	goto st0;
st42:
	if ( ++p == pe )
		goto _out42;
case 42:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st43;
		case 95: goto st43;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st43;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st43;
	} else
		goto st43;
	goto st0;
st43:
	if ( ++p == pe )
		goto _out43;
case 43:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st44;
		case 95: goto st44;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st44;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st44;
	} else
		goto st44;
	goto st0;
st44:
	if ( ++p == pe )
		goto _out44;
case 44:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st45;
		case 95: goto st45;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st45;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st45;
	} else
		goto st45;
	goto st0;
st45:
	if ( ++p == pe )
		goto _out45;
case 45:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st46;
		case 95: goto st46;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st46;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st46;
	} else
		goto st46;
	goto st0;
st46:
	if ( ++p == pe )
		goto _out46;
case 46:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st47;
		case 95: goto st47;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st47;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st47;
	} else
		goto st47;
	goto st0;
st47:
	if ( ++p == pe )
		goto _out47;
case 47:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st48;
		case 95: goto st48;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st48;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st48;
	} else
		goto st48;
	goto st0;
st48:
	if ( ++p == pe )
		goto _out48;
case 48:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st49;
		case 95: goto st49;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st49;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st49;
	} else
		goto st49;
	goto st0;
st49:
	if ( ++p == pe )
		goto _out49;
case 49:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st50;
		case 95: goto st50;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st50;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st50;
	} else
		goto st50;
	goto st0;
st50:
	if ( ++p == pe )
		goto _out50;
case 50:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st51;
		case 95: goto st51;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st51;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st51;
	} else
		goto st51;
	goto st0;
st51:
	if ( ++p == pe )
		goto _out51;
case 51:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st52;
		case 95: goto st52;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st52;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st52;
	} else
		goto st52;
	goto st0;
st52:
	if ( ++p == pe )
		goto _out52;
case 52:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st53;
		case 95: goto st53;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st53;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st53;
	} else
		goto st53;
	goto st0;
st53:
	if ( ++p == pe )
		goto _out53;
case 53:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st54;
		case 95: goto st54;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st54;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st54;
	} else
		goto st54;
	goto st0;
st54:
	if ( ++p == pe )
		goto _out54;
case 54:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st55;
		case 95: goto st55;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st55;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st55;
	} else
		goto st55;
	goto st0;
st55:
	if ( ++p == pe )
		goto _out55;
case 55:
	switch( (*p) ) {
		case 32: goto tr2;
		case 36: goto st56;
		case 95: goto st56;
	}
	if ( (*p) < 48 ) {
		if ( 45 <= (*p) && (*p) <= 46 )
			goto st56;
	} else if ( (*p) > 57 ) {
		if ( 65 <= (*p) && (*p) <= 90 )
			goto st56;
	} else
		goto st56;
	goto st0;
st56:
	if ( ++p == pe )
		goto _out56;
case 56:
	if ( (*p) == 32 )
		goto tr2;
	goto st0;
	}
	_out0: cs = 0; goto _out; 
	_out2: cs = 2; goto _out; 
	_out3: cs = 3; goto _out; 
	_out4: cs = 4; goto _out; 
	_out5: cs = 5; goto _out; 
	_out6: cs = 6; goto _out; 
	_out7: cs = 7; goto _out; 
	_out8: cs = 8; goto _out; 
	_out9: cs = 9; goto _out; 
	_out10: cs = 10; goto _out; 
	_out11: cs = 11; goto _out; 
	_out12: cs = 12; goto _out; 
	_out13: cs = 13; goto _out; 
	_out14: cs = 14; goto _out; 
	_out15: cs = 15; goto _out; 
	_out16: cs = 16; goto _out; 
	_out57: cs = 57; goto _out; 
	_out17: cs = 17; goto _out; 
	_out18: cs = 18; goto _out; 
	_out19: cs = 19; goto _out; 
	_out20: cs = 20; goto _out; 
	_out21: cs = 21; goto _out; 
	_out22: cs = 22; goto _out; 
	_out23: cs = 23; goto _out; 
	_out24: cs = 24; goto _out; 
	_out25: cs = 25; goto _out; 
	_out26: cs = 26; goto _out; 
	_out27: cs = 27; goto _out; 
	_out28: cs = 28; goto _out; 
	_out29: cs = 29; goto _out; 
	_out30: cs = 30; goto _out; 
	_out31: cs = 31; goto _out; 
	_out32: cs = 32; goto _out; 
	_out33: cs = 33; goto _out; 
	_out34: cs = 34; goto _out; 
	_out35: cs = 35; goto _out; 
	_out36: cs = 36; goto _out; 
	_out37: cs = 37; goto _out; 
	_out38: cs = 38; goto _out; 
	_out39: cs = 39; goto _out; 
	_out40: cs = 40; goto _out; 
	_out41: cs = 41; goto _out; 
	_out42: cs = 42; goto _out; 
	_out43: cs = 43; goto _out; 
	_out44: cs = 44; goto _out; 
	_out45: cs = 45; goto _out; 
	_out46: cs = 46; goto _out; 
	_out47: cs = 47; goto _out; 
	_out48: cs = 48; goto _out; 
	_out49: cs = 49; goto _out; 
	_out50: cs = 50; goto _out; 
	_out51: cs = 51; goto _out; 
	_out52: cs = 52; goto _out; 
	_out53: cs = 53; goto _out; 
	_out54: cs = 54; goto _out; 
	_out55: cs = 55; goto _out; 
	_out56: cs = 56; goto _out; 

	_out: {}
	}
#line 109 "http11_parser.rl"

  parser->cs = cs;
  parser->nread += p - (buffer + off);

  assert(p <= pe && "buffer overflow after parsing execute");
  assert(parser->nread <= len && "nread longer than length");
  assert(parser->body_start <= len && "body starts after buffer end");
  assert(parser->mark < len && "mark is after buffer end");
  assert(parser->field_len <= len && "field has length longer than whole buffer");
  assert(parser->field_start < len && "field starts after buffer end");

  if(parser->body_start) {
    /* final \r\n combo encountered so stop right here */
    
#line 1189 "http11_parser.c"
#line 123 "http11_parser.rl"
    parser->nread++;
  }

  return(parser->nread);
}

int http_parser_finish(http_parser *parser)
{
  int cs = parser->cs;

  
#line 1202 "http11_parser.c"
#line 134 "http11_parser.rl"

  parser->cs = cs;

  if (http_parser_has_error(parser) ) {
    return -1;
  } else if (http_parser_is_finished(parser) ) {
    return 1;
  } else {
    return 0;
  }
}

int http_parser_has_error(http_parser *parser) {
  return parser->cs == http_parser_error;
}

int http_parser_is_finished(http_parser *parser) {
  return parser->cs == http_parser_first_final;
}
