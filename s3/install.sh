root=$(pwd)
comps=~/.zshcomps
if ! [[ -e "template/.find_func" ]]; then

    pushd "template" || exit 1

    cp ".find_func.template" ".find_func"

    if [[ $(uname) = Darwin ]]; then
        sed -i "" "s#PWD#${root}#" ".find_func"
    else
        sed -i "s#PWD#${root}#" ".find_func"
    fi

    eval "zsh -x ${root}/utils/zshrc.sh"

    echo >>"${HOME}/.zshrc"

    cat ".find_func" >>"${HOME}/.zshrc"

    popd || exit 1
fi

on_my_zsh_fun="${HOME}/.oh-my-zsh/functions/"

[[ -d "${on_my_zsh_fun}" ]] || mkdir -p "${on_my_zsh_fun}"

for comp_fun in comps/**/_*; do
    # TODO: save manifest files reinstall
    cp -f "${comp_fun}" "${on_my_zsh_fun}"
done
