#!/usr/bin/perl

#use Tk;
use strict;
use warnings;
use Tk;
use XML::Simple;
use Data::Dumper;

#use Lingua::EN::PluralToSingular 'to_singular';
use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Inflect::Number qw( to_S to_PL );
use Array::Utils qw(:all);
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use List::MoreUtils qw(uniq);
use Lingua::EN::StopWordList;
use Lingua::Stem::En;
use Text::Levenshtein qw(distance);

my (
    $abstract1,   $sentence1,
    $word1,       %word1_hash,
    $word2,       %word2_hash,
    $word1_total, $char1,
    $char1_total, $sentence1_count,
    $word1_count, $char1_count,
    $EOS1_count,  $identical_word1_count,
    $identical_word1_SW_count
);
$char1_count              = "char1 number is";
$word1_count              = "word1 number is";
$EOS1_count               = "EOS1 number is";
$identical_word1_count    = "identical_word1 number is";
$identical_word1_SW_count = "identical_word1_SW number is";
my $name;
my $stemmed_words;

my $types      = [ [ 'txt files', '.txt' ], [ 'All Files', '*' ], ];
my $mw         = MainWindow->new;
$mw->title('Frame Example');
my $frame1 = $mw->Frame(
    -label       => '',
    -borderwidth => 5,
    -relief      => 'groove'
);
my $frame2 = $mw->Frame(
    -label       => 'Frame 2',
    -borderwidth => 5,
    -relief      => 'groove'
);
my $cb1 = $frame1->Button(
    -text    => 'openfile',
    -command => \&Open_file
);
my $cb3 = $frame1->Button(
    -text    => 'Porter algorithm',
    -command => \&porter_algo
);
my $cb4 = $frame1->Button(
    -text    => 'Edit distance',
    -command => \&Edit_dis
);
my $cb5 = $mw->Entry(
    -width => 40,
    -textvariable => \$name,
);
my $frame3 = $mw->Frame(
    -label       => 'Frame 3',
    -borderwidth => 5,
    -relief      => 'groove'
);
my $frame4 = $mw->Frame(
    -label       => 'Frame 4',
    -borderwidth => 5,
    -relief      => 'groove'
);

my $text1 = $frame2->Text( -width => 60, -height => 20 );
my $text2 = $frame3->Text( -width => 60, -height => 20);
my $text3 = $frame3->Text( -width => 60, -height => 20);
my $text4 = $frame4->Text( -width => 60, -height => 20);

my $char1_label    = $frame2->Label( -textvariable => \$char1_count );
my $word1_label    = $frame2->Label( -textvariable => \$word1_count );
my $EOS1_label     = $frame2->Label( -textvariable => \$EOS1_count );
#my $ID_word1_label = $frame2->Label( -textvariable => \$identical_word1_count );
#my $ID_word1_SW_label =
#$frame2->Label( -textvariable => \$identical_word1_SW_count );

my $exit = $frame2->Button(
    -text    => 'Exit',
    -command => [ $mw => 'destroy' ]
);
$frame1->pack( -side => 'top' );
$cb1->pack;
$cb3->pack;
$cb4->pack;
$cb5->pack;
$frame2->pack( -side => 'left' );
$text1->pack;
$frame3->pack( -side => 'right' );
$text2->pack;
$text3->pack;
$char1_label->pack;
$word1_label->pack;
$frame4->pack( -side => 'bottom' );
$text4->pack;
$EOS1_label->pack;
#$ID_word1_label->pack;
#$ID_word1_SW_label->pack;

#$exit->pack;
MainLoop;

sub Edit_dis {
    my $text = $cb5->get();    
    print "text = $text\n";
    my @stem_text = ($text);
    my $after_stemmed_text = Lingua::Stem::En::stem({ -words => \@stem_text,
                                                      -locale => 'en',
                          });
    my @uniq = uniq(@$stemmed_words);    
    my @sorted = 
       #sort{ $a->[0] cmp $b->[0]}
       sort { $a->[1] <=> $b->[1] or $a->[0] cmp $b->[1] }
       map { [$_, distance("@$after_stemmed_text", $_)] }
       @uniq;
    my $j =1;
    $text4->delete('1.0','end');
    foreach (@sorted) {
        
        $text4->insert( 'end', "$j: $_->[0] $_->[1]\n" );
        $j++;
    }
    my $post_stemmed_text = $after_stemmed_text->[0];
    if ( $sorted[0]->[1] == 0) {
        $cb5->delete(0,'end');
        $cb5->insert('end', $text . " match " . $post_stemmed_text);

        highlightText($text);

    }
    else {
        $cb5->delete(0,'end');
        my $i = $sorted[0]->[1];
        foreach (@sorted){
            if ($i < $_->[1]) {
                last;
            }
            #$cb5->delete(0,'end');
            $cb5->insert('end', "$_->[0] ");

        }
        $cb5->insert('end', $i);
    }
    
}


sub highlightText
{
  my $string;
  my $current = '1.0';
  my $length = 0;
  my $current_last;
  my $length_last;

  $text1->tagConfigure( 'search', -background => 'lightgreen', -font =>
                        [-family => 'Arial Unicode MS', -size => '9', -weight => 'bold'] );
  $text1->see("1.0");
  $text1->tagRemove( 'search', qw/0.0 end/ );
  $string = $_[0];
  $current = '1.0';
  $length = 0;

  while (1)
  {

    $current = $text1->search(-count =>\$length, "-regexp",'-nocase',$string, $current, 'end' );
    last if not $current;
    #warn "Posn=$current count=$length\n",
        $text1->see($current);
        $text1->tagAdd( 'search', $current, "$current + $length char" );
        $current = $text1->index("$current + $length char");
   }
}


sub Zipf {
    my $GNUPlot = '/usr/bin/gnuplot';
    my $gnuplot_file = 'gnuplot.gif';
    my $file = "output1.txt";
    open my $P, "|-", "gnuplot" or die;
    print $P 'set output "plot.png" ';
    print $P "plot 'output1.txt' using 1:3 with dots";
    flush $P;
 
#$printflush $P qq[
#        set output "plot.png"
#        plot "output1.txt" using 1:3 with dots
#];
close $P;
#    open ( GNUPLOT, "|$GNUPlot");
#    print GNUPLOT << "EOPLOT";
#set output "$gnuplot_file"
#plot "output1.txt" using 1:3 with dots
#EOPLOT

#    close (GNUPLOT);




}


sub porter_algo {


    $stemmed_words = Lingua::Stem::En::stem({ -words => $word1,
                                              -locale => 'en',
                        });
   #$stemmed_words = Lingua::Stem::En::stem({ -words => $stemmed_words,
    #                                          -locale => 'en',
    #                    });

    
    foreach (@$stemmed_words) {
        if ( exists $word2_hash{$_} ) {
            $word2_hash{$_}++;

        }
        else {
            $word2_hash{$_} = 1;
        }
    }

    open(my $fh2, ">", "output2.txt")
        or die "cannot open > output2.txt: $!";
    my $i=1;
    foreach (sort { $word2_hash{$b} <=> $word2_hash{$a} or $a cmp $b} keys %word2_hash) {
        print $fh2 "$i $_ $word2_hash{$_}\n";
        $text3->insert( 'end', "$i: $_ $word2_hash{$_}\n" );
        $i++;
    }

}

sub Open_file {
    my $open = $mw->getOpenFile(
        -filetypes        => $types,
        -defaultextension => '.txt'
    );
    my $fh;
    open($fh, "<", $open)
        or die "cannot open < 24115477.html: $!";

    $/ = "";
    my $i=1;
    
    while (<$fh>){
        if ($i == 5){
            $abstract1 = $_;
            
        }
    print "$i $_\n";
    $i++;


    } 
    close $fh;

    print "abstract = $abstract1\n";
    $sentence1 = sentence($abstract1);
    $word1     = word( \@$sentence1 );
    foreach (@$word1) {
        if ( exists $word1_hash{$_} ) {
            $word1_hash{$_}++;

        }
        else {
            $word1_hash{$_} = 1;
        }
    }
    open(my $fh1, ">", "output1.txt") 
	    or die "cannot open > output1.txt: $!"; 
    $i=1;
    foreach (sort { $word1_hash{$b} <=> $word1_hash{$a} or $a cmp $b} keys %word1_hash) {
        print $fh1 "$i $_ $word1_hash{$_}\n";
        $text2->insert( 'end', "$i: $_ $word1_hash{$_}\n" );
        $i++;
    }
    close $fh1;
    $word1_total = @$word1;
    $word1_count = "word1 number = $word1_total";

    $char1_total = char($word1);
    $char1_count = "char1 number = $char1_total";

}

sub char {

    my $count = 0;
    my @char_count;
    foreach ( @{ $_[0] } ) {
        @char_count = split( "", $_ );
        $count += scalar @char_count;
    }
    return $count;

}

sub word {
    my @word;

    foreach my $sentence ( @{ $_[0] } ) {

        $sentence =~ s/(.*?),/$1/g;
        $sentence =~ s/\((.*?)\)/$1/g;
        $sentence =~ s/\[(.*?)\]/$1/g;
        $sentence =~ s/(.*):/$1/g;
        $sentence = lc $sentence;
        $sentence =~ s/(.*)(\.|\?|\:)$/$1/;

        my @word_array = split( /\s+/, $sentence );
        foreach (@word_array) {
#            $_ =~ s/(.*):/$1/;
#            $_ = to_S($_);
#            $_ =~ s/'(.*)'/$1/;
            push @word, $_;
        }

    }

    return \@word;
}

sub sentence {
    add_acronyms( 'lt', 'gen' );    ## adding support for 'Lt. Gen.'

    my $line      = 0;
    my $sentences = get_sentences( $_[0] );    ## Get the sentences.

    foreach (@$sentences) {
        $line++;
        $text1->insert( 'end', "$line: $_\n" );
    }
    $EOS1_count = "EOS1 number=$line";
    return $sentences;

}
