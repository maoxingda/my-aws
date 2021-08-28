function sls() {
    if ((s3_debug == 1)); then set -vx; fi
    trap 'if ((s3_debug == 1)); then set +vx; fi' EXIT

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

    local S3Uri="$1"

    if [[ -z ${S3Uri} || ${S3Uri} == '.' ]]; then
        S3Uri="${s3_pwd}"

    elif is_relpath "${S3Uri}"; then
        if [[ ${s3_pwd} == '/' ]]; then
            S3Uri="/${S3Uri}"
        else
            S3Uri="${s3_pwd}/${S3Uri}"
        fi
    fi

    cmd="aws s3 ls s3:/${S3Uri%/}/ --human-readable"

    ((recursive)) && cmd="${cmd} --recursive"

    eval "${cmd}"
}
