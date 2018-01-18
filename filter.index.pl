use strict;
use Math::Combinatorics;

my $usage =<<USAGE;
##################################################
#	Program	:	$0
#	Writer	:	chenyuelong
#	Date	:	20160919
#
#	usage	:
#	perl $0 <index> <outdir> <samelength>
#
#	index格式如下：
#	PAA 1-L\t1\tCATTGCTT
#	PAA 2-L\t2\tTTCGGATT
#	PAA 3-L\t3\tTCATCATT
#	PAA 5-L\t5\tGCTCCTGT
#	PAA 6-L\t6\tAGCTCGGT
#	PAA 7-L\t7\tCAACAGGT
#	PAA 8-L\t8\tTTCAAGGT
#	PAA 9-L\t9\tCCTAACGT
#
#2016-10-8 更新：
#	将最低index设为了13个
#	加入了一个新的条件，就是每个位置的碱基是否平衡	
##################################################
USAGE
#########################################
my $sameLENGTH = 3;
#########################################


die $usage unless @ARGV == 3;
my $index = shift;
my $outdir = shift;
$sameLENGTH = shift;
system("mkdir -p $outdir/index_Same_length_$sameLENGTH");
open IN,$index || die $!;
my %idx;
while(<IN>){
	s/[\r\n]+//;
	my @cells = split /\t/;
	$idx{$cells[1]} = $_;
}
close IN;
print "index load finished!\n".`date`."\n";
my $hasDup = 1;
my $lop = 13;
while($hasDup){
	my $hash_idx;
	$hasDup=deleteDup(\%idx,$lop);
	$lop++;
	
}



sub deleteDup{
	my %number;
	my $sub_idx = shift;
	my $sub_lop = shift;
	my %sub_hash = %$sub_idx;
	my @indexes = keys %sub_hash;
	my $combinat = Math::Combinatorics->new(count => $sub_lop, data => [@indexes],);
	my $class =1 ;
	while(my @combo = $combinat->next_combination){
		if(isdup($sub_idx,@combo)){
			next;
		}
		elsif(isbalance($sub_idx,@combo)){
			next;
		}
		else{
			open OUT,">>$outdir/index_Same_length_$sameLENGTH/index_$sub_lop.txt" || die $!;
			print OUT "index_$class";
			foreach my $cb(@combo){
				my @cells = split /\t/,$sub_hash{$cb};
				print OUT "\t$cells[1]\_$cells[2]";
			}
			$class++;
			print OUT "\n";
			close OUT;
		}
	}
	if($class == 1){
		return 0;
	}
	else{
#		print "class_$class\t$sub_lop\n".`date`."\n";
		return 1;
	}
}
sub isbalance{
	my $sub_idx = shift;
	my @tmps = @_;
	my %sub_hash = %$sub_idx;
	my $number = @_;
	for(my $i=0;$i<length($sub_hash{$tmps[0]});$i++){
		my %base;
		my @bases;
		foreach my $idx(@tmps){
			push(@bases,$sub_hash{$idx});
			my @ts = split //,$sub_hash{$idx};
			$base{$ts[$i]}++;
		}
#		print "@bases";
		foreach my $b(keys %base){
			my @tp = split /\t/,$base{$b};
#			print "碱基不平衡\n" if $tp[-1]/$number>0.4;
			return 1 if $tp[-1]/$number>0.4;
		}
	}
	return 0;
}
sub isdup{
	my $sub_idx = shift;
	my @tmps = @_;
#	print "Indexes:@tmps\n".`date`."\n";
	my %sub_hash = %$sub_idx;
	my $combinat = Math::Combinatorics->new(count => 2, data => [@tmps],);
	while(my @cbs = $combinat->next_combination){
		my $tmp1 = (split /\t/,$sub_hash{$cbs[0]})[2];
		my $tmp2 = (split /\t/,$sub_hash{$cbs[1]})[2];
		if(compare($tmp1,$tmp2)){
#			print "有重复\n";
			return 1;
		}
	}
#	print "没重复\n";
	return 0;
}

sub compare{
	my $tmp1 = shift;
	my $tmp2 = shift;

	my @tmp1s = split //,$tmp1;
	my @tmp2s = split //,$tmp2;
	my $number = 0;
	for(my $i=0;$i<@tmp1s;$i++){
		if($tmp1s[$i] eq $tmp2s[$i]){
			$number++;
		}
	}
	if($number > $sameLENGTH){
		return 1;
	}
	else{
		return 0;
	}
}

