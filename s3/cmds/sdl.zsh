function sdl() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt=""
    local quiet=0
    local dryrun=0
    local include=""
    local recursive=0
    local nprogress=0

    while getopts hrdqni: opt; do
        case ${opt} in
        h)
            tip "NAME"
            tip "    $0"

            echo
            tip "SYNOPSIS"
            tip "    $0 [-h] [-r] [-d] [-q] [-n] [-i <wildcard>] <S3Uri> [LocalPath]"

            tip "DESCRIPTION"
            tip "    Copies S3 object to a local file."

            echo
            tip "OPTIONS"
            tip "    -h Print this message, then exit" && echo

            tip "    -r Command is performed on all files or objects under the specified directory or prefix."
            tip "    -d Displays the operations that would be performed using the specified command without actually running them."
            tip "    -q Does not display the operations performed from the specified command."
            tip "    -n File transfer progress is not displayed."
            return 0
            ;;
        r)
            recursive=1
            ;;
        d)
            dryrun=1
            ;;
        q)
            quiet=1
            ;;
        n)
            nprogress=1
            ;;
        i)
            include="${{OPTARG}}"
            ;;
        ?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# > 2)); then
        tip "Expect 1 or 2 positional argument: <S3Uri> [LocalPath], got $#"
        return 1
    fi

    local s3Uri=$1
    local localPath=$2

    [[ -z ${s3Uri} || ${s3Uri} == "." ]] && s3Uri="${s3_pwd%/}/"

    if is_relpath "${s3Uri}"; then
        s3Uri="${s3_pwd%/}/${s3Uri%/}/"
    fi

    if [[ ${s3Uri} == "s3://" ]]; then
        tip "Missing bucket name"
        return 1
    fi

    [[ ${localPath} == "." ]] && localPath="${PWD}/"

    if is_relpath "${localPath}"; then
        localPath="${PWD}/${localPath%/}/"
    fi

    cmd="aws s3 cp ${s3Uri} ${localPath}"

    ((quiet)) && cmd="${cmd} --quiet"

    ((dryrun)) && cmd="${cmd} --dryrun"

    ((recursive)) && cmd="${cmd} --recursive"

    ((nprogress)) && cmd="${cmd} --no-progress"

    [[ -n ${include} ]] && cmd="${cmd} --exclude '*' --include '${include}'"

    eval "${cmd}"
}
