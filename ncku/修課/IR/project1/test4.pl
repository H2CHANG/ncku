#!/usr/bin/perl

use strict;
use warnings;
use feature 'state';
# use module
use XML::Simple;
use Data::Dumper;
use Lingua::EN::PluralToSingular 'to_singular';
use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Inflect::Number qw( to_S to_PL );
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";

our @pubmed_data;
our %word_data;
our %char_data;
# create object

my $xml = new XML::Simple (KeyAttr=>[]);


#remove_attribute($ARGV[0], "data1.txt");
my $data1 = $xml->XMLin("$ARGV[0]");
my $data2 = $xml->XMLin("$ARGV[1]");
#traverse( $data );


my $abstract1 = $data1->{PubmedArticle}->{MedlineCitation}->{Article}->{Abstract}->{AbstractText};
#my $abstract2 = $data2->{PubmedArticle}->{MedlineCitation}->{Article}->{Abstract}->{AbstractText};
my $abstract2 = $data2->{PubmedArticle}->{MedlineCitation}->{Article}->{Abstract}->{AbstractText}->{content};
#print "abstract1 = $abstract1\n";
#print "abstract2 = $abstract2\n";
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


my @final_array;

foreach (sort keys %word1_hash){
    push @final_array, [1, $_, $word1_hash{$_}];
    
    
    }
foreach (sort keys %word2_hash){
    push @final_array, [2, $_, $word2_hash{$_}];
    
    
    }


#print Data::Dumper->Dump([@final_array]);

my @sort_array = sort {$a->[1] cmp $b->[1]} @final_array;
open my $xml_file, '>', "data1.txt"
    or die "can't open $!";
foreach (@sort_array){
        printf $xml_file "%2d%20s%5d\n", $_->[0], $_->[1], $_->[2];
    
    }
close $xml_file;

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
open my $char_file, '>>', "data2.txt"
    or die "can't open $!";
foreach (sort keys %char1_hash){
        printf $char_file "%20s%5d\n", $_, $char1_hash{$_};
    
    }

foreach (sort keys %char2_hash){
        printf $char_file "%20s%5d\n", $_, $char2_hash{$_};
    
    }
close $char_file;





sub sentence {
   add_acronyms('lt','gen');               ## adding support for 'Lt. Gen.'

 
   my $sentences=get_sentences($_[0]);     ## Get the sentences.

#   foreach (@$sentences){
#      print "sentencesss = $_\n";
  
#  }
   return $sentences;   

}
sub word {
      my @word;
      #print"------------\n";
      #print Dumper @{$_[0]};
      
      foreach my $sentence (@{$_[0]}) {
        #print "test = $_";
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
        #print "i=$i\n";
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
