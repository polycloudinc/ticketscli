---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK046
aliases:
- TIK046
name: Switch From Mikefarah Yq To Python Yq
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank:
ticket_created: '2026-06-18T15:10:05Z'
ticket_updated: '2026-06-20T06:07:52Z'
ticket_completed: '2026-06-20T06:07:47Z'
---
# Introduction

Replace all uses of mikefarah/yq with a Python helper script bundled alongside tickets.sh in the npm package. kislyuk/yq is not a suitable replacement because it is a thin `jq` wrapper with no front-matter support. Instead, a custom Python script (`yz.py`) using PyYAML will handle all YAML operations — both front matter extraction/mutation in Markdown files and plain YAML read/write for settings.yaml and statistics.yaml. This keeps dependencies minimal (python3 + pyyaml) and avoids requiring any system-level yq or jq binary.

# Requirements

- A `yz.py` Python helper script must be created in the npm package directory (alongside `tickets.sh`, `Ticket.md`) and added to the `"files"` array in `package.json`
- `yz.py` must support subcommands for all current yq operations: front matter extract, front matter update/mutate, front matter key listing, front matter field deletion, plain YAML read, plain YAML write, and plain YAML append-to-sequence
- `tickets.sh` must pre-check dependencies (python3, pyyaml) early and emit clear error messages with install instructions when they are missing
- `tickets.sh` must NOT attempt to install dependencies (not its responsibility)
- All 36 existing `yq eval` calls in `tickets.sh` must be replaced with `python3 "$script_dir/yz.py"` invocations
- `yz.py` must be invoked relative to `$script_dir` (the location of tickets.sh within the npm package), so it works correctly when tickets.sh is run via `npx @aleisium/tickets`
- Both copies of `tickets.sh` (root `tickets.sh` and `als-tickets-cli/als-tickets-cli-main/tickets.sh`) must remain in sync
- `.devcontainer/Dockerfile` must install python3 + pyyaml instead of downloading mikefarah/yq
- `Tickets System.md` documentation must be updated to reflect the new dependency requirements
- `tickets validate` must require python3 + pyyaml (replace the current mikefarah yq version check)
- No jq, kislyuk/yq, or any system-level yq binary is required

# Technical Solution

## `yz.py` design

The helper script lives at `als-tickets-cli/als-tickets-cli-main/yz.py` and exposes these subcommands:

```
yz.py extract <file.md> <yaml_path> [default]
    Reads a front matter value; returns default (or empty) if missing.
    Replaces: yq eval --front-matter extract '.field // ""' file.md

yz.py update <file.md> <yaml_path> <value>
    Sets a front matter field in-place. Writes first then renames atomically.
    Replaces: yq eval -i --front-matter process '.field = val' file.md

yz.py set-env <file.md> <yaml_path> <env_var>
    Sets a front matter field from an environment variable value.
    Replaces: TS="$ts" yq eval -i --front-matter process '.field = env(TS)' file.md

yz.py delete <file.md> <yaml_path>
    Removes a front matter field in-place.
    Replaces: yq eval -i --front-matter process 'del(.field)' file.md

yz.py keys <file.md>
    Lists top-level front matter keys (one per line).
    Replaces: yq eval --front-matter extract 'keys | .[]' file.md

yz.py read <file.yaml> <yaml_path> [default]
    Reads a value from a plain YAML file.
    Replaces: yq eval '.field // "default"' file.yaml

yz.py write <file.yaml> <yaml_path> <value>
    Writes a value into a plain YAML file in-place.
    Replaces: yq eval -i '.field = val' file.yaml

yz.py append <file.yaml> <yaml_path> <json_object>
    Appends a JSON object to a YAML sequence in-place.
    Replaces: yq eval -i ".seq += [{...}]" file.yaml
```

Implementation uses Python stdlib for file I/O / atomic writes and PyYAML (`import yaml`) for YAML parsing/serialization. Front matter is handled by splitting on `---` delimiters and parsing the middle section as YAML. Plain YAML files use `yaml.safe_load` / `yaml.dump`.

## Dependency check (in tickets.sh)

A check function runs before any subcommand logic that requires YAML operations:

```bash
check_dependencies() {
  if ! command -v python3 &>/dev/null; then
    echo "Error: python3 is required. Install it with your system package manager." >&2
    exit 1
  fi
  if ! python3 -c "import yaml" &>/dev/null; then
    echo "Error: PyYAML is required. Install it with: pip install pyyaml" >&2
    exit 1
  fi
  if [[ ! -f "$script_dir/yz.py" ]]; then
    echo "Error: yz.py not found alongside tickets.sh ($script_dir/yz.py)" >&2
    exit 1
  fi
}
```

## Call site mapping

| Current yq call | Replacement |
|---|---|
| `yq eval --front-matter extract '.ticket_status // ""' file.md` | `python3 "$script_dir/yz.py" extract file.md .ticket_status` |
| `yq eval -i --front-matter process '.ticket_rank = null' file.md` | `python3 "$script_dir/yz.py" update file.md .ticket_rank null` |
| `TS="$ts" yq eval -i --front-matter process '.ticket_updated = env(TS)' file.md` | `TS="$ts" python3 "$script_dir/yz.py" set-env file.md .ticket_updated TS` |
| `yq eval -i --front-matter process 'del(.ticket_completed)' file.md` | `python3 "$script_dir/yz.py" delete file.md .ticket_completed` |
| `yq eval --front-matter extract 'keys \| .[]' file.md` | `python3 "$script_dir/yz.py" keys file.md` |
| `yq eval '.code_prefix // "TIK"' settings.yaml` | `python3 "$script_dir/yz.py" read settings.yaml .code_prefix TIK` |
| `yq eval -i ".statistics += [{...}]" stats.yaml` | `python3 "$script_dir/yz.py" append stats.yaml .statistics '{...}'` |

## Script directory resolution

`tickets.sh` already resolves `script_dir` via:
```bash
script_dir=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
```
Since `npx @aleisium/tickets` resolves through the npm bin symlink chain, `$0` will be the real path inside the npm package, and `$script_dir/yz.py` will resolve correctly whether run via `./tickets.sh`, `bash tickets.sh`, or `npx @aleisium/tickets`.

# Execution Plan

1. Create `yz.py` in `als-tickets-cli/als-tickets-cli-main/yz.py` with all subcommands
2. Add `yz.py` to the `"files"` array in `als-tickets-cli/als-tickets-cli-main/package.json`
3. Update `tickets.sh` dependency check: replace the mikefarah yq version check with `check_dependencies()` verifying python3 + pyyaml
4. Port front-matter extract calls: `yq eval --front-matter extract` → `python3 "$script_dir/yz.py" extract`
5. Port front-matter process calls: `yq eval -i --front-matter process` → `python3 "$script_dir/yz.py" update` / `delete` / `set-env`
6. Port front-matter key listing: `yq eval --front-matter extract 'keys | .[]'` → `python3 "$script_dir/yz.py" keys`
7. Port plain YAML read calls: `yq eval '.field'` → `python3 "$script_dir/yz.py" read`
8. Port plain YAML write/append calls: `yq eval -i` → `python3 "$script_dir/yz.py" write` / `append`
9. Update `.devcontainer/Dockerfile` to install python3 + pyyaml instead of downloading mikefarah/yq
10. Update `Tickets System.md` documentation to reflect new dependencies
11. Sync changes to both copies of `tickets.sh`
12. Test all subcommands: list, validate, create, transition, rank, statistics