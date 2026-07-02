# opencharly/distro-ubuntu

The **Ubuntu image family** for [OpenCharly](https://github.com/opencharly/charly),
split into its own repository and mounted as a git submodule at `box/ubuntu`
of the main repo.

## What's here

| Kind | Entries |
|---|---|
| `image:` | `ubuntu` (base), `ubuntu-builder`, `ubuntu-coder`, `ubuntu-debootstrap`, `ubuntu-debootstrap-builder` |
| `vm:` | `ubuntu-debootstrap` (bootstrap-from-scratch via debootstrap) |
| `check:` | `check-ubuntu-debootstrap-vm` (disposable bootstrap-VM bed) |

## Composition by reference — nothing is vendored

This repo contains **no candies of its own** and carries no build-config file.
Everything is pulled from `github.com/opencharly/charly` by **github reference**,
and the shared build vocabulary is embedded in the `charly` binary:

- every candy in `charly.yml` is an `@github.com/opencharly/charly/candy/<name>:<tag>` ref;
- the distro/builder/init build vocabulary is **embedded in the `charly` binary**
  (`charly/charly.yml`) — `import:` is empty (`import: []`). Ubuntu is deb-family:
  `distro.ubuntu` is `inherits: debian`, and the embedded vocabulary carries BOTH
  the `ubuntu` and `debian` distro configs, so the inheritance resolves with no
  import. It also carries the `deb` format template and the `debootstrap` builder
  template.

The `ubuntu` base roots at the upstream docker.io `ubuntu:24.04` image directly
(the `ubuntu-debootstrap-builder` is `base: debian:13`, since debootstrap is a
Debian tool), so this repo needs **no remote base include**. All references pin
to a single tag of the upstream repo, so a build is reproducible. There is
exactly one definition of every layer — no duplication.

## No coupling with main

Nothing in the main `opencharly` repo consumes any Ubuntu image (no
`base: ubuntu` image stays in main), so there is **no main ↔ ubuntu coupling**:
the only edge is `ubuntu → main` (this repo pulls candies via `@github` refs). Main
pulls nothing back. The image DAG is acyclic
(`ubuntu-coder → ubuntu → docker.io/ubuntu:24.04`;
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
libvirt/QEMU and carries `disposable: true`, so `charly -C box/ubuntu update
check-ubuntu-debootstrap-vm` rebuilds it unattended.

## Requirements

A build of any image here fetches from the upstream repo, so it needs network
access and a `charly` recent enough to understand the config's schema version
(`charly` hard-fails with an "update charly" message if the config is newer than the
binary supports).

---
*Assisted-by: Claude*
