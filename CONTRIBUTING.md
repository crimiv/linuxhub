Contributing to Linux Hub
=========================

Guidelines
----------
- Create feature branches named `feat/<description>` or `fix/<description>`.
- Keep PRs small and focused. Describe the change and rationale.
- Ensure CI passes (luacheck and luac -p) before requesting review.
- Add tests or manual verification steps where applicable.

Code style
----------
- Follow Lua idioms used in the repo.
- Avoid changing unrelated files in a single commit.

Review process
--------------
- Open a PR against `main` and request reviewers.
- Address feedback with follow-up commits on the same branch.
- Squash/merge once approvals and CI pass.

Security & remote scripts
-------------------------
- Remote script loads are centralized in `shared/network.lua`. Validate remote URLs before adding them.
- Avoid adding untrusted remote sources without a clear justification.

Thank you for contributing!