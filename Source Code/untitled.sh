#!/bin/bash
echo -n "Launching automated key generation setup"
echo -n "Enter your distro(ie ubuntu,arch,centos"

read os

case os in
	ubuntu)
		echo -n "Installing strongswan"
		sudo apt install strongswan
		sudo apt install strongswan-pki
		sudo apt install libstrongswan-extra-plugins
		echo -n "Starting strongswan service"
		sudo systemctl enable --now strongswan
		echo -n "Installation complete, now generating certificates"

	centos)
		echo -n "Installing strongswan"
		sudo yum install -y epel-release
		sudo yum install -y openvpn
		sudo yum install -y easy-rsa
		sudo yum install -y strongswan
		echo -n "Starting strongswan service"
		sudo systemctl enable --now strongswan
		echo -n "Installation complete, now generating certificates"
 	arch)
		echo -n "Installing strongswan"
		sudo pacman -S strongswan
		echo -n "Starting strongswan service"
		sudo systemctl enable --now strongswan
		echo -n "Installation complete, now generating certificates"
		;;

	*)
		echo -n "Unknown"
		;;
esac
ipsec pki --gen --outform pem > caKey.pem
ipsec pki --self --in caKey.pem --dn "CN=VPN CA" --ca --outform pem > caCert.pem
openssl x509 -in caCert.pem -outform der | base64 -w0 ; echo
export PASSWORD="password"
export USERNAME="client"

ipsec pki --gen --outform pem > "${USERNAME}Key.pem"
ipsec pki --pub --in "${USERNAME}Key.pem" | ipsec pki --issue --cacert caCert.pem --cakey caKey.pem --dn "CN=${USERNAME}" --san "${USERNAME}" --flag clientAuth --outform pem > "${USERNAME}Cert.pem"

openssl pkcs12 -in "${USERNAME}Cert.pem" -inkey "${USERNAME}Key.pem" -certfile caCert.pem -export -out "${USERNAME}.p12" -password "pass:${PASSWORD}"

echo -n "-----------------certificates generated------------------"

