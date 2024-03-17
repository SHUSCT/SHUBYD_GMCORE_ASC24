# Branch Naming Convention

In order to facilitate clear communication and organization within the team, we adhere to the following branch naming conventions:

## Types of Branches

- **Feature Branches**: Branches created for new features or enhancements.
- **Bugfix Branches**: Branches for fixing bugs.
- **Docmentation Branches**: Improve project documentation.

## Naming Scheme

### General Format

`<type>/<short-description>-<issue-number>`

### Types

- For a **feature**: `feature/<feature-name>-<issue-number>`
- For a **bugfix**: `bugfix/<issue-or-bug-number>-<issue-number>`
- For a **documentation**: `doc/<documenation-name>-<issue-number>`

### Description

- Use dashes to separate words.
- The `<feature-name>` or `<short-description>` should be concise and descriptive.
- For bugfix and hotfix branches, use the issue or bug tracker number if applicable.
- `<issue-number>` is the issue number from the issue tracker.

## Examples

- Feature Branch: `feature/omp-#123`
- Bugfix Branch: `bugfix/fix-login-error-#114514`
- Documentation Branch: `doc/Env-Setup-Guide-#810`

## Notes

- Avoid using generic names like `tmp` for branches. Always use meaningful names that reflect the purpose of the branch.
- Delete the branch from the remote repository after it has been merged and is no longer needed.
- Keep the branch up-to-date with the base branch (use `git merge main` on your branch) to minimize merge conflicts.

By following these guidelines, we aim to maintain a clean, organized, and efficient workflow.
