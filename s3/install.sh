aws_s3_cli=$(find "$(PWD)" -type f -name "s3_cli.sh")

if [[ "${SHELL}" =~ "zsh" ]]; then
    # shellcheck disable=SC2129
    # shellcheck disable=SC2028
    echo "\n# >>> aws s3 cli initialize >>>" >>"${HOME}/.zshrc"
    echo ". \"${aws_s3_cli}\"" >>"${HOME}/.zshrc"
    echo "# <<< aws s3 cli initialize <<<" >>"${HOME}/.zshrc"

elif [[ "${SHELL}" =~ "bash" ]]; then
    # shellcheck disable=SC2129
    # shellcheck disable=SC2028
    echo -e "\n# >>> aws s3 cli initialize >>>" >>"${HOME}/.bashrc"
    echo ". \"${aws_s3_cli}\"" >>"${HOME}/.bashrc"
    echo "# <<< aws s3 cli initialize <<<" >>"${HOME}/.bashrc"
fi
