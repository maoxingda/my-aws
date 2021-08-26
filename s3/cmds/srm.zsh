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
            print "Usage:"
            print "    $0 [-h] [-r] [-i wildcard] [-d dryrun] <S3Uri>\n"

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
        \?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# == 0)); then
        print "Expect S3Uri argument, got none"
        return 1
    fi

    if (( $# > 1 )); then
        # shellcheck disable=SC2145
        print "Expect one argument: S3Uri, got $@"
        return 1
    fi

    local s3Uri=$1

    if [[ ${s3Uri} == .* ]]; then
        print "Bucket names must begin and end with ==a letter or number.=="
        return 1

    elif is_relative_path "${s3Uri}"; then
        # shellcheck disable=SC2154
        s3Uri="${s3_pwd%/}/${s3Uri}"
    fi

    if ((recursive)); then
        if [[ ${include} =~ .+ ]]; then
            if ((dryrun == 1)); then
                aws s3 rm "${s3Uri}" --recursive --exclude "*" --include "${include} --dryrun"
            else
                aws s3 rm "${s3Uri}" --recursive --exclude "*" --include "${include}"
            fi
        else
            if ((dryrun == 1)); then
                aws s3 rm "${s3Uri}" --recursive --dryrun
            else
                aws s3 rm "${s3Uri}" --recursive
            fi
        fi
    else
        if ((dryrun == 1)); then
            aws s3 rm "${s3Uri}" --dryrun
        else
            aws s3 rm "${s3Uri}"
        fi
    fi
}
