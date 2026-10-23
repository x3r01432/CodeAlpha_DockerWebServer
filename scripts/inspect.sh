#!/usr/bin/env sh
NAME=${1:-codealpha-web}
docker inspect --format 'Status={{.State.Status}} Health={{.State.Health.Status}} User={{.Config.User}} Memory={{.HostConfig.Memory}} NanoCPUs={{.HostConfig.NanoCpus}} ReadOnly={{.HostConfig.ReadonlyRootfs}}' "$NAME"
docker stats --no-stream "$NAME"
