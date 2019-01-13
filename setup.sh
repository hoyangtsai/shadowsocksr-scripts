#!/bin/bash

setupEnv(){
  yum update -y
  yum install git jq -y
  cd ~/
  git clone https://github.com/shadowsocksr-backup/shadowsocksr.git
  cd shadowsocksr/
  git checkout -b manyuser origin/manyuser
  git clone https://github.com/hoyangtsai/shadowsocksr-scripts.git
}

editConfig() {
  JQR=""
  
  echo "What's the password?"
  read -p PASSWORD
  if [ $PASSWORD ]; then
    JQR=".password=\"$PASSWORD\""
  fi

  # echo "What's the server port?"
  # read PORT
  # if [ $PORT ]; then
  #   JQR="$JQR | .server_port=$PORT"
  # fi

  cat shadowsocksr-scripts/user-config.json | jq "$JQR" > user-config.json
    
  echo "Edit user-config.json done!!"
}

setupIPtables(){
  echo "Which port is enabled?"
  read -p PORT
  iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
  iptables -I INPUT -p udp --dport $PORT -j ACCEPT
  /etc/rc.d/init.d/iptables save
  /etc/init.d/iptables restart

  echo "Edit iptables done!!"
}

setupBBR(){
  wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
  chmod a+x bbr.sh
  ./bbr.sh
}

setupEnv
editConfig
setupIPtables
setupBBR

echo "Setup completed!!"