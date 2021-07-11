function sdb() {
    if ((s3_debug == 1)); then
        s3_debug=0
        print "debug off"
    else
        s3_debug=1
        print "debug on"
    fi
}
