## Contributing

First off, thank you for considering contributing to I_HATE_LIVE_FORENSIC. Our aim to make I_HATE_LIVE_FORENSIC look the same with windows calculator(standard)

### Where do I go from here?

If you've noticed a bug or have a feature request, [make one][new issue]! It's
generally best if you get confirmation of your bug or approval for your feature
request this way before starting to code.

If you have a general question about I_HATE_LIVE_FORENSIC, you can post it on [Stack
Overflow], the issue tracker is only for bugs, design and feature requests. (eg. exception handling or change button color)

### Fork & create a branch

If this is something you think you can fix, then [fork I_HATE_LIVE_FORENSIC] and create
a branch with a descriptive name.

A good branch name would be (where issue #10 is the ticket you're working on):

```sh
git checkout -b 010-add-calculator-function
```

### Get the test suite running

you can check this content on README.md
https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/blob/main/README.md

### Implement your fix or feature

At this point, you're ready to make your changes! Feel free to ask for help;
everyone is a beginner at first :smile_cat:

### View your changes in this repository with (browser or command)

gui_calculaotr is meant to be used by humans, not cucumbers. So make sure to take
a look at your changes in a browser or you can track it with command prompt


### Make a Pull Request

At this point, you should switch back to your master branch and make sure it's
up to date with Active Admin's master branch:

```sh
git remote add upstream git@https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC
git checkout master
git pull upstream master
```

Then update your feature branch from your local copy of master, and push it!

```sh
git checkout 001-add-WINDOWS_LIVE_FORENSIC-function
git rebase master
git push --set-upstream origin 001-add-WINDOWS_LIVE_FORENSIC-function
```

Finally, go to GitHub and [make a Pull Request][] :D

Github Actions will run our test suite against all supported Rails versions. We
care about quality, so your PR won't be merged until all tests pass. It's
unlikely, but it's possible that your changes pass tests in one Rails version
but fail in another. In that case, you'll have to setup your development
environment (as explained in step 3) to use the problematic Rails version, and
investigate what's going on!

### Keeping your Pull Request updated

If a maintainer asks you to "rebase" your PR, they're saying that a lot of code
has changed, and that you need to update your branch so it's easier to merge.

To learn more about rebasing in Git, there are a lot of [good][git rebasing]
[resources][interactive rebase] but here's the suggested workflow:

```sh
git checkout 001-add-WINDOWS_LIVE_FORENSIC-function
git pull --rebase upstream master
git push --force-with-lease 001-add-WINDOWS_LIVE_FORENSIC-function ```

### Merging a PR (maintainers only)

A PR can only be merged into master by a maintainer if:

* It is passing CI.
* It has been approved by at least two maintainers. If it was a maintainer who
  opened the PR, only one extra approval is needed.
* It has no requested changes.
* It is up to date with current master.

Any maintainer is allowed to merge a PR if all of these conditions are
met.

### Shipping a release (maintainers only)

Maintainers need to do the following to push out a release:

* Switch to the master branch and make sure it's up to date.
* Run one of `bin/rake release:prepare_{prerelease,prepatch,patch,preminor,minor,premajor,major}`, push the result and create a PR.
* Review and merge the PR. The generated changelog in the PR should include all user visible changes you intend to ship.
* Run `bin/rake release` from the target branch once the PR is merged.
