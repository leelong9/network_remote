#! /bin/bash
#~dafault port?, can i use root to download commands, fresh linux means sshopen? which parts are automated?
#~ if using &> /dev/null, do not need if brackets and variables
#~ DATE_TIME=$(date)
#~ TIME=$(date | awk '{print $1 $2 $3}')

#~ Create By:ONG LEE LONG S22
#~ UNIT: CFC020223
#~ LECTURER:JAMES


CURRENT_DIR=$(pwd)
LOGTIME(){
	
	date +"%Y %m %d  %H:%M"
	
	}
	
	

	
#~ ask for user password 
echo "$(LOGTIME) Script started." >> mylog
echo 'Enter Current Machine(Kali) password. (For installation of commands).'
read kalipasswd
echo -e "\n\n\n"

echo Updating/Upgrading packages...
sleep 3
echo "$kalipasswd" | sudo -S apt-get update -y 
echo "$kalipasswd" | sudo -S apt-get upgrade -y 
echo "$kalipasswd" | sudo -S apt-get dist-upgrade -y 
echo "$(LOGTIME) Updating/Upgrading Packages." >> mylog
echo -e "\n\n\n\n"
#~ check whether commands already installed
for cmd in  nmap whois sshpass #~run command for each inputs
do  

 if command -v "$cmd" &> /dev/null
 then
   echo "$cmd is already installed"
   echo "$(LOGTIME) $cmd is already installed." >> mylog
 else
  echo "$cmd is not installed.Proceed to install."
  echo "$kalipasswd" | sudo -S apt-get install "$cmd" -y &> /dev/null #~ -S reads password from STDIN
  echo "$(LOGTIME) Installing $cmd" >> mylog 
 fi
 
 done

 #~ check whether geoip-bin already installed
 if command -v geoiplookup &> /dev/null
 then
   echo "geoip-bin is already installed"
   echo "$(LOGTIME) geoip-bin is already installed." >> mylog
 else
  echo "geoip-bin is not installed.Proceed to install."
  echo "$kalipasswd" | sudo -S apt-get install geoip-bin -y &> /dev/null #~ -S reads password from STDIN
   echo "$(LOGTIME) Installing geoip-bin" >> mylog 
 fi
 
 #~ check whether Nipe already installed.
nipee=$(find / -type d -name nipe 2>/dev/null)                  #~nipe installed  
 if [ $nipee  ] 
 then
    echo "Nipe is already installed. Checking for status..."
    echo "$(LOGTIME) Nipe is already installed. Checking for status." >> mylog
    cd "$CURRENT_DIR"
    cd nipe
    nipestatus=$(echo $kalipasswd | sudo -S perl nipe.pl status | grep -i Status | awk '{print $3}' )
    #~ echo $kalipasswd | sudo -S perl nipe.pl start
    #~ echo $kalipasswd | sudo -S perl nipe.pl restart
    #~ echo $kalipasswd | sudo -S perl nipe.pl status
    if [ $nipestatus == true  &>/dev/null  ]             #~nipe started
    then
 
    
    spoofedip=$(echo $kalipasswd | sudo -S perl nipe.pl status | grep -i Ip | awk '{print $3}')
    spoofedcountry=$(geoiplookup $spoofedip | awk '{print $5}')
    
    echo -e "\nYou are anonymous." 
    echo -e "Your Spoofed IP address is $spoofedip. Spoofed Country : $spoofedcountry\n"
    echo "$(LOGTIME) Nipe started. Spoofed IP address:$spoofedip. Spoofed Country:$spoofedcountry." >> mylog
    cd ..  #~ go back to original directory
    
    
  
    
    
    
    else												#~nipe not started
    
    
    echo -e "\nYou are not anonymous. Please start Nipe before starting the script."
    echo Exiting ...
    cd ..
    echo "$(LOGTIME) Nipe not started. Exit script." >> mylog
    exit   
    
    fi
     
    
    
 else                                                     #~nipe not installed
    echo "Nipe is not installed.Proceed to install."
    cd "$CURRENT_DIR"
    echo "$(LOGTIME) Installing Nipe" >> mylog
    git clone https://github.com/htrgouvea/nipe
    cd nipe
    yes | sudo cpan install Try::Tiny Config::Simple JSON
	sudo perl nipe.pl install 
    #~ echo $kalipasswd | sudo -S perl nipe.pl start
    #~ echo $kalipasswd | sudo -S perl nipe.pl restart
    #~ echo $kalipasswd | sudo -S perl nipe.pl status 
    echo -e "\nYou are not anonymous. Please start Nipe before starting the script."
    cd ..
    echo "$(LOGTIME) Nipe installed and not started. Exit script. " >> mylog
    exit
 fi

#~ echo "$DATE_TIME All necessary commands installed" >> mylog
echo "$(LOGTIME) All necessary commands installed" >> mylog

#~ ---------------------------------------------------------------------------------


#~ ask user for remote server information and which victim to scan

echo -e "Enter Remote Server Username"
read remoteusr
echo -e "\nEnter Remote Server Password"
read remotepasswd
echo -e "\nEnter Remote Server Ip Address"
read remoteip
echo -e "\nEnter Remote Server Port"
read remoteport
echo -e "\nDomain/IP address to scan:"
read victim

#~ connects to remote server and scan victim

echo -e "\nConnecting to remote server@$remoteip:\n"
echo "$(LOGTIME) Connecting to remote server@$remoteip." >> mylog
sshpass -p $remotepasswd ssh -t -t -o StrictHostKeyChecking=no $remoteusr@$remoteip -p $remoteport victim="$victim" '


 
curl -L ipconfig.me > ipaddr.txt 2> /dev/null;
echo "Current user: $(whoami)";
echo -e "Current Directory: $(pwd)\n";
uptime;
echo -e "\nExternal IP Address:";
cat ipaddr.txt;
echo -e;
whois $(cat ipaddr.txt) | grep -i country | sort | uniq | tr c C;

mkdir Scanned_$victim &> /dev/null;
cd Scanned_$victim;
echo "Scanning $victim. Saved data in nmap_$victim.txt.";
nmap $victim -Pn -vv  > "nmap_$victim.txt";
echo "Whoising $victim. Saved data in whois_$victim.txt.";
whois $victim > "whois_$victim.txt";
echo Save files into Scanned_$victim directory.;
exit 
'


echo "$(LOGTIME) Scanned $victim and saved data into Scanned_$victim directory." >> mylog




#~ copy folder to local
echo -e "\nCopying Scanned_$victim directory to $CURRENT_DIR." 
sleep 3
sshpass -p "$remotepasswd" scp -rP $remoteport $remoteusr@$remoteip:"~/Scanned_$victim" .
  
  



echo "$(LOGTIME) Copied Scanned_$victim directory to $CURRENT_DIR." >> mylog
echo "Log Files located at $CURRENT_DIR named mylog."
#~ ---------------------------------------------------------------























#~ ) | tee -a ./project.log   #~ logging


#~ sshpass -p tc ssh -t -t tc@192.168.111.130 '
#~ nmap scanme.nmap.com -Pn -vv ;
#~ whois 8.8.8.8;
#~ echo tc | sudo -S -s "whoami; ";

#~ '



#~ if ! command -v nmap   &> /dev/null   #~ check for nmap  installed and discard output into nullfile
#~ then
    #~ sudo apt-get install nmap #~  command not installed
    
#~ else 

    #~ echo its here        #~ command  installed
    #~ exit
#~ fi




