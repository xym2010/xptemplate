exec xpt#once#init

let s:oldcpo = &cpo
set cpo-=< cpo+=B

let s:log = xpt#debug#Logger( 'warn' )
let s:log = xpt#debug#Logger( 'debug' )

let g:EmptyFilter = {}

" rc:       1: right status. 0 means nothing should be updated.
let s:proto = {
      \ 'force'   : 0,
      \ }

fun! xpt#flt#New( nIndent, text, ... ) "{{{
    let flt = deepcopy( s:proto )

    " force:    force using this.
    call extend( flt, {
          \ 'nIndent' : a:nIndent,
          \ 'text'    : a:text,
          \ 'force'   : a:0 == 1 && a:1,
          \ }, 'force' )

    return flt

endfunction "}}}

fun! xpt#flt#NewSimple( nIndent, text, ... ) "{{{

    let flt = { 'nIndent' : a:nIndent, 'text' : a:text, }

    if a:0 == 1 && a:1
        let flt.force = 1
    endif

    return flt

endfunction "}}}

fun! xpt#flt#Extend( flt ) "{{{
    " no reference existed in s:proto, no need to deepcopy it
    call extend( a:flt, s:proto, 'keep' )
endfunction "}}}

fun! xpt#flt#Simplify( flt ) "{{{
    " -987654 is assumed to be an pseudo NONE value
    call filter( a:flt, 'v:val!=get(s:proto,v:key,-987654)' )
endfunction "}}}

fun! xpt#flt#Eval( flt, closures ) "{{{

    let r = { 'rc' : 1 }
    let rst = xpt#eval#Eval( a:flt.text, a:closures )

    call s:log.Debug( 'filter eval result=' . string( rst ) )

    if type( rst ) == type( 0 )

        let r.rc = 0

    elseif type( rst ) == type( '' )

        call extend( r, { 'action': 'build', 'text' : rst } )

    elseif type( rst ) == type( [] )

        call extend( r, { 'action' : 'pum', 'pum' : rst } )

    else
        " rst is dictionary

        if has_key( rst, 'action' )
            call extend( r, rst, 'error' )
        else
            r.action = 'build'
        endif

        " TODO fix cursor usage
        if has_key( r, 'cursor' )
            call xpt#flt#ParseCursorSpec( r )
        endif

    endif

    return r

endfunction "}}}

fun! xpt#flt#ParseCursorSpec( flt_rst ) "{{{

    let rst = a:flt_rst

    if type( rst.cursor ) == type( [] )
          \ && type( rst.cursor[ 0 ] ) == type( '' )

        " convert [ '<mark>', [ <offset> ] ] format to standard format

        let rst.cursor = { 'rel' : 1,
              \ 'where' : rst.cursor[ 0 ],
              \ 'offset' : get( rst.cursor, 1, [ 0, 0 ] ) }

    endif

    " TODO use has_key instead
    " TODO this is always true?
    let rst.isCursorRel = type( rst.cursor ) == type( {} )

endfunction "}}}

fun! s:AddIndentToPHs( flt ) "{{{

    if a:flt.rst.nIndent == 0
        return
    endif


    let nIndent = a:flt.rst.nIndent
    let rst = []

    for ph in a:flt.rst.phs
        if type( ph ) == type( '' )
            call add( rst, xpt#util#AddIndent( ph, nIndent ) )
        else
            call add( rst, ph )
        endif

        unlet ph
    endfor


    let a:flt.rst.phs = rst

endfunction "}}}

let &cpo = s:oldcpo