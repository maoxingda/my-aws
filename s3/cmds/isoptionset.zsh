function isoptionset() {
    if [[ -o ${1} ]]; then
        echo "yes"
    else
        echo "no"
    fi
}
