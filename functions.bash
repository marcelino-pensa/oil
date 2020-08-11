
function home {
    cd $PENSA_ROS_PATH
}

function buildit {
    cd $PENSA_ROS_PATH
    ./build.sh --desktop
    cd -
}

function pingbeep {
    printf "%s" "Attempting to ping $DRONE_HOSTNAME.local..."
    while ! timeout 0.2 ping -c 1 -n $DRONE_HOSTNAME.local &> /dev/null
    do
        printf "%c" "."
        test $? -gt 128 && break
    done
    printf "success"
    echo ""
    paplay ~/oil/beep.ogg
}

function sshdrone {
    # echo "connecting to pensa@$DRONE_HOSTNAME.local..."
    # echo "If this incorrect, set DRONE_HOSTNAME to C0001 or similar"
    ssh -t pensa@"$DRONE_HOSTNAME".local "$@"
}

function ssshdrone {
    sshdrone "sudo -i $@"
}

function rsshdrone {
    ssh -t root@"$DRONE_HOSTNAME".local "$@"
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
    ssh -t root@"$PERCH_HOSTNAME".local "$@"
}

function sshbasestation {
    # echo "connecting to pensa@$BASESTATION_HOSTNAME.local..."
    # echo "If this incorrect, set BASESTATION_HOSTNAME to basestation or similar"
    ssh -t pensa@"$BASESTATION_HOSTNAME".local "$@"
}

function ssshbasestation {
    sshbasestation "sudo -i $@"
}

function rsshbasestation {
    ssh -t root@"$BASESTATION_HOSTNAME".local "$@"
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

function ondronetest {
    ssh -t pensa@"$DRONE_HOSTNAME".local "bash -s" < ~/oil/ondronetest.sh
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

function copykeysall {
    IP=$(hostname -I | awk '{print $1}')
    REMOTE_SCRIPT=$(cat ~/oil/copy_ssh_key_to_root_template.sh)
    REMOTE_SCRIPT="${REMOTE_SCRIPT/USER/$USER}"
    REMOTE_SCRIPT="${REMOTE_SCRIPT/USER/$USER}"
    echo "$REMOTE_SCRIPT" > ~/oil/tmp/copy_ssh_key_to_root.sh

    ssh-copy-id -i ~/.ssh/id_rsa.pub pensa@"$DRONE_HOSTNAME".local
    scp ~/oil/tmp/copy_ssh_key_to_root.sh pensa@"$DRONE_HOSTNAME".local:/tmp/
    sshdrone "sudo -s bash /tmp/copy_ssh_key_to_root.sh"
    ssh-copy-id -i ~/.ssh/id_rsa.pub pensa@"$PERCH_HOSTNAME".local
    scp ~/oil/tmp/copy_ssh_key_to_root.sh pensa@"$PERCH_HOSTNAME".local:/tmp/
    sshperch "sudo -s bash /tmp/copy_ssh_key_to_root.sh"
    ssh-copy-id -i ~/.ssh/id_rsa.pub pensa@"$BASESTATION_HOSTNAME".local
    scp ~/oil/tmp/copy_ssh_key_to_root.sh pensa@"$BASESTATION_HOSTNAME".local:/tmp/
    sshbs "sudo -s bash /tmp/copy_ssh_key_to_root.sh"
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
    ~/oil/bounce.py $BASESTATION_HOSTNAME
    bounceperch
}

function bouncedrone {
    ~/oil/bounce.py $DRONE_HOSTNAME
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