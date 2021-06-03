
function home {
    cd $PENSA_ROS_PATH
}

function res {
    cd $PENSA_ROS_PATH/third_party/pensa_resources
}

function ops {
    cd $PENSA_FLIGHT_OPS_PATH
}

function buildit {
    cd $PENSA_ROS_PATH
    ./build.sh --desktop
    cd -
}

function bleep {
    paplay ~/oil/bleep.ogg
    paplay ~/oil/bleep.ogg
}

function pingdevice {
    PING_HOSTNAME=$1
    printf "%s" "Attempting to ping $PING_HOSTNAME..."
    while ! timeout 0.2 ping -c 1 -n $PING_HOSTNAME &> /dev/null
    do
        printf "%c" "."
        test $? -gt 128 && break
    done
    printf "success"
    echo ""
    paplay ~/oil/beep.ogg
}

function pingdrone {
    pingdevice $DRONE_HOSTNAME.local
}

function pingperch {
    pingdevice $PERCH_HOSTNAME.local
}

function pingbasestation {
    pingdevice $BASESTATION_HOSTNAME.local
}

function pingbs {
    pingbasestation
}

function sshdrone {
    # echo "connecting to pensa@$DRONE_HOSTNAME.local..."
    # echo "If this incorrect, set DRONE_HOSTNAME to C0001 or similar"
    ssh -tX pensa@"$DRONE_HOSTNAME".local "$@"
}

function ssshdrone {
    sshdrone "sudo -i $@"
}

function rsshdrone {
    ssh -t root@"$DRONE_HOSTNAME".local "cd rosws/src/pensa; bash"
}

function sshperch {
    # echo "connecting to pensa@$PERCH_HOSTNAME.local..."
    # echo "If this incorrect, set PERCH_HOSTNAME to P0025 or similar"
    ssh -t pensa@"$PERCH_HOSTNAME".local "$@"
}

function ssshperch {
    sshperch "sudo -i $@"
}

function rsshperch {
    ssh -t root@"$PERCH_HOSTNAME".local "cd rosws/src/pensa; bash"
}

function sshbasestation {
    # echo "connecting to pensa@$BASESTATION_HOSTNAME.local..."
    # echo "If this incorrect, set BASESTATION_HOSTNAME to basestation or similar"
    ssh -tX pensa@"$BASESTATION_HOSTNAME".local "$@"
}

function ssshbasestation {
    sshbasestation "sudo -i $@"
}

function rsshbasestation {
    ssh -t root@"$BASESTATION_HOSTNAME".local "cd rosws/src/pensa; bash"
}

function ssshbs {
    ssshbasestation "$@"
}

function sshbs {
    sshbasestation "$@"
}

function rsshbs {
    rsshbasestation "$@"
}

function prsshbs {
    pingbs && rsshbs "$@"
}

function ondronetest {
    ssh -t pensa@"$DRONE_HOSTNAME".local "bash -s" < ~/oil/ondronetest.sh
}

function rename_device {
    target_host=$1
    new_name=$2

    ssh-keygen -f "/home/adam/.ssh/known_hosts" -R "${target_host}.local"
    ssh-keygen -f "/home/adam/.ssh/known_hosts" -R "${new_name}.local"
    pingdevice $target_host.local
    echo "renaming ${target_host}.local to ${new_name}.local, please enter passwords..."
    ssh -t pensa@"${target_host}".local "sudo -i change-hostname ${new_name}; sudo -i reboot now"
    pingdevice $new_name.local
    echo "${target_host}.local renamed to ${new_name}.local"
}

function rename_bxxx {
    target_host="bxxx"
    new_name="basestation"  # .local will be appended automatically
    rename_device $target_host $new_name
}

function copy_drone_ulg_path {
    echo "Attempting to pull ULG file from drone"
    ULGPATH=$(sshdrone "cat /var/log/pensa/drone_ros.log | grep -a logger | tail -n1" | awk -F " " '{print $NF}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | tee /dev/tty)
    if hash xclip 2>/dev/null; then
        echo $ULGPATH
        echo $ULGPATH | xclip -selection c
        echo "Path copied to clipboard."
    else
        echo "xclip is not installed; can't copy the path to your clipboard automatically."
        echo "You can install it via 'sudo apt install xclip'."
    fi
}

function set_gcs_url {
    IP=$(hostname -I | awk '{print $1}')
    REMOTE_SCRIPT=$(cat ~/oil/set_gcs_url_template.sh)
    REMOTE_SCRIPT="${REMOTE_SCRIPT/VARIP/$IP}"
    echo "$REMOTE_SCRIPT" > ~/oil/tmp/set_gcs_url.sh
    scp ~/oil/tmp/set_gcs_url.sh pensa@"$DRONE_HOSTNAME".local:/tmp/
    sshdrone "sudo -s bash /tmp/set_gcs_url.sh"
}

function copy_ssh_keys {
    TARGET=$1

    ssh-keygen -f "/home/adam/.ssh/known_hosts" -R "$TARGET"

    ssh-copy-id -i ~/.ssh/id_ed25519.pub -f pensa@"$TARGET"
    scp ~/oil/tmp/copy_ssh_key_to_root.sh pensa@"$TARGET":/tmp/
    ssh -t pensa@"$TARGET" "sudo -s bash /tmp/copy_ssh_key_to_root.sh"
}

function copy_ssh_keys_all {
    IP=$(hostname -I | awk '{print $1}')
    # get the key text and trim leading and trailing whitespace
    KEYVAL=$(cat ~/.ssh/id_ed25519.pub | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    echo ">${KEYVAL}<"
    REMOTE_SCRIPT=$(cat ~/oil/copy_ssh_key_to_root_template.sh)
    REMOTE_SCRIPT="${REMOTE_SCRIPT/USER/$KEYVAL}"
    REMOTE_SCRIPT="${REMOTE_SCRIPT/USER/$KEYVAL}"
    echo "$REMOTE_SCRIPT" > ~/oil/tmp/copy_ssh_key_to_root.sh

    copy_ssh_keys "$DRONE_HOSTNAME".local
    copy_ssh_keys "$PERCH_HOSTNAME".local
    copy_ssh_keys "$BASESTATION_HOSTNAME".local
}

function zero_drone_camera_offset {
    scp ~/oil/zero_drone_camera_offset.sh pensa@"$DRONE_HOSTNAME".local:/tmp/
    sshdrone "sudo -s bash /tmp/zero_drone_camera_offset.sh"
}

function drone_git_status {
    sshdrone -t "sudo -i bash -c \"cd /root/rosws/src/pensa; pwd; git status; git --no-pager diff\""
}

function get_drone_ros_log {
    scp pensa@"$DRONE_HOSTNAME".local:/var/log/pensa/drone_ros.log .
}

function get_branches {
    sshdrone -t "sudo -i bash -c \"cd /root/rosws/src/pensa; pwd; git fetch; git status -uno\""
    sshperch -t "sudo -i bash -c \"cd /root/rosws/src/pensa; pwd; git fetch; git status -uno\""
    sshbs -t "sudo -i bash -c \"cd /root/rosws/src/pensa; pwd; git fetch; git status -uno\""
}

function bounceperch {
    ~/oil/bounce.py $PERCH_HOSTNAME
}

function bouncebs {
    sshbs -t "sudo -i bash -c \"bounce all\""
    bounceperch
}

function bouncedrone {
    ~/oil/down.py $DRONE_HOSTNAME
}

function checkout_branches_and_build {
    sshdrone -t "sudo -i bash -c \"cd /root/rosws/src/pensa; pwd; git fetch; git checkout $1; git pull; ./build.sh --daisy\""
    sshperch -t "sudo -i bash -c \"cd /root/rosws/src/pensa; pwd; git fetch; git checkout $1; git pull; ./build.sh --perch\""
    sshbs -t "sudo -i bash -c \"cd /root/rosws/src/pensa; pwd; git fetch; git checkout $1; git pull; ./build.sh --basestation\""
    bouncebs
}

function see3cam_connected {
    sshdrone -t "sudo -i bash -c \"ls /dev/front_cam\""
}

function bsmaster {
    export ROS_MASTER_URI=http://basestation.local:11311
}

function memaster {
    export ROS_MASTER_URI=http://localhost:11311
}

function set_drone {
    echo $1 > ~/oil/drone_hostname
    source ~/oil/device_names.bash
}

function set_basestation {
    echo $1 > ~/oil/basetation_hostname
    source ~/oil/device_names.bash
}

function set_perch {
    echo $1 > ~/oil/perch_hostname
    source ~/oil/device_names.bash
}
