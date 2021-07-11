function sls() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0

    while getopts hr opt; do
        case ${opt} in
        h)
            echo "Usage: $0 [-r] [s3Uri]"
            return 0
            ;;
        r)
            recursive=1
            ;;
        \?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# > 1)); then
        echo "Expect 0 or 1 positional argument, got $#"
        return 1
    fi

    local s3Uri=$1

    if [[ "${s3Uri}" == "" || "${s3Uri}" == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"

    elif is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if ((recursive)); then
        aws s3 ls ${s3Uri} --human-readable --recursive
    else
        aws s3 ls ${s3Uri} --human-readable
    fi
}
