function sdl() {
    if ((s3_debug == 1)); then set -vx; fi
    trap 'if ((s3_debug == 1)); then set +vx; fi' EXIT

    local opt=''
    local quiet=0
    local dryrun=0
    local include=''
    local recursive=0
    local no_progress=0

    while getopts 'hrdqni': opt; do
        case ${opt} in
        h)
            tip "NAME"
            tip "    $0"

            echo
            tip "SYNOPSIS"
            tip "    $0 [-h] [-r] [-d] [-q] [-n] [-i <wildcard>] <S3Uri> [LocalPath]"

            echo
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
            no_progress=1
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

    typeset -a err

    err[2]='Expect 1 or 2 positional argument: <S3Uri> [LocalPath], got'
    err[3]='Missing bucket name.'

    if (($# == 0 || $# > 2)); then
        tip "${err[2]} $#"
        return 2
    fi

    local S3Uri="$1"
    local LocalPath="$2"

    [[ ${S3Uri} == "." ]] && S3Uri="${s3_pwd}"

    if is_relpath "${S3Uri}"; then
        if [[ ${s3_pwd} == '/' ]]; then
            S3Uri="/${S3Uri}"
        else
            S3Uri="${s3_pwd}/${S3Uri}"
        fi
    fi

    if [[ ${S3Uri} == '/' ]]; then
        tip "${err[3]}"
        return 3
    fi

    if is_relpath "${LocalPath}"; then
        LocalPath="${PWD}/${LocalPath}"
    fi

    cmd="aws s3 cp s3:/${S3Uri} ${LocalPath}"

    ((quiet)) && cmd="${cmd} --quiet"

    ((dryrun)) && cmd="${cmd} --dryrun"

    ((recursive)) && cmd="${cmd} --recursive"

    ((no_progress)) && cmd="${cmd} --no-progress"

    [[ -n ${include} ]] && cmd="${cmd} --exclude '*' --include '${include}'"

    eval "${cmd}"
}
