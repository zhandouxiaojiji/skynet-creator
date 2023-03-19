if [ ! -f "./etc/config.openai" ]; then
  cp ./etc/.config.openai ./etc/config.openai
fi
./build/bin/skynet ./etc/config.test