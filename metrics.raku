sub lev(@a, @b) {
	return +@b                                 if @a == 0;
	return +@a                                 if @b == 0;
	return lev(@a.tail(* - 1), @b.tail(* - 1)) if @a[0] eq @b[0];
	1 + min(
		lev(@a.tail(* - 1), @b            ),
		lev(@a,             @b.tail(* - 1)),
		lev(@a.tail(* - 1), @b.tail(* - 1)),
	)
}

# https://github.com/thundergnat/Text-Levenshtein/blob/master/lib/Text/Levenshtein.pm6
sub distance ($s, *@t) {
    my $n = $s.chars;
    my @result;

    for @t -> $t {
        @result.push(0)  and next if $s eq $t;
        @result.push($n) and next unless my $m = $t.chars;
        @result.push($m) and next unless $n;

        my @d;

        map { @d[$_; 0] = $_ }, 1 .. $n;
        map { @d[0; $_] = $_ }, 0 .. $m;

        for 1 .. $n -> $i {
            my $s_i = $s.substr($i-1, 1);
            for 1 .. $m -> $j {
                @d[$i; $j] = min @d[$i-1; $j] + 1, @d[$i; $j-1] + 1,
                  @d[$i-1; $j-1] + ($s_i eq $t.substr($j-1, 1) ?? 0 !! 1)
            }
        }
        @result.push: @d[$n; $m];
    }
    @result
}

sub MAIN(
	Str:D $dataset where * ~~ 'lc'|'apl'
) {
	my @metrics = gather {
		for
			"test-data/$dataset/metadata.csv".IO.lines.skip>>.split(',')
		-> ($image, $truth) {
			my $proc;
			note $image, ' ', $truth;
			my $size =
				(run <<magick identify -ping -format '[%h,%w]' "test-data/$dataset/$image">>, :out)
				.out
				.slurp: :close
			;
			my $gray = $image.subst: '.png', '.gray';
			run <<magick "test-data/$dataset/$image" "test-data/$dataset/$gray">>;
			my $json = "\{
				size:     $size,
				path:     'test-data/$dataset/$gray',
				alphabet: '$dataset',
			\}";
			spurt 'shape-contexts.json5', $json;
			$proc = run <dyalogscript shape.apl>, :out;
			next if $proc.exitcode != 0;
			my @predictions = $proc.out.slurp(:close).split("\r");
			@predictions>>.note;
			my $top1 = $truth eq @predictions[0];
			my $top3 = [&&] ($truth.comb Z(elem) [Z] @predictions[0, 1, 2]>>.comb);
			my $cer = distance(@predictions[0], $truth)[0] / $truth.chars;
			note $top1, $top3, $cer;
			take $top1, $top3, $cer;
		}
	}
	say ([Z+] @metrics) >>/>> +@metrics;
}
