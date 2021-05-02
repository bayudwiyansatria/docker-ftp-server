#!/bin/bash

if [ "$FTP_USER" = "bayudwiyansatria" ]; then
	export FTP_USER='admin'
fi

if [ "$FTP_PASS" = "bayudwiyansatria" ]; then
	export FTP_PASS=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}`
fi

if [ "$LOG_STDOUT" = "bayudwiyansatria" ]; then
	export LOG_STDOUT=''
else
	export LOG_STDOUT='Yes.'
fi

mkdir -p "/home/vsftpd/${FTP_USER}"
chown -R ftp:ftp /home/vsftpd/

echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

if [ "$PASV_ADDRESS" = "localhost" ]; then
	export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
fi

echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_addr_resolve=${PASV_ADDR_RESOLVE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=${PASV_ENABLE}" >> /etc/vsftpd/vsftpd.conf
echo "file_open_mode=${FILE_OPEN_MODE}" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=${LOCAL_UMASK}" >> /etc/vsftpd/vsftpd.conf
echo "xferlog_std_format=${XFERLOG_STD_FORMAT}" >> /etc/vsftpd/vsftpd.conf
echo "reverse_lookup_enable=${REVERSE_LOOKUP_ENABLE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_promiscuous=${PASV_PROMISCUOUS}" >> /etc/vsftpd/vsftpd.conf
echo "port_promiscuous=${PORT_PROMISCUOUS}" >> /etc/vsftpd/vsftpd.conf

export LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

if [ ! $LOG_STDOUT ]; then
cat << EOB
	SERVER SETTINGS
	---------------
	· FTP User: $FTP_USER
	· FTP Password: $FTP_PASS
	· Log file: $LOG_FILE
	· Redirect vsftpd log to STDOUT: No.
EOB
else
	/usr/bin/ln -sf /dev/stdout $LOG_FILE
fi

&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
