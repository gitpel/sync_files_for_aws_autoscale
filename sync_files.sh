#!/bin/sh

# Default variables
HOST=`hostname`
LOCALIP=`ifconfig eth0 | grep "inet addr:" | awk '{split($2,a,":"); print a[2]}'`
REALIP=`dig +short myip.opendns.com @resolver1.opendns.com`
CURRENTDIR="$(dirname "$0")"
SETTINGS="$CURRENTDIR/sync_files.conf"
SERVERIP=(dig +short "$SERVER")

# Get Setting from File
. $SETTINGS


function log {
	(
		echo =======================
		echo Date: "$(date)"
		echo Host: "$HOST"
		echo Local IP: "$LOCALIP"
		echo External IP: "$REALIP"
		echo Key file: "$KEYFILE"
		echo Server: "$SERVER"
		echo Server IP: "$SERVERIP"
		echo User: "$USER"
		echo Rsync attributes: "$ATTRIBUTES"
	) >> "$LOGFILE"
}

# If you are master exit
function immaster {
	if [ "$REALIP" == "$SERVERIP" ]; then
		echo Real IP same as Server IP - I\'m master >> "$LOGFILE"
		exit 0
	fi
        if [ "$LOCALIP" == "$SERVERIP" ]; then
		echo Local IP same as Server IP - I\'m master >> "$LOGFILE"
                exit 0
        fi
}


# Copy files usin Rsync
function syncfiles {
	while read SOURCE; do
		rsync "-$ATTRIBUTES" -e 'ssh -i '"$KEYFILE"'' "$USER"@"$SERVERIP":"$SOURCE/" "$SOURCE" --log-file="$LOGFILE"
	done < "$SOURCELIST"
}

log
immaster
syncfiles
exit 0

