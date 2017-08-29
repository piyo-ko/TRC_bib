#!/usr/local/bin/perl

# Usage: ./bib.pl [B|S|BS|SB] < data/2017/TRCOpenBibData_yyyymmdd.txt 

# 他の使用例
#$ grep 角川 data/2017/TRCOpenBibData_20170826.txt | ./bib.pl 

use strict;
use warnings;
use utf8;
binmode STDIN,  ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";


#my ($in_fh, $out_fh);
#open($in_fh, "<:utf8", [filename]) || die("Cannot open [filename]");
#open($out_fh, ">:utf8", [filename]) || die("Cannot open [filename]");

#close($in_fh);
#close($out_fh);

my $mode = 'B'; # デフォルト値 (文庫を抽出)
if (0 < $#ARGV) {
  die "引数が多すぎ。\n";
} elsif (0 == $#ARGV) {
  if ($ARGV[0] eq 'S') { # 新書を抽出
    $mode = 'S';
  } elsif ($ARGV[0] eq 'BS' || $ARGV[0] eq 'SB') { # 文庫と新書を抽出
    $mode = 'BS';
  }
  # それ以外の場合はデフォルト (文庫を抽出)
}

while(<STDIN>) {
  chomp;
  my @bib = split(/\t/, $_);
  if ($#bib != 17) {
    print STDERR "Error (the last index of bib is $#bib) : $_\n";
    next;
  }
  my $ISBN = $bib[0]; # (A) ISBN (ハイフン付き13桁)
  my $title_1 = $bib[1]; # (B) タイトル
  my $title_2 = $bib[2]; # (C) サブタイトル
  my $author_1 = $bib[3]; # (D) 著者1
  my $author_2 = $bib[4]; # (E) 著者2
  my $version = $bib[5]; # (F) 版表示 (「新版」など)
  my $publisher = $bib[6]; # (G) 出版社
  my $seller = $bib[7]; # (H) 発売者
  my $year_month = $bib[8]; # (I) 出版年月 (「2017.8」など)
  my $page = $bib[9]; # (J) ページ数等 (「173p」など)
  my $size = $bib[10]; # (K) 大きさ (「19cm」など)
  my $appendix = $bib[11]; # (L) 付属資料の種類と形態
  my $series_title_1 = $bib[12]; # (M) シリーズ名・シリーズ番号1 (「岩波現代文庫」など)
  my $series_title_2 = $bib[13]; # (N) シリーズ名・シリーズ番号2
  my $series_title_3 = $bib[14]; # (O) シリーズ名・シリーズ番号3
  my $title_3 = $bib[15]; # (P) 各巻のタイトル
  my $price = $bib[16]; # (Q) 本体価格 (「¥1200」など)
  my $set_price = $bib[17]; # (R) セット本体価格
  
  my $to_be_printed = (($mode eq 'B' || $mode eq 'BS') && ($series_title_1 =~ /文庫/)) ||
    (($mode eq 'S' || $mode eq 'BS') && ($series_title_1 =~ /新書/));
  if ($to_be_printed) {
    my $URL = gen_amazon_link($ISBN);
    print "『$title_1\』$author_1 ($series_title_1) $price\n$URL\n\n";
  }

}


sub gen_amazon_link {
  my ($ISBN13) = @_;
  my $sum = 4*10;
  my $tmp = '';
  my $ISBN10 = '4';
  if ($ISBN13 =~ /^978-4-([\-\d]+)-\d$/) {
    my $tmp = $1;
    my $len = length($tmp);
    my $i = 0;
    my $t = 0;
    while ($t < $len) {
      my $t_th_char = substr($tmp, $t, 1);
      if ($t_th_char eq '-') {
        $t++;
        next;
      }
      # ここで $t_th_char は数字。
      $sum += $t_th_char * (9 - $i);
      $ISBN10 .= $t_th_char;
      $i++;
      $t++;
    }
    my $c = 11 - ($sum % 11);
    if ($c == 10) {
      $ISBN10 .= 'X';
    } elsif ($c == 11) {
      $ISBN10 .=  '0';
    } else {
      $ISBN10 .= $c;
    }
    my $URL = "https://www.amazon.co.jp/dp/" . $ISBN10 . "/";
    return $URL;
  } else {
    die "Bad ISBN [$ISBN13]\n";
  }
}
