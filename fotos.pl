#!/usr/bin/env perl
use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use Image::ExifTool 'ImageInfo';
use File::Copy qw(move);
$|=1;	# This turns off output buffering. Useful for real-time display of progress or error messages.

print "Path: ";
chomp(my $path = <>);
print "Name: ";
chomp(my $basename = <>);

opendir(D, "$path") || die "Can't open directory $path: $!\n";
my @list = readdir(D);
closedir(D);

foreach my $f (@list) {
	if ($f =~ /.jpg$/gi){
		my $oldname = $path . $f;
		open (my $fh, '<', $oldname) or die "Can't open '$oldname': $!";
		binmode($fh);
		my $md5 = Digest::MD5->new;
		while (<$fh>) {
			$md5->add($_);
		}
		close($fh);		
		my $digest = $md5->hexdigest;		
		$digest = substr($digest,0,7);
		my $exif = Image::ExifTool->new;
		$exif->ExtractInfo($oldname);
		my $date = $exif->GetValue('DateTimeOriginal', 'PrintConv');
		$date =~ s/:/-/g;
		$date =~ s/ /_/g;
		my $newname = $path . $basename . "_" . $date . "_" . $digest . ".jpg";
		if ($oldname ne $newname){
			move $oldname, $newname;
			print(".");
		}
		else{
			print("Oldname its the same for: $f\n");
		}
	}
} 