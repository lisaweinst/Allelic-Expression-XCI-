#!/usr/bin/env perl
#!/usr/bin/perl -w

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;

my $help;
GetOptions(
    'h|help'=>        \$help
)||usage(); 
usage () if defined $help;

open IN, $ARGV[0] or die "Can't open $ARGV[0]:$!";
my %hash;
while(<IN>){
    chomp;
    my ($chr, $pos, $alt)=(split "\t", $_)[0,1, 4];
    $alt=uc $alt;
    $hash{$chr}{$pos}{alt}=$alt;
}
close(IN);

open IN, $ARGV[1] or die "Can't open $ARGV[1]:$!";
while(<IN>){
    chomp;
    my ($chr, $pos, $ref, $alleles, $quals)=split " ", $_;
    $alleles=uc $alleles;
    my @Alleles=split "", $alleles;
    my $alt=$hash{$chr}{$pos}{alt};
    my ($count_ref, $count_alt, $count_others)=(0) x 3;
    for(my $i=0; $i<@Alleles; $i++){
        if($Alleles[$i] eq $ref){
            $count_ref++;
        }elsif($Alleles[$i] eq $alt){
            $count_alt++;
        }else{
            $count_others++
        }
    }
    my $per_ref=sprintf("%.4f", $count_ref/($count_ref+$count_alt+$count_others));
    my $per_alt=sprintf("%.4f", $count_alt/($count_ref+$count_alt+$count_others));
    my $per_others=sprintf("%.4f", $count_others/($count_ref+$count_alt+$count_others));
    say join "\t",($chr, $pos, $count_ref, $per_ref, $count_alt, $per_alt,  $count_others, $per_others);
}
close(IN);


sub usage{
    my $scriptName=basename $0;
print <<HELP;
This script was used to get count and percentage of reference and alternative allele from gatk pileup file
Usage: perl $scriptName *vcf *pileup.tsv >output

    -h  --help  print this help information screen

HELP
    exit(-1);
}