# box/ubuntu — signpost (not the rule-set)

This submodule is the **Ubuntu** base image family: a self-contained `charly.yml`
that pulls main's shared candy layers via `@github` refs — no namespace import
(`import: []`); the distro/builder/init build vocabulary is embedded in the `charly`
binary (`charly/charly.yml`).

**Load these skills FIRST (R0):**

- `/charly-distros:ubuntu` — the Ubuntu base image (adopt-mode uid-1000 `ubuntu`).
- `/charly-distros:ubuntu-builder` — the builder image.
- `/charly-distros:ubuntu-debootstrap`, `/charly-distros:ubuntu-debootstrap-builder` —
  the bootstrap path.
- `/charly-coder:ubuntu-coder` — the dev image; `/charly-vm:ubuntu` — the bootstrap VM.

**Authoritative rules live in the `opencharly` superproject's root `CLAUDE.md`**
(R0–R10, hard-cutover, AI attribution, git-workflow). This file only signposts
and restates no rule. The multi-agent workflow is in `/charly-internals:agents`.
History lives in this repo's `CHANGELOG/` (one file per month).
