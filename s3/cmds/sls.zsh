function sls() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0

    while getopts 'hr' opt; do
        case ${opt} in
        h)
            tip "Usage: $0 [-r] [S3Uri]"
            return 0
            ;;
        r)
            recursive=1
            ;;
        ?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# > 1)); then
        tip "Expect 0 or 1 positional argument: [S3Uri], got $#"
        return 2
    fi

    local s3_uri="$1"

    if [[ -z ${s3_uri} || ${s3_uri} == "." ]]; then
        s3_uri="${s3_pwd%%/}"

    elif is_relpath "${s3_uri}"; then
        s3_uri="${s3_pwd%%/}/${s3_uri}"
    fi

    cmd="aws s3 ls ${s3_uri} --human-readable"

    ((recursive)) && cmd="${cmd} --recursive"

    eval "${cmd%%/}/"
}
