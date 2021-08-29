function smv() {
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
            tip "    $0 [-h] [-r] [-d] [-q] [-n] [-i <wildcard>] <S3SrcUri> [S3DstUri]"

            echo
            tip "DESCRIPTION"
            tip "    Copies S3 object to another location in S3."

            echo
            tip "OPTIONS"
            tip "    -h Print this message, then exit"

            echo
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

    err[2]='Expect 1 or 2 positional argument: <S3SrcUri> [S3SrcUri], got'
    err[3]='Missing bucket name.'

    if (($# == 0 || $# > 2)); then
        tip "${err[2]} $#"
        return 2
    fi

    local S3SrcUri="$1"
    local S3DstUri="$2"

    [[ ${S3SrcUri} == "." ]] && S3SrcUri="${s3_pwd}"

    if is_relpath "${S3SrcUri}"; then
        if [[ ${s3_pwd} == '/' ]]; then
            S3SrcUri="/${S3SrcUri}"
        else
            S3SrcUri="${s3_pwd}/${S3SrcUri}"
        fi
    fi

    if [[ ${S3SrcUri} == '/' ]]; then
        tip "${err[3]}"
        return 3
    fi

    if is_relpath "${S3DstUri}"; then
        if [[ ${s3_pwd} == '/' ]]; then
            S3DstUri="/${S3DstUri}"
        else
            S3DstUri="${s3_pwd}/${S3DstUri}"
        fi
    fi

    S3SrcUri="$(normpath "${S3SrcUri}")"
    S3DstUri="$(normpath "${S3DstUri}")"

    cmd="aws s3 mv s3:/${S3SrcUri} s3:/${S3DstUri}"

    ((quiet)) && cmd="${cmd} --quiet"

    ((dryrun)) && cmd="${cmd} --dryrun"

    ((recursive)) && cmd="${cmd} --recursive"

    ((no_progress)) && cmd="${cmd} --no-progress"

    [[ -n ${include} ]] && cmd="${cmd} --exclude '*' --include '${include}'"

    eval "${cmd}"
}
