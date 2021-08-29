function normpath() {
    if ((s3_debug == 1)); then set -vx; fi
    trap 'if ((s3_debug == 1)); then set +vx; fi' EXIT

    [[ -z "$1" ]] && return 1

    local skip=0
    local dn="$1" np ce

    # check if we have absolute path and if not make it absolute
    [[ ${dn:0:1} != '/' ]] && dn="${PWD}/${dn}"

    # loop on processing all path elements
    while [[ ${dn} != '/' ]]; do
        # retrive current path element
        ce="$(basename "${dn}")"

        # shink our path on one(current) element
        dn="$(dirname "${dn}")"

        # basename/dirname correct handle multimple "/" chars
        # so we can not warry about them

        # skip elements "/./"
        [[ ${ce} == '.' ]] && continue

        # skip elements "/*/.."
        if (( skip )); then
            skip=0
            continue
        fi

        if [[ ${ce} == '..' ]]; then
            # if we have point on parent dir, we must skip next element
            # in other words "a/b/../c" must become "a/c"
            ((skip = 1))
        else
            # this is normal element and we must add it to result
            [[ -n ${np} ]] && np="/${np}"
            np="${ce}${np}"
        fi
    done

    print "/${np}"
}
