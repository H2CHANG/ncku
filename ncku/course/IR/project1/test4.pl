#!/usr/bin/perl

use strict;
use warnings;

# use module
use XML::Simple;
use Data::Dumper;
use Lingua::EN::PluralToSingular 'to_singular';
use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Inflect::Number qw( to_S to_PL );
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";


my $xml = new XML::Simple (KeyAttr=>[]);

my $data1 = $xml->XMLin("$ARGV[0]");
my $data2 = $xml->XMLin("$ARGV[1]");


open my $word_file, '>', "data2.txt"
    or die "can't open $!";
open my $char_file, '>>', "data3.txt"
    or die "can't open $!";

my $abstract1 = $data1->{PubmedArticle}->{MedlineCitation}->{Article}->{Abstract}->{AbstractText}->{content};
#my $abstract2 = $data2->{PubmedArticle}->{MedlineCitation}->{Article}->{Abstract}->{AbstractText};
my $abstract2 = $data2->{PubmedArticle}->{MedlineCitation}->{Article}->{Abstract}->{AbstractText};

my $sentence1 = sentence($abstract1);
my $sentence2 = sentence($abstract2);



my $word1 = word(\@$sentence1);
my $word2 = word(\@$sentence2);

my %word1_hash;
my %word2_hash;

foreach (@$word1){
    if (exists $word1_hash{$_} ) {
                $word1_hash{$_}++;
            
            }
    else {
                $word1_hash{$_} = 1;
            }
    }
 
foreach (@$word2){
    if (exists $word2_hash{$_} ) {
                $word2_hash{$_}++;
            
            }
    else {
                $word2_hash{$_} = 1;
            }
    }
my $word1_total= 0;
my $word2_total=0;
foreach (sort keys %word1_hash){
    $word1_total = $word1_hash{$_} + $word1_total;
    
    
    }
foreach (sort keys %word2_hash){
    $word2_total = $word2_hash{$_} + $word2_total;
    
    
    } 
print "word1 = $word1_total\n";
print "word2 = $word2_total\n";


my @final_array;

foreach (sort keys %word1_hash){
    push @final_array, [$_, 1, $word1_hash{$_}];
    
    
    }
foreach (sort keys %word2_hash){
    push @final_array, [$_, 2, $word2_hash{$_}];
    
    
    }


my @sort_array = sort {$a->[0] cmp $b->[0]} @final_array;

foreach (@sort_array){
        printf $word_file "%25s%10d%10d\n", $_->[0], $_->[1], $_->[2];
    
    }
close $word_file;

cmp_file(@sort_array);

my %char1_hash;
my %char2_hash;

#print split ("", @$word1);

foreach (sort keys %word1_hash) {
    my @chars = split ("",$_);
    my $values = $word1_hash{$_};
    foreach (@chars) {
        if (exists $char1_hash{$_} ) {
            $char1_hash{$_} += $values;
            
        }
        else {
            $char1_hash{$_} = 1 * $values;
       
        }
     }
}
foreach (sort keys %word2_hash) {
    my @chars = split ("",$_);
    my $values = $word2_hash{$_};
    foreach (@chars) {
        if (exists $char2_hash{$_} ) {
            $char2_hash{$_} += $values;
            
        }
        else {
            $char2_hash{$_} = 1 * $values;
       
        }
     }
}

my $char1 = 0;
my $char2 = 0;
foreach (sort keys %char1_hash){
        printf $char_file "%20s%5d\n", $_, $char1_hash{$_};
        $char1 = $char1 + $char1_hash{$_};
    }

foreach (sort keys %char2_hash){
        printf $char_file "%20s%5d\n", $_, $char2_hash{$_};
        $char2 = $char2 + $char2_hash{$_};
    }
close $char_file;
print "char1 = $char1\n";
print "char2 = $char2\n";





sub sentence {
   add_acronyms('lt','gen');               ## adding support for 'Lt. Gen.'

   my $line =1 ; 
   my $sentences=get_sentences($_[0]);     ## Get the sentences.

   open my $sentence_file, '>>', "data1.txt"
      or die "can't open $!";
   foreach (@$sentences){
       print $sentence_file "$line:   $_\n";
       $line++;
    }
   print $sentence_file "--------------------\n";
   close $sentence_file;

   return $sentences;   

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


sub cmp_file{
    my $i;
    my $flag = 1;
    my @array = @_;
    for($i=0;$i<$#array; $i=$i+2){
   
        if($array[$i]->[1] eq $array[$i+1]->[1]){
 
            if ($array[$i]->[2] == $array[$i+1]->[2]){
                next;
                
                } 
            else {
     
                 $flag=0;
                 last;
                }
            }
         else {
         
                 $flag=0;
                 last;
             
             
             }

         
             
    }
         if ($flag ==1 ){
             print "the two same files\n";
             }
          else {
              print "the two different files\n";
              }    
    
    }
