# variables declaration
declare s3_debug=0

s3_pwd="s3://"
s3_old_pwd="s3://"
s3_open_debug="set -vx"
s3_close_debug="set +vx"

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
    if ((s3_debug == 1)); then eval "${s3_open_debug}"; fi
    trap "if ((s3_debug == 1)); then ${s3_close_debug}; fi" EXIT

    local pos_args=()
    typeset -A opt_args

    for arg; do
        if [[ "${arg}" == "-r" ]]; then
            opt_args["-r"]="--recursive"

        elif [[ "${arg}" == "-h" ]]; then
            opt_args["-h"]="--help"

        elif [[ "${arg}" =~ ^-.* ]]; then
            echo "Unknown option: ${arg}"
            return 1
        else
            pos_args+=("${arg}")
        fi
    done

    if [[ ${opt_args["-h"]} == "--help" ]]; then
        echo "Usage: sls [s3Uri] [-r]"
        return 1
    fi

    if ((${#pos_args} > 1)); then
        echo "Expect 0 or 1 positional argument, got ${#pos_args}"
        return 1
    fi

    local s3Uri="${pos_args[1]}"

    if [[ "${s3Uri}" == "" || "${s3Uri}" == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"

    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri%'/'}/"
    fi

    if [[ ${opt_args["-r"]} == "--recursive" ]]; then
        aws s3 ls ${s3Uri} --human-readable --recursive
    else
        aws s3 ls ${s3Uri} --human-readable
    fi

    if ((s3_debug == 1)); then eval "${s3_close_debug}"; fi
}

function scd() {
    if ((s3_debug == 1)); then eval "${s3_open_debug}"; fi
    trap "if ((s3_debug == 1)); then ${s3_close_debug}; fi" EXIT

    if (($# > 1)); then
        echo "Usage: scd [s3Uri]"
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

    if ((s3_debug == 1)); then eval "${s3_close_debug}"; fi
}

function sup() {
    if ((s3_debug == 1)); then eval "${s3_open_debug}"; fi
    trap "if ((s3_debug == 1)); then ${s3_close_debug}; fi" EXIT

    local pos_args=()
    typeset -A opt_args

    local opt=0
    for arg; do
        if ((opt == 1)); then
            opt_args["-i"]=${arg}
            opt=0

        elif [[ "${arg}" == "-h" ]]; then
            echo "Usage: sup <LocalPath> <S3Uri> [-r] [-i partten]"
            return 1

        elif [[ "${arg}" == "-r" ]]; then
            opt_args["-r"]="--recursive"

        elif [[ "${arg}" == "-i" ]]; then
            opt=1
        else
            pos_args+=("${arg}")
        fi
    done

    if ((${#pos_args} > 2)); then
        echo "Expect 1 or 2 positional argument, got ${#pos_args}"
        return 1
    fi

    local localPath="${pos_args[1]}"
    local s3Uri="${pos_args[2]}"

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

    if [[ ${opt_args["-r"]} == "--recursive" ]]; then
        if [[ ${opt_args["-i"]} =~ .+ ]]; then
            aws s3 cp "${localPath}" "${s3Uri}" --recursive --exclude "*" --include "${opt_args["-i"]}"
        else
            aws s3 cp "${localPath}" "${s3Uri}" --recursive
        fi
    else
        aws s3 cp "${localPath}" "${s3Uri}"
    fi

    if ((s3_debug == 1)); then eval "${s3_close_debug}"; fi
}

function sdown() {
    if ((s3_debug == 1)); then eval "${s3_open_debug}"; fi
    trap "if ((s3_debug == 1)); then ${s3_close_debug}; fi" EXIT

    local pos_args=()
    typeset -A opt_args

    local opt=0
    for arg; do
        if ((opt == 1)); then
            opt_args["-i"]=${arg}
            opt=0

        elif [[ "${arg}" == "-h" ]]; then
            echo "Usage: sdown <s3Uri> <LocalPath> [-r] [-i partten]"
            return 1

        elif [[ "${arg}" == "-r" ]]; then
            opt_args["-r"]="--recursive"

        elif [[ "${arg}" == "-i" ]]; then
            opt=1
        else
            pos_args+=("${arg}")
        fi
    done

    if ((${#pos_args} > 2)); then
        echo "Expect 1 or 2 positional argument, got ${#pos_args}"
        return 1
    fi

    local s3Uri="${pos_args[1]}"
    local localPath="${pos_args[2]}"

    if [[ "${s3Uri}" == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"
    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri}"
    fi

    if [[ "${localPath}" == "" || "${localPath}" == "." ]]; then
        localPath="${PWD}/"
    fi

    if [[ ${opt_args["-r"]} == "--recursive" ]]; then
        if [[ ${opt_args["-i"]} =~ .+ ]]; then
            aws s3 cp "${s3Uri}" "${localPath}" --recursive --exclude "*" --include "${opt_args["-i"]}"
        else
            aws s3 cp "${s3Uri}" "${localPath}" --recursive
        fi
    else
        aws s3 cp "${s3Uri}" "${localPath}"
    fi

    if ((s3_debug == 1)); then eval "${s3_close_debug}"; fi
}

function smv() {
    if ((s3_debug == 1)); then eval "${s3_open_debug}"; fi
    trap "if ((s3_debug == 1)); then ${s3_close_debug}; fi" EXIT

    local pos_args=()
    typeset -A opt_args

    local opt=0
    for arg; do
        if ((opt == 1)); then
            opt_args["-i"]=${arg}
            opt=0

        elif [[ "${arg}" == "-h" ]]; then
            echo "Usage: smv <s3Uri> <s3Uri> [-r] [-i partten]"
            return 1

        elif [[ "${arg}" == "-r" ]]; then
            opt_args["-r"]="--recursive"

        elif [[ "${arg}" == "-i" ]]; then
            opt=1
        else
            pos_args+=("${arg}")
        fi
    done

    if ((${#pos_args} > 2)); then
        echo "Expect 1 or 2 positional argument, got ${#pos_args}"
        return 1
    fi

    s3SrcUri="${pos_args[1]}"
    s3DstUri="${pos_args[2]}"

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

    if [[ ${opt_args["-r"]} == "--recursive" ]]; then
        if [[ ${opt_args["-i"]} =~ .+ ]]; then
            aws s3 mv "${s3SrcUri}" "${s3DstUri}" --recursive --exclude "*" --include "${opt_args["-i"]}"
        else
            aws s3 mv "${s3SrcUri}" "${s3DstUri}" --recursive
        fi
    else
        aws s3 mv "${s3SrcUri}" "${s3DstUri}"
    fi

    if ((s3_debug == 1)); then eval "${s3_close_debug}"; fi
}

function srm() {
    if ((s3_debug == 1)); then eval "${s3_open_debug}"; fi
    trap "if ((s3_debug == 1)); then ${s3_close_debug}; fi" EXIT

    local pos_args=()
    typeset -A opt_args

    local opt=0
    for arg; do
        if ((opt == 1)); then
            opt_args["-i"]=${arg}
            opt=0

        elif [[ "${arg}" == "-h" ]]; then
            echo "Usage: srm [s3Uri] [-r] [-i partten]"
            return 1

        elif [[ "${arg}" == "-r" ]]; then
            opt_args["-r"]="--recursive"

        elif [[ "${arg}" == "-i" ]]; then
            opt=1
        else
            pos_args+=("${arg}")
        fi
    done

    if ((${#pos_args} > 1)); then
        echo "Expect 0 or 1 positional argument, got ${#pos_args}"
        return 1
    fi

    local s3Uri="${pos_args[1]}"

    if [[ "${s3Uri}" == "" || "${s3Uri}" == "." ]]; then
        s3Uri="${s3_pwd%'/'}/"
    elif _is_relative_path "${s3Uri}"; then
        s3Uri="${s3_pwd%'/'}/${s3Uri}"
    fi

    if [[ ${opt_args["-r"]} == "--recursive" ]]; then
        if [[ ${opt_args["-i"]} =~ .+ ]]; then
            aws s3 rm "${s3Uri}" --recursive --exclude "*" --include "${opt_args["-i"]}"
        else
            aws s3 rm "${s3Uri}" --recursive
        fi
    else
        aws s3 rm "${s3Uri}"
    fi

    if ((s3_debug == 1)); then eval "${s3_close_debug}"; fi
}

function _is_relative_path() {
    local path=$1
    if [[ "${path:0:1}" != "/" && "${path:0:5}" != "s3://" ]]; then
        return 0
    fi
    return 1
}

function getOptsFunction() {
    if ((s3_debug == 1)); then eval "${s3_open_debug}"; fi
    local OPTIND
    while getopts ":c:l:u:s:" opt; do
        case "$opt" in
        c) # default character to display if no weather, leave empty for none
            c="$OPTARG"
            ;;
        l) # supply city name instead of using internet
            l="$OPTARG"
            ;;
        u) # how often to update weather in seconds
            u="$OPTARG"
            ;;
        s) # weather update alert string to supply, if any
            s="$OPTARG"
            ;;
        h)
            # echo the help file
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        esac
    done

    shift $((OPTIND - 1))

    # set defaults if command not supplied
    if [ -z "$u" ]; then u=10800; fi
    if [ -z "$c" ]; then c="$"; fi
    if ((s3_debug == 1)); then eval "${s3_close_debug}"; fi
}

function arg_parse() {
    recursive=0
    for arg; do
        if [[ "${arg}" == "-r" ]]; then
            recursive=1
        fi
    done
    echo $recursive
}
