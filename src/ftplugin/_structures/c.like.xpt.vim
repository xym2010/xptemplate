XPTemplate priority=like


XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $BRACKETSTYLE  \ 
XPTvar $INDENT_HELPER /* void */;

" containers
let [s:f, s:v] = XPTcontainer() 





" ========================= Function and Varaibles =============================
" fun! s:f.c_enum_next(ptn) dict
  " let v = self.V()
  " if v == a:ptn
    " return ''
  " else
    " return ",\n  elt"
  " endif
" endfunction

" ================================= Snippets ===================================
XPTemplateDef

XPT enum hint=enum\ {\ ..\ }
XSET var..|post=Echo( V() =~ 'var..$' ? '' : V() )
enum `name^
{
    `elt^`
    `more...{{^,
    `elt^`
    `more...^`}}^
}` `var^;
..XPT

XPT en hint=enum\ {\ ..\ }
enum `name^
{
    `elt^`
    `...{{^,
    `elt^`
    `...^`}}^
};


XPT struct hint=struct\ {\ ..\ }
struct `structName^
{
    `type^ `field^;`
    `...^
    `type^ `field^;`
    `...^
}` `var^^;


XPT bitfield hint=struct\ {\ ..\ :\ n\ }
struct `structName^
{
    `type^ `field^ : `bits^;`
    `...^
    `type^ `field^ : `bits^;`
    `...^
}` `var^^;





