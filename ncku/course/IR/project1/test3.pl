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


#file 
my $remove_attribute_file; #to data1.txt
my $xml_file; # from $ARGV[0] == data.txt
my $out_file; # to data2.txt
my $count_file; #to data3.txt
my $char_file; #to data4.txt

open $xml_file, '<', $ARGV[0]
    or die "can't open $!";

open $remove_attribute_file, '>', 'data1.txt'
    or die "can't open $!";


while (<$xml_file>){
     $_ =~ m/<(.*?)>/;
     print "found $1\n";
     my $temp =$1;
     my $word;
     my @attribute = split(' ', $temp);
     print "attribute[0] = $attribute[0]\n";
     
     $word = $attribute[0];
     $_ =~ s/<(.*?)>/<$word>/;
     print $remove_attribute_file "$_";
    }
close $remove_attribute_file;
close $xml_file;

my $data = $xml->XMLin("data1.txt");


traverse( $data );


print "\n------------------------------------------------\n";
open $out_file, '>', 'data2.txt'
    or die "can't open $!";
    

add_acronyms('lt','gen');               ## adding support for 'Lt. Gen.'

#make sentence
foreach (@pubmed_data){
    state $sentence_count = 0;
    
    my $sentences=get_sentences($_);     ## Get the sentences.
    foreach my $sentence (@$sentences) {
        $sentence_count++;
        $sentence =~ s/(.*?),/$1/g;
        $sentence =~ s/\((.*?)\)/$1/g;
        $sentence =~ s/\[(.*?)\]/$1/g;
        $sentence =~ s/(.*):/$1/g;
        $sentence = lc $sentence;
    
        $sentence =~ s/(.*)(\.|\?|\:)$/$1/;
        
        print $out_file "$sentence_count.$sentence\n";
        
        my @word_array = split(/\s+/, $sentence);
        foreach (@word_array) {
            $_ =~ s/(.*):/$1/;
            $_ = to_S ($_);
            $_ =~ s/'(.*)'/$1/;
            if (exists $word_data{$_} ) {
                $word_data{$_}++;
            
            }
            else {
                $word_data{$_} = 1;
            }
        
           }        
        }
    
    }
close $out_file;

open $count_file, '>', 'data3.txt'
    or die "can't open $!";
foreach (sort keys %word_data) {
    print $count_file "key = $_\n";
    print $count_file "value =  $word_data{$_}\n";
       
    }
close $count_file;
open $char_file, '>', 'data4.txt'
    or die "can't open $!";
foreach (sort keys %word_data) {
    my @chars = split ("",$_);
    my $values = $word_data{$_};
    foreach (@chars) {
        if (exists $char_data{$_} ) {
            $char_data{$_} += $values;
            
        }
        else {
            $char_data{$_} = 1 * $values;
       
        }
     }
}
foreach (sort keys %char_data) {
    print $char_file "key = $_\n";
    print $char_file "value =  $char_data{$_}\n";
       
    }
close $char_file;

sub traverse {
    our @pubmed_data;
    my ($element) = @_;
    if( ref( $element ) =~ /HASH/ ) {
        foreach my $key (keys %$element) {
  #          print "key=$key\n";
  #          next if ($key eq "PubmedData");
            traverse( $$element{$key} );
            }
    } 
    elsif( ref( $element)  =~ /ARRAY/ )  {
        #my $i = $_[0];
        traverse( $_ ) foreach @$element;
    } 
    else {
   #     print "$element\n";
       push @pubmed_data, $element;
    }
}