function isoptionset() {
    if [[ -o ${1} ]]; then
        print "yes"
    else
        print "no"
    fi
}
