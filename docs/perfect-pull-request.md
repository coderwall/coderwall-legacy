<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. The Perfect Pull Request</a>
<ul>
<li><a href="#sec-1-1">1.1. Topic branches</a></li>
<li><a href="#sec-1-2">1.2. Test coverage</a>
<ul>
<li><a href="#sec-1-2-1">1.2.1. Existing specs as example</a></li>
</ul>
</li>
<li><a href="#sec-1-3">1.3. Good pull-request titles</a></li>
<li><a href="#sec-1-4">1.4. Integrating with bounties on Assembly using WIP numbers</a></li>
<li><a href="#sec-1-5">1.5. Good descriptions</a></li>
<li><a href="#sec-1-6">1.6. Squashing branch commit history</a></li>
<li><a href="#sec-1-7">1.7. Updating your Pull Request after changes are made</a></li>
<li><a href="#sec-1-8">1.8. Simple vs Complex</a></li>
<li><a href="#sec-1-9">1.9. When your Pull Request contains unwanted commits</a></li>
</ul>
</li>
</ul>
</div>
</div>

# The Perfect Pull Request<a id="sec-1" name="sec-1"></a>

When contributing to Coderwall, you'll want to submit code
for review and integration.  To do this you'll need to use
Github's Pull Request system.

Once submitted, Coderwall developers will be able to inspect
your changes and discuss with you any changes necessary to
include the code into Coderwall.

To save yourself and everyone else a lot of time, and to
make the contribution process as smooth as possible, we ask
you to follow these guidelines.

## Topic branches<a id="sec-1-1" name="sec-1-1"></a>

First off, your code will need to be in a new branch, we
call these **topic branches**.

To create a local branch, we give it a descriptive name and
append the bounty number we're working on.  Use the command
below to create a branch called **my-branch-name-123**

```
git checkout -b my-branch-name-123
```

## Test coverage<a id="sec-1-2" name="sec-1-2"></a>

To make integration easy, code you want to submit, should
always be written with test coverage.

Test driven development can be helpful to make sure you
achieve this. For more on test first development read the
work by @scottwambler <http://agiledata.org/essays/tdd.html>.

Of course, you don't have to write your code test first, you
could always write your tests after writing your code, or
use a combination approach, it's entirely up to you.

Either way, you're going to need tests to show that your
code is working as expected, and ease it into the
integration process. (It will protect the codebase from many
breakages in the future too.)

### Existing specs as example<a id="sec-1-2-1" name="sec-1-2-1"></a>

Look inside the `spec` folder to see the current test
coverage, you will need to add your specs to this suite.
The existing specs in the project will serve as good
examples.

## Good pull-request titles<a id="sec-1-3" name="sec-1-3"></a>

Naming things is more an art than a science. As a rule, keep
it short, keep it descriptive, keep it simple.

The name you give to your pull request is important, and
needs to communicate with a wide audience of developers.

## Integrating with bounties on Assembly using WIP numbers<a id="sec-1-4" name="sec-1-4"></a>

Always append the bounty number to the end of the pull
request name, use the format **#123** (if you were working on
bounty 123)

## Good descriptions<a id="sec-1-5" name="sec-1-5"></a>

Descriptions are also quite difficult to get right. As with
the pull request name, keep it short and sweet.

-   Important details should be written out as bullet points
-   like this very important pair of points

## Squashing branch commit history<a id="sec-1-6" name="sec-1-6"></a>

Many bounties you work on will be expected as a single
commit, or in some cases a few very specific commits.

Often though, in the course of your work, you'll make
commits for small pieces of work, maybe you just finished
wiring a test, committed, wrote passing code, committed
again.  Just as easily, you could commit before leaving your
workstation, or going home, or leaving for work, or any
number of interruptions during a coding session.

You should clean up your local branch history so that it is
a single commit, or in a few cases, a couple of commits that
clearly contain specific parts of the solution in your topic
branch.  Generally, just squashing to a single commit is
preferable.

**Rebase to clean your commit history**

We can use rebase to squash our commits together, follow the
steps to take below.

Note, it will be easier to do this if your editor of choice
is configured for use with git, see [associating text editors with git](https://help.github.com/articles/associating-text-editors-with-git)

1.  begin a git rebase on the branch commit history.  **git
    rebase -i HEAD~n** where **n** is the number of commits back
    you need to squash.  For example, let's say you have 6 commits in
    your branch, do `git rebase -i HEAD~6`

2.  The editor configured for use with git will appear,
    listing the commits selected, and the word **pick** on the
    left of each commit.  The commit at the top will be the
    oldest, running down to the latest.  Check that the
    commits shown are the ones you want to squash.  If not,
    quit now and start again, changing `HEAD~n` to the correct pointer.

3.  Leave the **pick** on the first row alone.

4.  Change the subsequent rows to replace **pick** with **s** (or **squash**.)

5.  Change nothing else,  save / close the editor (or
    document or buffer.)

6.  The editor should now open showing all the commit
    messages combined. Re-organise / clean the notes into a
    single, clean commit message. The heading line should
    include the match the pull request name with the bounty
    number.

7.  Save the new commit message, check it looks ok in the **git log**

8.  If you're squashing after initiating the pull request, you will
    need to `git push --force` when pushing the commit back to github.

## Updating your Pull Request after changes are made<a id="sec-1-7" name="sec-1-7"></a>

You can make changes after your pull request is submitted,
effectively it is still private branch. If it's necessary to
add new code, to add a new test, or fix something.

Add all the changes interactively using `git add -p` and
then `git commit --amend` to patch the previous commit with
your amend.

Please note, you can also add your changes as new commits,
and then squash them before pushing the changes up to github

When you push your amended (or newly squashed) commits, you
must use the `--force` switch. ie. `git push --force`

## Simple vs Complex<a id="sec-1-8" name="sec-1-8"></a>

If the piece of work you are submitting is complex, and
touches many parts of the system, you should separate the
work into a set of commits, instead of a single one.

If you are unsure about the level of complexity in your
work, check other pull-request which have been accepted, how
does your stack up?

If you still can't decide, squash your commits into a group
of logical sections of work, ensure that any dependencies
are met within each group, and that they build / pass their tests.

You can check this before squashing, by running the test
suite on the last commit in a set.  Never send a broken
commit in your pull requests.

## When your Pull Request contains unwanted commits<a id="sec-1-9" name="sec-1-9"></a>

If your pull-request has commits that are unwanted, you can
either squash them out, or simply start a new branch, and
use cherry pick to construct a new version of the branch,
omitting the bad commit.  Note that rebase squash will
usually take care of this situation.

Git cherry pick, is fairly simple to use.  View the git log
of your current branch, make a note of the commit SHA1s you
want to keep.

Next, create a new local branch, and cherry pick each
commit into the new branch.

e.g.  if we noted that commits, `823a69b`, `a98e12c` and `a9171ad` are
good, and the rest are trash, we'd do.

```
git checkout -b new-branch-for-bounty-123
# We're now in the new branch...

for sha in 823a69b a98e12c a9171ad; do
    git cherry-pick $sha
done
```

We will need to open a new pull request for this branch. as
mentioned above, an extra commit to tidy up followed by rebase 
pick/squash may be able to take care of this within the existing
branch. The only time you'd really want to do a cherry pick, is 
when it's simpler to do so.

If you have any questions about our pull request process,
please contact the coderwall team.  One of us will be happy
to help.

## Fix those errors

Found a factual mistake in this document? Let me know and I’ll correct it.
