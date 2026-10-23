# CodeAlpha_DockerWebServer

CodeAlpha DevOps Internship, **Task 4: Docker web server**. A static website served by Nginx in a hardened Docker container, with lifecycle scripts, a troubleshooting guide and GitHub Actions CI that builds and smoke-tests the container.

## Architecture

```
browser ──► host :8080 ──► container codealpha-web (nginx-unprivileged 1.27.3-alpine, uid 101, listens 8080)
                              ├─ /usr/share/nginx/html  ← site/ (baked into image)
                              ├─ /healthz               ← used by Docker HEALTHCHECK
                              └─ logs → stdout/stderr → json-file driver (10 MB x 3 rotation)
```

Hardening: non-root user, read-only root filesystem (tmpfs `/tmp`), all Linux capabilities dropped, `no-new-privileges`, limits of 0.5 CPU and 64 MB RAM, `server_tokens off`, security headers.

## Files
- `Dockerfile` – pinned base image, non-root, HEALTHCHECK
- `nginx.conf` – server config, `/healthz` endpoint
- `docker-compose.yml` – ports, resource limits, logging, hardening
- `Makefile` – `build run stop restart logs inspect health smoke clean`
- `scripts/smoke-test.sh`, `scripts/inspect.sh`
- `TROUBLESHOOTING.md`
- `ci/ci.yml` – GitHub Actions workflow: build + smoke test on every push (see *Enabling CI* below)

## Run it
Requires Docker with Compose v2.
```bash
make build      # build the image
make run        # start in the background
make smoke      # wait for healthy and test it
open http://localhost:8080
make logs       # follow access logs
make inspect    # health, user, limits, live stats
make stop
```

## Proof (real output)
```
health: healthy
index: ok
healthz: ok
security headers: ok
404: ok
non-root: ok (uid 101)
SMOKE TEST PASSED
Status=running Health=healthy User=101 Memory=67108864 NanoCPUs=500000000 ReadOnly=true
NAME            CPU %     MEM USAGE / LIMIT   MEM %
codealpha-web   0.00%     6.848MiB / 64MiB    10.70%
codealpha-web  | 172.18.0.1 - - [23/Oct/2026:21:42:21 +0000] "GET / HTTP/1.1" 200 433 "-" "curl/8.14.1" "-"
```

## LinkedIn demo script (60–90 s)
1. (10 s) "For CodeAlpha DevOps Task 4 I containerised an Nginx web server." Show the repo.
2. (15 s) Open the `Dockerfile`: pinned image, runs as non-root, HEALTHCHECK.
3. (15 s) Open `docker-compose.yml`: CPU/memory limits, read-only filesystem, log rotation.
4. (20 s) Terminal: `make build run smoke` and show `SMOKE TEST PASSED`; open localhost:8080 in the browser.
5. (10 s) `make inspect` and `make logs` to show health, limits and access logs.
6. (10 s) Show the green GitHub Actions run. "Thanks @CodeAlpha #DevOps #Docker"

## Enabling CI
The workflow lives in `ci/ci.yml` because the token used to publish this repo has no `workflow` scope, and GitHub rejects pushes to `.github/workflows/` without it. To switch it on:
```bash
gh auth refresh -s workflow        # one-time, in your browser
mkdir -p .github/workflows && git mv ci/ci.yml .github/workflows/ci.yml
git commit -m "Enable GitHub Actions CI" && git push
```
The same steps it runs (`docker compose build`, `up -d`, `scripts/smoke-test.sh`) were run locally and passed (see Proof).

## License
MIT © 2026 Steven Rios
