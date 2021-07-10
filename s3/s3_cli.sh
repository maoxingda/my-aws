# variables declaration
declare s3_debug=0

s3_pwd="s3://"
s3_old_pwd="s3://"

# functions declaration
function spwd() {
    echo "${s3_pwd}"
}

function sdebug() {
    if ((s3_debug == 1)); then
        s3_debug=0
        echo "debug switch off"
    else
        s3_debug=1
        echo "debug switch on"
    fi
}

function sls() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0

    while getopts hr opt; do
        case ${opt} in
        h)
            echo "Usage: $0 [-r] [s3Uri]"
            return 0
            ;;
        r)
            recursive=1
            ;;
        \?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# > 1)); then
        echo "Expect 0 or 1 positional argument, got $#"
        return 1
    fi

    local s3Uri=$1

    if [[ "${s3Uri}" == "" || "${s3Uri}" == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"

    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if ((recursive)); then
        aws s3 ls ${s3Uri} --human-readable --recursive
    else
        aws s3 ls ${s3Uri} --human-readable
    fi
}

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

    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if eval "aws s3 ls ${s3Uri} >> /dev/null 2&>1"; then
        s3_old_pwd=${s3_pwd}
        s3_pwd=${s3Uri}
    else
        echo "scd: no such object, prefix, or bucket: ${s3Uri}"
    fi
}

function sup() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0
    local include=""

    while getopts hri: opt; do
        case ${opt} in
        h)
            echo "Usage: $0 [-h] [-r] [-i wldcard] [localPath] [s3Uri]"
            return 0
            ;;
        r)
            recursive=1
            ;;
        i)
            include="${{OPTARG}}"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    ((OPTIND > 1)) && shift $((OPTIND - 1))

    if (($# > 2)); then
        echo "Expect 1 or 2 positional argument, got $#"
        return 1
    fi

    local localPath=$1
    local s3Uri=$2

    if [[ "${localPath}" == "." ]]; then
        localPath="${PWD}/"

    elif _is_relative_path "${localPath}"; then
        localPath="${PWD}/${localPath}"
    fi

    if [[ ${s3Uri} == "" || ${s3Uri} == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"

    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if [[ ${s3Uri} == "s3://" ]]; then
        echo "missing bucket name"
        return 1
    fi

    if ((recursive)); then
        if [[ ${include} =~ .+ ]]; then
            aws s3 cp "${localPath}" "${s3Uri}" --recursive --exclude "*" --include "${include}"
        else
            aws s3 cp "${localPath}" "${s3Uri}" --recursive
        fi
    else
        aws s3 cp "${localPath}" "${s3Uri}"
    fi
}

function sdown() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT
    
    local opt
    local recursive=0
    local include=""

    while getopts hri: opt; do
        case ${opt} in
        h)
            echo "Usage: $0 [-h] [-r] [-i wldcard] [s3Uri] [localPath]"
            return 0
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

    if (($# > 2)); then
        echo "Expect 1 or 2 positional argument, got $#"
        return 1
    fi

    local s3Uri=$1
    local localPath=$2

    if [[ "${s3Uri}" == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"
        
    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri}"
    fi

    if [[ "${localPath}" == "" || "${localPath}" == "." ]]; then
        localPath="${PWD}/"
    fi

    if ((recursive)); then
        if [[ ${include} =~ .+ ]]; then
            aws s3 cp "${s3Uri}" "${localPath}" --recursive --exclude "*" --include "${include}"
        else
            aws s3 cp "${s3Uri}" "${localPath}" --recursive
        fi
    else
        aws s3 cp "${s3Uri}" "${localPath}"
    fi
}

function smv() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0
    local include=""

    while getopts hri: opt; do
        case ${opt} in
        h)
            echo "Usage: $0 [-h] [-r] [-i wldcard] <s3Uri> [s3Uri]"
            return 0
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

    if (($# > 2)); then
        echo "Expect 1 or 2 positional argument, got $#"
        return 1
    fi

    s3SrcUri=$1
    s3DstUri=$2

    if [[ "${s3SrcUri}" == "." ]]; then
        s3SrcUri="${s3_pwd%'/'}/"

    elif _is_relative_path "${s3SrcUri}"; then
        s3SrcUri="${s3_pwd%'/'}/${s3SrcUri}"
    fi

    if [[ "${s3DstUri}" == "" || "${s3DstUri}" == "." ]]; then
        s3DstUri="${s3_pwd%'/'}/"
        
    elif _is_relative_path "${s3DstUri}"; then
        s3DstUri="${s3_pwd%'/'}/${s3DstUri}"
    fi

    if [[ "${s3SrcUri}" == "${s3DstUri}" ]]; then
        echo "The source is same as destination"
        return 1
    fi

    if ((recursive)); then
        if [[ ${include} =~ .+ ]]; then
            aws s3 mv "${s3SrcUri}" "${s3DstUri}" --recursive --exclude "*" --include "${include}"
        else
            aws s3 mv "${s3SrcUri}" "${s3DstUri}" --recursive
        fi
    else
        aws s3 mv "${s3SrcUri}" "${s3DstUri}"
    fi
}

function srm() {
    if ((s3_debug == 1)); then set -vx; fi
    trap "if ((s3_debug == 1)); then set +vx; fi" EXIT

    local opt
    local recursive=0
    local include=""

    while getopts hri: opt; do
        case ${opt} in
        h)
            echo "Usage: $0 [-h] [-r] [-i wldcard] [s3Uri]"
            return 0
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

    if (($# > 1)); then
        echo "Expect 0 or 1 positional argument, got $#"
        return 1
    fi

    local s3Uri=$1

    if [[ "${s3Uri}" == "" || "${s3Uri}" == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"
        
    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri}"
    fi

    if ((recursive)); then
        if [[ ${include} =~ .+ ]]; then
            aws s3 rm "${s3Uri}" --recursive --exclude "*" --include "${include}"
        else
            aws s3 rm "${s3Uri}" --recursive
        fi
    else
        aws s3 rm "${s3Uri}"
    fi
}

function _is_relative_path() {
    local path=$1
    if [[ "${path:0:1}" != "/" && "${path:0:5}" != "s3://" ]]; then
        return 0
    fi
    return 1
}