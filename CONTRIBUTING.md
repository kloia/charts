# Versioning

SemVer is used for versioning.

Each chart under `charts/` are versioned separately using
[release-please,](https://github.com/googleapis/release-please)
and it's complementary GitHub Action.

Versioning is automated, with the exceptions of setting up versioning for
new charts and bumping a chart to `1.0.0`.

# Authoring/Modifying Charts

## Creating a new chart

1. Fork this repository or create a new branch
2. Run `helm create <chart-name>` under `charts/`
3. Setup versioning
   - Recommended first time version numbers are `0.1.0` and `1.0.0`
   - Set the initial version in `charts/<chart-name>/Chart.yaml`
   - Set the release-please configuration in `release-please-config.json`
     under the packages field as
     ```json5
     {
       "packages": {
         "charts/<chart-name>": {
           "release-type": "helm",
           "changelog-path": "CHANGELOG.md",
           // Set this to true if the initial version is less than 1.0.0 (e.g. 0.1.5).
           // When the chart is ready for it's 1.0.0 release, set it back to false.
           "bump-minor-pre-major": false,
           "extra-label": "charts/<chart-name>",
           "release-label": "charts/<chart-name>"
         }
       }
     }
     ```
4. Setup automatic PR labeling
   - Create the following entry in `.github/configs/labeler.yaml`
     ```yaml
     charts/<chart-name>:
     - charts/<chart-name>/**
     ```
5. Implement the chart's functionality
6. Open a pull request against `main`, with the PR title matching
   the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) spec.

   e.g.: `feat(<chart-name>): create <chart-name>`
7. **And the most important part**:

   When merging the pull request, add `Release-As: <initial-version>` at the top of squash merge
   description, so it ends up in the commit message body on `main`

## Importing an external chart

1. Fork this repository or create a new branch
2. Copy your chart under `charts/`, make sure the name matches the convention of `lower-case-with-dashes`
3. Setup versioning
   - Get the current version from `charts/<chart-name>/Chart.yaml`
   - Set the release-please configuration in `release-please-config.json`
     under the packages field as
     ```json5
     {
       "packages": {
         "charts/<chart-name>": {
           "release-type": "helm",
           "changelog-path": "CHANGELOG.md",
           // Set this to true if the initial version is less than 1.0.0 (e.g. 0.1.5).
           // When the chart is ready for it's 1.0.0 release, set it back to false.
           "bump-minor-pre-major": false,
           "extra-label": "charts/<chart-name>",
           "release-label": "charts/<chart-name>"
         }
       }
     }
     ```
4. Setup automatic PR labeling
   - Create the following entry in `.github/configs/labeler.yaml`
     ```yaml
     charts/<chart-name>:
     - charts/<chart-name>/**
     ```
5. Open a pull request against `main`, with the PR title matching
   the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) spec.

   e.g.: `feat(<chart-name>): import <chart-name>`
6. **And the most important part**:

   When merging the pull request, add `Release-As: <current-version>` at the top of squash merge
   description, so it ends up in the commit message body on `main`

## Modifying an existing chart

If it's an already existing chart under this repo and it's versioning has been already setup,
don't touch the version values.

1. Fork this repository or create a new branch
2. Add your changes
3. Open a pull request against `main`, with the PR title matching
   the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) spec.

   e.g.: `feat(<chart-name>): add new value`

   e.g.: `fix(<chart-name>): incorrect value usage`
 
## Reviewing Pull Requests

**IMPORTANT: If the PR is for a new or imported chart, make sure to add 
`Release-As: <current-version>` at the top of squash merge
description, so it ends up in the commit message body on `main`.**

This is how release-please picks up initial releases. If this gets skipped,
release-please will want to create an unnecessary version bump.

This automated versioning encourages requires a linear git history, 
so only "squash and merge" is allowed on the repo.

Because all commits under the pr are squashed, contributors don't have to use conventional commits
within the scope of pull requests, just the pull request title having a valid conventional commit message
is enough.

# Releasing Charts

As pull requests are merged to `main`, release-please will open and maintain a PR with the pattern
of `chore(main): release <chart-name> <version>`.

This pull request will track all further changes in main, and determine the correct next version based
on the commit messages.

Merging this pull request back to `main` will trigger a workflow of:
1. Updating CHANGELOG.md for the chart
2. Creating a GitHub Release and Git Tag
3. Packaging the Helm Chart
4. Uploading the package to GitHub Release as an asset
5. Indexing the package to `helm-repo/main` branch's `index.yaml`,
   with the package url pointing to the GitHub Release download link.

## Releasing the 1.0.0 version for a 0.x.x chart

Release Please prevents breaking changes of a `0.x.x` chart from bumping to a `1.0.0`
with the option `"bump-minor-pre-major": true`.

If you want to create a `1.0.0` release for such charts, simply remove the
option `"bump-minor-pre-major": true` (or set it to false) for the chart from `release-please-config.json`
and make a breaking change. The Release Please's PR will update itself to bump to `1.0.0`.

# Extras

## Workflows

`.github/workflows/release-please.yaml` defines the entire lifecycle of a chart and handles:
1. change tracking
2. versioning
3. changelog creation
4. releasing
5. packaging
6. indexing

`.github/workflows/labeler.yaml` and `.github/config/labeler.yaml` automatically labels PRs depending on the
files touched.

## Why not just use chart-releaser?

Helm's chart-releaser doesn't do versioning by itself, it handles the part of creating the GitHub release,
packaging, indexing, putting the index on the `helm-repo/main` GitHub Pages branch.

You need to maintain versions manually, bumping values by hand in pull requests.

Unfortunately release-please's and chart-releaser's GitHub Actions both insist on creating a tag,
which makes them conflict with each others change tracking mechanisms.

It was just easier to implement chart-releaser's functionality in the workflow for our use-case.
