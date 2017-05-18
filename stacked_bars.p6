use Terminal::ANSIColor;

my @partial_blocks = flat " ",
    ("LEFT " <<~<<
    "ONE EIGHTH, ONE QUARTER, THREE EIGHTHS, HALF, FIVE EIGHTHS, THREE QUARTERS, SEVEN EIGHTHS".split(", ") >>~>>
    " BLOCK").join(", ").parse-names.comb;

my @colors = |("green", "yellow", "red", "blue", "magenta") xx *;

sub stacked_bars(@percentages, @cols = @colors, :$width = 15) {
    my @parts = ($width <<*<< @percentages)>>.round(0.01);
    my @cumulative = [\+] @parts;
    # Split the bars among lines, because we can only have one split line per character in the terminal
    my @splitpoints = @cumulative.rotor(2 => 1).grep({ .[0].floor == .[1].floor })>>.[0]>>.floor;
    my @output = "\c[FULL BLOCK]" xx $width;
    dd @parts;
    if @splitpoints {
    } else {
        my $idx;
        for @cumulative {
            $idx++;
            @output[$_.floor] = @partial_blocks[($_ % 1.0) * 8] ~ color(@cols[$idx] ~ " on_" ~ @cols[$idx + 1]);
        }
        @output[0] [R~]= color(@cols[0] ~ " on_" ~ @cols[1]);
        .print for @output;
        say color("reset");
        say "";
    }
}

sub MAIN {
    for ^100 {
        my @parts = (rand / 2).round(0.01) xx *;
        my @cumul = [\+] @parts;
        my $count = @cumul.first(* > 1, :k);
        my @percentages = flat @parts[^$count], 1 - [+] @parts[^$count];
        @percentages.pop if @percentages[*-1] == 0;
        stacked_bars(@percentages);
    }
}
