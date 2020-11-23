#!/usr/bin/perl
# Gina Cannarozzi Nov 28, 2018 
# process blast output resulting from blasting Mathieu's SNPs plus 100 bp up and downstream
# output is adding two lines to his csv file which has the new chromosomal loaction and position
# Usage Process.pl in directory with a bunch of files starting with Blast n
# input file RIL_QTL-Clean.csv has to be accessible somewhere

use warnings;
use strict;
use autodie;
use File::Glob ':globally';
no warnings 'uninitialized';

#my $blastfile = $ARGV[0];
  my @configs = <blastn*>;
# saving results from perfect length matches those starting at 1 and stopping at 201 
  my %perfchr ={};
  my %perfpos ={};
# saving results from all matches those starting at 1 and stopping at 201 
  my %allchr ={};
  my %allpos ={};

# parse the filenames and use this as the hash key 
foreach my $fn (@configs) {
# the filenames look like this blastn.Peaxi162Scf01650_82242.Pex301
  my @parts = split /\./, $fn;
# mathieu's indicators look like this:  Peaxi162Scf01650:82242
  (our $newname = $parts[1]) =~ s/_/:/; #make compatible with mathieus naming
#  print "part $parts[1]\n";
#  print "$newname\n";
  open(my $fh, '<', $fn) or die "Could not open file '$fn' $!";
  my $firstline = <$fh>;
  next if ($firstline =~ /scaf/) ;
  close $fh;

# from the blast file get the chromosome and location of the top hit
# check if the query alignment start is 1 and the end is 201, if so  it is a perfect match
#
  print $firstline, "\n";
  my @words = split /\t/, $firstline;
  #$words[1] is the new chromosome number
  # 6 and 7 should be 1 and 201
  # 8 and 9 are the location in the chromosome 
  # need to check if chromosome is in the forward or reverse direction
#  print substr($words[1],-5,5) , "\t",  $words[6], "\t",  $words[7], "\t",  $words[8], "\t",  $words[9], "\n";
  if ($words[6] == 1 && $words[7] == 201) {
#    my $k = index($words[1],"Scf");
#    print $k, "\n";
    $perfchr{$newname} = (index($words[1],"Scf") >=0 ) ? $words[1] : substr($words[1], -1, 1);
   print  "case1", "\t", $perfchr{$newname}, "\n";
    $perfpos{$newname} =  ( $words[9] > $words[8] ) ? $words[8]+100 : $words[8]-100;
    $allchr{$newname} = (index($words[1],"Scf") >=0 ) ? $words[1] : substr($words[1], -1, 1);
    $allpos{$newname} =  ( $words[9] > $words[8] ) ? $words[8]+100 : $words[8]-100;
  } else {
    $allchr{$newname} = (index($words[1],"Scf") >=0 ) ? $words[1] : substr($words[1], -1, 1);
   print  "case2", "\t", $allchr{$newname}, "\n";
    if ($words[6] == 1) {
    $allpos{$newname} =  ( $words[9] > $words[8] ) ? $words[8]+100 : $words[9]+100;
    } elsif ($words[7] == 201) {
    $allpos{$newname} =  ( $words[9] > $words[8] ) ? $words[9]-100 : $words[8]-100;
    } else { # just skip it
#     my $newint = int ($words[6] + ($words[7]-$words[6])/2) ;
#    $allpos{$newname} =  $newint;
    }
  }
}

# create 2 arrays, one with chromosome, one with position for perfect cases and all cases 
open(my $matfile, '<', "../RIL_QTL-Clean.csv") ;
 # reads in first line
  my $snplist = <$matfile>;
  close $matfile;

# initialize arrays
  my @snps = split /,/, $snplist;
  my @pchr = (0) x @snps; 
  my @ppos = (0) x @snps; 
  my @achr = (0) x @snps; 
  my @apos = (0) x @snps; 
  
  for my $i (0 .. $#snps)
{
   $pchr[$i] = $perfchr{$snps[$i]};
   $ppos[$i] = $perfpos{$snps[$i]};
   $achr[$i] = $allchr{$snps[$i]};
    print $allchr{$snps[$i]}, "\n";
   $apos[$i] = $allpos{$snps[$i]};
}

# print 3 lines into perfect file

open(my $outfile, '>', 'mathieu.perf.out.csv');

print $outfile join ",", @snps;
print $outfile "\n";
print $outfile join ",", @pchr;
print $outfile "\n";
print $outfile join ",", @ppos;
print $outfile "\n";

#copy rest of file

open( $matfile, '<', "../RIL_QTL-Clean.csv") ;
while (<$matfile>) {
 print $outfile $_;
}
close $matfile;
close $outfile;

# print 3 lines into all file

open( $outfile, '>', 'mathieu.all.out.csv');

print $outfile join ",", @snps;
print $outfile "\n";
print "length snps ", scalar(@snps), "\n";
print $outfile join ",", @achr;
print $outfile "\n";
print "length achr ", scalar(@achr), "\n";
print $outfile join ",", @apos;
print $outfile "\n";
print "length apos ", scalar(@apos), "\n";

#copy rest of file

open( $matfile, '<', "../RIL_QTL-Clean.csv") ;
while (<$matfile>) {
 print $outfile $_;
}
close $matfile;
close $outfile;


open( $outfile, '>', 'mathieu.markersforcircos.txt');
for my $i (0 .. $#snps)
{
#     print  $snps[$i], "\t", "Pex", $achr[$i], "\t", $apos[$i], "\t", $apos[$i], "\n"
  if ($apos[$i]) {
     print  $outfile "Pex", $achr[$i], "\t", $apos[$i], "\t", $apos[$i], "\n"
  };
}

open( $outfile, '>', 'mathieu.strudel.txt');
for my $i (0 .. $#snps)
{
#     print  $snps[$i], "\t", "Pex", $achr[$i], "\t", $apos[$i], "\t", $apos[$i], "\n"
#  if ($apos[$i]) {
     print  $outfile "feature", "\t", "genome", "\t", $achr[$i], "\t", "\"",$snps[$i],"\"", "\t", "SNP", "\t", $apos[$i], "\n"
#  };
}
close $outfile;
