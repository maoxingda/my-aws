function scd() {
    if ((s3_debug == 1)); then set -vx; fi
    trap 'if ((s3_debug == 1)); then set +vx; fi' EXIT

    while getopts 'h' opt; do
        case ${opt} in
        h)
            tip "Usage:"
            tip "    $0 [-h | [S3Uri]]"
            return 0
            ;;
        ?)
            return 1
            ;;
        esac
    done

    (($# > 1)) && tip "Usage: $0 [S3Uri]" && return 1

    local S3Uri="$1"

    if (($# == 0)); then
        s3_old_pwd="${s3_pwd}"
        S3Uri='/'
        s3_pwd='/'
        return 0

    elif [[ ${S3Uri} == "-" ]]; then
        tmp_pwd="${s3_pwd}"
        s3_pwd="${s3_old_pwd}"
        s3_old_pwd="${tmp_pwd}"
        return 0

    elif [[ ${S3Uri} == ".." ]]; then
        s3_old_pwd="${s3_pwd}"
        s3_pwd="$(normpath "${s3_pwd}/..")"
        return 0

    elif is_relpath "${S3Uri}"; then
        if [[ ${s3_pwd} == '/' ]]; then
            S3Uri="/${S3Uri}"
        else
            S3Uri="${s3_pwd}/${S3Uri}"
        fi
    fi

    S3Uri="$(normpath "${S3Uri}")"

    not_find_msg="$0: no such object, prefix, or bucket: ${S3Uri}"

    if ((s3_scd_quiet)); then
        if eval "aws s3 ls s3:/${S3Uri} >/dev/null 2>&1"; then
            s3_old_pwd=${s3_pwd}
            s3_pwd=${S3Uri}
        else
            tip "${not_find_msg}"
        fi
    else
        if eval "aws s3 ls s3:/${S3Uri} --human-readable"; then
            eval "aws s3 ls s3:/${S3Uri}/ --human-readable"
            s3_old_pwd=${s3_pwd}
            s3_pwd=${S3Uri}
        else
            tip "${not_find_msg}"
        fi
    fi
}
