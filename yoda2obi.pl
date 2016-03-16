#!/usr/bin/perl
#
# Edit by Tony Cheng
#

$new_sn = `/bin/date +\%y\%m\%d\%H\%M`; chomp $new_sn;
$new_ip = "1.2.3.4";
$working_dir = "/var/named/chroot/var/named";
system "cd $working_dir/../;/bin/tar zcvf named-$new_sn.tar.gz named/";
#@domain = `ls -l $working_dir/*.hosts|awk '{print \$8}'`;
@domain = `/bin/ls -l $working_dir/strongniche*.hosts|/bin/awk '{print \$8}'`;
foreach (@domain) {
    chomp;
    $filename_read = $_;
    $_ =~ s/chroot\/var\/named/chroot\/var\/named\/newip/;
    $filename_write = $_;
    open (FHR, "$filename_read") or die "can't open $filename_read: $!\n";
    open (FHW, ">$filename_write") or die "can't open $filename_write: $!\n";
    while (<FHR>) {
        $_ =~ s/\d+; Serial Number/$new_sn; Serial Number/ if (/; Serial Number/);
        $_ =~ s/5.6.7.8/$new_ip/ if (/5.6.7.8/);
        print FHW $_;
    }
    close (FHW); close (FHR);
}
print "Done!\n";
system "mv -f $working_dir/newip/* $working_dir;chown -R named:named /var/named/chroot/var/named";
system "/sbin/service named restart";
