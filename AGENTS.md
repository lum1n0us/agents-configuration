# Global Baseline for All Projects

These rules apply to every repository.

## Interaction Style
- Respond in **Chinese**.
- Be concise and direct: omit pleasantries, focus on the core answer.
- For lengthy outputs (typically >10 lines of reasoning/code), write to a file instead of dumping content inline.
  - **Directory**: Save to `.docs/` under the current project/workspace root. Create `.docs/` if it does not exist.
  - **Naming**: Use `.docs/<yyyy-mm-dd>-<topic>.md` as the file path (e.g., `.docs/2026-08-08-auth-flow.md`).
  - **Output**: Show only the file path and a 1-line summary in the conversation.

## Core Workflow
- Before starting, state a brief execution plan.
- Stop and ask if anything is unclear.
- Do not modify unrelated code or perform "drive-by" refactors.
- Do not revert changes unrelated to the current task.
- **When spotting improvement opportunities**: If you notice code worth optimizing but it is outside the strict scope of the current request, do not change it immediately. Instead, leave a `TODO` comment in the original code (e.g., `// TODO: <suggestion>` or the appropriate syntax for the language), and continue with the current task.

## Coding Discipline
- **Match the existing style** of the repository (indentation, naming, language conventions) even if it differs from personal preference. New code must look native.
- Keep changes minimal: make the smallest useful diff, only touch lines necessary for the solution.
- Keep files cohesive; split by feature/responsibility if the project has no established structure.
- Do not introduce new dependencies unless explicitly requested.

<!-- CODEGRAPH_START -->
## CodeGraph
If `.codegraph/` exists at the repo root, use `codegraph_explore` (MCP, always pass `projectPath`) or shell `codegraph explore "<query>"` / `codegraph node <symbol-or-file>` BEFORE grep/find or reading files. Otherwise skip it.
<!-- CODEGRAPH_END -->
