#!/bin/bash
#

set -e

default_platform=`case $(uname -m) in i386)   echo "linux/386" ;; i686)   echo "linux/386" ;; x86_64) echo "linux/amd64";; aarch64)echo "linux/arm64";; esac`
default_arch=`case $(uname -m) in i386)   echo "386" ;; i686)   echo "386" ;; x86_64) echo "amd64";; aarch64)echo "arm64";; esac`

PLATFORM="$default_platform"
VERSION="5.0.1"
IMAGE_NAME="opengauss"
DOCKER_FILE="Dockerfile"
IMAGE_PREFIX="docker.io/enmotech"
BUILD_ARGS=
DRIVER_OPTS=
LOCAL_IMAGE=
MERGE=1

while true; do
  case "$1" in
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --version|-v)
      VERSION="$2"
      shift 2
      ;;
    --image-name|-n)
      IMAGE_NAME="$2"
      shift 2
      ;;
    --dockerfile|-f)
      DOCKER_FILE="$2"
      shift 2
      ;;
    --image-prefix)
      IMAGE_PREFIX="$2"
      shift 2
      ;;
    --build-arg)
      BUILD_ARGS=( --build-arg "$2" ${BUILD_ARGS[*]} )
      shift 2
      ;;
    --driver-opt)
      DRIVER_OPTS=( --driver-opt "$2" ${DRIVER_OPTS[*]} )
      shift 2
      ;;
    --no-merge)
      MERGE=0
      shift 1
      ;;
    *)
      break
  esac
done

if [[ "$VERSION" < "5.0.1" ]]; then
  ./buildDockerImage.sh -i -v "$VERSION"
  exit 0
fi


PLATFORMS=()
if [[ "$MERGE" -eq 0 ]]; then
  PLATFORMS=( ${PLATFORM/,/ } )
fi


LOCAL_IMAGE="${IMAGE_PREFIX}/${IMAGE_NAME}"


#if [[ -n "$VERSION" ]]; then
#  LOCAL_IMAGE="${LOCAL_IMAGE}:${VERSION}"
#fi

# Go into version folder
cd "$VERSION" || {
  echo "Could not find version directory '$VERSION'";
  exit 1;
}



if docker buildx version > /dev/null 2>&1; then
  docker buildx use opengauss_builder || docker buildx create --name opengauss_builder ${DRIVER_OPTS[*]} --use --platform="${PLATFORM}"

  if [[ "${#PLATFORMS[@]}" -gt 0 ]]; then
    for platform in "${PLATFORMS[@]}"; do
      arch="${platform#linux/}"
      local_image="${LOCAL_IMAGE}:${arch}-${VERSION}"

      docker buildx build --provenance=false -t "${local_image}" --load -f "${DOCKER_FILE}" --platform "${platform}" ${BUILD_ARGS[*]} .
    done
  else
    local_image="${LOCAL_IMAGE}:${VERSION}"
    BUILD_ARGS=( ${BUILD_ARGS[*]} --push )

    docker buildx build --provenance=false -t "${local_image}"  -f "${DOCKER_FILE}"  --platform "${PLATFORM}" ${BUILD_ARGS[*]} .
  fi

else
  if [[ "$PLATFORMS" == "$default_platform" ]]; then
    arch="${PLATFORM#linux/}"
    local_image="${LOCAL_IMAGE}:${arch}-${VERSION}"

    BUILD_ARGS=( ${BUILD_ARGS[*]} --build-arg TARGETARCH="${default_arch}" )
    DOCKER_BUILDKIT=1 docker build -t "${local_image}" -f "${DOCKER_FILE}" ${BUILD_ARGS[*]} .
  else
    echo "platforms not match local and docker client not support buildx"
    exit 1
  fi

fi


