[root@yoda nagios_command]# cat /root/tony/nagios_command/check_yoda_diskusage.pl
#!/usr/bin/perl
# -------------------------------
# Edit by Tony
# Version : 2014/12/24
# Purpose : Disk Usage Check
#--------------------------------
$hostname = "yoda";
$servicename = "Disk-Yoda";
$nsca_server = "1.2.3.4";
$nsca_config = "/etc/send_nsca.cfg";
#$throttle_warning_percent = 30;
#$throttle_critical_percent = 40;
$throttle_warning_percent = 60;
$throttle_critical_percent = 90;
$min_size = 0;
$debug = 0;

chomp($disk_usage_result = `df -h|grep sda1`);
#[root@yoda nagios_command]# df -h|grep sda1
#Filesystem            Size  Used Avail Use% Mounted on
#/dev/sda1              17G  8.6G  7.2G  55% /
($total_size,$usage_size) = $disk_usage_result =~ /sda1\s+(\S+)G\s+(\S+)G\s+\S+\s+\S+%/;

$disk_usage_percent = sprintf("%.2f",$usage_size/$total_size*100);
$throttle_warning_size = sprintf ("%.2f",$total_size*$throttle_warning_percent/100);
$throttle_critical_size = sprintf ("%.2f",$total_size*$throttle_critical_percent/100);
print "\$usage_size = $usage_size\n" if $debug == 1;
print "\$total_size = $total_size\n" if $debug == 1;
print "\$throttle_warning_size = $throttle_warning_size\n" if $debug == 1;
print "\$throttle_critical_size = $throttle_critical_size\n" if $debug == 1;
print "\$min_size = $min_size\n" if $debug == 1;
print "\$disk_usage_percent= $disk_usage_percent\n" if $debug == 1;

%status_message = (
    "OK"=>"Disk Usage OK: Disk Usage :$disk_usage_percent% is lower than $throttle_warning_percent%",
    "Warn"=>"Disk Usage Warning: Disk Usage :$disk_usage_percent% is in between $throttle_warning_percent% and $throttle_critical_percent%",
    "Critical"=>"Disk Usage Critical: Disk Usage :$disk_usage_percent% is higher than $throttle_critical_percent%",
);

#echo "yoda;Disk-Yoda;0;testOK|yodadisk=3524MB;8640;9000;0;9900"|send_nsca -H 1.2.3.4 -c /etc/send_nsca.cfg -d ";"
#echo "SCALAR(0x909363c);Disk-Yoda;0;Disk Usage OK: Disk Usage :50.59% is lower than 60%|yodadisk=8.60;90959378.40;15.30;151598868.00;17.00"|/usr/local/bin/send_nsca -H 106.104.130.235 -c /etc/send_nsca.conf -d ";"
if ($disk_usage_percent < $throttle_warning_percent) {
    $status_message_final = $status_message{OK};
    $status_code = 0;
} elsif (($disk_usage_percent >= $throttle_warning_percent) && ($disk_usage_percent < $throttle_critical_percent)) {
    $status_message_final = $status_message{Warn};
    $status_code = 1;
} else {
    $status_message_final = $status_message{Critical};
    $status_code = 2;
}

$command = sprintf("echo \"%s;%s;%d;%s|yodadisk=%.2fGB;%.2f;%.2f;%.2f;%.2f\"|/usr/local/bin/send_nsca -H %s -c %s -d \";\"",
          $hostname, $servicename, $status_code, $status_message_final, $usage_size,
          $throttle_warning_size, $throttle_critical_size,
          $min_size, $total_size, $nsca_server, $nsca_config);

system "$command\n";
