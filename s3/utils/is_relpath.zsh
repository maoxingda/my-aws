function is_relpath() {
    local path=$1
    if [[ "${path:0:1}" != "/" && "${path:0:5}" != "s3://" ]]; then
        return 0
    fi
    return 1
}
