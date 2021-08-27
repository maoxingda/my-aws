root=$(pwd)
cfg=~/.zshrc
ff='.find_func'
comps=~/.zshcomps
manifest=~/.myzsh.custom.compfuncs.manifest

# Parse command line arguments
while getopts 'r' opt; do
    case ${opt} in
    r)
        reinstall=1
        ;;
    ?)
        exit 1
        ;;
    esac
done

# Save configuration
if ((reinstall)) || [[ ! -f "template/${ff}" ]]; then

    pushd "template" || exit 1

    cp ".find_func.template" "${ff}"

    if [[ $(uname) == Darwin ]]; then
        sed -i "" "s#PWD#${root}#" "${ff}"
    else
        sed -i "s#PWD#${root}#" "${ff}"
    fi

    cfgcmd="zsh ${root}/utils/zshrc.sh"

    [[ -o x ]] && cfgcmd="zsh -x ${cfgcmd:4:256}"

    eval "${cfgcmd}"

    echo >>"${cfg}"

    cat "${ff}" >>"${cfg}"

    popd || exit 1
fi

# Remove the continuation blank lines
if [[ $(uname) == Darwin ]]; then
    sed -i '' -e '/^$/N;/\n$/D' "${cfg}"
else
    sed -e '/^$/N;/\n$/D' "${cfg}"
fi

# Copy custom completion functions
on_my_zsh_fun="${HOME}/.oh-my-zsh/functions/"

[[ -d "${on_my_zsh_fun}" ]] || mkdir -p "${on_my_zsh_fun}"

if [[ -f ${manifest} ]]; then
    cfs=(${(f)"$(<${manifest})"}) && rm -f ${manifest}

    if ((reinstall)); then
        # shellcheck disable=SC1058
        # shellcheck disable=SC1073
        # shellcheck disable=SC1072
        for cf (${cfs}); do
            rm -f ${on_my_zsh_fun}${cf}
        done
    fi
fi

for comp_fun in comps/**/_*; do
    # Save manifest files reinstall or uninstall
    bn=$(basename ${comp_fun})
    cfs+=($bn)
    cp -f "${comp_fun}" "${on_my_zsh_fun}"
done

# Remove duplicate elements from cfs array
#cfs=${(u)cfs}

# Save manifest
# shellcheck disable=SC1073
# shellcheck disable=SC1058
# shellcheck disable=SC1072
for cf (${(u)cfs}); do
    print ${cf}>>${manifest}
done