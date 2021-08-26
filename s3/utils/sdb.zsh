function sdb() {
    if ((s3_debug == 1)); then
        s3_debug=0
        echo "debug off"
    else
        s3_debug=1
        echo "debug on"
    fi
}
