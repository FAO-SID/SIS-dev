# Workshop deploy layer (multi-country, one host, distinct ports)

Dedicated layer for running the participating countries' SIS instances on one
server for a workshop / demo — each reachable at `http://<IP>:<port>`.

**It does not modify the one-country base.** `docker-compose.yml` and
`deploy.sh` are untouched. Everything multi-country is the two files here:

- `docker-compose.workshop.yml` — merge override (project-scoped names +
  network, per-country nginx port, dev ports dropped, memory limits).
- `deploy-workshop.sh` — project-aware wrapper around the base deploy steps.

See `../../PRODUCTION-PLAN.md` for the rationale.

## Requirements

- Docker + **Docker Compose ≥ 2.24** (for the `!override` tag that drops the
  base's dev port bindings). Ubuntu 24.04 + current docker-ce is fine.
  `docker compose version` to check; the wrapper hard-fails if it's older.
- One **directory per country** (each needs its own bind-mounted volumes), so
  each is a full copy of the repo + this `ops/` layer.

> The IDE may flag `!override` as "Unresolved tag" — that's a generic-YAML
> false positive; it's a Compose Spec tag handled by `docker compose` ≥ 2.24.

## Port convention

| CC | Port |  | CC | Port |  | CC | Port |
| -- | ---- |--| -- | ---- |--| -- | ---- |
| BD | 8011 |  | LA | 8016 |  | PH | 8020 |
| BT | 8012 |  | LK | 8017 |  | TH | 8021 |
| ID | 8013 |  | MN | 8018 |  | UZ | 8022 |
| KG | 8014 |  | NP | 8019 |  | VN | 8023 |
| KH | 8015 |  |    |      |  |    |      |

## Install one country

```bash
# 1. one dir per country = full repo copy (own volumes)
sudo cp -r /opt/sis-template /opt/sis-bt
cd /opt/sis-bt

# 2. bring it up (CC + port). .env + secrets auto-generate on first run.
ops/workshop/deploy-workshop.sh BT 8012
#   → builds the SPA with relative URLs, seeds COUNTRY_CODE=BT, creates the
#     admin user, prints the one-time admin password.

# 3. browse http://<IP>:8012/  and log in as admin.
```

Repeat per country with its port. To script all 13:

```bash
while read cc port; do
  d=/opt/sis-$(echo "$cc" | tr A-Z a-z)
  cp -r /opt/sis-template "$d"
  ( cd "$d" && ops/workshop/deploy-workshop.sh "$cc" "$port" )
done <<'EOF'
BD 8011
BT 8012
ID 8013
KG 8014
KH 8015
LA 8016
LK 8017
MN 8018
NP 8019
PH 8020
TH 8021
UZ 8022
VN 8023
EOF
```

## Operate

```bash
cd /opt/sis-bt
P=sis-bt; C="docker compose -p $P -f docker-compose.yml -f ops/workshop/docker-compose.workshop.yml"
$C ps            # status
$C logs -f sis-api
$C down          # stop (keeps volumes);  add -v to wipe the DB
```

Add demo rasters/profiles per country by dropping files into that dir's
`sis-web-services/volume` and registering from the admin UI, same as the
single-country flow.

## Optional: landing page on :80

A static `index.html` listing the 13 countries with links to their `:<port>`
(plain nginx or `python -m http.server 80`) so nobody reads ports off a slide.

## Graduation: a country moves to its own machine

Each `/opt/sis-<cc>/` is self-contained. To hand it over:

```bash
docker compose -p sis-bt ... down
rsync -a /opt/sis-bt/  newhost:/opt/sis-bt/      # includes DB + raster volumes
# on the new host, run the BASE deploy (no workshop override):
ssh newhost 'cd /opt/sis-bt && ./deploy.sh'      # nginx back on :80, base names
```

Nothing in the data is workshop-specific — the move is a copy, and it drops
the override entirely.
