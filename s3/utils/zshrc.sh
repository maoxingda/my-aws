cfg="${HOME}/.zshrc"
cfgtmp="${cfg}.tmp"

beg=0 # begin line of the configuration
end=0 # end line of the configuration

beg_cfg='# >>> aws s3 cli initialize >>>'
end_cfg='# <<< aws s3 cli initialize <<<'

loopcount=0

while IFS=$'\n' read -r line; do

    ((loopcount++))

    ((end != 0)) && echo "${line}" >>"${cfgtmp}"

    if [[ ${line} == "${beg_cfg}" ]]; then
        beg=${loopcount}

    elif [[ ${line} == "${end_cfg}" ]]; then
        end=${loopcount}
    fi

    ((beg == 0)) && echo "${line}" >>"${cfgtmp}"

done <"${cfg}"

cp -f "${cfgtmp}" "${cfg}"

rm -f "${cfgtmp}"
