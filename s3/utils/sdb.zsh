function sdb() {
    if ((s3_debug == 1)); then
        s3_debug=0
        tip "debug off"
    else
        s3_debug=1
        tip "debug on"
    fi
}
