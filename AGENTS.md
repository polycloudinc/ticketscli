# Agent Skills

When making changes to agent skills, edit the files under `.apm/skills/` (the source directory). The `.agents/skills/` directory is synchronized from `.apm/` by the APM command and should not be edited directly.

When renaming a skill, update its `.apm/skills/<name>/` directory and frontmatter `name`, then run `apm install` and compare the new `.agents/skills/<name>/SKILL.md` with its source. APM may retain the former generated skill path and lockfile entries from a legacy deployment; inspect `.agents/skills/` and `apm.lock.yaml` after installing instead of assuming the old path was removed. Use APM-supported cleanup for stale deployments; do not edit `.agents/` directly.

Whenever functional changes are made to this system, update the project documentation (currently `Tickets System.md`).
