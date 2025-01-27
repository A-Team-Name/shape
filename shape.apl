⎕IO←0
⎕PW←12345

'dec' 'disp' 'displays'⎕CY'dfns'
'assign'⎕CY'dfns'
cs←'!#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~˙λ∇⋄⍝⍺⍵¯×÷←↑→↓∆∊∘∧∨∩∪≠≡≢≤≥⊂⊃⊆⊖⊢⊣⊤⊥⌈⌊⌶⌷⎕⌸⌹⌺⌽⌿⍀⍉⍋⍎⍒⍕⍙⍟⍠⍣⍤⍥⍨⍪⍬⍱⍲⍳⍴⍷⍸○⍬⊇⍛⍢⍫√'

Load←{
	⍝ ⍵: ⍬
	⍝ ←: bitarray
	tie←⍵ ⎕NTIE 0
	data←¯1≠(124 877 3⍴⎕NREAD tie 83 ¯1)[;;0]
	_←⎕NUNTIE tie
	data
}

Split←{
	⍝ ⍵: bitarray to split
	⍝ ←: list of split bitarrays

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
	⍝ ⍵: list of bitarrays to save
	⍝ ←: ⍬

	glyphs←⍵
	{
		n←⍕⍵
		g←⍵⊃glyphs
		⍝ ⎕←'writing' n
		name←n,'.gray'
		_←⎕SH 'touch ',name
		tie←name ⎕NTIE 0
		_←(-g) ⎕NREPLACE tie 0 83
		_←⎕NUNTIE tie
		_←⎕SH 'magick -depth 8 -size ',(' '⎕R'x'⍕⌽⍴g),' ',name,' ',n,'.png'
		_←⎕SH 'rm ',name
	}¨⍳≢glyphs
}

Loot←{
	⍝ ⍵: ⍬
	⍝ ←: list of curve sets each with shape 2 (x y) × 3 (start control end) × n (number of curves)

	⍝ ttx -s BQN386.ttf # for ttx files
	D2P←{
		d←⍵
		p←⍳≢d
		_←2{p[⍵]←⍺[⍺⍸⍵]}/⊂⍤⊢⌸d
		p
	}
	(d e x kv t)←↓⍉⎕XML⊃⎕NGET'font/BQN386._c_m_a_p.ttx'
	p←D2P d
	(u n)←↓⍉↑⊢/¨kv/⍨p=1⊃⍸p=1
	⍝ ascii - `"` + `˙` + `λ` + apl/bqn specials
	n←n[cs⍳⍨⎕UCS dec¨u]
	{
		(d e x kv t)←↓⍉⎕XML⊃⎕NGET'font/BQN386._g_l_y_f.',⍵,'.ttx'
		p←D2P d
		⊃,/{
			(x y on)←⍵
			m←2=/(⊢⍴⍨1+⍴)on
			i←⍸m
			x←(2÷⍨x[i]+x[(≢x)|i+1])@(1+(⊢+⍳⍤≢)i)⊢(m+1)/x
			y←(2÷⍨y[i]+y[(≢y)|i+1])@(1+(⊢+⍳⍤≢)i)⊢(m+1)/y
			on←(~on[i])@(1+(⊢+⍳⍤≢)i)⊢(m+1)/on ⍝ should be 1 0 1 0 ... 1 0
			x←⍉(⊢⍴⍨3,⍨3÷⍨⍴)1⌽(on+1)/x
			y←⍉(⊢⍴⍨3,⍨3÷⍨⍴)1⌽(on+1)/y
			↑x y
		}¨1↓kv{
			⊂↓⍉↑{(⊃1⊃⎕VFI)¨'-'⎕R'¯'¨⊢/⍵}¨⍵
		}⌸⍨p×p∊⍸'contour'∘≡¨e
	}¨'[A-Z]'⎕R'&_'¨n
}

Distribute←{
	⍝ ⍺: number of points to distribute
	⍝ ⍵: curve set with shape 2 (x y) × 3 (start control end) × n (curves)
	⍝ ←: points matrix with shape 2 (x y) × ⍺

	⍝ https://raphlinus.github.io/curves/2018/12/28/bezier-arclength.html
	⍝ for now we do the very simple estimate
	a←  .5*⍨+⌿×⍨ -⌿⍤2⊢⍵[;2 0;]
	b←+⌿.5*⍨+⌿×⍨2-⌿⍤2⊢⍵
	l←a+2×b
	n←⊃{⍵@⍺⊢0⍴⍨≢l}/↓⍉{⍺,≢⍵}⌸1+(+\l)⍸⍺÷⍨(+/l)×⍳⍺ ⍝ could be a way to do this that uses less space idk
	t←n+\⍤⍴¨÷n⌈n=0
	t←↑(1-t) t
	a←     +⌿⍤2⊢t×⍤2⊢⍵[;0 1;]
	b←     +⌿⍤2⊢t×⍤2⊢⍵[;1 2;]
	(⊃,/)⍤1+⌿⍤2⊢t×⍤2⊢1 0 2⍉↑a b
}

Contexts←{
	⍝ ⍺[0]: number of distance bins
	⍝ ⍺[1]: number of angle bins
	⍝ ⍵: points matrix with shape 2 (x y) × n
	⍝ ←: n×⍺[0]×⍺[1] array of shape contexts

	⍺←5 12
	(rb tb)←⍺
	⍝ potential optimisation: only do triangle
	⍝ TODO: eliminate self
	d←-⍨⍤0 1⍨⍤1⊢⍵ ⍝ TODO: this can just be a ∘.-⍨⍤1 no?
	r←⍟(⊢∨0=⊢).5*⍨+⌿×⍨d
	t←(12○⊣+0J1×⊢)⌿d ⍝ https://aplcart.info?q=atan2
	i  ←1+r⍸⍨(⌈/∊r)×(⍳÷   ⊢)rb-1
	i,¨←  t⍸⍨○¯1+   (⍳÷.5×⊢)tb
	{
		h←rb tb⍴0
		h[⍵]+←1
		h
	}⍤1⊢i
}

EdgePoints←{
	⍝ ⍺: maximum number of edgepoints to pick (default 100)
	⍝ ⍵: bit array to find edgepoints on
	⍝ ←: 2×_ array of edgepoint coords

	⍝ potential improvement: also check diagonal corners so we have more points
	⍺←100
	p←1 ¯1×⍤0 1⍉⌽↑⍸⍵∧⊃∨/⍵∘≠¨(1⊖⍵) (¯1⊖⍵) (1⌽⍵) (¯1⌽⍵)
	⍺>1⊃⍴p: p
	p[;{⍵[⍋⍵]}⍺?1⊃⍴p]
}

⍝ ⎕←displays Contexts ↑(¯1 0 1 ¯1 0 1 ¯1 0 1)(1 1 1 0 0 0 ¯1 ¯1 ¯1)

⍝ ⎕←'import matplotlib.pyplot as plt'
⍝ {
⍝ 	⎕←'plt.scatter('
⍝ 	⎕←'[0-9-,.]+'⎕R'[&],'⊢⍵⎕CSV⊂''
⍝ 	⎕←')'
⍝ 	⎕←'plt.show()'
⍝ }¨100 Distribute¨ Loot ⍬

font ←Contexts¨ 100 Distribute¨ Loot ⍬
input←Contexts¨ 100 EdgePoints¨ Split Load 'josh.rgb'

⍝ greedy matching algorithm
⍝ ⎕←⍉'{(+⌿⍵)÷≢⍵}'{⍺,' ',⍵}⍤0 1⊢cs[(10↑⍋)⍤1⊢input∘.{
⍝ 	c←.5×+/+/⍺(×⍨⍤-÷+)⍤2⍤2 3⊢⍵
⍝ 	+/{
⍝ 		i←(⊢⍳⌊/),c
⍝ 		j←⌊i÷1⊃⍴c
⍝ 		k←i|⍨1⊃⍴c
⍝ 		w←c[j;k]
⍝ 		c⌿⍨←~(0⊃⍴c)↑⍸⍣¯1,j
⍝ 		c/⍨←~(1⊃⍴c)↑⍸⍣¯1,k
⍝ 		w
⍝ 	}¨⍳≢c
⍝ }font]

⍝ hungarian matching (everyone say thank you John Scholes)
⎕←⍉'{(+⌿⍵)÷≢⍵}'{⍺,' ',⍵}⍤0 1⊢cs[(10↑⍋)⍤1⊢input∘.{(+/⍤2⊢×assign).5×+/+/⍺(×⍨⍤-÷+)⍤2⍤2 3⊢⍵}font]

⍝ TODO:
⍝ - [ ] matching visualisations
⍝ - [ ] consider difference in tangent angle between points
⍝ - [ ] store contours separately and only allow matchings between shapes with the same number of countours

