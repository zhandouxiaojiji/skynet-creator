if [ ! -f "./etc/config.test" ]; then
  cp ./etc/.config.test ./etc/config.test
fi
./build/bin/skynet ./etc/config.test
