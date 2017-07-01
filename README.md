# Git Cop

[![Gem Version](https://badge.fury.io/rb/git-cop.svg)](http://badge.fury.io/rb/git-cop)
[![Code Climate GPA](https://codeclimate.com/github/bkuhlmann/git-cop.svg)](https://codeclimate.com/github/bkuhlmann/git-cop)
[![Code Climate Coverage](https://codeclimate.com/github/bkuhlmann/git-cop/coverage.svg)](https://codeclimate.com/github/bkuhlmann/git-cop)
[![Gemnasium Status](https://gemnasium.com/bkuhlmann/git-cop.svg)](https://gemnasium.com/bkuhlmann/git-cop)
[![Circle CI Status](https://circleci.com/gh/bkuhlmann/git-cop.svg?style=svg)](https://circleci.com/gh/bkuhlmann/git-cop)
[![Patreon](https://img.shields.io/badge/patreon-donate-brightgreen.svg)](https://www.patreon.com/bkuhlmann)

Enforces Git rebase workflow with consistent Git commits for a clean and easy to read/debug project
history.

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Features](#features)
  - [Requirements](#requirements)
  - [Setup](#setup)
    - [Install](#install)
    - [Configuration](#configuration)
    - [Rake](#rake)
  - [Usage](#usage)
    - [Command Line Interface (CLI)](#command-line-interface-cli)
    - [Continuous Integration (CI)](#continuous-integration-ci)
  - [Cops](#cops)
    - [Commit Author Email](#commit-author-email)
    - [Commit Author Name Capitalization](#commit-author-name-capitalization)
    - [Commit Author Name Parts](#commit-author-name-parts)
    - [Commit Body Bullet](#commit-body-bullet)
    - [Commit Body Leading Space](#commit-body-leading-space)
    - [Commit Body Line Length](#commit-body-line-length)
    - [Commit Body Phrase](#commit-body-phrase)
    - [Commit Subject Length](#commit-subject-length)
    - [Commit Subject Prefix](#commit-subject-prefix)
    - [Commit Subject Suffix](#commit-subject-suffix)
  - [Style Guide](#style-guide)
    - [General](#general)
    - [Commits](#commits)
    - [Branches](#branches)
    - [Tags](#tags)
    - [Rebases](#rebases)
    - [Pull Requests](#pull-requests)
  - [Tests](#tests)
  - [Versioning](#versioning)
  - [Code of Conduct](#code-of-conduct)
  - [Contributions](#contributions)
  - [License](#license)
  - [History](#history)
  - [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Features

- Enforces a [Git Rebase Workflow](http://www.bitsnbites.eu/a-tidy-linear-git-history).
- Enforces a clean and consistent Git commit history.
- Provides a suite of cops which can be enabled/disabled or customized for your preference.

## Requirements

0. [Ruby 2.4.1](https://www.ruby-lang.org)

## Setup

### Install

For a secure install, type the following (recommended):

    gem cert --add <(curl --location --silent https://www.alchemists.io/gem-public.pem)
    gem install git-cop --trust-policy MediumSecurity

NOTE: A HighSecurity trust policy would be best but MediumSecurity enables signed gem verification
while allowing the installation of unsigned dependencies since they are beyond the scope of this
gem.

For an insecure install, type the following (not recommended):

    gem install git-cop

### Configuration

This gem can be configured via a global configuration:

    ~/.config/git-cop/configuration.yml

It can also be configured via [XDG environment variables](https://github.com/bkuhlmann/runcom#xdg)
as provided by the [Runcom](https://github.com/bkuhlmann/runcom) gem.

The default configuration is as follows:

    :commit_author_email:
      :enabled: true
    :commit_author_name_capitalization:
      :enabled: true
    :commit_author_name_parts:
      :enabled: true
      :minimum: 2
    :commit_body_bullet:
      :enabled: true
      :blacklist:
        - "*"
        - "•"
    :commit_body_leading_space:
      :enabled: true
    :commit_body_line_length:
      :enabled: true
      :length: 72
    :commit_body_phrase:
      :enabled: true
      :blacklist:
        - obviously
        - basically
        - simply
        - of course
        - just
        - everyone knows
        - however
        - easy
    :commit_body_present:
      :enabled: false
    :commit_subject_length:
      :enabled: true
      :length: 72
    :commit_subject_prefix:
      :enabled: true
      :whitelist:
        - Fixed
        - Added
        - Updated
        - Removed
        - Refactored
    :commit_subject_suffix:
      :enabled: true
      :whitelist:
        - "."

Feel free to take this default configuration, modify, and save as your own custom
`configuration.yml`.

### Rake

This gem provides optional Rake tasks. They can be added to your project by adding the following
requirement to the top of your `Rakefile`:

    require "git/cop/rake/setup"

Now, when running `bundle exec rake -T`, you'll see `git_cop` included in the list.

If you need a concrete example, check out the [Rakefile](Rakefile) of this project for details.

## Usage

### Command Line Interface (CLI)

From the command line, type: `git-cop --help`

    git-cop -c, [--config]        # Manage gem configuration.
    git-cop -h, [--help=COMMAND]  # Show this message or get help for a command.
    git-cop -p, [--police]        # Police current branch for issues.
    git-cop -v, [--version]       # Show gem version.

To check if your Git commit history is clean, run: `git-cop --police`. It will exit with a
failure if at least one issue is detected (handy for CI builds).

This gem does not check commits on `master`. This is intentional as you would generally not want to
rewrite or fix commits on `master`. This gem is best used on feature branches as it automatically
detects all commits made since `master` on the feature branch and will raise errors if any of the
feature branch commits do not conform to the style guide.

Here is an example workflow, using the gem defaults where errors would be raised:

    cd example
    git checkout -b test
    printf "%s\n" "Test content." > test.txt
    git add --all .
    git commit --message "This is a bogus commit message that is also terribly long and will word wrap"
    git-cop --police

    # Output:
    Running Git Cop...

    d0f9bf40a09d10618bcf8a38a5ddd3bcf12fd550 (Brooke Kuhlmann, 3 seconds ago): This is a bogus commit message that is also terribly long and will word wrap
      Commit Subject Length: Invalid length. Use 72 characters or less.
      Commit Subject Prefix: Invalid prefix. Use: "Fixed", "Added", "Updated", "Removed", "Refactored".
      Commit Subject Suffix: Invalid suffix. Use: ".".

    3 issues detected.

With this output, you can see the number of issues detected. Each issue shows the commit, cop name,
and the error with help text.

### Continuous Integration (CI)

This gem automatically detects when it is running on a CI build server via the `CI=true` environment
variable. Most CI build servers respect and enable this variable. If your CI server doesn't, you'll
want to make sure you have `CI=true` set in your environment.

Calculation of commits is done by reviewing all commits made on the current feature branch since
branching from `master`. Some CI servers don't respect this and blow away any branch information,
most notibly, Travis CI. For that reason, Travis CI is not supported or recommended as they use
`git clone --depth=<number>` cloning which can't be customized and destroys any knowledge of
`master` and feature branch information.

Build servers like [Circle CI](https://circleci.com) are recommended. The builds for this gem are
done via Circle CI as well.

## Cops

The following details the various cops provided by this gem to ensure a high standard of commits for
your project.

### Commit Author Email

| Enabled | Defaults |
|---------|----------|
| true    | none     |

Ensures author email address exists. Git requires an author email when you use it for the first time
too. This takes it a step further to ensure the email address loosely resembles an email address.

    # Disallowed
    mudder_man

    # Allowed
    jayne@serenity.com

### Commit Author Name Capitalization

| Enabled | Defaults |
|---------|----------|
| true    | none     |

Ensures auther name is properly capitalized. Example:

    # Disallowed
    jayne cobb
    dr. simon tam

    # Allowed
    Jayne Cobb
    Dr. Simon Tam

### Commit Author Name Parts

| Enabled |  Defaults  |
|---------|------------|
| true    | minimum: 2 |

Ensures author name consists of, at least, a first and last name. Example:

    # Disallowed
    Kaylee

    # Allowed
    Kaywinnet Lee Frye

### Commit Body Bullet

| Enabled |        Defaults       |
|---------|-----------------------|
| true    | blacklist: ["*", "•"] |

Ensures commit message bodies use a standard Markdown syntax for bullet points. Markdown supports
the following syntax for bullets:

    *
    -

It's best to use `-` for bullet point syntax as `*` are easier to read when used for *emphasis*.
This makes parsing the Markdown syntax easier when reviewing a Git commit as the syntax used for
bullet points and *emphasis* are now, distinctly, unique.

### Commit Body Leading Space

| Enabled | Defaults |
|---------|----------|
| true    | none     |

Ensures there is a leading space between the commit subject and body. Generally, this isn't an issue
but sometimes the Git CLI can be misued or a misconfigured Git editor will smash the subject line
and start of the body as one run-on paragraph. Example:

    # Disallowed

    Curabitur eleifend wisi iaculis ipsum.
    Pellentque morbi-trist sentus et netus et malesuada fames ac turpis egestas. Vestibulum tortor
    quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu_libero sit amet quam
    egestas semper. Aenean ultricies mi vitae est. Mauris placerat's eleifend leo. Quisque et sapien
    ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, orn si amt wit.

    # Allowed

    Curabitur eleifend wisi iaculis ipsum.

    Pellentque morbi-trist sentus et netus et malesuada fames ac turpis egestas. Vestibulum tortor
    quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu_libero sit amet quam
    egestas semper. Aenean ultricies mi vitae est. Mauris placerat's eleifend leo. Quisque et sapien
    ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, orn si amt wit.

### Commit Body Line Length

| Enabled |  Defaults  |
|---------|------------|
| true    | length: 72 |

Ensures each line of the commit body is no longer than 72 characters in length for consistent
readabilty and word-wrap prevention on smaller screen sizes. For further details, read Tim Pope's
original [article](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) on the
subject.

### Commit Body Phrase

| Enabled |                       Defaults                       |
|---------|------------------------------------------------------|
| true    | blacklist: (see configuration list, mentioned above) |

Ensures non-descriptive words/phrases are avoided in order to keep commit message bodies informative
and specific. The blacklist is case insensitive. Detection of blacklisted words/phrases is case
insensitve as well. Example:

    # Disallowed

    Obviously, the existing implementation was too simple for my tastes. Of course, this couldn't be
    allowed. Everyone knows the correct way to implement this code is to do just what I've added in
    this commit. Easy!

    # Allowed

    Necessary to fix due to a bug detected in production. The included implentation fixes the bug
    and provides the missing spec to ensure this doesn't happen again.

### Commit Body Present

| Enabled |  Defaults  |
|---------|------------|
| false   | none       |

Checks that there is always a commit body. A commit with only empty characters (whitespace, carriage returns, etc.) is also considered to be empty.

### Commit Subject Length

| Enabled |  Defaults  |
|---------|------------|
| true    | length: 72 |

Ensures the commit subject length is no more than 72 characters in length. This default is more
lenient than Tim Pope's
[50/72 rule](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) as it gives one
the ability to formulate a more descriptive subject line without being too wordy or suffer being
word wrapped.

### Commit Subject Prefix

| Enabled |        Defaults        |
|---------|------------------------|
| true    | whitelist: (see below) |

Ensures the commit subject uses consistent prefixes that help explain *what* is being commited. The
whitelist *is* case sensitive. The default whitelist consists of the following prefixes:

- *Fixed* - Existing code that has been fixed.
- *Removed* - Code that was once added and is now removed.
- *Added* - New code that is an enhancement, feature, etc.
- *Updated* - Existing code that has been modified.
- *Refactored* - Existing code that has been cleaned up and does not change functionality.

In practice, using a prefix other than what has been detailed above to explain *what* is being
committed is never needed. This whitelist is not only short and easy to remember but also has the
added benefit of categorizing the commits for building release notes, change logs, etc. This becomes
handy when coupled with another tool, [Milestoner](https://github.com/bkuhlmann/milestoner), for
producing consistent project milestones and Git tag histories.

### Commit Subject Suffix

| Enabled |     Defaults     |
|---------|------------------|
| true    | whitelist: ["."] |

Ensures commit subjects are suffixed consistently. The whitelist *is* case sensitive and only allows
for periods (`.`) to ensure each commit is sentance-like when generating release notes, Git tags,
change logs, etc. This is handy when coupled with a tool, like
[Milestoner](https://github.com/bkuhlmann/milestoner), which automate project milestone releases.

## Style Guide

In addition to what is described above and automated for you, the following style guide is also
worth considering:

### General

- Use a [Git rebase workflow](http://www.bitsnbites.eu/a-tidy-linear-git-history) instead of a Git
  merge workflow.
- Use `git commit --fixup` when fixing a previous commit, addressing pull request feedback, etc.,
  and don't need to modifiy the original commit message.
- Use `git commit --squash` when fixing a previous commit, addressing pull request feedback, etc.,
  and want to combine the original commit message with the squash commit message into a single
  message.
- Use `git rebase --interactive` when cleaning up commit history, order, messages, etc. Should be
  done prior to submitting a pull request or when pull request feedback has been addressed and you
  are ready to merge to `master`.
- Use `git push --force-with-lease` instead of `git push --force` when pushing changes after an
  interactive rebasing session.
- Avoid checking in development-specific configuration files (add to `.gitignore` instead).
- Avoid checking in sensitive information (i.e. security keys, passphrases, etc).
- Avoid "WIP" (a.k.a. "Work in Progress") commits and/or pull requests. Be confident with your code
  and collegues' time. Use branches, stashes, etc. instead -- share a link to a diff if you have
  questions/concerns during development.

### Commits

- Use small, atomic commits:
  - Easier to review and provide feedback.
  - Easier to review implementation and corresponding tests.
  - Easier to document with detailed subject messages (especially when grouped together in a pull
    request).
  - Easier to reword, edit, squash, fix, or drop when interactively rebasing.
  - Easier to merge together versus tearing apart a larger commit into smaller commits.
- Use commits in a logical order:
  - Each commit should tell a story and be a logical building block to the next commit.
  - Each commit, when reviewed in order, should be able to explain *how* the feature or bug fix was
    completed and implemented properly.
- Use a commit subject that explains *what* is being commited.
- Use a commit message body that explains *why* the commit is necessary. Additional considerations:
  - If the commit has a dependency to the previous commit or is a precursor to the commit that will
    follow, make sure to explain that.
  - Include links to dependent projects, stories, etc. if available.

### Branches

- Use feature branches for new work.
- Maintain branches by rebasing upon `master` on a regular basis.

### Tags

- Use tags to denote milestones/releases:
  - Makes it easier to record milestones and capture associated release notes.
  - Makes it easier to compare differences between versions.
  - Provides a starting point for debugging production issues (if any).

### Rebases

- Avoid rebasing a shared branch. If you must do this, clear communcation should be used to warn
  those ahead of time, ensure that all of their work is checked in, and that their local branch is
  deleted first.

### Pull Requests

- Avoid authoring and reviewing your own pull request.
- Keep pull requests short and easy to review:
  - Provide a high level overview that answers *why* the pull request is necessary.
  - Provide a link to the story/task that prompted the pull request.
  - Provide screenshots/screencasts if possible.
  - Ensure all commits within the pull request are related to the purpose of the pull request.
- Review and merge pull requests quickly:
  - Maintain a consistent pace -- Review morning, noon, and night.
  - Try not to let them linger more than a day.
- Use emojis to help identify the types of comments added during the review process:
  - Generally, an emoji should prefix all feedback. Format: `<emoji> <feedback>`.
  - :tea: - Signifies you are reviewing the pull request. This is *non-blocking* and is meant to be
    informational. Useful when reading over a pull request with a large number of commits, reviewing
    complex code, requires additional testing by the reviewer, etc.
  - :information_source: - Signifies informational feedback that is *non-blocking*. Can also be used
    to let one know you are done reviewing but haven't approved yet (due to feedback that needs
    addressing), rebasing a pull request and then merging, waiting for a blocking pull request to be
    resolved, status updates to the pull request, etc.
  - :art: - Signifies an issue with code style and/or code quality. This can be *blocking* or *non-
    blocking* feedback but is feedback generally related to the style/quality of the code,
    implementation details, and/or alternate solutions worth considering.
  - :bulb: - Indicates a helpful tip or trick for improving the code. This can be *blocking* or
    *non-blocking* feedback and is left up to the author to decide (generally, it is a good idea to
    address and resolve the feedback).
  - :star: - Signifies code that is liked, favorited, remarkable, etc. This feedback is *non-
    blocking* and is always meant as positive/uplifting.
  - :white_check_mark: - Signifies approval of a pull request. The author can merge to `master` and
    delete the feature branch at this point.
- If the pull request discussion gets noisy, stop typing and switch to face-to-face chat.
- If during a code review, additional features are discovered, create stories for them and then
  return to reviewing the pull request.
- The author, not the reviewer, should merge the feature branch upon approval.
- Ensure the following criteria is met before merging your feature branch to master:
  - Ensure all `fixup!` and `squash!` commits are interactively rebased and merged.
  - Ensure your feature branch is rebased upon `master`.
  - Ensure all tests and code quality checks are passing.
  - Ensure the feature branch is deleted after being successfully merged.

## Tests

To test, run:

    bundle exec rake

## Versioning

Read [Semantic Versioning](http://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

## Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

## Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

Copyright (c) 2017 [Alchemists](https://www.alchemists.io).
Read [LICENSE](LICENSE.md) for details.

## History

Read [CHANGES](CHANGES.md) for details.
Built with [Gemsmith](https://github.com/bkuhlmann/gemsmith).

## Credits

Developed by [Brooke Kuhlmann](https://www.alchemists.io) at
[Alchemists](https://www.alchemists.io).
