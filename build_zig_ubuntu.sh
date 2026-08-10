ZIG_VERSION=$1

declare -a arr=("jammy" "noble" "questing" "resolute")
for i in "${arr[@]}"
do
  DEBIAN_DIST=$i
  FULL_VERSION=$ZIG_VERSION-${DEBIAN_DIST}_amd64
  docker build . -f Dockerfile.ubuntu -t zig-master-$DEBIAN_DIST --build-arg ZIG_VERSION=$ZIG_VERSION --build-arg DEBIAN_DIST=$DEBIAN_DIST --build-arg FULL_VERSION=$FULL_VERSION
  id="$(docker create zig-master-$DEBIAN_DIST)"
  docker cp $id:/zig-master_$FULL_VERSION.deb - > ./zig-master_$FULL_VERSION.deb
  tar -xf ./zig-master_$FULL_VERSION.deb
done

