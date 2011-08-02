" Vim compiler file
" Language:	Ruby
" Function:	Code coverage information with rcov
" Maintainer:	Mauricio Fernandez <mfp at acm dot org>
" Info:		
" URL:		http://eigenclass.org/hiki.rb?rcov
" ----------------------------------------------------------------------------
"
" Changelog:
" 0.1:	initial version, shipped with rcov 0.6.0
"
" Comments:
" Initial attempt. 
" ----------------------------------------------------------------------------

if exists("current_compiler")
  finish
endif
let current_compiler = "rcov"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=rake\ $*\ RCOVOPTS=\"-D\ --no-html\ --no-color\"\ $*

CompilerSet errorformat=
     \%+W\#\#\#\ %f:%l\,
     \%-C\ \ \ ,
     \%-C!!\ 

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: nowrap sw=2 sts=2 ts=8 ff=unix :
