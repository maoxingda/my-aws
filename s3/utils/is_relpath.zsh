function is_relpath() {
    local dir=$1
    if [[ "${dir:0:1}" != "/" && "${dir:0:5}" != "s3://" ]]; then
        return 0
    fi
    return 1
}
