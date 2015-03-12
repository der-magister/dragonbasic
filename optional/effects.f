{ -- MF/TIN EFFECTS functions
  -- Original code by Jeff Massung, 2003 }

\ set or clear the mosaic bit for a background
code-thumb mosaictiles ( bg flag -- )
	w pop
	
	\ move to REG_BGxCNT
	$40 ## v2 mov,
	20 ## v2 v2 lsl,	\ REGISTERS
	1 ## tos tos lsl,
	8 ## tos add,
	
	\ set or reset bit in REG_BGxCNT
	v2 tos +( v1 ldrh,
	$40 ## v0 mov,
	v0 v1 bic,
	0 ## w cmp,
	4 #offset eq? b,
	v0 v1 orr,
	v2 tos +( v1 strh,
	
	\ done
	tos pop
	ret
end-code

\ set or reset the sprite mosaic bit of a sprite
code-thumb spritemosaic ( sprite flag -- )
	w pop
	
	\ address of sprite
	$30 ## v2 mov,
	20 ## v2 v2 lsl,	\ IWRAM
	3 ## w w lsl,
	v2 w w add,
	
	\ load and clear or set
	w 0@ v0 ldrh,
	$10 ## v1 mov,
	8 ## v1 v1 lsl,		\ $1000
	v1 v0 bic,
	0 ## tos cmp,
	4 #offset eq? b,
	v1 v0 orr,
	w 0@ v0 strh,
	
	\ done
	tos pop
	ret
end-code

\ set parameters of mosaic effect
code-thumb mosaic ( bgx bgy objx objy -- )
	v0 v1 v2 pop

	\ sprite
	12 ## tos tos lsl,
	8 ## v0 v0 lsl,
	v0 tos orr,
	
	\ bg
	4 ## v1 v1 lsl,
	v1 tos orr,
	v2 tos orr,
	
	\ set
	$40 ## v0 mov,
	20 ## v0 v0 lsl,	\ REGISTERS
	v0 $4c #( tos str,

	\ done
	tos pop
	ret
end-code

\ fade the screen black
code-thumb fadeout ( -- )
	$4000050 w LITERAL	\ REGISTERS + $50
	
	\ REG_BLDCNT = $EF
	$ef ## v0 mov,
	w 0@ v0 strh,		\ REGISTERS + $50
	
	\ Loop v1 = 0-15
	0 ## v1 mov,
	
	l: __loop
	
	\ REG_COLEY = v1
	w $4 #( v1 strh,	\ REGISTERS + $54
	1 ## v1 v1 add,
	
	\ Wait for a vertical blank (160)
	$50 ## w sub,		\ REGISTERS
	l: __wait
	w 6 #( v2 ldrh,		\ REGISTERS + $6
	160 ## v2 cmp,
	__wait ne? b,
	
	\ Wait for a vertical blank (159)
	l: __wait
	w 6 #( v2 ldrh,		\ REGISTERS + $6
	159 ## v2 cmp,
	__wait ne? b,
	
	$50 ## w add,		\ REGISTERS + $50

	\ Loop 16 times
	$10 ## v1 cmp,
	__loop le? b,
	
	ret
end-code

\ fade the screen in
code-thumb fadein ( -- )
	$4000050 w LITERAL	\ REGISTERS + $50
	
	\ REG_BLDCNT = $EF
	$ef ## v0 mov,
	w 0@ v0 strh,		\ REGISTERS + $50
	
	\ Loop v1 = 0-15
	0 ## v1 mov,
	
	l: __loop
	
	\ REG_COLEY = 16-v1
	$10 ## v0 mov,
	v1 v0 a sub,
	w $4 #( a strh,		\ REGISTERS + $54
	1 ## v1 v1 add,
	
	\ Wait for a vertical blank (160)
	$50 ## w sub,		\ REGISTERS
	l: __wait
	w 6 #( v2 ldrh,		\ REGISTERS + $6
	160 ## v2 cmp,
	__wait ne? b,
	
	\ Wait for a vertical blank (159)
	l: __wait
	w 6 #( v2 ldrh,		\ REGISTERS + $6
	159 ## v2 cmp,
	__wait ne? b,
	
	$50 ## w add,		\ REGISTERS + $50

	\ Loop 16 times
	$10 ## v1 cmp,
	__loop le? b,
	
	ret
end-code
