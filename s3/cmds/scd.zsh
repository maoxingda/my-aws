function scd() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    if (($# > 1)); then
        echo "Usage: $0 [s3Uri]"
        return 1
    fi

    local s3Uri=$1

    if (($# == 0)); then
        s3Uri="s3://"
        s3_pwd=${s3Uri}

    elif [[ "${s3Uri}" == "-" ]]; then
        s3Uri=${s3_old_pwd}

    elif [[ "${s3Uri}" == ".." ]]; then
        s3Uri=$(/usr/bin/python -c "import os; print(os.path.dirname('${s3_pwd%'/'}'))")
        if [[ ${s3Uri} == "s3:/" ]]; then
            s3Uri="${s3Uri}/"
        fi

    elif is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if ((s3_scd_quiet)); then
        if eval "aws s3 ls ${s3Uri} >> /dev/null 2>&1"; then
            s3_old_pwd=${s3_pwd}
            s3_pwd=${s3Uri}
        else
            echo "scd: no such object, prefix, or bucket: ${s3Uri}"
        fi
    else
        if eval "aws s3 ls ${s3Uri} --human-readable"; then
            s3_old_pwd=${s3_pwd}
            s3_pwd=${s3Uri}
        else
            echo "scd: no such object, prefix, or bucket: ${s3Uri}"
        fi
    fi
}
