#!/bin/sh
#
# Sample SEMP V1 script to purge all durable mqtt sessions on given vpn.
# Warning: all sessions will be destroyed, use at user's own risk.
#

#source env.sh
#Change to pattern to grep on search for connections to delete.  Also adjust connection and VPN information

HOST=localhost
VPN=default
ADMIN_USER=admin
ADMIN_PASS=admin
SEMP_URL=http://localhost:8080
VPN="*"
PATTERN=2

if [ -z $HOST ] || [ -z $VPN ]
then
    echo "Enter Solace PubSub+ connection details in env.sh"
    exit
fi

echo "Purge all sessions on VPN \"$VPN\" for broker \"$HOST\" (y/n)?\nWarning all MQTT Sessions will be destroyed!"
read answer
#read answer
#answer="y"
if [ "$answer" == "Y" -o "$answer" == "y" ] ;then

	echo "Getting sessions following pattern -100"

	SHOW_SEMP="<rpc><show><message-vpn><vpn-name>${VPN}</vpn-name><mqtt/><mqtt-session/><client-id-pattern>*</client-id-pattern><detail/><count/><num-elements>1000</num-elements></message-vpn></show></rpc>"
	curl -u $ADMIN_USER:$ADMIN_PASS $SEMP_URL/SEMP -w "\nHTTP return code: %{http_code}\n" -d "${SHOW_SEMP}" > /tmp/show.out
	> /tmp/mqtt-clients.out
	for x in $(cat /tmp/show.out); do
		echo $x | grep "client-id" | grep "${PATTERN}" >>  /tmp/mqtt-clients.out
	done

	echo "CLIENTS"
	cat  /tmp/mqtt-clients.out

	for y in $(cat /tmp/mqtt-clients.out); do
		clientId=$(echo $y|sed 's/[</]*client-id>//g')
		echo "--------------------------------------------------------------"
		echo "--- Working on ClientId: $clientId ---"
		STOP_SEMP="<rpc><message-vpn><vpn-name>${VPN}</vpn-name><mqtt><mqtt-session><client-id>${clientId}</client-id><shutdown/></mqtt-session></mqtt></message-vpn></rpc>"
		echo; echo "--- Stop mqtt client ---"
		curl -u $ADMIN_USER:$ADMIN_PASS $SEMP_URL/SEMP -w "\nHTTP return code: %{http_code}\n" -d "${STOP_SEMP}"
	
		KILL_SEMP="<rpc><message-vpn><vpn-name>default</vpn-name><mqtt><no><mqtt-session><client-id>${clientId}</client-id></mqtt-session></no></mqtt></message-vpn></rpc>"
		echo; echo "--- Kill mqtt client ---"
		curl -u $ADMIN_USER:$ADMIN_PASS $SEMP_URL/SEMP -w "\nHTTP return code: %{http_code}\n" -d "${KILL_SEMP}"
	done
fi

