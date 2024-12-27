⎕IO←0
⎕PW←12345

⍝ data ←⍉⍪0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
⍝ data⍪←  1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1 0 0
⍝ data⍪←  1 0 0 0 0 1 0 0 0 1 1 1 0 0 0 0 0 0
⍝ data⍪←  1 0 0 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1
⍝ data⍪←  1 0 1 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0
⍝ data⍪←  1 1 1 0 1 1 1 1 0 0 0 0 0 0 0 1 0 0

data ←⍉⍪0 0 0 0 0
data⍪←  0 1 0 0 0
data⍪←  0 0 0 0 0
data⍪←  1 1 1 1 1
data⍪←  0 0 0 0 0
data⍪←  0 0 0 1 0

tie←'josh.rgb' ⎕NTIE 0
data←¯1≠(124 877 3⍴⎕NREAD tie 83 ¯1)[;;0]
⎕NUNTIE tie

(h w)←⍴data
p←⍳×/⍴data
{
	~data[⌊⍵÷w;w|⍵]: ⍵
	(l u)←⍵+¯1,-w
	i←u,⍣(u≥0) ⊢ l,⍣(l=⍥(⌊÷∘w)⍵) ⊢ ⍬
	i/⍨←data[i(⌊⍤÷,¨|⍨)w]
	0=≢i: ⍵
	r←{p[⍵]}⍣≡i
	p[⍵,1↓r]←⊃r
	⍵
}¨p
p←{p[⍵]}⍣≡p
s←(,data)×1+p
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
	name←n,'.gray'
	_←⎕SH 'touch ',name
	tie←name ⎕NTIE 0
	_←(-⍵=s) ⎕NREPLACE tie 0 83
	_←⎕NUNTIE tie
	_←⎕SH 'magick -depth 8 -size 877x124 ',name,' ',n,'.png'
}¨∪s
