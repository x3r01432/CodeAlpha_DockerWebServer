.PHONY: build run stop restart logs inspect health smoke clean
build:   ; docker compose build
run:     ; docker compose up -d
stop:    ; docker compose down
restart: stop run
logs:    ; docker compose logs -f --tail=100
inspect: ; ./scripts/inspect.sh
health:  ; docker inspect --format '{{.State.Health.Status}}' codealpha-web
smoke:   ; ./scripts/smoke-test.sh
clean:   ; docker compose down --rmi local -v
