pwd="${PWD}"
on_my_zsh_fun="${HOME}/.oh-my-zsh/functions/"

if ! [[ -e "template/find_func.sh" ]]; then

    cd "template" || exit 1

    cp "find_func.sh.template" "find_func.sh"

    sed -i "" "s#search_path_placeholder#${pwd}#" "find_func.sh"

    echo >>"${HOME}/.zshrc"
    cat "find_func.sh" >>"${HOME}/.zshrc"
fi

if ! [[ -d "${on_my_zsh_fun}" ]]; then
    mkdir -p "${on_my_zsh_fun}"
fi

for comp_fun in $(find "${pwd}/comps" -type f -name "_*"); do
    cp "${comp_fun}" "${on_my_zsh_fun}"
done
