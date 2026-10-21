# AGENTS.md — distro-ubuntu

The **Ubuntu image family** — charly's `box/ubuntu`. A self-contained
`charly.yml` that pulls main's shared candy layers via `@github` refs — no
namespace import (`import: []`); the distro/builder/init build vocabulary is
embedded in the `charly` binary (`charly/charly.yml`). Ubuntu is deb-family:
`distro.ubuntu` is `inherits: debian`.

Canonical files:

- `charly.yml` — the root manifest: the `discover:` tree, the inline
  `check-ubuntu-debootstrap-vm` bed, and ONE `skill:` entity
  (`githubrunner-ubuntu`, owned by the `github-runner-ubuntu` candy that is the
  `githubrunner-ubuntu` VM's extracted payload) as **routing metadata only**.
- `candy/ubuntu-skills/charly.yml` — the `ubuntu-skills` bundle candy PLUS the
  five `skill:` entities whose only other owner was an image (`ubuntu`,
  `ubuntu-builder`, `ubuntu-coder`, `ubuntu-debootstrap`,
  `ubuntu-debootstrap-builder`), each with `owner: ubuntu-skills`. A skill's
  `owner:` must be a CANDY: an image is a `candy:` node carrying
  `base:`/`from:`, so it has no source directory, its skill's prose can never be
  read and the node never reaches the `ai.opencharly.skill` label
  (opencharly/sdk#434). The candy is composed into every image that carries one
  of those skills.
- `.agents/skills/<name>/SKILL.md` — the six skill BODIES, one directory per
  entity's `name:`, at THIS REPO'S ROOT — never in a candy directory. The root
  is the directory a harness rooted here discovers natively and the base the
  marketplace corpus reads, so the corpus and the `ai.opencharly.skill` label
  name the same file (`deploykit.candyRepoRoot`, opencharly/sdk#445). Five of the
  bodies belong to `ubuntu-skills`, one to `github-runner-ubuntu`. The files are
  the source of record for the prose; five of the six entities carry
  `triggers:`, and `ubuntu-debootstrap-builder` does not.
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

- Edit the box manifest under `box/<name>/charly.yml`, the skill's routing node
  in its OWNING candy's `charly.yml`, and the skill's body at the repo root
  (`.agents/skills/<name>/`) together — the body is the projected usage source,
  so a change not mirrored in it leaves the corpus stale.
- This repo carries two candies of its own: `github-runner-ubuntu` (the CI-runner
  recipe) and `ubuntu-skills` (the skill-prose bundle that exists because a
  `skill:` owner must be a candy, opencharly/sdk#434). Any other new layer
  belongs in its own `layer-*` repo and is referenced here by a pinned `@github`
  ref.
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
