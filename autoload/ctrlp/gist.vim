if exists('g:loaded_ctrlp_gist') && g:loaded_ctrlp_gist
  finish
endif
let g:loaded_ctrlp_gist = 1

let s:gist_var = {
\  'init':   'ctrlp#gist#init()',
\  'exit':   'ctrlp#gist#exit()',
\  'accept': 'ctrlp#gist#accept',
\  'lname':  'gist',
\  'sname':  'gist',
\  'type':   'path',
\  'sort':   0,
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:gist_var)
else
  let g:ctrlp_ext_vars = [s:gist_var]
endif

function! s:format_gist(gist)
  let files = sort(keys(a:gist.files))
  if empty(files)
    return ""
  endif
  let file = a:gist.files[files[0]]
  if has_key(file, "content")
    let code = file.content
    let code = "\n".join(map(split(code, "\n"), '"  ".v:val'), "\n")
  else
    let code = ""
  endif
  return printf("%s %s%s", a:gist.id, type(a:gist.description)==0?"": a:gist.description, code)
endfunction

function! ctrlp#gist#init()
  let s:list = gist#list("mine")
  if s:list == []
    if !exists('g:github_user')
      let s:system = function(get(g:, 'webapi#system_function', 'system'))
      let g:github_user = substitute(s:system('git config --get github.user'), "\n", '', '')
      if strlen(g:github_user) == 0
        let g:github_user = $GITHUB_USER
      end
    endif
    let s:list = gist#list(g:github_user)
  endif
  return map(filter(s:list, '!empty(v:val.files)'), 's:format_gist(v:val)')
endfunc

function! ctrlp#gist#accept(mode, str)
	echo a:str
  let id = matchstr(filter(copy(s:list), 'v:val ==# a:str')[0], '^\d\+\ze')
  call ctrlp#exit()
  redraw!
  if len(id)
    exe "Gist" id
  endif
endfunction

function! ctrlp#gist#exit()
  if exists('s:list')
    unlet! s:list
  endif
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#gist#id()
  return s:id
endfunction

" vim:fen:fdl=0:ts=2:sw=2:sts=2
