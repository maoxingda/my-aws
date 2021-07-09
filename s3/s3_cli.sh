# variables declaration
debug=0

OLDPS1=""
s3_pwd="s3://"
s3_old_pwd="s3://"
open_debug="set -vx"
close_debug="set +vx"

# functions declaration
function spwd() {
    echo "${s3_pwd}"
}

function debug() {
    if ((debug == 1)); then
        debug=0
    else
        debug=1
    fi
}

function sls() {
    if ((debug == 1)); then eval "${open_debug}"; fi

    local s3Uri=$1

    if (($# > 1)) && [[ $2 != "-r" ]]; then
        echo "Usage: sls [s3Uri]"

        if ((debug == 1)); then eval "${close_debug}"; fi
        return 1
    fi

    if _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri}"
    else
        s3Uri=${s3_pwd}
    fi

    if [[ ${s3Uri: -1} != "/" ]]; then
        s3Uri="${s3Uri}/"
    fi

    if [[ "$2" == "-r" ]]; then
        aws s3 ls ${s3Uri} --recursive
    else
        aws s3 ls ${s3Uri}
    fi

    if ((debug == 1)); then eval "${close_debug}"; fi
}

function scd() {
    if ((debug == 1)); then eval "${open_debug}"; fi

    if (($# > 1)); then
        echo "Usage: scd [s3Uri]"

        if ((debug == 1)); then eval "${close_debug}"; fi
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

    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if eval "aws s3 ls ${s3Uri} >> /dev/null 2&>1"; then
        s3_old_pwd=${s3_pwd}
        s3_pwd=${s3Uri}
    else
        echo "scd: no such object, prefix, or bucket: ${s3Uri}"
    fi

    if ((debug == 1)); then eval "${close_debug}"; fi
}

function sup() {
    if ((debug == 1)); then eval "${open_debug}"; fi

    local localPath=$1
    local s3Uri=$2

    if _is_relative_path "${localPath}"; then
        localPath="${PWD}/${localPath}"
    fi

    if [[ ${s3Uri} == "" || ${s3Uri} == "." || ${s3Uri} == "-r" ]]; then
        s3Uri=${s3_pwd}

    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if [[ ${s3Uri} == "s3://" ]]; then
        echo "missing bucket"
        if ((debug == 1)); then eval "${close_debug}"; fi
        return 1
    fi

    if [[ $2 == "-r" || $3 == "-r" ]]; then
        aws s3 cp "${localPath}" "${s3Uri}" --recursive
    else
        aws s3 cp "${localPath}" "${s3Uri}"
    fi

    if ((debug == 1)); then eval "${close_debug}"; fi
}

function sdown() {
    if ((debug == 1)); then eval "${open_debug}"; fi

    local s3Uri=$1
    local localPath=$2

    if _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri}"
    fi

    if [[ "${localPath}" == "" || "${localPath}" == "." || "${localPath}" == "-r" ]]; then
        localPath="${PWD}"
    fi

    if [[ $2 == "-r" || $3 == "-r" ]]; then
        aws s3 cp "${s3Uri}" "${localPath}" --recursive
    else
        aws s3 cp "${s3Uri}" "${localPath}"
    fi
    if ((debug == 1)); then eval "${close_debug}"; fi
}

function smv() {
    if ((debug == 1)); then eval "${open_debug}"; fi

    if (($# < 2)); then
        echo "Usage: scpy <s3Uri> <s3Uri>"

        if ((debug == 1)); then eval "${close_debug}"; fi
        return 1
    fi

    s3SrcUri=$1
    s3DstUri=$2

    if _is_relative_path "${s3SrcUri}"; then
        s3SrcUri="${s3_pwd%'/'}/${s3SrcUri}"
    fi

    if _is_relative_path "${s3DstUri}"; then
        s3DstUri="${s3_pwd%'/'}/${s3DstUri}"
    fi

    if [[ "$3" == "-r" ]]; then
        aws s3 mv "${s3SrcUri}" "${s3DstUri}" --recursive
    else
        aws s3 mv "${s3SrcUri}" "${s3DstUri}"
    fi

    if ((debug == 1)); then eval "${close_debug}"; fi
}

function srm() {
    if ((debug == 1)); then eval "${open_debug}"; fi

    if (($# == 0)); then
        echo "Usage: sremove s3Uri"
        if ((debug == 1)); then eval "${close_debug}"; fi
        return 1
    fi

    local s3Uri=$1

    if [[ "${s3Uri}" == "-i" ]]; then
        s3Uri="${s3_pwd%'/'}/"
    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri}"
    fi

    if [[ "$1" == "-i" ]]; then
        aws s3 rm "${s3Uri}" --include $2

    elif [[ $2 == "-r" ]]; then
        aws s3 rm "${s3Uri}" --recursive
    else
        aws s3 rm "${s3Uri}"
    fi

    if ((debug == 1)); then eval "${close_debug}"; fi
}

function _is_relative_path() {
    local path=$1
    if [[ "${path:0:1}" != "/" && "${path:0:5}" != "s3://" ]]; then
        return 0
    fi
    return 1
}
