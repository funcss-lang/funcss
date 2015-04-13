let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
imap <F3> <F3>
imap <F9> <F9>
map 	 
nnoremap  @:
map g :!git 
nnoremap e :e %	q:k$T/de:q:<Up>
map [Z] 
imap ï o
xmap S <Plug>VSurround
xmap X <Plug>(Exchange)
vnoremap ZR :TTS
vmap [% [%m'gv``
map \t <Plug>TaskList
nmap \a <Plug>ToggleAutoCloseMappings
map \rwp <Plug>RestoreWinPosn
map \swp <Plug>SaveWinPosn
map \tt <Plug>AM_tt
map \tsq <Plug>AM_tsq
map \tsp <Plug>AM_tsp
map \tml <Plug>AM_tml
map \tab <Plug>AM_tab
map \m= <Plug>AM_m=
map \tW@ <Plug>AM_tW@
map \t@ <Plug>AM_t@
map \t~ <Plug>AM_t~
map \t? <Plug>AM_t?
map \w= <Plug>AM_w=
map \ts= <Plug>AM_ts=
map \ts< <Plug>AM_ts<
map \ts; <Plug>AM_ts;
map \ts: <Plug>AM_ts:
map \ts, <Plug>AM_ts,
map \t= <Plug>AM_t=
map \t< <Plug>AM_t<
map \t; <Plug>AM_t;
map \t: <Plug>AM_t:
map \t, <Plug>AM_t,
map \t# <Plug>AM_t#
map \t| <Plug>AM_t|
map \T~ <Plug>AM_T~
map \Tsp <Plug>AM_Tsp
map \Tab <Plug>AM_Tab
map \TW@ <Plug>AM_TW@
map \T@ <Plug>AM_T@
map \T? <Plug>AM_T?
map \T= <Plug>AM_T=
map \T< <Plug>AM_T<
map \T; <Plug>AM_T;
map \T: <Plug>AM_T:
map \Ts, <Plug>AM_Ts,
map \T, <Plug>AM_T,o
map \T# <Plug>AM_T#
map \T| <Plug>AM_T|
map \Htd <Plug>AM_Htd
map \anum <Plug>AM_aunum
map \aenum <Plug>AM_aenum
map \aunum <Plug>AM_aunum
map \afnc <Plug>AM_afnc
map \adef <Plug>AM_adef
map \adec <Plug>AM_adec
map \ascom <Plug>AM_ascom
map \aocom <Plug>AM_aocom
map \adcom <Plug>AM_adcom
map \acom <Plug>AM_acom
map \abox <Plug>AM_abox
map \a( <Plug>AM_a(
map \a= <Plug>AM_a=
map \a< <Plug>AM_a<
map \a, <Plug>AM_a,
map \a? <Plug>AM_a?
vmap ]% ]%m'gv``
vmap a% [%v]%
nmap cxx <Plug>(ExchangeLine)
nmap cxc <Plug>(ExchangeClear)
nmap cx <Plug>(Exchange)
nmap cs <Plug>Csurround
nmap ds <Plug>Dsurround
nnoremap <silent> gf yi"q:pIe %:h/A.coffee
nmap gx <Plug>NetrwBrowseX
xmap gS <Plug>VgSurround
nmap ySS <Plug>YSsurround
nmap ySs <Plug>YSsurround
nmap yss <Plug>Yssurround
nmap yS <Plug>YSurround
nmap ys <Plug>Ysurround
vmap zt <Plug>TranslateBlockText
map z] z[
map z> z<
map z) z(
map z} z{
vnoremap z  `>z 
nnoremap z  %%v%`>x`<x
vnoremap z< `>a>`<i<
vnoremap z` `>a``<i`
vnoremap z' `>a'`<i'
vnoremap z# `>a|`<i#
vnoremap z" `>a"`<i"
vnoremap z$ `>a$`<i$
vnoremap z[ `>a]`<i[
vnoremap z( `>a)`<i(
vnoremap z* `>a*`<i\*
vnoremap z{ `>a}`<i{
nnoremap zdo %%v%`<ido%%v%`>aend`>x`<x==
nnoremap z` %%v%`>r``<r`
nnoremap z' %%v%`>r'`<r'
nnoremap z" %%v%`>r"`<r"
nnoremap z< %%v%`>r>`<r<
nnoremap z$ %%v%`>r$`<r$
nnoremap z[ %%v%`>r]`<r[
nnoremap z( %%v%`>r)`<r(
nnoremap z{ %%v%`>r}`<r{
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
nnoremap <silent> <Plug>SurroundRepeat .
vnoremap <silent> <Plug>TranslateBlockText `<ma`>mb:call TranslateBlockText()`av`b"gp
nnoremap <silent> <Plug>TranslateBlockText :call TranslateBlockText()
nnoremap <silent> <F11> :call conque_term#exec_file()
nmap <silent> <Plug>RestoreWinPosn :call RestoreWinPosn()
nmap <silent> <Plug>SaveWinPosn :call SaveWinPosn()
nmap <SNR>39_WE <Plug>AlignMapsWrapperEnd
map <SNR>39_WS <Plug>AlignMapsWrapperStart
map <F3> :NERDTreeFind
map <C-F12> :e%:s?.cpp$?.h?
map <F12> :e%:s?.h$?.cpp?
map <F9> :!if [ -f Rakefile ]; then rake; else make; fi
map <F2> q/"*p
imap  <Del> dwi
imap S <Plug>ISurround
imap s <Plug>Isurround
imap  lWi
imap  <Plug>Isurround
inoremap = vBy`>a=="
inoremap <silent> OC <Right>
imap [3;5~ <Del> dwi
imap  [S1z=
inoreabbr lorem Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
let &cpo=s:cpo_save
unlet s:cpo_save
set autoindent
set autowrite
set background=dark
set backspace=indent,eol,start
set expandtab
set exrc
set fileencodings=utf-8,latin2
set grepprg=grep\ -nH\ $*
set helplang=en
set history=50
set hlsearch
set ignorecase
set incsearch
set isident=@,48-57,_,192-255,$
set mouse=a
set pastetoggle=<F11>
set path=.,/usr/include,,,src/compiler/**,src/**
set printoptions=paper:a4
set ruler
set runtimepath=~/.vim,~/.vim/bundle/AutoClose,~/.vim/bundle/HTML5-Syntax-File,~/.vim/bundle/Handlebars,~/.vim/bundle/TaskList.vim,~/.vim/bundle/ebnf.vim,~/.vim/bundle/eclipse.vim,~/.vim/bundle/plantuml-syntax,~/.vim/bundle/sketch.vim,~/.vim/bundle/sudo.vim,~/.vim/bundle/surround.vim,~/.vim/bundle/vim-blade,~/.vim/bundle/vim-exchange,~/.vim/bundle/vim-fugitive,~/.vim/bundle/vim-gf,~/.vim/bundle/vim-jade,~/.vim/bundle/vim-less,~/.vim/bundle/vim-mustache-handlebars,~/.vim/bundle/vim-pogoscript,~/.vim/bundle/vim-scala,~/.vim/bundle/vim-stylus,/var/lib/vim/addons,/usr/share/vim/vimfiles,/usr/share/vim/vim73,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/bundle/vim-scala/after,~/.vim/after,/usr/share/lilypond/2.12.3/vim/
set secure
set shiftwidth=4
set showcmd
set showmatch
set smartcase
set smarttab
set softtabstop=4
set spelllang=hu
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set suffixesadd=.coffee
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Dropbox/funcss
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +2 src/compiler.coffee
badd +1 test/compiler_test.coffee
badd +3 test/compiler/funcss_test.coffee
badd +2 src/compiler/generator.coffee
badd +1 src/compiler/semantics.coffee
badd +1 src/compiler/syntax.coffee
badd +1 src/compiler/generator/optimizer.coffee
badd +1 src/compiler/helpers/stream.coffee
badd +15 src/compiler/semantics/cascade.coffee
badd +7 src/compiler/semantics/selectors.coffee
badd +1 src/compiler/semantics/values/type_nodes.coffee
badd +100 src/compiler/semantics/values/vds.coffee
badd +2 src/compiler/syntax/parser.coffee
badd +36 src/compiler/syntax/tokenizer.coffee
badd +7 test/bdd.coffee
badd +5 test/compiler/parser_test.coffee
badd +4 test/compiler/ssjs_test.coffee
badd +5 test/compiler/stylesheet_test.coffee
badd +2 test/compiler/tokenizer_test.coffee
badd +1 test/compiler/types_test.coffee
badd +5 test/compiler/vds_test.coffee
badd +2 test/compiler/walk_test.coffee
badd +5 tmp/vds-additional-params.coffee
badd +1 src/compiler/semantics/values.coffee
badd +1 src/compiler/semantics/values/tp_nodes.coffee
badd +1 src/compiler/semantics/values/../../syntax/ss_nodes.coffee
badd +0 bdd/stylesheet/simple_stylesheet.fcss
badd +1 src/compiler/semantics/selectors/sl_nodes.coffee
silent! argdel *
edit src/compiler.coffee
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
exe 'vert 1resize ' . ((&columns * 31 + 70) / 141)
exe 'vert 2resize ' . ((&columns * 109 + 70) / 141)
argglobal
enew
file NERD_tree_1
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal nobuflisted
setlocal buftype=nofile
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
setlocal cursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'nerdtree'
setlocal filetype=nerdtree
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=tcq
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal nomodifiable
setlocal nrformats=octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=4
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=4
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=hu
setlocal statusline=%{exists('b:NERDTreeRoot')?b:NERDTreeRoot.path.str():''}
setlocal suffixesadd=
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'nerdtree'
setlocal syntax=nerdtree
endif
setlocal tabstop=8
setlocal tags=~/Dropbox/funcss/.git/tags,./tags,./TAGS,tags,TAGS
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal winfixwidth
setlocal nowrap
setlocal wrapmargin=0
wincmd w
argglobal
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=Error:\ In\ %f\\,\ %m\ on\ line\ %l,Error:\ In\ %f\\,\ Parse\ error\ on\ line\ %l:\ %m,SyntaxError:\ In\ %f\\,\ %m,%-G%.%#
setlocal expandtab
if &filetype != 'coffee'
setlocal filetype=coffee
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=GetCoffeeIndent(v:lnum)
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e,0],0),0.,=else,=when,=catch,=finally
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=coffee\ -c\ \ $*\ src/compiler.coffee
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=javascriptcomplete#CompleteJS
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=2
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=4
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=hu
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'coffee'
setlocal syntax=coffee
endif
setlocal tabstop=8
setlocal tags=~/Dropbox/funcss/.git/coffee.tags,~/Dropbox/funcss/.git/tags,./tags,./TAGS,tags,TAGS
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 5 - ((4 * winheight(0) + 17) / 35)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
5
normal! 021l
wincmd w
2wincmd w
exe 'vert 1resize ' . ((&columns * 31 + 70) / 141)
exe 'vert 2resize ' . ((&columns * 109 + 70) / 141)
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
