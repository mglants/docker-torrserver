#!/bin/bash


type setopt >/dev/null 2>&1
set_goarm() {
  if [[ "$1" =~ arm([5,7]) ]]; then
    GOARCH="arm"
    GOARM="${BASH_REMATCH[1]}"
    GO_ARM="GOARM=${GOARM}"
  else
    GOARM=""
    GO_ARM=""
  fi
}
set_gomips() {
  if [[ "$1" =~ mips ]]; then
    if [[ "$1" =~ mips(64) ]]; then MIPS64="${BASH_REMATCH[1]}"; fi
    GO_MIPS="GOMIPS${MIPS64}=softfloat"
  else
    GO_MIPS=""
  fi
}
GOBIN="go"

$GOBIN version

LDFLAGS="'-s -w'"
FAILURES=""
ROOT=${PWD}

#### Build web
echo "Build web"
$GOBIN run gen_web.go

#### Build server
echo "Build server"
cd "${ROOT}/server" || exit 1
$GOBIN clean -i -r -cache #--modcache
$GOBIN mod tidy

BUILD_FLAGS="-ldflags=${LDFLAGS}"

#####################################
### X86 build section
#####

GOOS=${TARGETOS}
GOARCH=${TARGETARCH}
set_goarm "$GOARCH"
set_gomips "$GOARCH"
BIN_FILENAME="/tmp/torrserver"
CMD="GOOS=${GOOS} GOARCH=${GOARCH} ${GO_ARM} ${GO_MIPS} ${GOBIN} build ${BUILD_FLAGS} -o ${BIN_FILENAME} ./cmd"
echo "${CMD}"
eval "$CMD" || FAILURES="${FAILURES} ${GOOS}/${GOARCH}${GOARM}"
#CMD="../upx -q ${BIN_FILENAME}"; # upx --brute produce much smaller binaries
#echo "compress with ${CMD}"
#eval "$CMD"

# eval errors
if [[ "${FAILURES}" != "" ]]; then
  echo ""
  echo "failed on: ${FAILURES}"
  exit 1
fi