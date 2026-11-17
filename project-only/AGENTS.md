# WAMR Project Rules

These rules apply to the WAMR repository only. They add to the global baseline.

## Main Worktree
- `<main worktree>` is the first entry of `git worktree list`. Get its path with:
  `git worktree list --porcelain | sed -n '1s/^worktree //p'`
- Do not assume the current directory is the main worktree. Resolve the path first.

## Plan Before Code Changes
- Before changing any code, write a plan document.
- Save it to `<main worktree>/.docs/<yyyy-mm-dd>-<topic>.md`, even when working in another worktree.
- Create `.docs/` if it does not exist.
- The plan states the goal, the files to change, the approach, and how to verify.

## Devcontainer
- Run every daily development operation inside the devcontainer, through the devcontainer CLI: building, testing, `git commit`, debugging (gdb, etc.).
- Command form: `devcontainer exec --workspace-folder=<main worktree> -- <command>`.
- Use the devcontainer of the main worktree by default. Use another worktree's devcontainer only when the user says so.
- Before a task, check the container with `devcontainer exec --workspace-folder=<main worktree> -- echo "test"`. If the check fails, run `devcontainer up --workspace-folder=<main worktree>` once and check again. If it still fails, STOP and report.
- Never fall back to the host.
- Project skills follow this section. When a skill's devcontainer command uses `<repo root>` as the workspace folder, read it as `<main worktree>`, unless the user says otherwise.

## Commit Messages
- State what the problem is, or what the benefit is.
- Do not describe how the change is implemented. The diff shows that.
- Do not write verification results (tests passed, build succeeded, etc.).
- Do not repeat the reproduction steps. Link the issue instead if one exists.
