function isoptionset() {
    if [[ -o ${1} ]]; then
        tip "yes"
    else
        tip "no"
    fi
}
