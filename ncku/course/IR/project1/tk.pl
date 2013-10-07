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

my ($abstract1, $sentence1, $word1, %word1_hash, $word1_total, $char1, $char1_total, $sentence1_count, $word1_count, $char1_count, $EOS1_count, $identical_word1_count, $identical_word1_SW_count);
my ($abstract2, $sentence2, $word2, %word2_hash, $word2_total, $char2, $char2_total, $sentence2_count, $word2_count, $char2_count, $EOS2_count, $identical_word2_count, $identical_word2_SW_count);
$char1_count  = "char1 number is";
$word1_count  = "word1 number is";
$EOS1_count   = "EOS1 number is";
$identical_word1_count = "identical_word1 number is";
$identical_word1_SW_count = "identical_word1_SW number is";
$char2_count  = "char2 number is";
$word2_count  = "word2 number is";
$EOS2_count   = "EOS2 number is";
$identical_word2_count = "identical_word2 number  is";
$identical_word2_SW_count = "identical_word2_SW number is";

my $similarity = "similarity is";

my $types = [ ['xml files', '.xml'],
              ['All Files',   '*'],];
my $file_count = 1;
my $mw = MainWindow->new;
$mw->title('Frame Example');
my $frame1 = $mw->Frame(-label => '',
                       -borderwidth => 5, -relief => 'groove');
my $frame2 = $mw->Frame(-label => 'Frame 2',
                       -borderwidth => 5, -relief => 'groove');
my $frame3 = $mw->Frame(-label => 'Frame 3',
                       -borderwidth => 5, -relief => 'groove');
my $frame4 = $mw->Frame(-label => '',
                       -borderwidth => 20, -relief => 'groove');
my $cb1 = $frame1->Button(-text => 'openfile1', 
                          -command => \&open_file);
my $cb2 = $frame1->Button(-text => 'openfile2',
                          -command => \&open_file);
my $cb3 = $frame1->Button(-text => 'compare',
                          -command => \&compare);

my $text1 = $frame2->Text(-width => 60, -height => 20);
my $char1_label = $frame2->Label(-textvariable => \$char1_count);
my $word1_label = $frame2->Label(-textvariable => \$word1_count);
my $EOS1_label = $frame2->Label(-textvariable => \$EOS1_count);
my $ID_word1_label = $frame2->Label(-textvariable => \$identical_word1_count);
my $ID_word1_SW_label = $frame2->Label(-textvariable => \$identical_word1_SW_count);
my $text2 = $frame3->Text(-width => 60, -height => 20);
my $char2_label = $frame3->Label(-textvariable => \$char2_count);
my $word2_label = $frame3->Label(-textvariable => \$word2_count);
my $EOS2_label = $frame3->Label(-textvariable => \$EOS2_count);
#my $identical_label = $frame4->Label(-textvariable => \$identical_words);
my $ID_word2_label = $frame3->Label(-textvariable => \$identical_word2_count);
my $ID_word2_SW_label = $frame3->Label(-textvariable => \$identical_word2_SW_count);
my $similarity_label = $frame4->Label(-textvariable => \$similarity);
my $text3 = $frame4->Text(-width => 60, -height =>20);

my $exit = $frame2->Button(-text => 'Exit',
                       -command => [$mw => 'destroy']);
$frame1->pack(-side => 'top');
$cb1->pack;
$cb2->pack;
$cb3->pack;
$frame2->pack(-side => 'left');
$text1->pack;
$char1_label->pack;
$word1_label->pack;
$EOS1_label->pack;
$ID_word1_label->pack;
$ID_word1_SW_label->pack; 
$frame3->pack(-side => 'right');
$text2->pack;
$char2_label->pack;
$word2_label->pack;
$EOS2_label->pack;
$ID_word2_label->pack;
$ID_word2_SW_label->pack;
$frame4->pack(-side => 'bottom');
$similarity_label->pack;
$text3->pack;
#$exit->pack;
MainLoop;


sub open_file {
  my $open = $mw->getOpenFile(-filetypes => $types,
                              -defaultextension => '.xml');
  my $xml = new XML::Simple (KeyAttr=>[]);


  if ($file_count == 1){

      my $data1 = $xml->XMLin("$open");
      
      $abstract1 = $data1->{PubmedArticle}->{MedlineCitation}->{Article}->{Abstract}->{AbstractText}->{content};
      $sentence1 = sentence($abstract1);
      $word1 = word(\@$sentence1);
      foreach (@$word1){
          if (exists $word1_hash{$_} ) {
                $word1_hash{$_}++;

            }
         else {
                $word1_hash{$_} = 1;
            }
      }
      $word1_total = @$word1;
      $word1_count = "word1 number = $word1_total";
      $char1_total = char($word1);
      $char1_count = "char1 number = $char1_total";
      $file_count++;
  }

  else {
      my $data2 = $xml->XMLin("$open");
      $abstract2 = $data2->{PubmedArticle}->{MedlineCitation}->{Article}->{Abstract}->{AbstractText};
      $sentence2 = sentence($abstract2);
      $word2 = word(\@$sentence2);
      foreach (@$word2){
          if (exists $word2_hash{$_} ) {
                $word2_hash{$_}++;

            }
          else {
                $word2_hash{$_} = 1;
            }
      }  
      $word2_total = @$word2;
      $word2_count = "word2 number = $word2_total";
      $char2_total = char($word2);
      $char2_count = "char2 number = $char2_total";
  }
  
  
}

sub char {

    my $count =0;
    my @char_count;
    foreach my $word (@{$_[0]}) {
        @char_count = split ("",$word);
        $count += scalar @char_count;
    }
    return $count;

}


sub word {
      my @word;

      foreach my $sentence (@{$_[0]}) {

        $sentence =~ s/(.*?),/$1/g;
        $sentence =~ s/\((.*?)\)/$1/g;
        $sentence =~ s/\[(.*?)\]/$1/g;
        $sentence =~ s/(.*):/$1/g;
        $sentence = lc $sentence;
        $sentence =~ s/(.*)(\.|\?|\:)$/$1/;

        my @word_array = split(/\s+/, $sentence);
        foreach (@word_array) {
            $_ =~ s/(.*):/$1/;
            $_ = to_S ($_);
            $_ =~ s/'(.*)'/$1/;
            push @word, $_;
         }

       }

       return \@word;
   }



sub sentence {
   add_acronyms('lt','gen');               ## adding support for 'Lt. Gen.'

   my $line =0 ;
   my $sentences=get_sentences($_[0]);     ## Get the sentences.

   if ($file_count == 1){
       foreach (@$sentences){
           $line++;
           $text1->insert('end',"$line: $_\n");
    }
   $EOS1_count = "EOS1 number=$line";
   return $sentences;
   }
   else {
          foreach (@$sentences){
           #print "file2 $_\n";
           $line++;
           $text2->insert('end',"$line: $_\n");
          }
          $EOS2_count = "EOS2 number=$line";
          return $sentences;

   }

}


sub compare {

   my @unique = intersect(@$word1, @$word2);
   my @uni = uniq(@unique);
   my $stop_words_ref = Lingua::EN::StopWordList -> new -> words;
   my @final_uni = grep { not $_ ~~ @$stop_words_ref } @uni;
   print "array1 =", join (" ", @final_uni), "\n";
   highlightText(1, @final_uni);
   highlightText(2, @final_uni);
   my $word1_ID_count=0;
   my $word1_ID_SW_count=0;
   my $word2_ID_count=0; 
   my $word2_ID_SW_count=0;
   foreach(@uni){
       if (exists $word1_hash{$_}) { 
           $word1_ID_count = $word1_ID_count + $word1_hash{$_};
       }   
   }
  foreach(@uni){
       if (exists $word2_hash{$_}) { 
           $word2_ID_count = $word2_ID_count + $word2_hash{$_};
       }
  }
  foreach(@final_uni){
       if (exists $word1_hash{$_}) {
           $word1_ID_SW_count = $word1_ID_SW_count + $word1_hash{$_};
       }
  }
  my $ID_count = @final_uni;
  $text3->insert('end', "identical words number is = $ID_count\n");
  foreach(@final_uni){
       $text3->insert('end',"$_\n");

       if (exists $word2_hash{$_}) { 
           $word2_ID_SW_count = $word2_ID_SW_count + $word2_hash{$_};
   
       }
  }
  

   $identical_word1_count = "identical_word1 number is = $word1_ID_count";
   $identical_word1_SW_count = "identical_word1_SW number is = $word1_ID_SW_count";
   $identical_word2_count = "identical_word2 number is = $word2_ID_count";
   $identical_word2_SW_count = "identical_word2_SW number is = $word2_ID_SW_count";   
   my $similarity_count = ($word1_ID_count + $word2_ID_count)/($word1_total + $word2_total); 
   $similarity = "Similarity = $similarity_count";
   

}


sub highlightText
{
  my $string = "we";
  my $current = '1.0';
  my $length = 0;
  my $current_last;
  my $length_last;
  
  if (1 == shift ){
  $text1->tagConfigure( 'search', -background => 'lightgreen', -font =>
[-family => 'Arial Unicode MS', -size => '9', -weight => 'bold'] );
  $text1->see("1.0");
  $text1->tagRemove( 'search', qw/0.0 end/ );
   foreach (@_) {
  $string = $_;
  $current = '1.0';
  $length = 0;
  while (1)
  {

    $current = $text1->search(-count => \$length, "-regexp",'-nocase',
$string, $current, 'end' );
    last if not $current;
    #warn "Posn=$current count=$length\n",
    $text1->see($current);
    $text1->tagAdd( 'search', $current, "$current + $length char" );
    $current = $text1->index("$current + $length char");
  }
  }


  }
  else {
  $text2->tagConfigure( 'search', -background => 'lightgreen', -font =>
[-family => 'Arial Unicode MS', -size => '9', -weight => 'bold'] );
  $text2->see("1.0");
  $text2->tagRemove( 'search', qw/0.0 end/ );
   foreach (@_) {
  $string = $_;
  $current = '1.0';
  $length = 0;
  while (1)
  {

    $current = $text2->search(-count => \$length, "-regexp",'-nocase',
$string, $current, 'end' );
    last if not $current;
    #warn "Posn=$current count=$length\n",
    $text2->see($current);
    $text2->tagAdd( 'search', $current, "$current + $length char" );
    $current = $text2->index("$current + $length char");
  }
  }



  }


}
