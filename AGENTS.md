# AGENTS.md — distro-ubuntu

The **Ubuntu image family** — charly's `box/ubuntu`. A self-contained
`charly.yml` that pulls main's shared candy layers via `@github` refs — no
namespace import (`import: []`); the distro/builder/init build vocabulary is
embedded in the `charly` binary (`charly/charly.yml`). Ubuntu is deb-family:
`distro.ubuntu` is `inherits: debian`.

Canonical files:

- `charly.yml` — the root manifest: the `discover:` tree, the inline
  `check-ubuntu-debootstrap-vm` bed, and the embedded `skill:` entities
  (`ubuntu`, `ubuntu-builder`, `ubuntu-coder`, `ubuntu-debootstrap`,
  `ubuntu-debootstrap-builder`).
- `box/<name>/charly.yml` — one manifest per image / builder / VM box.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `README.md` — user overview only; never agent guidance.

## Load these skills first (R0)

- `/charly-distros:ubuntu` — the Ubuntu 24.04 base image (adopt-mode uid-1000
  `ubuntu`).
- `/charly-distros:ubuntu-builder` — the multi-stage builder image.
- `/charly-distros:ubuntu-debootstrap`,
  `/charly-distros:ubuntu-debootstrap-builder` — the bootstrap path.
- `/charly-coder:ubuntu-coder` — the kitchen-sink dev image.
- `/charly-vm:ubuntu-debootstrap-vm` — the bootstrap VM + its check bed.
- `/charly-image:image` + `/charly-image:layer` — composition and candy
  authoring (`charly.yml` schema, `plan:` step verbs, service declarations).
- `/charly-check:check` — the disposable check beds and `plan:` authoring.

## Build / validate / test

- The merge gate is the **org-wide** `charly/pr-validator` (required check
  `validate / validate`, defined in `opencharly/.github`); this repo has **no
  per-repo candy gate** and ships only `.github/workflows/tag-on-merge.yml`.
- The functional evidence is the disposable `check-ubuntu-debootstrap-vm` bed
  and the `plan:` `check:` steps on every box. A docs-only change runs no runtime
  bed — the documentation-only change class runs the non-runtime standards only.

## Modify this repo

- Edit the box manifest under `box/<name>/charly.yml` and any embedded `skill:`
  entity together — the skill is the projected usage source, so a change not
  mirrored in the skill leaves the corpus stale.
- This repo carries no candies of its own; a new layer belongs in its own
  `layer-*` repo and is referenced here by a pinned `@github` ref.
- Preserve the adopt-mode `ubuntu:ubuntu` identity: `${USER}`/`${HOME}` differ
  from the other deb-based boxes (`ubuntu-coder` → `ubuntu:/home/ubuntu`;
  `debian-coder` → `user:/home/user`).
- New behaviour claims belong in a `plan:` as an observable `check:` step, and
  in the owning skill.

## Landing

- PR-only. Every change lands through a pull request; the org-required
  `charly/pr-validator` validates the diff and body and arms native auto-merge
  on PASS. Direct pushes to `main` are blocked.
- History lives in `CHANGELOG/` (written by `tag-on-merge` at merge time); the
  PR body IS the changelog.
- The authoritative rulebook is the umbrella `AGENTS.md` in
  `opencharly/opencharly` and `charly/AGENTS.md` in the charly repo. Do not
  restate its rules here.
