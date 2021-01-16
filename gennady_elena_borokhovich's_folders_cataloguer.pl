#!/usr/local/bin/perl5


#################################################################################
#	
#	
#	--= Gennady and Elena Borokhovich's disk folders cataloguer =--
#	
#	
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#	
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#	
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <https://www.gnu.org/licenses/>
#	
#	
#	This program looks for folders, starting from selected, on a disk
#	and lists all of them into a file.
#	
#	Starting parameters:
#	1. starting folder 
#	2. path (will be added to the beginning of listed folders)
#	
#	Starting parameters input:
#	1. CGI-query (GET or POST)
#	2. !OR! in a file of "$in_folder" var
#	
#	
#	Copyright 2021 Gennady Borokhovich, Elena Borokhovich, Oleg Kozhukhov
#	
#	
#################################################################################


#	--= Preparing Data & Time (Begin) =--
@MON = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec);
@MONTH = ("01".."12");
@WD = (Sun,Mon,Tue,Wed,Thu,Fri,Sat);

$dt = time;
($s,$m,$h,$md,$M,$y,$wd) = localtime ($dt);
$y = $y + 1900;
$md = "0$md" if ($md < 10);
$h = "0$h" if ($h < 10);
$m = "0$m" if ($m < 10);
$s = "0$s" if ($s < 10);

$date = "$WD[$wd], $md-$MON[$M]-$y $h:$m:$s KRD";
#	--= Preparing Data & Time (End) =--


$in_folder = "folders_list_in.txt";
$file = "folders_list.txt";
$error = "folders_list_error_log.txt";
$db = "folders_list.txt";
$db_backup = "folders_list_BackUp $y-$MONTH[$M]-$md.txt";

open (ERROR, ">> $error") or die ("$date\tOpen file \"$error\" error: $!\n");
open (FILE, "> $file") or print (ERROR "$date\tOpen file \"$file\" error: $!\n");


# --- Reading Existing Data (from DB) ---

$open_ok = open (INPUT, "< $db") or print (ERROR "$date\tOpen file \"$db\" error: $!\n");
if ($open_ok) {
  @db_data = <INPUT>;
  close (INPUT) or print (ERROR "$date\tClose file \"$db\" error: $!\n");

open (DB_BACKUP, "> $db_backup") or (die ("$date\tCreate file \"$db_backup\" error: $!\n") and print (ERROR "$date\tOpen file \"$db_backup\" error: $!\n"));

$i = 0;
while ($db_data[$i]) {
  print DB_BACKUP "$db_data[$i]";
  $i++;
}

close (DB_BACKUP) or print (ERROR "$date\tClose file \"$db_backup\" error: $!\n");
  
  # --- Writing Data to an Output File ---
  $i = 0;
  while ($db_data[$i]) {
    print FILE "$db_data[$i]";
    $i++;
  }
  
  print FILE "!!!NEW_DATA_BEGINS_HERE!!!\n";
  
  
#	--= Reading Incoming Parameters (Begin) =--
$method = $ENV{'REQUEST_METHOD'};

if ($method eq "GET") {
$incoming_data = $ENV {'QUERY_STRING'};
$read_bytes = length ($incoming_data);
}
else {
$read_bytes = read (STDIN,$incoming_data,$ENV{'CONTENT_LENGTH'});
}

if ($read_bytes) {
$incoming_data =~ s/%(..)/pack ("C", hex ($1))/eg;
$incoming_data =~ tr/+/ /;
@incoming_parameters = split (/&/, $incoming_data);
}
else {
$open_ok = open (IN_DATA, "< $in_folder") or print (ERROR "$date\tOpen file \"$in_folder\" error: $!\n");
if ($open_ok) {
@incoming_parameters = <IN_DATA>;
foreach $parameter (@incoming_parameters){
#$parameter =~ s[ *\n][]g;
chomp ($parameter);
}
$beginning_dir = $incoming_parameters[0];
close (IN_DATA) or print (ERROR "$date\tClose file \"$temp\" error: $!\n");
}
else {
$beginning_dir = "\.";
}
#print $beginning_dir;
}
#	--= Reading Incoming Parameters (End) =--


#	--= (Begin) =--

($beginning_dir eq "\\") ? ($cur_dir = "\\") : ($cur_dir = "$beginning_dir\\");
$i=0;
$descriptor = "DIR";
$temp2 = (@all_files = glob "${cur_dir}*.*");
print FILE "$y-$MONTH[$M]-$md\t$beginning_dir\tdir\n";  
&read_dir ($beginning_dir,$descriptor);



# --- end of the first "$open_ok" ---
}



sub read_dir {
  my ($dir,$descriptor) = @_;
  my ($temp,$temp2,$temp3,@empty,$attention,@index_exist,$open_ok,$file,$i,$j,@all_jpg,@full_jpg,@all_files,@index_html,$read_ok,$file_contents,$width,$height);
  $open_ok = opendir ($descriptor, "$dir") or print (ERROR "$date\tOpen dir \"$dir\" error: $!\n");
  if ($open_ok){
    while ($file = readdir $descriptor){
      next if (($file eq "..") or ($file eq "."));
      ($dir eq "\\") ? ($full_file = "\\$file") : ($full_file = "$dir\\$file");
      
      if (-d $full_file){
	    $i++;

        print FILE "$y-$MONTH[$M]-$md\t$full_file\tdir\n";
#        $hash{$full_file} = "dir";
        $descriptor_new = "$descriptor$i";
        &read_dir ($full_file,$descriptor_new);
      }
      else{
        print FILE "$y-$MONTH[$M]-$md\t$full_file\tfile\n";
      }
    }
  }
  closedir $descriptor or print (ERROR "$date\tClose dir \"$descriptor\" error: $!\n");
}


close (FILE) or print (ERROR "$date\tClose file \"$file\" error: $!\n");;
close (ERROR) or die ("$date\tClose file \"$error\" error: $!\n");
