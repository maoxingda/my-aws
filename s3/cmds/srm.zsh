function srm() {
    # shellcheck disable=SC2154
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local dryrun=0
    local include=""
    local recursive=0

    while getopts hdri: opt; do
        case ${opt} in
        h)
            echo "Usage:"
            echo "    $0 [-h] [-r] [-d] [-i <wildcard>] <S3Uri>" && echo

            echo "    -h Print this message, then exit" && echo

            echo "    -r Command is performed on all files or objects under the specified directory or prefix."
            echo "    -d Displays the operations that would be performed using the specified command without actually running them."
            echo "    -i Don’t exclude files or objects in the command that match the specified pattern. See http://docs.aws.amazon.com/cli/latest/reference/s3/index.html#use-of-exclude-and-include-filters"

            return 0
            ;;
        d)
            dryrun=1
            ;;
        r)
            recursive=1
            ;;
        i)
            include="${OPTARG}"
            ;;
        ?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# == 0)); then
        echo "Expect argument: S3Uri, got none"
        return 1
    fi

    if (($# > 1)); then
        # shellcheck disable=SC2145
        echo "Expect 1 positional argument: S3Uri, got: $@"
        return 1
    fi

    local s3Uri=$1

    if [[ ${s3Uri:0:1} == . ]]; then
        echo "Bucket names must begin and end with a letter or number."
        return 1

    elif is_relative_path "${s3Uri}"; then
        # shellcheck disable=SC2154
        s3Uri="${s3_pwd%/}/${s3Uri}"
    fi

    cmd="aws s3 rm ${s3Uri}"

    ((dryrun)) && cmd="${cmd} --dryrun"

    ((recursive)) && cmd="${cmd} --recursive"

    [[ -n ${include} ]] && cmd="${cmd} --exclude '*' --include '${include}'"

    eval "${cmd}"
}
