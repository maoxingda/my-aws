function scd() {
    if ((s3_debug == 1)); then set -vx; fi
    trap 'if ((s3_debug == 1)); then set +vx; fi' EXIT

    (($# > 1)) && tip "Usage: $0 [S3Uri]" && return 1

    local s3_uri="$1"

    if (($# == 0)); then
        s3_old_pwd="${s3_pwd}"
        s3_uri='/'
        s3_pwd='/'
        retrun 0

    elif [[ ${s3_uri} == "-" ]]; then
        tmp_pwd="${s3_pwd}"
        s3_pwd="${s3_old_pwd}"
        s3_old_pwd="${tmp_pwd}"
        retrun 0

    elif [[ ${s3_uri} == ".." ]]; then
        s3_old_pwd="${s3_pwd}"
        s3_pwd="${s3_pwd%/*}"
        return 0

    elif is_relpath "${s3_uri}"; then
        s3_uri="${s3_pwd%%/}/${s3_uri}"
    fi

    not_find_msg="$0: no such object, prefix, or bucket: ${s3_uri}"

    if ((s3_scd_quiet)); then
        if eval "aws s3 ls ${s3_uri} >/dev/null 2>&1"; then
            s3_old_pwd=${s3_pwd}
            s3_pwd=${s3_uri}
        else
            tip "${not_find_msg}"
        fi
    else
        if eval "aws s3 ls ${s3_uri} --human-readable"; then
            s3_old_pwd=${s3_pwd}
            s3_pwd=${s3_uri}
        else
            tip "${not_find_msg}"
        fi
    fi
}
