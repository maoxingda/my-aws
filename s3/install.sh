set -x
root=$(dirname "$0")
if ! [[ -e "template/.find_func" ]]; then

    pushd "template" || exit 1

    cp ".find_func.template" ".find_func"

    # TODO: OS X or Linux
    sed -i "" "s#PWD#${root}#" ".find_func"

    # TODO: print to echo
    print >>"${HOME}/.zshrc"

    cat ".find_func" >>"${HOME}/.zshrc"

    popd || exit 1
fi

on_my_zsh_fun="${HOME}/.oh-my-zsh/functions/"

[[ -d "${on_my_zsh_fun}" ]] || mkdir -p "${on_my_zsh_fun}"

for comp_fun in comps/**/_*; do
    cp -f "${comp_fun}" "${on_my_zsh_fun}"
done
