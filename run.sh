#!/bin/sh

# Send SIGTERM to the application.
term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143 # 128(External) + 15(SIGTERM)
}

# Setup the trap for the SIGTERM.
trap 'kill ${!}; term_handler' SIGTERM

# Start application.
java org.springframework.boot.loader.launch.JarLauncher &
pid="$!"

# Wait the signal.
while true; do
  # Check if process is still running.
  kill -0 "$pid" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "Process $pid is not running. Terminating the container."
    term_handler
  fi
  # Signal confirmation interval.
  sleep 5
done
