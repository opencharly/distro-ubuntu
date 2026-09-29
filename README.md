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
| VM | `ubuntu-debootstrap` (bootstrap-from-scratch via `debootstrap`) |
| Check bed | `check-ubuntu-debootstrap-vm` (disposable bootstrap-VM bed) |

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

## Requirements

A build of any image here fetches from the upstream repo, so it needs network
access and a `charly` recent enough to understand the config's schema version
(`charly` hard-fails with a "newer than this charly supports" message if the
config schema is newer than the binary supports).

## Layout

- `charly.yml` — the root manifest: the `discover:` tree, the inline
  `check-ubuntu-debootstrap-vm` bed, and the embedded `skill:` entities
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
