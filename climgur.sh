#!/usr/bin/env bash

set -e
set -o pipefail
readonly NAME=$(basename $0)
readonly VER="0.01"
source .climgur.rc

# temp file and trap statement - trap for clean end
case "$(uname 2>/dev/null)" in
    'Linux') TMP_FILE=$(mktemp --tmpdir img_$$-XXXX.png) ;;
    'Darwin') TMP_FILE=$(mktemp img_$$-XXXX.png) ;;
esac
trap 'rm -rf ${TMP_FILE} ; exit 1' 0 1 2 3 9 15

# check if scrot exists
[ -z $(which scrot 2>/dev/null) ] &&\
    { printf "%s\n" "scrot not found"; exit 1; }

# check if curl exists
[ -z $(which curl 2>/dev/null) ] &&\
    { printf "%s\n" "curl not found"; exit 1; }

function image()
{
    case "${IMAGE}" in
        's'|'ss'|'screenshot')
            #$(which scrot) -z "${_SC_OPT}" ${TMP_FILE} >/dev/null 2>&1
            $(which scrot) -z ${TMP_FILE} >/dev/null 2>&1
            curl -sH "Authorization: Client-ID ${CLIENT_ID}" \
                -F "image=@${TMP_FILE}" "https://api.imgur.com/3/upload" |\
                python -m json.tool |\
                sed -e 's/^ *//g' -e '/{/d' -e '/}/d'
        ;;
        'u'|'upload') ;;
        *) printf "\nOptions\n\n" ;;
    esac
}

function usage()
{
    printf "\ntesting\n\n"
}

function upload()
{
curl -sH \
    "Authorization: Client-ID ${CLIENT_ID}" \
    -F "image=@${TMP_FILE}" \
    "https://api.imgur.com/3/upload"
}

function account_info()
{
curl -sH \
    "Authorization:Client-ID ${CLIENT_ID}" \
    https://api.imgur.com/3/account/${USER_NAME} |\
    python -m json.tool
}

while getopts "ahi:su:" OPT; do
    case "${OPT}" in
        a) account_info ;;
        h) usage ;;
        i) IMAGE=$OPTARG
            image ;;
        s) screenshot ;;
        u) file upload ;;
    esac
done
[ ${OPTIND} -eq 1 ] && { usage ; }
shift $((OPTIND-1))
