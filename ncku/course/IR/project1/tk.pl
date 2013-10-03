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
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";

my ($abstract1, $sentence1, $word1, %word1_hash, $word1_total, $char1, $char1_total, $sentence1_count, $word1_count, $char1_count, $EOS1_count);
my ($abstract2, $sentence2, $word2, %word2_hash, $word2_total, $char2, $char2_total, $sentence2_count, $word2_count, $char2_count, $EOS2_count);
$char1_count  = "char1 number is";
$word1_count  = "word1 number is";
$EOS1_count   = "EOS1 number is";
$char2_count  = "char2 number is";
$word2_count  = "word2 number is";
$EOS2_count   = "EOS2 number is";
my $types = [ ['xml files', '.xml'],
              ['All Files',   '*'],];
my $file_count = 1;
my $mw = MainWindow->new;
$mw->title('Frame Example');
my $frame1 = $mw->Frame(-label => 'Frame 1',
                       -borderwidth => 5, -relief => 'groove');
my $frame2 = $mw->Frame(-label => 'Frame 2',
                       -borderwidth => 5, -relief => 'groove');
my $frame3 = $mw->Frame(-label => 'Frame 3',
                       -borderwidth => 5, -relief => 'groove');
my $cb1 = $frame1->Button(-text => 'openfile1', 
                          -command => \&open_file);
my $cb2 = $frame1->Button(-text => 'openfile2',
                          -command => \&open_file);
my $text1 = $frame2->Text(-width => 80, -height => 30);
my $char1_label = $frame2->Label(-textvariable => \$char1_count);
my $word1_label = $frame2->Label(-textvariable => \$word1_count);
my $EOS1_label = $frame2->Label(-textvariable => \$EOS1_count);
my $text2 = $frame3->Text(-width => 80, -height => 30);
my $char2_label = $frame3->Label(-textvariable => \$char2_count);
my $word2_label = $frame3->Label(-textvariable => \$word2_count);
my $EOS2_label = $frame3->Label(-textvariable => \$EOS2_count);


my $exit = $frame2->Button(-text => 'Exit',
                       -command => [$mw => 'destroy']);
$frame1->pack(-side => 'top');
$cb1->pack;
$cb2->pack;
$frame2->pack(-side => 'left');
$text1->pack;
$char1_label->pack;
$word1_label->pack;
$EOS1_label->pack;
$frame3->pack(-side => 'right');
$text2->pack;
$char2_label->pack;
$word2_label->pack;
$EOS2_label->pack;
#$exit->pack;
MainLoop;


sub open_file {
  my $open = $mw->getOpenFile(-filetypes => $types,
                              -defaultextension => '.xml');
  print qq{You chose to open "$open"\n} if $open;
  my $xml = new XML::Simple (KeyAttr=>[]);


  if ($file_count == 1){
#      my $xml = new XML::Simple (KeyAttr=>[]);

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
  }
  
  
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

   #open my $sentence_file, '>>', "data1.txt"
   #   or die "can't open $!";
   if ($file_count == 1){
       foreach (@$sentences){
           $line++;
           #print $sentence_file "$line:   $_\n";
           $text1->insert('end',"$line: $_\n");
          #  $line++;
    }
   #print $sentence_file "--------------------\n";
   #close $sentence_file;
   $EOS1_count = "EOS1 number=$line";
   return $sentences;
   }
   else {
          foreach (@$sentences){
           print "file2 $_\n";
           #print $sentence_file "$line:   $_\n";
           $line++;
           $text2->insert('end',"$line: $_\n");
           # $line++;
          #return $sentences;
          }
          $EOS2_count = "EOS2 number=$line";
          return $sentences;

   }

}

