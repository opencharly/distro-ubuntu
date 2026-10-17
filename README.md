# distro-ubuntu

The **Ubuntu image family** for [OpenCharly](https://github.com/opencharly/charly) —
deb-family, on the upstream `ubuntu:24.04` base.

This repo is mounted as a git submodule at `box/ubuntu` of the main repo. It
contains **no candies of its own** and carries no build-config file: every candy
is an `@github.com/opencharly/<layer-*|pod-*|plugin-*>[:subdir]:<tag>` ref into
its standalone candy repo, and the distro/builder/init build vocabulary is
embedded in the `charly` binary — `import:` is empty (`import: []`). Ubuntu is
deb-family: `distro.ubuntu` is `inherits: debian`, and the embedded vocabulary
carries both distro configs, so the inheritance resolves with no import.

## What's here

| Kind | Entries |
|---|---|
| Base / builder | `ubuntu` (base), `ubuntu-builder` (pixi/npm/cargo multi-stage builder) |
| Images | `ubuntu-coder` (kitchen-sink dev box), `ubuntu-debootstrap-builder` (`base: debian:13`), `ubuntu-debootstrap` (`from: builder:debootstrap`) |
| VM | `ubuntu-debootstrap` (bootstrap-from-scratch via `debootstrap`), `githubrunner-ubuntu` (co-tenant-safe CI-runner VM for the org's self-hosted fleet) |
| Check bed | `check-ubuntu-debootstrap-vm` (disposable bootstrap-VM bed), `check-githubrunner-ubuntu-vm` (CI-runner VM R10 bed) |

The `ubuntu` base runs as uid-1000 `ubuntu` via **adopt mode** — the upstream
`ubuntu:24.04` image ships a pre-existing `ubuntu:ubuntu` account, and the
embedded `distro.ubuntu` vocabulary adopts it rather than creating a new user.

## No coupling with main

Nothing in the main `opencharly` repo consumes any Ubuntu image (no
`base: ubuntu` image stays in main), so there is no main ↔ ubuntu coupling: the
only edge is `ubuntu → main` (this repo pulls candies via `@github` refs). The
image DAG is acyclic (`ubuntu-coder → ubuntu → docker.io/ubuntu:24.04`;
`ubuntu-debootstrap → ubuntu-debootstrap-builder → docker.io/debian:13`).

## Build

```bash
# Inside the submodule (the build verb defaults to charly.yml):
charly box build ubuntu

# From the parent opencharly repo:
charly -C box/ubuntu box build ubuntu

# Standalone, against the published repo:
charly --repo opencharly/distro-ubuntu box build ubuntu
```

The first build resolves the upstream github references into
`~/.cache/charly/repos/` and materializes the referenced layers under
`.build/_layers/`.

## debootstrap-from-scratch (`ubuntu-debootstrap` / `check-ubuntu-debootstrap-vm`)

`ubuntu-debootstrap` builds an Ubuntu rootfs from scratch via `debootstrap`
inside the privileged `ubuntu-debootstrap-builder` container (`from:
builder:debootstrap`). `check-ubuntu-debootstrap-vm` boots that rootfs under
libvirt/QEMU and carries `disposable: true`, so it rebuilds unattended:

```bash
charly -C box/ubuntu check run check-ubuntu-debootstrap-vm
```

## CI runners (`githubrunner-ubuntu` / `check-githubrunner-ubuntu-vm`)

The Ubuntu half of the org's self-hosted CI fleet: a `kind: vm` entity (cloud_image noble,
UEFI-insecure, q35, 128 GiB / 32 GiB / 16 vCPU) that four GitHub Actions runner instances
share. It exists because the Blacksmith-shaped CI of `opencharly/openclaw-enterprise` needs a
rootful Docker daemon, privileged k3s node containers, systemd and apt + passwordless sudo —
none of which a rootless pod provides.

Those workflows assume **one job per machine**, so the recipe carries the co-tenancy fixes
each measured failure demanded: Docker pinned to `29.4.0` (the version the CI asserts), the
daemon on its own unit and socket so a lane's `systemctl stop docker.service` is a no-op for
its co-tenants, `/var/run/docker.sock` kept as a symlink for the lanes that hardcode or mount
it, per-runner `DOCKER_HOST`, a timer that repairs a dangling socket, a store GC that collects
the buildkit builders cancelled lanes leak (13 of them held 84 GB and filled the disk),
a capped journal, and unprivileged user namespaces enabled for bwrap-sandboxed lanes.

```bash
# The R10 gate (disposable VM, no secret, registers no runner):
charly check run check-githubrunner-ubuntu-vm
```

Registration is a token-guarded operator step — the runner tree and the exact label sets are
provisioned, the `config.sh` run is not. Details: the `githubrunner-ubuntu` skill and the
header of the entity in `charly.yml`. The CachyOS half of the fleet (rootless
`box/githubrunner` pods and their bed) lives in `opencharly/distro-cachyos`.

## Requirements

A build of any image here fetches from the upstream repo, so it needs network
access and a `charly` recent enough to understand the config's schema version
(`charly` hard-fails with a "newer than this charly supports" message if the
config schema is newer than the binary supports).

## Layout

- `charly.yml` — the root manifest: the `discover:` tree, the inline
  `check-ubuntu-debootstrap-vm` bed, and the `skill:` entities as **routing
  metadata only** (their bodies live under `.agents/skills/<name>/SKILL.md`)
  (`ubuntu`, `ubuntu-builder`, `ubuntu-coder`, `ubuntu-debootstrap`,
  `ubuntu-debootstrap-builder`).
- `box/<name>/charly.yml` — one manifest per image / builder / VM box.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `README.md` — this user overview.

## Related

- Owning skills: `/charly-distros:ubuntu`, `/charly-distros:ubuntu-builder`,
  `/charly-distros:ubuntu-debootstrap`,
  `/charly-distros:ubuntu-debootstrap-builder`, `/charly-coder:ubuntu-coder`
- Bootstrap VM: `/charly-vm:ubuntu-debootstrap-vm`
- Sibling: `/charly-distros:debian` (deb-family, create mode)
- [`opencharly/charly`](https://github.com/opencharly/charly) — the charly CLI and image builder
- [`opencharly/opencharly`](https://github.com/opencharly/opencharly) — the umbrella
