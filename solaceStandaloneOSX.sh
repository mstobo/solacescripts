
sudo su -

groupadd -g 501 solgroup
useradd -u 1001 -g 501 sysadmin
sudo useradd -u 1001 -g 501 sysadmin
passwd sysadmin
usermod -aG sudo sysadmin

#you can remove lines 11-22 if this is a fresh environment; otherwise remove the existing instance and externalize volumes
docker ps -a
docker stop solaceStandaloneOSX
docker rm -f solaceStandaloneOSX
docker ps -a

rm -rf /opt/vmr/internalSpool
rm -rf /opt/vmr/diags
rm -rf /opt/vmr/jail
rm -rf /opt/vmr/softAdb
rm -rf /opt/vmr/var
rm -rf /opt/vmr/adb
ls -la /opt/vmr/

mkdir -p /opt/vmr/internalSpool
mkdir -p /opt/vmr/diags
mkdir -p /opt/vmr/jail
mkdir -p /opt/vmr/softAdb
mkdir -p /opt/vmr/var
mkdir -p /opt/vmr/adb
chown -R sysadmin:solgroup /opt/vmr
ls -la /opt/vmr/


docker run \
--user=1001 \
--publish 55554:55555 \
--publish 2222:2222 \
--publish 8300:8300 \
--publish 8301:8301 \
--publish 8302:8302 \
--publish 8741:8741 \
--publish 8301:8301/udp \
--publish 8302:8302/udp \
--publish 8081:8080 \
--publish 1943:1943 \
--publish 55443:55443 \
--publish 55556:55556 \
--publish 8008:8008 \
--publish 9000:9000 \
--publish 9443:9443 \
--publish 5671:5671 \
--publish 1883:1883 \
--publish 8883:8883 \
--publish 8000:8000 \
--publish 8443:8443 \
--publish 5550:5550 \
--uts=host \
--shm-size=2g \
--ulimit core=-1 \
--ulimit memlock=-1 \
--ulimit nofile=2448:42192 \
--restart=always \
--detach=true \
--memory-swap=-1 \
--memory-reservation=0 \
--env ‘username_admin_globalaccesslevel=admin’ \
--env ‘username_admin_password=admin’ \
--env ‘routername=primary’ \
-v /opt/vmr/internalSpool:/usr/sw/internalSpool \
-v /opt/vmr/diags:/var/lib/solace/diags \
-v /opt/vmr/jail:/usr/sw/jail \
-v /opt/vmr/softAdb:/usr/sw/internalSpool/softAdb \
-v /opt/vmr/var:/usr/sw/var \
-v /opt/vmr/adb:/usr/sw/adb \
--name=solaceStandaloneOSX solace-pubsub-evaluation:9.9.0.34

docker exec -it primary /usr/sw/loads/currentload/bin/cli -A
session timeout 0
enable
configure
message-spool message-vpn default
create queue TransactionMgr
access-type exclusive
max-spool-usage 1500
permission all consume
no shutdown
