#!/bin/bash
# set -x

EMAIL=root@localhost
SKIP_CHECK=0

while getopts "ye:" opt ; do
  case "${opt}" in
    y)
      echo running non-interactively
      SKIP_CHECK=1
    ;;
    e)
      echo using email ${OPTARG}
      EMAIL="$OPTARG"
    ;;
    \?)
      echo invalid option >&2;
      exit 1;
    ;;
  esac
done

check_continue() {
  if [ $SKIP_CHECK -eq 1 ]; then
    $CMD || exit 1
    return
  fi

  ask=1
  while [[ $ask == 1 ]]; do
    read -p "Continue (y/n/s)?" choice
    case "$choice" in
      y|Y )
        $CMD || exit 1 ; ask=0
      ;;
      n|N )
        echo "no, exiting"; exit 1
      ;;
      s|S )
        echo "skipping"; ask=0
      ;;
      * )
        echo "invalid"
      ;;
    esac
  done
}

CMD="/usbkey/scripts/setup_manta_zone.sh"
echo running step 1: $CMD
check_continue $CMD

CMD="/zones/$(vmadm lookup alias=manta0)/root/opt/smartdc/manta-deployment/networking/gen-coal.sh"
echo running step 2 and writing to /root/netconfig.json: $CMD
check_continue $CMD > /root/netconfig.json

CMD="ln -s /zones/$(vmadm lookup alias=manta0)/root/opt/smartdc/manta-deployment/networking /var/tmp/networking"
echo running step 3: $CMD
check_continue $CMD

CMD="cd /var/tmp/networking"
echo running step 4: $CMD
check_continue $CMD

CMD="./manta-net.sh /root/netconfig.json"
echo running step 5: $CMD
check_continue $CMD

CMD="zlogin $(vmadm list -H -o uuid alias=manta0) /opt/smartdc/manta-deployment/build/node/bin/node /opt/smartdc/manta-deployment/bin/manta-init -s coal -e $EMAIL --marlin_image=$(imgadm avail | awk '/sdc-multiarch/{print $1}' | head -1)"
echo running step 6: $CMD
check_continue $CMD

CMD="zlogin $(vmadm list -H -o uuid alias=manta0) /opt/smartdc/manta-deployment/bin/manta-deploy-coal"
echo running step 7: $CMD
check_continue $CMD
