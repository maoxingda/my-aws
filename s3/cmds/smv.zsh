function smv() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0
    local include=""

    while getopts hri: opt; do
        case ${opt} in
        h)
            print "Usage: $0 [-h] [-r] [-i wldcard] <s3Uri> [s3Uri]"
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

    s3SrcUri=$1
    s3DstUri=$2

    if [[ "${s3SrcUri}" == "." ]]; then
        s3SrcUri="${s3_pwd%'/'}/"

    elif is_relative_path "${s3SrcUri}"; then
        s3SrcUri="${s3_pwd%'/'}/${s3SrcUri}"
    fi

    if [[ "${s3DstUri}" == "" || "${s3DstUri}" == "." ]]; then
        s3DstUri="${s3_pwd%'/'}/"

    elif is_relative_path "${s3DstUri}"; then
        s3DstUri="${s3_pwd%'/'}/${s3DstUri}"
    fi

    if [[ "${s3SrcUri}" == "${s3DstUri}" ]]; then
        print "The source is same as destination"
        return 1
    fi

    if ((recursive)); then
        if [[ ${include} =~ .+ ]]; then
            aws s3 mv "${s3SrcUri}" "${s3DstUri}" --recursive --exclude "*" --include "${include}"
        else
            aws s3 mv "${s3SrcUri}" "${s3DstUri}" --recursive
        fi
    else
        aws s3 mv "${s3SrcUri}" "${s3DstUri}"
    fi
}
