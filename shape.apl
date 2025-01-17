⎕IO←0
⎕PW←12345

'dec' 'disp' 'displays'⎕CY'dfns'

Load←{
	tie←⍵ ⎕NTIE 0
	data←¯1≠(124 877 3⍴⎕NREAD tie 83 ¯1)[;;0]
	_←⎕NUNTIE tie
	data
}

Split←{
	⍝ data ←⍉⍪0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	⍝ data⍪←  1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1 0 0
	⍝ data⍪←  1 0 0 0 0 1 0 0 0 1 1 1 0 0 0 0 0 0
	⍝ data⍪←  1 0 0 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1
	⍝ data⍪←  1 0 1 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0
	⍝ data⍪←  1 1 1 0 1 1 1 1 0 0 0 0 0 0 0 1 0 0
	⍝ ⎕←' ⌸'[data]

	⍝ data ←⍉⍪0 0 0 0 0
	⍝ data⍪←  0 1 0 0 0
	⍝ data⍪←  0 0 0 0 0
	⍝ data⍪←  1 1 1 1 1
	⍝ data⍪←  0 0 0 0 0
	⍝ data⍪←  0 0 0 1 0

	⍝ TODO
	⍝ - [x] iterate over i,j pairs
	⍝ - [ ] do first row and column independently, avoid validity check for later rows

	data←⍵
	(h w)←⍴data
	p←(⍉w h⍴⍳h),⍤0⊢h w⍴⍳w
	_←{
		(i j)←⍵
		~data[i;j]: ⍵
		k←(i≥1)(j≥1)/(¯1 0)(0 ¯1)+¨⊂(i j)
		k/⍨←data[k]
		0=≢k: ⍵
		k←⌷∘p¨⍣≡k
		p[i;j;]←⊃k
		1=≢k: ⍵
		((1⊃k)⌷p)←⊃k
		⍵
	}⍤1⊢p
	p←,+/w 1×⍤1⊢p
	p←{p[⍵]}⍣≡p
	s←(,data)×1+p

	c←{⍵[⍋⍵]}∪s
	s←c⍳s
	m←↓s∘.=⍨1+⍳¯1+≢c
	i←w|⍸¨m
	min←⌊/¨i
	max←⌈/¨i
	_←m{(⍺/s)←⍵}¨1+⌊/⍤⍸⍤1(⊢∨∨.∧⍨)⍣≡∨∘⍉⍨(min∘.≥min)∧(max∘.≤max)∨min∘.≤min+0.5×max-min

	⍝ FIXME: not so much duplicate computation please
	c←{⍵[⍋⍵]}∪s
	s←c⍳s
	m←↓s∘.=⍨1+⍳¯1+≢c
	i←w|⍸¨m
	min←⌊/¨i
	max←⌈/¨i
	g←(0,0,⍨0⍪0⍪⍨⊢)¨(∨⌿⊢⍤/⊢)¨h w∘⍴¨m
	g←g[⍋min] ⍝ TODO: subsort by max
	g
}

Save←{
	glyphs←⍵
	{
		n←⍕⍵
		g←⍵⊃glyphs
		⎕←'writing' n
		name←n,'.gray'
		_←⎕SH 'touch ',name
		tie←name ⎕NTIE 0
		_←(-g) ⎕NREPLACE tie 0 83
		_←⎕NUNTIE tie
		_←⎕SH 'magick -depth 8 -size ',(' '⎕R'x'⍕⌽⍴g),' ',name,' ',n,'.png'
		_←⎕SH 'rm ',name
	}¨⍳≢glyphs
}

⍝ Save Split Load 'josh.rgb'

⍝ ttx -s BQN386.ttf
⍝ TODO:
⍝ - [ ] extract glyph data from ttx
⍝ - [ ] figure out what to do next

DepthToParent←{
    d←⍵
    p←⍳≢d
    _←2{p[⍵]←⍺[⍺⍸⍵]}/⊂⍤⊢⌸d
    p
}
(d e x kv t)←↓⍉⎕XML⊃⎕NGET'font/BQN386._c_m_a_p.ttx'
p←DepthToParent d
(u n)←↓⍉↑⊢/¨kv/⍨p=1⊃⍸p=1
⍝ ascii - `"` + `˙` + specials
cs←'!#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~˙λ∇⋄⍝⍺⍵¯×÷←↑→↓∆∊∘∧∨∩∪≠≡≢≤≥⊂⊃⊆⊖⊢⊣⊤⊥⌈⌊⌶⌷⎕⌸⌹⌺⌽⌿⍀⍉⍋⍎⍒⍕⍙⍟⍠⍣⍤⍥⍨⍪⍬⍱⍲⍳⍴⍷⍸○⍬⊇⍛⍢⍫√'
n←n[cs⍳⍨⎕UCS dec¨u]
⎕←{
	d e x kv t←↓⍉⎕XML⊃⎕NGET'font/BQN386._g_l_y_f.',⍵,'.ttx'
	p←DepthToParent d
	⍪{
		(x y on)←⍵
		m←2=/(⊢⍴⍨1+⍴)on
		i←⍸m
		x←(2÷⍨x[i]+x[(≢x)|i+1])@(1+(⊢+⍳⍤≢)i)⊢(m+1)/x
		y←(2÷⍨y[i]+y[(≢y)|i+1])@(1+(⊢+⍳⍤≢)i)⊢(m+1)/y
		on←(~on[i])@(1+(⊢+⍳⍤≢)i)⊢(m+1)/on ⍝ for sanity, should be 1 0 1 0 ... 1 0
		↑x y on
	}¨1↓kv{
		⊂↓⍉↑{(⊃1⊃⎕VFI)¨'-'⎕R'¯'¨⊢/⍵}¨⍵
	}⌸⍨p×p∊⍸'contour'∘≡¨e
}⊃'[A-Z]'⎕R'&_'¨n
