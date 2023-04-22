#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

#public ip

pub_ip=$(
  wget -qO- https://ipecho.net/plain
  echo
)

#root check

if ! [ $(id -u) = 0 ]; then
  echo -e "${RED}Plese run the script with root privilages!${ENDCOLOR}"
  exit 1
fi

########################################################################
###                                                                  ###
###                       SETUP FUNCTIONS                            ###
###                                                                  ###
########################################################################
clear
declare process_echo_history
declare last_process_status
APPDIR=$APPDIR

spinner() {
  #spinner animation
  local pid=$!
  local delay=0.20
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  wait $pid
  last_process_status=$?
  printf "    \b\b\b\b"
}

process_echo() {
  local RED=$(tput setaf 1)
  local GREEN=$(tput setaf 2)
  local YELLOW=$(tput setaf 3)
  local ENDCOLOR=$(tput sgr0)
  local text="$1"
  local text_color=${!2:-$(tput sgr0)}
  local characters=${#text}
  local start_col=$(($(tput cols) / 2 - $characters / 2))
  local start_line=$(($(tput lines) / 2))
  local spinner_col=$(($(tput cols) - 7))
  tput civis
  clear
  echo -e "$process_echo_history"

  tput cup $start_line $start_col
  tput el
  echo -en "${text_color}$text${ENDCOLOR}"

  tput cup $start_line $spinner_col

  spinner
  p_status=$([ "$last_process_status" -eq 0 ] && echo "${GREEN}[DONE]${ENDCOLOR}" || echo "${RED}[FAIL]${ENDCOLOR}")
  echo -e "${GREEN}${p_status}${ENDCOLOR}"
  process_echo_history+="\n $text ${p_status}"
  sleep 0.5
  tput clear
  echo -e "$process_echo_history $ENDCOLOR"
  sleep 0.2
  tput cvvis
  tput cnorm
}

#Install package

prepare(){

  apt-get update -y && apt-get upgrade -y
  apt install figlet lolcat -y
}

install_dependency() {
  apt install -y unzip cmake build-essential nodejs dropbear git socat
  apt install screenfetch -y
  apt install dialog -y
}

#Setup shell banner

shell_banner_setup(){


figlet -c "SSLaB - SSH" | /usr/games/lolcat && figlet -f digital -c "MADE WITH LOVE BY PROJECT SSLaB LK " | /usr/games/lolcat

echo ""
echo ""
echo ""
echo -e "                       \033[05;31mWELCOME THE SSLAB PANEL \033[05;33m\033[0m"
echo ""
echo -e "                       \033[05;31mIntroduction \033[05;33m....\033[0m"
echo ""
echo ""
echo -e "\033[1;31m• \033[1;33mUSE UBUNTU 20 / DEBIAN 11 FOR BETTER EXPERIENCE\033[0m"
echo ""
echo ""
echo -ne "\n${CYAN}Press Enter key to Continue The Script"
read
clear
figlet -c "SSLaB - SSH" | /usr/games/lolcat && figlet -f digital -c "MADE WITH LOVE BY PROJECT SSLaB LK " | /usr/games/lolcat

}

#Configuring dropbear

pre_dropbear() {

  mkdir $APPDIR
  mv /etc/default/dropbear /etc/default/dropbear.backup
  cat <<EOF >/etc/default/dropbear
NO_START=0
DROPBEAR_PORT=444
DROPBEAR_EXTRA_ARGS=
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
}

#Adding the banner

add_banner() {
  cat <<EOF >/etc/banner
<h1 style="text-align:center;"><span style="color:#332ebf;">&#8734; PROJ&#926;CT SSL&#916;B LK &#8734;</span></h1>
<h3 style="text-align:center;"><span style="color:#20B2AA;">&#9734; PRIVATE SERVER &#9734;</span></h3>
<h4 style="text-align:center;"><span style="color:#8b00ff">========================<span style="color:#ffffff"></span></span></h4>
<h4 style="text-align:center;"><span style="color:#A52A2A;">&#187; NO SPAM !!! &#171;</span></h4><h4 style="text-align:center;"><span style="color:#A52A2A;">&#187; NO DDOS !!! &#171;</span></h4><h4 style="text-align:center;"><span style="color:#A52A2A;">&#187; NO HACKING !!! &#171;</span></h4><h4 style="text-align:center;"><span style="color:#A52A2A;">&#187; NO TORRENT !!! &#171;</span></h4><h4 style="text-align:center;"><span style="color:#A52A2A;">&#187; NO OVER DOWNLOADING !!! &#171;</span></h4>
<h4 style="text-align:center;"><span style="color:#8b00ff">========================<span style="color:#ffffff"></span></span></h4>
<h5 style="text-align:center;"><span style="color:#FF6347;">&#9055; SSH PANEL 1.0 &#9055;</span></h5>
<h6 style="text-align:center;"><span style="color:#FF6347;">- Beta Version -</span></h6>
EOF
}
#Badvpn install

pre_badvpn() {

  cd $HOME
  wget https://github.com/ambrop72/badvpn/archive/master.zip
  unzip master.zip
  rm master.zip
  cd badvpn-master
  mkdir build
  cd build
  cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
  make install
  cd $HOME
}
#Proxy JavaScript Install

pre_Proxy() {

  cat <<EOF >/etc/systemd/system/nodews1.service
[Unit]
Description=P7COM-nodews1
Documentation=https://p7com.net/
After=network.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=node $APPDIR/proxy3.js -dhost 127.0.0.1 -dport 444 -mport 80
Restart=on-failure
RestartPreventExitStatus=1

[Install]
WantedBy=multi-user.target
EOF

  #proxy java

  cat <<EOF >$APPDIR/proxy3.js
/*
* Proxy Bridge
* Copyright PANCHO7532 - P7COMUnications LLC (c) 2021
* Dedicated to Emanuel Miranda, for giving me the idea to make this :v
*/
const net = require('net');
const stream = require('stream');
const util = require('util');
var dhost = "127.0.0.1";
var dport = "8080";
var mainPort = "8888";
var outputFile = "outputFile.txt";
var packetsToSkip = 0;
var gcwarn = true;
for(c = 0; c < process.argv.length; c++) {
    switch(process.argv[c]) {
        case "-skip":
            packetsToSkip = process.argv[c + 1];
            break;
        case "-dhost":
            dhost = process.argv[c + 1];
            break;
        case "-dport":
            dport = process.argv[c + 1];
            break;
        case "-mport":
            mainPort = process.argv[c + 1];
            break;
        case "-o":
            outputFile = process.argv[c + 1];
            break;
    }
}
function gcollector() {
    if(!global.gc && gcwarn) {
        console.log("[WARNING] - Garbage Collector isn't enabled! Memory leaks may occur.");
        gcwarn = false;
        return;
    } else if(global.gc) {
        global.gc();
        return;
    } else {
        return;
    }
}
function parseRemoteAddr(raddr) {
    if(raddr.toString().indexOf("ffff") != -1) {
        //is IPV4 address
        return raddr.substring(7, raddr.length);
    } else {
        return raddr;
    }
}
setInterval(gcollector, 1000);
const server = net.createServer();
server.on('connection', function(socket) {
    var packetCount = 0;
    //var handshakeMade = false;
    socket.write("HTTP/1.1 101 SSLAB-CLOUDFRONT\r\nContent-Length: 1048576000000\r\n\r\n");
    console.log("[INFO] - Connection received from " + socket.remoteAddress + ":" + socket.remotePort);
    var conn = net.createConnection({host: dhost, port: dport});
    socket.on('data', function(data) {
        //pipe sucks
        if(packetCount < packetsToSkip) {
            //console.log("---c1");
            packetCount++;
        } else if(packetCount == packetsToSkip) {
            //console.log("---c2");
            conn.write(data);
        }
        if(packetCount > packetsToSkip) {
            //console.log("---c3");
            packetCount = packetsToSkip;
        }
        //conn.write(data);
    });
    conn.on('data', function(data) {
        //pipe sucks x2
        socket.write(data);
    });
    socket.once('data', function(data) {
        /*
        * Nota para mas tarde, resolver que diferencia hay entre .on y .once
        */
    });
    socket.on('error', function(error) {
        console.log("[SOCKET] - read " + error + " from " + socket.remoteAddress + ":" + socket.remotePort); sock
        conn.destroy();
    });
    conn.on('error', function(error) {
        console.log("[REMOTE] - read " + error);
        socket.destroy();
    });
    socket.on('close', function() {
        console.log("[INFO] - Connection terminated for " + socket.remoteAddress + ":" + socket.remotePort);
        conn.destroy();
    });
});
server.listen(mainPort, function(){
    console.log("[INFO] - Server started on port: " + mainPort);
    console.log("[INFO] - Redirecting requests to: " + dhost + " at port " + dport);
});

EOF
}

pre_Proxy_start() {

  systemctl enable nodews1
  systemctl start nodews1
  systemctl stop nodews1.service # port 80 free
}

post_Stunnel() {
  cd /etc/stunnel
  cat <<EOF >/etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
cert = $APPDIR/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[https]
accept = 443
connect = 127.0.0.1:80
EOF

  clear
  figlet -c "SSLaB - SSH" | /usr/games/lolcat && figlet -f digital -c "MADE WITH LOVE BY PROJECT SSLaB LK " | /usr/games/lolcat
  echo ""
  echo ""

  #read -p "📧 Please Enter a valid email address: " zerossl_email
  #read -p "🌏 Please Enter the domain name: " zerossl_domain
  #
  #
  #mkdir $APPDIR/certs; pushd $APPDIR/certs
  #git clone https://github.com/acmesh-official/acme.sh.git
  #cd acme.sh

  #curl https://get.acme.sh | sh -s email="$zerossl_email" --issue -d "$zerossl_domain" --standalone --server letsencrypt --staging --test

  #bash acme.sh --register-account -m "$zerossl_email"
  #bash acme.sh --issue --standalone -d "$zerossl_domain" --force --staging --test
  #bash acme.sh --installcert -d "$zerossl_domain" --fullchainpath $APPDIR/certs/bundle.cer --keypath $APPDIR/certs/private.key
  #
  #
  #cat $APPDIR/certs/private.key $APPDIR/certs/bundle.cer > $APPDIR/stunnel.pem
  #

  #### download zerossl zipfile
  ###
  ###mkdir zerossl && cd zerossl
  ###read -p "What's your zerossl zip file link? (Dropbox): " zerofileslink
  ###
  ###wget $zerofileslink
  ###
  ####unzip_zerossl_zipfile
  ###
  ###unzip *
  ###
  ###cat private.key certificate.crt ca_bundle.crt > /etc/stunnel/stunnel.pem
  ###
  ###cd ..
  ###rm -rf zerossl
  ###clear

}

# zerossl-setup sub function - acme.sh install

acme_setup() {
  echo -e "acme.sh standalone webserver (Beta)\n\n"
  read -p "Please provide a valid email address: " zerossl_email
  read -p "Please provide the domain name: " zerossl_domain

  systemctl stop nodews1 2>&1 >/dev/null
  process_echo "Disabling nodews1 proxy script to clear the port 80 temporary"
  #              curl https://get.acme.sh | sh -s email="$zerossl_email" --issue -d "$zerossl_domain" --standalone --server letsencrypt --staging --test
  #              cat ~/.acme.sh/"$zerossl_domain"/"$zerossl_domain".key ~/.acme.sh/"$zerossl_domain"/"$zerossl_domain" ~/.acme.sh/"$zerossl_domain"/fullchain.cer >/etc/stunnel/stunnel.pem

  curl https://get.acme.sh | sh -s email="$zerossl_email" >/dev/null 2>&1 &
  process_echo "Installing acme.sh..."
  bash ~/.acme.sh/acme.sh --register-account -m "$zerossl_email" >/dev/null 2>&1 &
  process_echo "Registering zerossl account..."
  #    bash ~/.acme.sh/acme.sh --issue --standalone -d "$zerossl_domain" --force --staging --test >/dev/null 2>&1 &
  if [[ "$1" == "stage" ]]; then
	  echo "running acme staging command"
    bash ~/.acme.sh/acme.sh --issue --standalone -d "$zerossl_domain" --force --staging --test >/dev/null 2>&1 &
  else
	  echo "running acme production command"
    bash ~/.acme.sh/acme.sh --issue --standalone -d "$zerossl_domain" --force >/dev/null 2>&1 &
  fi
  process_echo "issuing standalone certificates..."
  bash ~/.acme.sh/acme.sh --installcert -d "$zerossl_domain" --fullchainpath "$certs_dir"/bundle.cer --keypath "$certs_dir"/private.key >/dev/null 2>&1 &
  process_echo "Installing certificates..."
  cat "$certs_dir"/private.key "$certs_dir"/bundle.cer >$APPDIR/stunnel.pem
  chmod 400 $APPDIR/stunnel.pem

  systemctl start nodews1 2>&1 >/dev/null
  process_echo "Starting service nodews1 proxy script back online"
}

# zerossl setup function
zerossl_setup() {
  mkdir $APPDIR/certs
  cd $APPDIR/certs
  local certs_dir=${PWD}

  TERMINAL=$(tty)
  HEIGHT=15
  WIDTH=40
  CHOICE_HEIGHT=4
  BACKTITLE="Coded by @BlurryFlurry & @noobconner21"
  TITLE="Zerossl setup"
  MENU="Choose one of the following methods for zerossl setup:"

  OPTIONS=(1 "Upload certs zip file manually"
  2 "Download url to certs zip"
  3 "acme.sh auto setup (test certs)"
  4 "acme.sh auto setup (production)")

  CHOICE=$(dialog --nocancel --clear \
    --backtitle "$BACKTITLE" \
    --title "$TITLE" \
    --menu "$MENU" \
    $HEIGHT $WIDTH $CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 >"$TERMINAL")

  clear
  case $CHOICE in
  1)
    echo "Manually upload zerossl zip file to $(pwd) directory"
    # zerossl cert files steps for manually upload
    clear
    echo -e " Step 1: visit https://zerossl.com, \n Step 2: login, \n Step 3: verify domain and download certificate files, \n Step 4: upload the zip file to $(pwd)/ directory \n"
    echo .
    read -r -s -p $'Press ESCAPE to continue...\n' -d $'\e'
    until [ "$(ls ./*.zip)" ]; do
      read -r -s -p $'Certs directory is still empty, Please upload files and press ESCAPE to continue...\n' -d $'\e'
    done

    ;;
  2)
    echo "Provide a direct remote download link to fetch the zerossl certificate zip file"
    read -p "What's your zerossl zip file link? (Dropbox): " zerofileslink
    until [ "$(curl -o /dev/null --silent --head --write-out '%{http_code}' $zerofileslink 2>/dev/null)" -eq 200 ]; do
      read -p $'\e[31mPlease provide a valid download url to your zerossl zip file (Dropbox)\e[0m: ' zerofileslink
    done
    wget "$zerofileslink"

    until [ "$(ls ./*.zip)" ]; do
      read -r -s -p $'\e[31m Certs directory is still empty, Please upload files and press ESCAPE to continue...\e[0m \n' -d $'\e'
    done
    ;;
  3)
    acme_setup stage
    ;;
  4)
    acme_setup live
    ;;
  esac
  # unzip certs, create stunnel.pem, start stunnel service
  if [ ! -f "$APPDIR/stunnel.pem" ]; then
    unzip ./*.zip
    cat private.key certificate.crt ca_bundle.crt >$APPDIR/stunnel.pem
    chmod 600 $APPDIR/stunnel.pem
  fi
  systemctl start stunnel4
  systemctl enable stunnel4
}

# Stunnel install

install_stunnel() {
  apt install stunnel4 -y
}

start_stunnel() {
  sudo systemctl enable stunnel4
  systemctl start stunnel4
  systemctl start nodews1.service
}

#creating badvpn systemd service unit

creating_badvpn() {

  cat <<'EOF' >/etc/systemd/system/badvpn.service
[Unit]
Description=BadVPN UDPGW Service

[Service]
ExecStart=/bin/bash -c '$$(which badvpn-udpgw) --listen-addr 127.0.0.1:7300 --max-clients 250 --max-connections-for-client 3'
ExecStop=/bin/bash -c '$$(pkill) badvpn-udpgw'

[Install]
WantedBy=multi-user.target
EOF
}

start_badvpn() {
  systemctl enable badvpn
  systemctl start badvpn
}

#install Panel

install_panel() {
  cd $APPDIR
  wget https://github.com/noobconner21/project1/raw/main/etc.zip
  unzip etc
  cd $APPDIR/etc
  mv menu /usr/local/bin
  wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
  chmod +x ChangeUser.sh
  chmod +x UserManager.sh
  chmod +x Banner.sh
  chmod +x DelUser.sh
  chmod +x ListUsers.sh
  chmod +x RemoveScript.sh
  chmod +x speedtest-cli
  chmod +x moniter.sh
  cd /usr/local/bin
  chmod +x menu

}

#enabling and starting all services

restart_system() {
  systemctl restart nodews1
  systemctl restart stunnel4
  sudo systemctl restart udpgw
  sudo systemctl restart badvpn
  #configure user shell to /bin/false
  echo /bin/false >>/etc/shells
  clear
}

########################################################################
###                                                                  ###
###                       INSTALL PROCESS                            ###
###                                                                  ###
########################################################################

prepare >/dev/null 2>&1 &
process_echo "Preparing the server..."

shell_banner_setup

echo -ne "\n${CYAN}● Installing Packages               ..."
install_dependency >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo ""
echo -ne "\n${CYAN}● Installing Dropbear               ..."
pre_dropbear >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo ""
echo -ne "\n${CYAN}● Adding default SSL Banner         ..."
add_banner >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo ""
echo -ne "\n${CYAN}● Installing Badvpn                 ..."
pre_badvpn >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo ""
echo -ne "\n${CYAN}● Installing Proxy JavaScript       ..."
pre_Proxy >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo ""
echo -ne "\n${CYAN}● Starting Proxy JavaScript         ..."
pre_Proxy_start >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo ""
echo -ne "\n${CYAN}● Installing Stunnel                ..."
install_stunnel >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo -e "${ENDCOLOR}"

post_Stunnel

echo -ne "\n${CYAN}● Starting Stunnel ..."
start_stunnel >/dev/null 2>&1 &
spinner
echo -ne "\tdone"

zerossl_setup

echo ""
echo -ne "\n${CYAN}● Installing Badvpn UDPW ..."
creating_badvpn >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo ""
echo -ne "\n${CYAN}● Starting Badvpn ..."
start_badvpn >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo ""
echo -ne "\n${CYAN}● Installing SSH Panel ..."
install_panel >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo
echo

echo -ne "\n${RED}● Restart Services ..."
restart_system >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo -e "${ENDCOLOR}"

clear
figlet -c "SSLaB - SSH" | /usr/games/lolcat && figlet -f digital -c "MADE WITH LOVE BY PROJECT SSLaB LK " | /usr/games/lolcat
echo ""
echo ""

#Adding the default user
echo -ne "${GREEN}Enter the default username : "
read username
while true; do
  read -p "Do you want to genarate a random password ? (Y/N) " yn
  case $yn in
  [Yy]*)
    password=$(
      tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c${1:-9}
      echo
    )
    break
    ;;
  [Nn]*)
    echo -ne "Enter password : "
    read password
    break
    ;;
  *) echo "Please answer yes or no." ;;
  esac
done
echo -ne "Enter the expiration date : "
read nod
exd=$(date +%F -d "$nod days")
useradd -e $exd -M -N -s /bin/false $username && echo "$username:$password" | chpasswd &&
  clear &&
  echo -e "${GREEN}-------------------- Default User Details --------------------" &&
  echo -e "" &&
  echo -e "${GREEN}\nUsername :${YELLOW} $username" &&
  echo -e "${GREEN}\nPassword :${YELLOW} $password" &&
  echo -e "${GREEN}\nExpire Date :${YELLOW} $exd ${ENDCOLOR}" ||
  echo -e "${RED}\nFailed to add default user $username please try again.${ENDCOLOR}"

#exit script
echo -e "\n${CYAN}Script installed. You can access the panel using 'menu' command. ${ENDCOLOR}\n"
echo -e "\nPress Enter key to exit"
read

reboot
