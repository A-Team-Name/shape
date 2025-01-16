⎕IO←0
⎕PW←12345

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

tie←'josh.rgb' ⎕NTIE 0
data←¯1≠(124 877 3⍴⎕NREAD tie 83 ¯1)[;;0]
⎕NUNTIE tie

⍝ TODO
⍝ - [x] iterate over i,j pairs
⍝ - [ ] do first row and column independently, avoid validity check for later rows

⍝ 'disp' 'displays' ⎕cy 'dfns'

(h w)←⍴data
p←(⍉w h⍴⍳h),⍤0⊢h w⍴⍳w
{
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
⍝ ⎕←h w⍴⍳h×w
⍝ ⎕←(⍴data)⍴s
⍝ ⎕←''
c←{⍵[⍋⍵]}∪s
s←c⍳s
⍝ ⎕←(⍴data)⍴('.',⎕A)[s]
⍝ ⎕←''
m←↓s∘.=⍨1+⍳¯1+≢c
i←w|⍸¨m
min←⌊/¨i
max←⌈/¨i
m{(⍺/s)←⍵}¨1+⌊/⍤⍸⍤1(⊢∨∨.∧⍨)⍣≡∨∘⍉⍨(min∘.≥min)∧(max∘.≤max)∨min∘.≤min+0.5×max-min
⍝ c←1↓∪s
⍝ ('.',⎕A)[(⊢(×⍤2)c∘.=⊢)s⍴⍨⍴data]
{
	n←⍕⍵
	⎕←'writing' n
	name←n,'.gray'
	_←⎕SH 'touch ',name
	tie←name ⎕NTIE 0
	_←(-⍵=s) ⎕NREPLACE tie 0 83
	_←⎕NUNTIE tie
	_←⎕SH 'magick -depth 8 -size 877x124 ',name,' ',n,'.png'
}¨∪s
