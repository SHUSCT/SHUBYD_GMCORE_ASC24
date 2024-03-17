# How to Contribute as a Collaborator

This documentation is about a version control strategy based on GitHub Flow.

## 1. Clone the Repository

```bash
git clone git@github.com:jamesnulliu/SHUBYD_GMCORE.git GMCORE

cd GMCORE

python ./pull_libs.py
python ./pull_data.py
```

## 2. Create/Switch to a Branch

On GitHub [branches page](https://github.com/jamesnulliu/SHUBYD_GMCORE/branches), **check if there has been an existing branch that is suitable for your contribution**. 

Let's suppose you want to add OpenMP support according to *issue 5* (We will talk about issues later). You should first check if there is a branch named `feature/omp-#5` on [branches page](https://github.com/jamesnulliu/SHUBYD_GMCORE/branches).

### 2.1. If There is a Suitable Branch

If there there has already been a branch called `feature/omp-#5` on GitHub, go to your local machine.

First list all local branches and check if there is a local branch called `feature/omp-#5`:

```bash
git branch
```

If there is a local branch called `feature/omp-#5`, then switch to it directly, and go to [3. Make Your Contirbution](#3-make-your-contribution) for next step:

```
git switch feature/omp-#5
```

If there isn't a local branch called `feature/omp-#5`, you should first fetch the new changes from remote repository, and then switch to the branch `feature/omp-#5`:

```
# Fetch the new changes from remote repository.
git fetch

# Create a local branch "feature/omp-#5", track the remote, and switch to that branch. 
# Note: Leave "origin/" unchanged.
git switch -c feature/omp-#5 --track origin/feature/omp-#5

# Pull the new changes from remote repository.
git pull --no-rebase
```

💡**Note**: 
- `origin` is a name that stores the URL of the remote repository.
- `git pull` only pulls the changes to the branch you are currently on. So switch to the branch before pulling.
- `--no-rebase` forces to merge the incoming and current changes.

Now, you can go to [3. Make Your Contirbution](#3-make-your-contribution) for next step.

### 2.2. If There is No Suitable Branch

If there is no suitable branch for your contribution, you have to create an issue on [issues page](https://github.com/jamesnulliu/SHUBYD_GMCORE/issues) to explain:

1. What you find in the source code that makes you decide to commit a change?
2. Where is the source code? Which line is the problem on?
3. What are you going to do?
4. Which collaborators do you want to help you? (Mention them by "@" their GitHub username)

Check [Appendix: Examples for Creating Issues](#examples-for-creating-issues) for more details.

After the issue about "Adding OpenMP Support" is created, you should **remember the issue number**. Suppose the issue number is `5`.

Then you can create a new branch from `main` following the [Branch Naming Convention](./Branch_Naming_Convention.md):

```
# Make sure you are on branch "main".
git switch main 

# Pull the new changes from remote repository.
git pull --no-rebase

# Create a new local branch from "main" called "feature/omp-#5".
git switch -c feature/omp-#5

# Push the local branch to remote repo, namely to create a new remote branch on GitHub. 
# Note: Don't forget the parameter "-u"!
git push -u origin feature/omp-#5:feature/omp-#5
```

After creating, pushing and pulling, go back to the [branches page](https://github.com/jamesnulliu/PrettyLazy0/branches), you will see a new branch called `feature/omp-#5`.

Now go to the issue you created, add a comment to mention that you have created a branch for it.

💡**Note**: 
- The branch name must be consistent with the issue number. In this case, the issue number is `5`, so the branch name is `feature/omp-#5`.
- After creating a branch, go to the issue you created and mention that you have created a branch for it.

## 3. Make Your Contribution

Now you can make your contribution to the project. You can add, modify, or delete files as needed. Once you've made your changes, you should commit them to your local branch and push to remote.

```
git checkout feature/omp-#5

# Add all changes to the staging area.
git add .

# Commit the changes with a descriptive message.
git commit  # or: git commit -m "<message>"

# In case someone just pushed some changes to "feature/omp-#5", pull from remote before your push.
git pull --no-rebase

# Push the changes to remote repo
git push origin feature/omp-#5
```

💡**Note**: 
- All changes should be done on branch `feature/omp-#5`. Do not make any changes to branch `main` directly.
- If Git warns you conflicts after `pull`, resolve the conflicts accroding to [Appendix: Resolve the Conflicts on Local Machine](#resolve-the-conflicts-on-local-machine). 

  After the conflicts are resolved, commit the changes and push to remote repository.

  ```
  # Remember to commit changes after resolving conflicts.
  git push origin feature/omp-#5
  ```

## 4. Test Your Branch on HPC

After pushing changes to branch `feature/omp-#5` on remote repository, you should test your branch on our HPC before merging your changes to a base branch.

First list all local branches on HPC and check if there is a local branch called `feature/omp-#5`:

```
git branch
```

If there is a local branch called `feature/omp-#5`, then switch to it directly, and start testing:

```
git switch feature/omp-#5
```

If there isn't a local branch called `feature/omp-#5`, you should first fetch the new changes from remote repository, and then switch to the branch `feature/omp-#5`:

```
# Fetch the new changes from remote repository.
git fetch

# Create a local branch "feature/omp-#5", track the remote, and switch to that branch. 
# Note: Leave "origin/" unchanged.
git switch -c feature/omp-#5 --track origin/feature/omp-#5

# Pull the new changes from remote repository.
git pull --no-rebase
```


## 4. Create a Pull Request

After testing your changes on branch `feature/omp-#5` on HPC, if you believe your changes are positive (i.e., no bugs, no performance degradation, etc.), you should create a **Pull Request (PR)** from `feature/omp-#5` to `main` on GitHub.

Please check [Appendix: Create a Pull Request to Merge Changes from `B` to `A`](#create-a-pull-request-to-merge-changes-from-b-to-a) for details.

💡**Note**: 
- A PR from `feature/omp-#5` to `main` indicates that you want to **merges the changes from `feature/omp-#5` to `main`**.
- Make sure that your code is well-tested and ready to be merged before creating a PR.

---

# Appendix

## Examples for Creating Issues

### Example 1: New Feature

I found that in file "src/dynamics/gmcore_mod.F90", line 535-541, there is a loop that can be parallelized with OpenMP. I want to add OpenMP support.

So I go to [issues page](https://github.com/jamesnulliu/SHUBYD_GMCORE/issues) and click `New issue` on the top-right corner.

In the title, I write: "Add OpenMP support for dynamics/gmcore_mod.F90:535-541".

In the description, I write: "I found that in file "src/dynamics/gmcore_mod.F90", line 535-541, there is a loop that can be parallelized with OpenMP. I want to add OpenMP support. I need help from @jamesnulliu and @collaborator1."

After that, I click `Submit new issue` on the bottom-right corner.

### Example 2: Bug Fix

I found a bug in file "src/dynamics/gmcore_mod.F90", line 535-541. I want to fix it.

So I go to [issues page](https://github.com/jamesnulliu/SHUBYD_GMCORE/issues) and click `New issue` on the top-right corner.

In the title, I write: "Fix a bug in dynamics/gmcore_mod.F90:535-541".

In the description, I write: "I found a bug in file "src/dynamics/gmcore_mod.F90", line 535-541. I want to fix it. I need help from @jamesnulliu and @collaborator1."

After that, I click `Submit new issue` on the bottom-right corner.

## Resolve the Conflicts on Local Machine

**Note**: You can only resolve the confilcts on your local machine, not on GitHub.

If there are conflicts after `pull` or `merge`, you should resolve them manually. 

First find out which files have conflicts:

```
# Check the status of the repository.
git status
```

Then open the files with conflicts.

The conflicts are marked with `<<<<<<<`, `=======`, and `>>>>>>>`. You should remove these markers and decide which changes to keep.

After resolving the conflicts, you should commit the changes to the target branch.

```
git add .
git commit  # or: git commit -m "<message>"
```

💡**Note**: 
- Because the merging process changed local files, do not forget to commit the changes after resolving conflicts.


## Create a Pull Request to Merge Changes from `B` to `A`

Suppose you have commited some changes on branch `B` and pushed to remote repository. And you now want to **create a PR to merge changes from `B` to `A`**.

1. **Navigate to the Repository on GitHub**: Open your web browser and go to the [GitHub page](https://github.com/jamesnulliu/SHUBYD_GMCORE) for the repository you've been working on.

2. **Initiate the Pull Request**: Click on the `Pull requests` tab near the top of the repository's GitHub page. Then, click on the `New pull request` button.

3. **Choose the Base and Compare Branches**: 
    - For the **base branch**, select `A`. This is the branch you want your changes to be pulled into.
    - For the **compare branch**, select your `B`. This is the branch that contains the changes you want to merge.

4. **Review Your Changes**: Review the changes to ensure everything is correct and as intended.

5. **Create the Pull Request**: 
    - Click on the `Create pull request` button. 
    - Provide a title and a detailed description for your PR. **Description is mandatory.**
    - Click on `Create pull request` again to submit your PR.
    
    If GitHub warns you there are conflicts and auto-merging is failed, refer to [Appendix: When Conflicts Happen during PR](#when-conflicts-happen-during-pr) for solution.


6. **Respond to Feedback**: Once your PR is submitted, other team members can review your changes, leave comments, and request additional modifications if necessary. Be prepared to respond to feedback and make further commits to your feature branch if required.

7. **Final Merge**: After your PR has been reviewed and approved by the necessary members of your team, someone with merge permissions will merge your changes into branch `A`. Once the merge is complete, your changes will be part of branch `A`, and your PR will be closed.


## When Conflicts Happen during PR

Suppose you are creating a PR from `B` to `A`.

If GitHub indicates there are conflicts between `B` and `A`,  your PR would not be merged automatically.

In this case, go back to your local machine and merge `A` to `B`:

```
git checkout A

# Pull new changes from remote repository.
# Since you haven't changed anything on branch "A", this action is safe.
git pull --no-rebase

# "B" is the branch where you have made changes.
git checkout B

# Originally, you want to create a PR on GitHub to merge the changes from "B" to "A";
# But since there are conflicts, you should first merge "A" to "B" on your local machine.
git merge A

# Becase there are conflicts betwwen new-coming "A" and "B", Git will warn you to resolve them.
```

Following this, Git will alert you there are conflicts during the merge process. Unlike GitHub, Git marks the conflicts in your local files on branch `B`. For steps on how to resolve these conflicts, refer to [Appendix: Resolve the Conflicts on Local Machine](#resolve-the-conflicts-on-local-machine).

After the conflicts are resolved, push `B` to remote repository:

```bash
# Remember to commit changes after resolving conflicts.
git push origin B
```

Go back to GitHub and navigate to the PR you created. 

You should be able to see that the conflicts have been resolved, and the merge conflict warning has disappeared. 


<!-- ##  Delete a Branch

If the branch `feature/omp-#5` is no longer needed, you can delete it:

```bash
# [Warning] Make sure this branch is no longer needed before deleting this branch
# Delete the branch "feature/omp-#5" locally
git branch -d feature/omp-#5
# Delete the branch "feature/omp-#5" on remote repo
git push origin --delete feature/omp-#5
``` -->