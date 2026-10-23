# Troubleshooting Guide

| Symptom | Likely cause | Check / fix |
|---|---|---|
| `bind: address already in use` on 8080 | Another process uses the port | `ss -ltnp \| grep 8080`; change the left side of `ports` in `docker-compose.yml` (e.g. `"8081:8080"`) |
| Health shows `unhealthy` | Nginx not answering `/healthz` | `docker inspect --format '{{json .State.Health}}' codealpha-web`; `make logs` |
| `nginx: [emerg] open() ... Permission denied` | Writing to a read-only path as non-root | Keep `tmpfs: /tmp`; do not listen on ports < 1024 (container runs as uid 101) |
| 404 for a page you added | File not copied into the image | Put it in `site/`, then `make build run` (the image must be rebuilt) |
| Container restarts repeatedly / exit 137 | Out of memory (64M limit) | `docker inspect --format '{{.State.OOMKilled}}' codealpha-web`; raise `memory` in compose |
| Changes to `nginx.conf` ignored | Old image still running | `make stop build run` |
| `permission denied ... docker.sock` | User not in `docker` group | `sudo usermod -aG docker $USER` and re-login |
| Config syntax check | — | `docker run --rm codealpha-webserver:1.0.0 nginx -t` |

Useful commands: `make inspect` (status, health, user, limits, live stats), `make logs`, `docker exec -it codealpha-web sh`.
