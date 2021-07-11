function supload() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0
    local include=""

    while getopts hri: opt; do
        case ${opt} in
        h)
            echo "Usage: $0 [-h] [-r] [-i wldcard] [localPath] [s3Uri]"
            return 0
            ;;
        r)
            recursive=1
            ;;
        i)
            include="${{OPTARG}}"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# > 2)); then
        echo "Expect 1 or 2 positional argument, got $#"
        return 1
    fi

    local localPath=$1
    local s3Uri=$2

    if [[ "${localPath}" == "." ]]; then
        localPath="${PWD}/"

    elif is_relative_path "${localPath}"; then
        localPath="${PWD}/${localPath}"
    fi

    if [[ ${s3Uri} == "" || ${s3Uri} == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"

    elif is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if [[ ${s3Uri} == "s3://" ]]; then
        echo "missing bucket name"
        return 1
    fi

    if ((recursive)); then
        if [[ ${include} =~ .+ ]]; then
            aws s3 cp "${localPath}" "${s3Uri}" --recursive --exclude "*" --include "${include}"
        else
            aws s3 cp "${localPath}" "${s3Uri}" --recursive
        fi
    else
        aws s3 cp "${localPath}" "${s3Uri}"
    fi
}
