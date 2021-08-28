function srm() {
    if ((s3_debug == 1)); then set -vx; fi
    trap 'if ((s3_debug == 1)); then set +vx; fi' EXIT

    local opt=''
    local dryrun=0
    local include=''
    local recursive=0

    while getopts 'hdri': opt; do
        case ${opt} in
        h)
            tip "Usage:"
            tip "    $0 [-h] [-r] [-d] [-i <wildcard>] <S3Uri>"

            echo
            tip "    -h Print this message, then exit"

            echo
            tip "    -r Command is performed on all files or objects under the specified directory or prefix."
            tip "    -d Displays the operations that would be performed using the specified command without actually running them."
            tip "    -i Don’t exclude files or objects in the command that match the specified pattern."
            tip "       See https://docs.aws.amazon.com/cli/latest/reference/s3/rm.html"

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

    typeset -a err

    err[2]='Expect argument: <S3Uri>, got none.'
    err[3]='Expect 1 positional argument: <S3Uri>, got:'

    if (($# == 0)); then
        tip "${err[2]}"
        return 2
    fi

    if (($# > 1)); then
        tip "${err[3]} $#"
        return 3
    fi

    local S3Uri="$1"

    if is_relpath "${S3Uri}"; then
        if [[ ${s3_pwd} == '/' ]]; then
            S3Uri="/${S3Uri}"
        else
            S3Uri="${s3_pwd}/${S3Uri}"
        fi
    fi

    cmd="aws s3 rm s3:/${S3Uri}"

    ((dryrun)) && cmd="${cmd} --dryrun"

    ((recursive)) && cmd="${cmd} --recursive"

    [[ -n ${include} ]] && cmd="${cmd} --exclude '*' --include '${include}'"

    eval "${cmd}"
}
