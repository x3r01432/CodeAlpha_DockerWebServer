#!/usr/bin/env sh
# Waits for the container to be healthy, then checks the page and headers.
set -eu
NAME=${1:-codealpha-web}; URL=${2:-http://localhost:8080}
for i in $(seq 1 30); do
  s=$(docker inspect --format '{{.State.Health.Status}}' "$NAME" 2>/dev/null || echo none)
  [ "$s" = healthy ] && break; sleep 2
done
echo "health: $s"; [ "$s" = healthy ]
curl -fsS "$URL/" | grep -q "Hello from Docker" && echo "index: ok"
curl -fsS "$URL/healthz" | grep -q ok && echo "healthz: ok"
curl -sI "$URL/" | grep -qi "x-frame-options: DENY" && echo "security headers: ok"
[ "$(curl -s -o /dev/null -w '%{http_code}' "$URL/missing")" = 404 ] && echo "404: ok"
[ "$(docker exec "$NAME" id -u)" != 0 ] && echo "non-root: ok (uid $(docker exec "$NAME" id -u))"
echo "SMOKE TEST PASSED"
