#!/bin/bash
#
#	crea-servverkey.bash
#	Create CA certificate and server certificate
#	(C) Luca Romano 2021
#
#
#
#
#############################################################################
#
#--> Global variables
#
CNX_PRG_NAME=$0
CNX_PATH_TO_OVPN=$HOME/openVPN
CNX_PATH_TO_EASYRSA=$CNX_PATH_TO_OVPN/EasyRSA
CNX_PATH_TO_CA=$CNX_PATH_TO_OVPN/ca
CNX_PATH_TO_PKI=$CNX_PATH_TO_OVPN/pki
CNX_PATH_TO_SERVER=$CNX_PATH_TO_OVPN/servers
CNX_CN=""
CNX_YN=""
CNX_SERVERNAME="server"
CNX_COMPLETED="N"

function confirm() {
	CNX_YN=""
	while [ "$CNX_YN" != "y" ]  && [ "$CNX_YN" != "Y" ] && [ "$CNX_YN" != "n" ] && [ "$CNX_YN" != "N" ]
	do
		echo "$1 (Y/N) ?"
		read CNX_YN
	done
}

function quit() {
	echo "$CNX_PRG_NAME: $1"
	exit 1
}

function select_cn() {
	CNX_CN=""
	while [ "$CNX_CN" == "" ]
	do
		echo "Please enter the common name (CN) for this server; q to quit"
		read CNX_CN
	done
}

function select_server_name() {
	CNX_SERVERNAME="server"
	echo "Please enter the name used to generate file or hit enter to accept default of '$CNX_SERVERNAME'; q to quit"
	read CNX_SERVERNAME
	if [ "$CNX_SERVERNAME" == "" ]
	then
		CNX_SERVERNAME="server"
	fi
}

function select_server_net() {
	CNX_SERVERNET=""
	echo "Please enter the network used by this server or hot return to accept default of '10.8.0.0'; q to quit"
	read CNX_SERVERNET
	if [ "$CNX_SERVERNET" == "" ]
	then
		CNX_SERVERNET="10.8.0.0"
	fi
}

function select_server_subnet() {
	CNX_SERVERSUBNET=""
	echo "Please enter the subnet used by this server or hit return to accept default of '255.255.255.0'; q to quit"
	read CNX_SERVERSUBNET
	if [ "$CNX_SERVERSUBNET" == "" ]
	then
		CNX_SERVERSUBNET="255.255.255.0"
	fi
}

#
#--> Message start
#
echo "---- $CNX_PRG_NAME: Create CA certificate and key for OpenVPN SERVER ----"

#
#--> MAIN part of script
#
if [ ! -d "$CNX_PATH_TO_EASYRSA" ]
then
	echo "Directory $CNX_PATH_TO_EASYRSA does NOT exist!"
	echo "Please download EasyRSA by doing:"
	echo
	echo "wget -P $CNX_PATH_TO_OVPN https://github.com/OpenVPN/easy-rsa/releases/download/v<Latest version>/EasyRSA-<Latest version>.tgz"
	echo "Execute tar xvf EasyRSA<Latest version>.tgz in your folder ($CNX_PATH_TO_OVPN)"
	echo "Execute ln -s EasyRSA<Latest version>.tgz EasyRSA"
	echo
	echo "Substitute latest version with the correct value (i.e. 3.0.8)"
	echo "Install EasyRSA and restart this script"
	echo "In EasyRSA folder do mv vars vars.example"
	echo
	quit "missing EasyRSA software, exiting..."
fi

if [ ! -d "$CNX_PATH_TO_PKI" ]
then
	echo "Directory $CNX_PATH_TO_PKI does NOT exist; creating..."
	mkdir $CNX_PATH_TO_PKI
fi

if [ ! -d "$CNX_PATH_TO_CA" ]
then
	echo "Directory $CNX_PATH_TO_CA does NOT exist; creating..."
	mkdir $CNX_PATH_TO_CA
fi

#
#--> LOOP until completed
#
while [ "$CNX_COMPLETED" == "N" ]
do

	select_cn
	if [ "$CNX_CN" == "q" ] || [ "$CNX_CN" == "Q" ]
	then
		quit "exiting upon user request..."
	fi

	select_server_name
	if [ "$CNX_SERVERNAME" == "q" ] || [ "$CNX_SERVERNAME" == "Q" ]
	then
		quit "exiting upon user request..."
	fi

	select_server_net
	if [ "$CNX_SERVERNET" == "q" ] || [ "$CNX_SERVERNET" == "Q" ]
	then
		quit "exiting upon user request..."
	fi

	select_server_subnet
	if [ "$CNX_SERVERSUBNET" == "q" ] || [ "$CNX_SERVERSUBNET" == "Q" ]
	then
		quit "exiting upon user request..."
	fi

	confirm "Generating CA and CERTIFICATE for SERVER called -> $CNX_SERVERNAME with Common Name (CN) -> $CNX_CN\nVPN network -> $CNX_SERVERNET, subnet $CNX_SERVERSUBNET"
	if [ "$CNX_YN" == "n" ] || [ "$CNX_YN" == "N" ]
	then
		continue
	fi

	CNX_PATH_TO_CFG="$CNX_PATH_TO_CA/$CNX_CN.vars"
	if [ ! -f "$CNX_PATH_TO_CFG" ]
	then
		echo "Configuration file $CNX_PATH_TO_CFG does NOT exist!"
		echo
		echo "Copy the example file (vars.example) located in $CNX_PATH_TO_EASYRSA to $CNX_PATH_TO_CFG"
		echo "cp $CNX_PATH_TO_EASYRSA/vars.example $CNX_PATH_TO_CFG"
		echo
		echo "Edit the file, uncomment the lines listed below and put the correct information"
		echo
		echo "#set_var EASYRSA_REQ_COUNTRY    "US""
		echo "#set_var EASYRSA_REQ_PROVINCE   "California""
		echo "#set_var EASYRSA_REQ_CITY       "San Francisco""
		echo "#set_var EASYRSA_REQ_ORG        "Copyleft Certificate Co""
		echo "#set_var EASYRSA_REQ_EMAIL      "me@example.net""
		echo "#set_var EASYRSA_REQ_OU         "My Organizational Unit""
		echo
		echo "Configure the file $CNX_PATH_TO_CFG and restart the script"
		echo
		quit "missing configuration file, exiting..."
	fi

	if [ ! -d "$CNX_PATH_TO_PKI/$CNX_CN" ]
	then
		echo "Directory $CNX_PATH_TO_PKI/$CNX_CN does NOT exist; creating..."
		mkdir $CNX_PATH_TO_PKI/$CNX_CN
	fi
	CNX_PATH_TO_PKI_CA=$CNX_PATH_TO_PKI/$CNX_CN/ca
	CNX_PATH_TO_PKI_SERVER=$CNX_PATH_TO_PKI/$CNX_CN/server
	cd $CNX_PATH_TO_EASYRSA
	./easyrsa --vars=$CNX_PATH_TO_CFG --pki-dir=$CNX_PATH_TO_PKI_CA init-pki
	./easyrsa --vars=$CNX_PATH_TO_CFG --pki-dir=$CNX_PATH_TO_PKI_CA build-ca nopass
	#
	#--> Done CA
	#
	#--> Server part
	#
	./easyrsa --vars=$CNX_PATH_TO_CFG --pki-dir=$CNX_PATH_TO_PKI_SERVER init-pki
	./easyrsa --vars=$CNX_PATH_TO_CFG --pki-dir=$CNX_PATH_TO_PKI_SERVER gen-req $CNX_SERVERNAME nopass
	./easyrsa --vars=$CNX_PATH_TO_CFG --pki-dir=$CNX_PATH_TO_PKI_CA import-req $CNX_PATH_TO_PKI_SERVER/reqs/$CNX_SERVERNAME.req $CNX_SERVERNAME
	./easyrsa --vars=$CNX_PATH_TO_CFG --pki-dir=$CNX_PATH_TO_PKI_CA sign-req server $CNX_SERVERNAME
	./easyrsa --vars=$CNX_PATH_TO_CFG --pki-dir=$CNX_PATH_TO_PKI_SERVER gen-dh
	sudo openvpn --genkey --secret $CNX_PATH_TO_PKI_SERVER/ta.key 
	sudo chmod 644 $CNX_PATH_TO_PKI_SERVER/ta.key
	mv $CNX_PATH_TO_PKI_CA/issued/$CNX_SERVERNAME.crt $CNX_PATH_TO_PKI_SERVER
	CNX_PATH_TO_SERVER=$CNX_PATH_TO_SERVER/$CNX_SERVERNAME
	mkdir $CNX_PATH_TO_SERVER
	CNX_SERVER_CONF=$CNX_PATH_TO_SERVER/$CNX_SERVERNAME.conf

	echo "#" > $CNX_SERVER_CONF
	echo "# Filename: `basename $CNX_SERVER_CONF`" >> $CNX_SERVER_CONF
	echo "# Automatically generated by script: `basename $CNX_PRG_NAME`" >> $CNX_SERVER_CONF
	echo "# VPN server name: $CNX_SERVERNAME" >> $CNX_SERVER_CONF
	echo "# Date: `date`" >> $CNX_SERVER_CONF
	echo "#" >> $CNX_SERVER_CONF
	cat $CNX_PATH_TO_SERVER/../server.conf.example | sed -e "s/cert xxxxxx/cert $CNX_SERVERNAME/g" \
		| sed -e "s/key xxxxxx/key $CNX_SERVERNAME/g" \
		| sed -e "s/_subnet/$CNX_SERVERNET/g" \
		| sed -e "s/_mask/$CNX_SERVERSUBNET/g" >> $CNX_SERVER_CONF
	cp $CNX_PATH_TO_PKI_SERVER/../ca/ca.crt $CNX_PATH_TO_SERVER
	cp $CNX_PATH_TO_PKI_SERVER/ta.key $CNX_PATH_TO_SERVER
	cp $CNX_PATH_TO_PKI_SERVER/dh.pem $CNX_PATH_TO_SERVER
	cp $CNX_PATH_TO_PKI_SERVER/$CNX_SERVERNAME.crt $CNX_PATH_TO_SERVER
	cp $CNX_PATH_TO_PKI_SERVER/private/$CNX_SERVERNAME.key $CNX_PATH_TO_SERVER
	echo "Server configuration for '$CNX_CN' finished"
	echo "Files are located in $CNX_PATH_TO_SERVER"
	echo
	echo "In the VPN server copy files $CNX_SERVERNAME.conf, $CNX_SERVERNAME.crt, $CNX_SERVERNAME.key, ca.crt, ta.key, dh.pem in /etc/openvpn folder"
	echo "Execute chmod 400 $CNX_SERVERNAME.key ta.key, dh.pem"
	echo "Execute systemctl enable openvpn@$CNX_SERVERNAME"
	echo "Execute systemctl start openvpn@$CNX_SERVERNAME"
	CNX_COMPLETED="Y"
done
