#!/bin/bash

clear; echo -ne "\e[104mGetting release....\e[49m" ; sleep 1
release=$(cat /etc/redhat-release | egrep -o '[1-9] ?' | head -1)
dir=$(pwd)
echo -e "\e[104m$release \e[49m"

#Unpack files.
echo -ne "\e[104mExtracting setup files....\e[49m"
mkdir $dir/pkgs &>/dev/null
tar -xvf pkgs.tar -C $dir/pkgs/ &>/dev/null
echo -e "\e[104mDone \e[49m"

#Remove subscription-manager and rhs-classic files.
echo -ne "\e[104mCleaning up subscription manager....\e[49m"
yum -y rhn* &>/dev/null
yum -y erase python-rhsm &>/dev/null
sed -i "s/proxy.*/#&/g" /etc/yum.conf
echo -e "\e[104mDone \e[49m"

#Re-Installing subscription-manager and files.
echo -ne "\e[104mNow setting up subscription manager....\e[49m"
case $release in
	5) 
		sed -i 's/1/0/g' /etc/yum/pluginconf.d/rhn*
		sed -i 's/1/0/g' /etc/yum.repos.d/*
		yum -y --nogpgcheck install $dir/pkgs/sm_$release* &>/dev/null
		echo -ne "\e[104mInstalling Katello-Bootstrap....\e[49m" &>/dev/null
		rpm -Uvh http://zena.jncb.com/pub/katello-ca-consumer-latest.noarch.rpm &>/dev/null
		test -d "/etc/pki/product" || mkdir -p "/etc/pki/product" && cp /etc/pki/product-default/69.pem /etc/pki/product/69.pem
		sed -i '602 s/self.*/#&/' /usr/lib64/python2.4/logging/handlers.py
		subscription-manager register --org="National_Commercial_Bank" --activationkey="rhel-5" --force &>/dev/null
		echo -e "\e[104mDone \e[49m"
		echo -e "\e[104mPlease attach subscription on Zena for $HOSTNAME.... \e[49m"
		read -p $'\e[104mPress enter to continue.... \e[49m'
		echo -ne "\e[104mRe-Installing and upgrading subscription-manager.... \e[49m"
		subscription-manager attach --auto &>/dev/null
		subscription-manager repos --enable "*" &>/dev/null
		yum clean all &>/dev/null
		yum -y install katello-agent &>/dev/null
		chkconfig goferd on
		chkconfig rhsmcertd on
		/etc/init.d/goferd restart
		/etc/init.d/rhsmcertd restart
		echo -e "\e[104mDone \e[49m" ; sleep 1
		;;
	6)
		sed -i 's/1/0/g' /etc/yum/pluginconf.d/rhn*
		sed -i 's/1/0/g' /etc/yum.repos.d/*
		yum -y --nogpgcheck install $dir/pkgs/sm_$release* &>/dev/null
		mv /etc/rhsm/rhsm.conf.kat-backup /etc/rhsm/rhsm.conf
		echo -ne "\e[104mInstalling Katello-Bootstrap.... \e[49m"
		subscription-manager clean &>/dev/null
		rpm -Uvh http://zena.jncb.com/pub/katello-ca-consumer-latest.noarch.rpm --replacefiles --replacepkgs &>/dev/null
		subscription-manager register --org="National_Commercial_Bank" --activationkey="rhel-6" --force &>/dev/null
		echo -e "\e[104mDone \e[49m"
		echo -e "\e[104mPlease attach subscription on Zena for $HOSTNAME.... \e[49m"
		read -p $'\e[104mPress enter to continue.... \e[49m'
		echo -ne "\e[104mRe-Installing and upgrading subscription-manager \e[49m"
		subscription-manager subscribe --auto &>/dev/null
		yum -y update subscription-manager &>/dev/null
		subscription-manager attach --auto &>/dev/null
		subscription-manager repos --enable "*" &>/dev/null
		yum clean all &>/dev/null
		yum -y install katello-agent &>/dev/null
		service goferd restart
		service rhsmcertd restart
		chkconfig goferd on
		chkconfig rhsmcertd on
		echo -e "\e[104mDone \e[49m" ; sleep 1
		;;
	7)
		sed -i 's/1/0/g' /etc/yum/pluginconf.d/rhn*
		sed -i 's/1/0/g' /etc/yum.repos.d/*
		yum -y --nogpgcheck install $dir/pkgs/sm_$release* &>/dev/null
		mv /etc/rhsm/rhsm.conf.kat-backup /etc/rhsm/rhsm.conf
		echo -ne "\e[104mInstalling Katello-Bootstrap.... \e[49m"
		subscription-manager clean &>/dev/null
		rpm -Uvh http://zena.jncb.com/pub/katello-ca-consumer-latest.noarch.rpm --replacefiles --replacepkgs &>/dev/null
		subscription-manager register --org="National_Commercial_Bank" --activationkey="rhel-7" --force &>/dev/null
		echo -e "\e[104mDone \e[49m"
		echo -e "\e[104mPlease attach subscription on Zena for $HOSTNAME.... \e[49m"
		read -p $'\e[104mPress enter to continue.... \e[49m'
		echo -ne "\e[104mAttching subscription(s).... "
		subscription-manager attach --auto &>/dev/null
		subscription-manager repos --enable "*" &>/dev/null
		yum clean all &>/dev/null
		yum -y install katello-agent &>/dev/null
		systemctl restart goferd
		systemctl restart rhsmcertd
		systemctl enable gopherd
		systemctl enable rhsmcertd
		echo -e "\e[104mDone \e[49m" ; sleep 1
		;;
	8)
		echo "Not updated for RHEL 8 yet"
		;;
esac
if [[ ( $dir != "/" ) ]]; then
	echo -e "\e[44mCleaning up files....\e[49m"
	rm -rf $dir/pkgs
	rm -f $dir/pkgs.tar
	rm sat-regster.sh
fi
echo -e "\e[44mAll done.... \e[49m"	
