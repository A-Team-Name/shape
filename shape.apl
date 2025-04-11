⎕IO←0
⎕PW←12345

'dec' 'disp' 'displays'⎕CY'dfns'
'assign'⎕CY'dfns'

Atan2←12○⊣+0J1×⊢ ⍝ x Atan2 y | https://aplcart.info?q=atan2

Load←{
	⍝ ⍺: input shape
	⍝ ⍵: input path
	⍝ ←: bitarray
	tie←⍵ ⎕NTIE 0
	data←0≤(⍺⍴⎕NREAD tie 83 ¯1)
	_←⎕NUNTIE tie
	data
}

Split←{
	⍝ ⍵: bitarray to split
	⍝ ←: list of split bitarrays

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
	⍝ ⍵: size of bins
	⍝ ←: ≢⍵ length vector, giving number of points in each bin
	l←⍵
	⊃{⍵@⍺⊢0⍴⍨≢l}/↓⍉{⍺,≢⍵}⌸1+(+\l)⍸⍺÷⍨(+/l)×⍳⍺
}

DistributeOverCurves←{
	⍝ ⍺: number of points to distribute
	⍝ ⍵: curve set with shape 2 (x y) × 3 (start control end) × n (curves)
	⍝ ←: (a b c) where
	⍝    a: points matrix with shape 2 (x y) × ⍺
	⍝    b: angles vector with shape ⍺
	⍝    c: number of contours

	⍺←100
	⍝ https://raphlinus.github.io/curves/2018/12/28/bezier-arclength.html
	⍝ for now we do the very simple estimate
	a←  .5*⍨+⌿×⍨ -⌿⍤2⊢⍵[;2 0;] ⍝ length start → end
	b←+⌿.5*⍨+⌿×⍨2-⌿⍤2⊢⍵        ⍝ length start → control → end
	l←a+2×b                    ⍝ approx length
	n←⍺ Distribute l           ⍝ number of points on each curve roughly even, could be a way to do this that uses less space idk
	t←n+\⍤⍴¨÷n⌈n=0             ⍝ timesteps for each curve
	t←↑(1-t) t                 ⍝ and also complementary timesteps
	⍝             ┌─a─────────┐  ┌─b─────────┐ (new a and b)
	⍝ B(t) = (1-t)((1-t)P0+tP1)+t((1-t)P1+tP2)
	⍝         ┌────────│──┴│──────────│──┘│
	⍝         │     ┌──┴───┴──────────┴───┘
	⍝         ├──┐ ┌┴─┐
	a ←       +⌿⍤2⊢t×⍤2⊢⍵[;0 1;]
	b ←       +⌿⍤2⊢t×⍤2⊢⍵[;1 2;]
	xy←(⊃,/)⍤1+⌿⍤2⊢t×⍤2⊢1 0 2⍉↑a b
	⍝ B'(t) = 2(1-t)(P1-P0)+2t(P2-P1)
	m←+∘(○0>⊢)⍨Atan2⌿+⌿⍤2(⊃,/)⍤1⊢t×⍤2⊢2×¯2-⌿⍤2⊢⍵ ⍝ normalised to >0
	xy m (2⊃⍴⍵)
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
	t←Atan2⌿d
	i  ←1+r⍸⍨(⌈/∊r)×(⍳÷   ⊢)rb-1
	i,¨←  t⍸⍨○¯1+   (⍳÷.5×⊢)tb
	{
		h←rb tb⍴0
		h[⍵]+←1
		h
	}⍤1⊢i
}

EdgePoints←{
	⍝ ⍺: number of edgepoints to pick (default 100)
	⍝    if ⍺ > points in the image, there will be duplicate points
	⍝ ⍵: bit array to find edgepoints on
	⍝ ←: (a b c) where
	⍝    a: points matrix with shape 2 (x y) × ⍺⋯)
	⍝    b: angles vector with shape ⍺
	⍝    c: number of contours

	⍺←100

	⍝ ⍝ potential improvement: also check diagonal corners so we have more points
	⍝ p←1 ¯1×⍤0 1⍉⌽↑⍸⍵∧⊃∨/⍵∘≠¨(1⊖⍵) (¯1⊖⍵) (1⌽⍵) (¯1⌽⍵)
	⍝ ⍺>1⊃⍴p: p
	⍝ p[;{⍵[⍋⍵]}⍺?1⊃⍴p]
	
	⍝ assumptions: we can always take a 3×3 window, and loops always close (no single-pixel wide chunks)
	b←⍵
	p←⍸⍵∧⊃∨/⍵∘≠¨(1⊖⍵) (¯1⊖⍵) (1⌽⍵) (¯1⌽⍵) ⍝ all edge points
	c←⍬                  ⍝ contours list
	ci←¯1+0×b            ⍝ contours list indices
	pi←2(⊢,¨⌽)1(⊢+⌽)3<⍳8 ⍝ indices of perimeter of the square
	_←{
		⍺←{ ⍝ current contour (create if none)
			a←⍵⌷ci
			a≠¯1: a
			c,←⊂2 0⍴⍬
			¯1+≢c
		}⍵
		(⍺⊃c),←⍪⍵
		(i j)←⍵
		ci[i;j]←⍺
		(i j)←⍵+¯1+pi⊃⍨8|1+⊃⍸2</9⍴b[¯1 0 1+i;¯1 0 1+j][pi] ⍝ indices of the next point
		ci[i;j]≠¯1: ⍺ ⍝ loop complete
		⍺∇i j         ⍝ continue on next point around the curve, tco babyy
	}¨p
	c←c{⍺[;⌊⍵÷⍨(1⊃⍴⍺)×⍳⍵]}¨⍺ Distribute (1⊃⍴)¨c ⍝ pick points from contour
	c←{1 ¯1×⍤0 1⊖⍵}¨c ⍝ i j → x y
	m←{
		n←1⊃⍴⍵
		n<3: n⍴0 ⍝ not enough points to get gradients
		+∘(○0>⊢)⍨Atan2⌿-/⍵[;n|(⍳n)∘.+¯1 1]
	}¨c
	(⊃,/c) (⊃,/m) (≢c)
}

⍝ character set
⍝ ascii - `"` + `˙` + `λ` + apl/bqn specials
⍝ cs←'!#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~˙λ∇⋄⍝⍺⍵¯×÷←↑→↓∆∊∘∧∨∩∪≠≡≢≤≥⊂⊃⊆⊖⊢⊣⊤⊥⌈⌊⌶⌷⎕⌸⌹⌺⌽⌿⍀⍉⍋⍎⍒⍕⍙⍟⍠⍣⍤⍥⍨⍪⍬⍱⍲⍳⍴⍷⍸○⍬⊇⍛⍢⍫√'
cs←'λ.()abcdefghijklmnopqrstuvwxyz'
⍝ cs←'λ.()fx'
 
⍝ logging utils
time←¯1 20⎕dt⊂⎕ts
Log←{⎕←(30↑⍵) (time-⍨¯1 20⎕DT⊂⎕TS)}

⍝ === OBTAIN SHAPE CONTEXTS ===
np  ←50    ⍝ number of points to sample from the edges of a shape
bins←5 12  ⍝ number of radial and angle bins
input←⎕JSON⎕OPT'Dialect' 'JSON5'⊃⎕NGET'shape-contexts.json5' ⍝ input specification

⍝ (coords bearings ncontours) for each glyph
 fontPoints←np DistributeOverCurves¨ Loot ⍬
inputPoints←np EdgePoints¨           Split input.size Load input.path

⍝ (nglyphs npoints bins[0] bins[1])
 font←(Contexts⍤⊃⍤⊃)⍤0⊢ fontPoints
input←(Contexts⍤⊃⍤⊃)⍤0⊢inputPoints

⍝ === SHORTLIST WITH REPRESENTATIVE SHAPE CONTEXTS ===
nr←10                ⍝ number of representative points to select
ns←5                 ⍝ number of font glyphs to shortlist
reps←input[;nr?np;;] ⍝ representative points

⍝ ⎕←2⎕NQ'.' 'GetEnvironment' 'MAXWS'

⍝ expand the contexts to shape (ninputglyphs nfontglyphs nreps npoints bins[0] bins[1])
sh←⍴reps ⋄ bigReps←(≢font)⌿⍤5⊢np⌿⍤3⊢reps⍴⍨sh[0],1    ,sh[1],1    ,sh[2 3]
sh←⍴font ⋄ bigFont←(≢reps)⌿⍤6⊢nr⌿⍤4⊢font⍴⍨1    ,sh[0],1    ,sh[1],sh[2 3]

⍝                                    SHAPE                                    NOTE
c  ←.5×+/+/bigReps(×⍨⍤-÷+)bigFont ⍝ (ninputglyphs nfontglyphs nreps npoints) matching costs
d  ←⌊/c                           ⍝ (ninputglyphs nfontglyphs nreps)         smallest d_GSC
nu ←(≢font)÷⍨+⌿⍤2⊢d               ⍝ (ninputglyphs nreps)                     normalisation factor N_u
d ÷←(≢font)⌿⍤2⊢nu⍴⍨(≢reps),1 nr   ⍝ (ninputglyphs nfontglyphs nreps)         normalised distances
k  ←⌊nr÷2                         ⍝                                          number of RSCs to consider
d  ←k÷⍨+/{⍵[k↑⍋⍵]}⍤1⊢d            ⍝ (ninputglyphs nfontglyphs)               representative distances between inputs and fonts
i  ←(ns↑⍋)⍤1⊢d                    ⍝ (ninputglyphs nshortlist)                shortlists for each input glyph

⍝ === DETAILED MATCHIING ON SHORTLIST ===

⍝ expand contexts to shape (ninputglyphs nshortlist npoints npoints bins[0] bins[1])
sh←⍴input ⋄ bigInput←np⌿⍤3⊢                      ns⌿⍤5⊢input⍴⍨sh[0],1    ,sh[1],1    ,sh[2 3]
sh←⍴font  ⋄ bigFont ←np⌿⍤4⊢i{⍵[⍺;;;;]}⍤1 5⊢(≢input)⌿⍤6⊢font ⍴⍨1    ,sh[0],1    ,sh[1],sh[2 3]
⍝                          └──shortlist──┘

⍝ detailed matching
c←.5×+/+/bigInput(×⍨⍤-÷+)bigFont ⍝ (ninputglyphs nshortlist npoints npoints) point-point matching costs
c←{+/+/⍵×assign ⍵}⍤2⊢c           ⍝ (ninputglyphs nshortlist)                 glyph-glyph matching costs
⎕←⍉cs[i{⍺[⍋⍵]}⍤1⊢c]

⎕off
⍝ junk lies below...

sh←npoints,npoints,bins
Cost←{
	p←⍺
	q←⍵
	contexts←p{.5×+/+/(1 0 2 3⍉sh⍴⍺)(×⍨⍤-÷+)sh⍴⍵}⍥(bins∘Contexts⊃)q
	angles←|p∘.-⍥(1∘⊃)q ⍝ TODO: better notion of angle distance from wikipedia
	c←0.9 0.1(⊃+.×)(⊢÷⌈/⍣2)¨contexts angles ⍝ weighted sum of angles and contexts

	(jj kk)←⍳¨⍴c
	m ←¯1⍴⍨≢c ⍝ the matching
	wm←¯1⍴⍨≢c ⍝ matching weights

	⍝ costs of matching points
	⍝ +/+/c×assign c ⍝ everybody say thank you John Scholes
	⍝ greedy matching (sacrifice accuracy for speed)
	ws←{
		i←(⊢⍳⌊/),c
		j←⌊i÷1⊃⍴c
		k←i|⍨1⊃⍴c
		w←c[j;k]
		 m[jj[j]]←kk[k]
		wm[jj[j]]←w
		m←~(0⊃⍴c)↑⍸⍣¯1,j ⍝ new m: mask
		c ⌿⍨←m
		jj/⍨←m
		m←~(1⊃⍴c)↑⍸⍣¯1,k
		c /⍨←m
		kk/⍨←m
		w
	}¨⍳≢c

	⍝ visualising matchings
	(⊃p)-⍤1 0←⌊/⊃p
	(⊃p)÷⍤1 0←⌈/⊃p
	(⊃q)-⍤1 0←⌊/⊃q
	(⊃q)÷⍤1 0←⌈/⊃q
	wm÷←⌈/wm
	py←'import matplotlib.pyplot as plt;'
	_←{py,←'¯'⎕R'-'⊢'plt.plot([',(⍕(⊃p)[0;⍵]),',',(⍕(⊃q)[0;m[⍵]]),'], [',(⍕(⊃p)[1;⍵]),',',(⍕(⊃q)[1;m[⍵]]),'], "o-", c = (',(⍕wm[⍵]),', 0, ',(⍕1-wm[⍵]),'));'}¨⍳≢m
	py,←'plt.show()'
	⎕SH 'python3 -c ''',py,''''

	+/ws
}
⍝ cost←.1 .9(⊃+.×)(⊢÷⌈/⍣2)¨(|input∘.-⍥(2∘⊃¨)font)(input ∘.Cost font)
cost←input ∘.Cost font
⍝ Log 'done matching'

⍝ (⍪'{(+⌿⍵)÷≢⍵}'),' ',
⎕←⍉cs[(10↑⍋)⍤1⊢cost]

⍝ TODO:
⍝ - [x] matching visualisations
⍝ - [x] consider difference in tangent angle between points
⍝ - [x] normalisation and weighting
⍝ - [x] fast pruning with representative contexts
⍝ - [x] round it out
⍝ - [ ] gsc: tangent in bins
⍝ - [ ] basic thin-plate splines

⍝ - [ ] regularised tps
⍝ - [ ] improve distribution of points over bezier curve
⍝ - [ ] lambda calc tests
⍝ - [ ] more accurate angles from edgepoints (least squares?)
⍝ - [ ] draw from more fonts
⍝ - [ ] fast pruning with shapemes??
⍝ - [ ] gaussian windows

