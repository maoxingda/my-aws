function sdownload() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0
    local include=""

    while getopts hri: opt; do
        case ${opt} in
        h)
            print "Usage: $0 [-h] [-r] [-i wldcard] [s3Uri] [localPath]"
            return 0
            ;;
        r)
            recursive=1
            ;;
        i)
            include="${OPTARG}"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# > 2)); then
        print "Expect 1 or 2 positional argument, got $#"
        return 1
    fi

    local s3Uri=$1
    local localPath=$2

    if [[ "${s3Uri}" == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"

    elif is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri}"
    fi

    if [[ "${localPath}" == "" || "${localPath}" == "." ]]; then
        localPath="${PWD}/"
    fi

    if ((recursive)); then
        if [[ ${include} =~ .+ ]]; then
            aws s3 cp "${s3Uri}" "${localPath}" --recursive --exclude "*" --include "${include}"
        else
            aws s3 cp "${s3Uri}" "${localPath}" --recursive
        fi
    else
        aws s3 cp "${s3Uri}" "${localPath}"
    fi
}
