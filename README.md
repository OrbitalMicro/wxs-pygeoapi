# wxs-pygeoapi workspace

This workspace combines:

- `pygeoapi/`: a Git submodule checkout used as the application source
- `wxs/`: local project-specific config and extensions layered on top of `pygeoapi`
- `.devcontainer/`: the development container used to run the stack locally

## Clone the workspace

Clone with submodules from the start using SSH:

```bash
git clone --recurse-submodules git@github.com:OrbitalMicro/wxs-pygeoapi.git
cd wxs-pygeoapi
```

If you already cloned without submodules, initialize them now:

```bash
git submodule update --init --recursive
```

This step matters because the devcontainer builds from `pygeoapi/`. If the submodule is missing, the container build will fail.

## Daily submodule management

To make sure the submodule checkout matches the commit recorded by the workspace repo:

```bash
git submodule update --init --recursive
```

To inspect the current submodule state:

```bash
git submodule status
```

Expected remotes inside `pygeoapi/` for contribution workflow:

- `origin`: `git@github.com:OrbitalMicro/pygeoapi.git`
- `upstream`: `git@github.com:geopython/pygeoapi.git`

To update the `pygeoapi` submodule itself and then record the new submodule commit in this workspace repo:

```bash
./sync-upstream.sh
git add pygeoapi
git commit -m "Update pygeoapi submodule"
```

What `./sync-upstream.sh` does:

- verifies the `pygeoapi` checkout and required remotes
- stashes local changes in the submodule if needed
- checks out `master`
- fetches `origin` and `upstream`
- rebases on `origin/master`
- merges `upstream/master`
- restores any stashed submodule changes

If you only want the submodule to move to the exact commit already recorded by the workspace repo, use `git submodule update --init --recursive` instead of the sync script.

## Run the devcontainer

Prerequisites:

- Docker or Docker Desktop
- VS Code
- The Dev Containers extension

From VS Code:

1. Open the workspace root.
2. Run `Dev Containers: Reopen in Container`.
3. Wait for the `pygeoapi` and `postgres` services to start.

The container configuration lives in `.devcontainer/` and uses Docker Compose.

Current behavior:

- builds the app container from `pygeoapi/Dockerfile`
- mounts the workspace into `/workspaces/wxs-pygeoapi`
- mounts `wxs/pygeoapi/config.yml` as `/pygeoapi/local.config.yml`
- mounts `wxs/pygeoapi/extensions` into the container
- starts PostgreSQL automatically
- exposes the app on `http://localhost:5000`

## Useful commands

Refresh submodules after pulling workspace changes:

```bash
git pull --rebase
git submodule update --init --recursive
```

Preview the submodule sync steps without changing anything:

```bash
./sync-upstream.sh --dry-run
```
