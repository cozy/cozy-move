#!/bin/bash

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 1; }
try() { "$@" || die "cannot $*"; }

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR=$(realpath ${SCRIPT_DIR}/..)
PACKAGE_NAME="cozy-move"
TODAY=$(date +%Y%m%d%H%M%S)
EPOCH=""

# Get root privilege
if [ "$(id -u)" = 0 ]; then
    SUDO=env
else
    SUDO=sudo
fi

cleanup() {
  MIX_ENV=prod mix teardown
}

getpackage(){
  echo "Swithing to branch ${BRANCH}"
  cd ${PROJECT_DIR}
  try git fetch
  try git checkout ${BRANCH}
  cd -
}

info(){
cat >&2 <<EOF
Epoch: ${EPOCH}
Suffix: ${SUFFIX}
--Other info--
   Old Hash: ${LAST_GIT_HASH}
   Current Branch Hash: ${CURRENT_GIT_HASH}
   Current Date: ${TODAY}
   Current Package Version: ${UPSTREAM_VERSION}
   Last Upstream Version: ${LAST_UPSTREAM_VERSION}
   Last Build Date: ${LAST_BUILDDATE}
EOF
}

updatechangelog() {
  [ -z "${DISTRO+x}" ] && DISTRO=$(lsb_release -s -c)
  CURRENT_GIT_HASH=$(git --git-dir=${PROJECT_DIR}/.git log -1 --oneline | awk '{ print $1 }')

  if [ -e debian/changelog ]; then
    LAST_UPSTREAM_VERSION=$(dpkg-parsechangelog | sed '/^Version/!d; s/.*://; s/~.*//')
    LAST_BUILDDATE=$(dpkg-parsechangelog | sed '/^Version/!d; s/.*[0-9]:[0-9].//;' | cut -d '~' -f 2)
    LAST_GIT_HASH=$(dpkg-parsechangelog --offset 0 --count 1 | grep -E -m 1 '\[*\]' | awk '{print $2}' | sed 's/\[//;s/\]//')
    SUFFIX=$(dpkg-parsechangelog | sed '/^Version/!d; s/.*\.//')
    LAST_BUILD_VERSION=$(dpkg-parsechangelog | sed '/^Version/!d; s/.* //;')
    if echo "${LAST_BUILD_VERSION}" | grep -q ':'; then
      EPOCH=${LAST_BUILD_VERSION%%:*}
    else
      EPOCH=""
    fi

    dpkg --compare-versions "${UPSTREAM_VERSION}" lt "${LAST_UPSTREAM_VERSION}" && echo "No downgrade allowed here" && exit 1

    if [ -n "${FORCE_EPOCH}" ]; then
      EPOCH=${FORCE_EPOCH}
    fi
    # Package version currently the same, inc build number and rebuild
    dch --no-auto-nmu -b --force-distribution -D "${DISTRO}" -v "${EPOCH=+${EPOCH}:}${UPSTREAM_VERSION}~${TODAY}~${DISTRO}" --vendor cozy "[${CURRENT_GIT_HASH}] New build"
  else
    if [ -n "${FORCE_EPOCH}" ]; then
      EPOCH=${FORCE_EPOCH}
    fi
    dch --create --package ${PACKAGE_NAME} --no-auto-nmu --force-distribution -D "${DISTRO}" -v "${EPOCH=+${EPOCH}:}${UPSTREAM_VERSION}~${TODAY}~${DISTRO}" --vendor cozy "[${CURRENT_GIT_HASH}] Initial debian packaging"
  fi

  # Add git changes if any
  if [ ! -z "${LAST_GIT_HASH}" ];then
    if [ "${LAST_GIT_HASH}" != "${CURRENT_GIT_HASH}" ]; then
        echo "Appending changes between ${LAST_GIT_HASH} and ${CURRENT_GIT_HASH}"
        dch -a ">> Changes since last upload (${LAST_GIT_HASH}):"
        if [ -d "${PROJECT_DIR}/.git" ]; then
            git --git-dir="${PROJECT_DIR}/.git" log --oneline "${LAST_GIT_HASH}..${CURRENT_GIT_HASH}" | sed 's,^,[,; s, ,] ,; s,Version,version,' > .gitout
            while read -r line; do
                dch -a "$line"
            done < .gitout
            rm -f .gitout
        fi
    fi
fi
}

help () {
    cat >&2 <<EOF
Usage: $0 [-s]

   Options :
   -t|--type binary
        Only build binary
   -b|--branch branch
        Build specific branch
   -e|--epoch epoch
        Force epoch


Examples: $0 -t


EOF
}

eval set -- "$(getopt -o hb:e:t: --l help,branch,epoch,type: -- "$@")" || { help; exit 1; }
while :; do
    case $1 in
    -h|--help)
        help
        exit 0
        ;;
    -t|--type)
        TYPE="$2"
        shift 2
        ;;
    -b|--branch)
        BRANCH="$2"
        shift 2
        ;;
    -e|--epoch)
        FORCE_EPOCH="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        help
        exit 1
        ;;
    esac
done

[ -z "$DEBUILD_FLAGS" ] && DEBUILD_FLAGS="-us -uc -i -I.git "

# for checking out git
if ! which git 1>/dev/null; then
    echo "Missing git-core, marking for installation"
    try ${SUDO} apt-get -y install git-core --no-install-recommends
fi

# make sure we have debuild no matter what
if ! which debuild 1>/dev/null; then
    echo "Missing debuild, marking for installation"
    try ${SUDO} apt-get -y install devscripts --no-install-recommends
fi

# make sure we have elixir
if ! which mix 1>/dev/null; then
    echo "Missing elixir, marking for installation"
    try ${SUDO} apt-get -y install esl-erlang elixir --no-install-recommends
fi

# make sure we have nodejs
if ! which nodejs 1>/dev/null; then
    echo "Missing nodejs, marking for installation"
    try ${SUDO} apt-get -y install nodejs=14* --no-install-recommends
else
    nodejs --version | grep -q -E '^v14\.' || die "Wrong nodejs version"
fi

# Get Package (switch git branch if needed)
[ -n "${BRANCH}" ] && getpackage

# update changelog if there something to update
[ -z "${UPSTREAM_VERSION+x}" ] && UPSTREAM_VERSION=$(grep -e '^[[:blank:]]*version:' "${PROJECT_DIR}/mix.exs" | cut -d'"' -f 2)
updatechangelog "${UPSTREAM_VERSION}"

# Print useful information
info

if [ "$TYPE" == "binary" ]; then
    echo "Building binary"
    DEBUILD_FLAGS="-e DEBIAN_VERSION ${DEBUILD_FLAGS} -b"
    #Make sure we have the package for get-build-deps
    if ! command -v dpkg-source 1>/dev/null 2>&1; then
        echo "Missing dev-tools, marking for installation"
        try ${SUDO} apt-get -y install binutils fakeroot quilt devscripts dpkg-dev libdistro-info-perl --no-install-recommends
    fi

    #aptitude is used by get-build deps
    if ! command -v aptitude 1>/dev/null 2>&1; then
        echo "Missing aptitude, marking for installation"
        try ${SUDO} apt-get -y install aptitude --no-install-recommends
    fi
    #equivs needed for mk-build-deps
     if ! command -v equivs-build 1>/dev/null 2>&1; then
         echo "Missing equivs-build, marking for installation"
         try ${SUDO} apt-get -y install equivs --no-install-recommends
     fi

     #test and install deps as necessary
     if ! dpkg-checkbuilddeps 1>/dev/null 2>&1; then
     echo "Missing build dependencies, will install them now:"
         yes y | ${SUDO} mk-build-deps debian/control -ir
     fi
     #test and install deps as necessary
     if ! command -v unzip 1>/dev/null 2>&1; then
     echo "Missing unzip, marking for installation"
         try ${SUDO} apt-get -y install unzip --no-install-recommends
     fi
else
  cleanup
  tar -C "${PROJECT_DIR}/.." --exclude .git -cavf "../${PACKAGE_NAME}_${UPSTREAM_VERSION}~${TODAY}~${DISTRO}.orig.tar.gz" "$(basename ${PROJECT_DIR})"
  DEBUILD_FLAGS="-I${PACKAGE_NAME} -I.gitignore -I.DS_Store -Ibuild-deb.sh -IREADME.md -Igo -IJenkinsfile ${DEBUILD_FLAGS} -S"
fi

#build the packages
echo "Building the packages"
export DEBIAN_VERSION=$(dpkg-parsechangelog --show-field Version)
debuild ${DEBUILD_FLAGS} && \
cat > debian-version.txt <<EOF
DEBIAN_VERSION=${DEBIAN_VERSION}
EOF

echo "Cleaning up"
debian/rules clean -s
