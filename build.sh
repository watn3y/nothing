#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME=$(basename "$PWD")

if [[ ! -f main.c ]]; then
    echo "main.c not found in $PWD" >&2
    exit 1
fi

echo "Project: $PROJECT_NAME"
echo "Image:   debian:bookworm-slim"

architectures=(
    "linux/amd64"
    "linux/386"
    "linux/arm64"
    "linux/arm/v7"
    "linux/riscv64"
    "windows/amd64"
)

mkdir -p build

read -r -d '' BUILD_SCRIPT <<'INNER' || true
PROJECT_NAME="$1"
shift

DEBIAN_FRONTEND=noninteractive apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    gcc gcc-x86-64-linux-gnu gcc-i686-linux-gnu gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu gcc-mingw-w64-x86-64 \
    libc6-dev libc6-dev-i386-cross libc6-dev-arm64-cross \
    libc6-dev-armhf-cross libc6-dev-riscv64-cross \
    binutils-x86-64-linux-gnu binutils-i686-linux-gnu \
    binutils-aarch64-linux-gnu binutils-arm-linux-gnueabihf \
    binutils-riscv64-linux-gnu binutils-mingw-w64-x86-64

failed=0
for arch in "$@"; do
    os="${arch%%/*}"
    rest="${arch#*/}"
    if [[ "$rest" == *"/"* ]]; then
        arch_type="${rest%%/*}"
        arm_version="${rest#*/}"
    else
        arch_type="$rest"
        arm_version=""
    fi

    suffix="$os-$arch_type"
    [[ -n "$arm_version" ]] && suffix="$suffix-$arm_version"

    ext=""
    [[ "$os" == "windows" ]] && ext=".exe"

    output_file="build/$PROJECT_NAME-$suffix$ext"

    case "$os/$arch_type" in
        linux/amd64)   CC="x86_64-linux-gnu-gcc";   STRIPCMD="x86_64-linux-gnu-strip" ;;
        linux/386)     CC="i686-linux-gnu-gcc";      STRIPCMD="i686-linux-gnu-strip" ;;
        linux/arm64)   CC="aarch64-linux-gnu-gcc";   STRIPCMD="aarch64-linux-gnu-strip" ;;
        linux/arm)     CC="arm-linux-gnueabihf-gcc"; STRIPCMD="arm-linux-gnueabihf-strip" ;;
        linux/riscv64) CC="riscv64-linux-gnu-gcc";   STRIPCMD="riscv64-linux-gnu-strip" ;;
        windows/amd64) CC="x86_64-w64-mingw32-gcc";  STRIPCMD="x86_64-w64-mingw32-strip" ;;
        *)
            echo "    SKIP: $arch"
            continue
            ;;
    esac

    cflags="-Os"
    [[ "$os" == "linux" ]] && cflags="$cflags -static"

    echo ">>> Building $arch"
    # shellcheck disable=SC2086
    if $CC $cflags -o "$output_file" main.c; then
        $STRIPCMD "$output_file" 2>/dev/null || true
        if tar -czf "$output_file.tar.gz" -C build "$(basename "$output_file")"; then
            rm "$output_file"
            echo "    OK:   $output_file.tar.gz"
        else
            echo "    FAIL: archive for $output_file" >&2
            failed=1
        fi
    else
        echo "    FAIL: build $arch" >&2
        failed=1
    fi
done

exit $failed
INNER

docker run --rm \
    -v "$PWD:/app" \
    -w /app \
    "debian:bookworm-slim" \
    bash -c "$BUILD_SCRIPT" _ "$PROJECT_NAME" "${architectures[@]}"
