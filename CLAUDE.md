# CLAUDE.md

Context and instructions for Claude Code working in this repository.

## What this is

A personal analytics portfolio: a Quarto website deployed to GitHub Pages. It
showcases data analytics and research projects built in R, Python, and SQL. Each
page is a written narrative that links out to a separate code repo. The pages
are NOT the code themselves - they are curated write-ups.

The repository already exists. Your job is to build the site from the scaffold
in this repo, keep it rendering, and add new project pages on request.

## Stack

- Quarto (static site generator)
- knitr engine for R pages, jupyter engine for Python pages
- SCSS theme on top of the `cosmo` Bootstrap theme
- ggplot2 for R figures, via a shared `theme_portfolio()`
- GitHub Actions -> GitHub Pages for deploy

## Commands

Run these from the repo root.

```bash
quarto preview          # live-reloading local preview while editing
quarto render           # render the whole site into _site/
quarto render projects/<file>.qmd            # render one page
quarto render projects/<file>.qmd --no-cache # force re-execution (see Freeze)
```

Do not run `quarto publish` locally. Publishing happens automatically on push to
`main` via `.github/workflows/publish.yml`.

## Repository layout

```
.
├── CLAUDE.md               # this file
├── README.md               # human-facing quickstart
├── _quarto.yml             # site config - navbar, theme, execute settings
├── styles.scss             # custom theme (fonts, colours, layout)
├── index.qmd               # landing page (auto-generated project listing)
├── about.qmd               # background + CV link
├── theme/
│   └── theme_portfolio.R   # shared ggplot theme + palette constants
├── projects/
│   ├── _metadata.yml       # settings applied to every project page
│   ├── _template.qmd       # copy-me skeleton (ignored by Quarto, leading _)
│   └── <slug>.qmd          # one page per project
├── assets/figures/         # PNGs exported from project repos
├── assets/favicon.png      # browser-tab icon
├── _freeze/                # cached executed output - COMMITTED, do not gitignore
└── .github/workflows/publish.yml
```

Files and folders whose names start with `_` are not rendered by Quarto, except
`_quarto.yml`, `_metadata.yml`, and `_freeze/` which are configuration/cache.
That is why `_template.qmd` never appears on the site.

## The freeze mechanism - the most important rule

`_quarto.yml` sets `execute: freeze: auto`. This means:

- Executed output for each page is cached in `_freeze/` and COMMITTED to git.
- On CI, Quarto reads the frozen output and skips execution. The runner installs
  only Quarto - no R, no Python, no packages. Builds are fast and rarely break.
- A page re-executes ONLY when its `.qmd` source changes. It does NOT re-execute
  when the underlying data or a package version changes.

Consequences for you:

- Always render pages locally (where R/Python and packages exist), then commit
  `_freeze/` along with the `.qmd`.
- NEVER add `_freeze/` to `.gitignore`.
- If a page's data changed but its source did not, force a refresh with
  `quarto render <page> --no-cache`, then commit the updated `_freeze/`.
- Do not expect the GitHub Action to execute code. If a page shows stale numbers
  on the live site, the fix is to re-render locally and push, not to change CI.

## Per-page engine rule

- A page with R chunks uses the knitr engine.
- A page with only Python chunks uses the jupyter engine.
- Keep one language per page. Do NOT mix R and Python in a single page - it
  requires reticulate under knitr and is fragile. If a project genuinely spans
  both languages, write one narrative page and link to both scripts.

## Figures

Two acceptable patterns for a page's figures:

1. Preferred: the project's own repo exports finished figures to PNG. Those PNGs
   are copied into `assets/figures/` and the page displays them with
   `![caption](../assets/figures/name.png)`. The page needs no packages and
   renders instantly.
2. Live: the page generates the figure in an R or Python chunk. Use this only
   for small, self-contained demos.

For any R figure, source the shared theme and apply it:

```r
source(here::here("theme/theme_portfolio.R"))
# ... build plot ...
p + theme_portfolio()
```

Use the accent-against-grey pattern: colour the one series that matters with
`portfolio_accent`, leave the rest `portfolio_grey`. This is what makes the
charts look designed rather than default.

## How to add a new project page

1. Copy `projects/_template.qmd` to `projects/<slug>.qmd`.
2. Fill the YAML header: `title`, `description`, `date`, `categories`, `image`.
   The `categories` become the filter pills and the per-card tool badges, so use
   real tool names (e.g. `[R, fixest, panel-econometrics]`).
3. Point `image:` at a thumbnail in `assets/figures/`.
4. Fill the summary box, then write the body in the fixed section order (see
   the template). Keep the body to roughly 600-900 words.
5. `quarto preview` to check it.
6. Render it so `_freeze/` updates: `quarto render projects/<slug>.qmd`.
7. Commit the `.qmd`, any new figures, AND `_freeze/`. Push to `main`.

Do NOT edit `index.qmd` to add the card - the listing regenerates the grid
automatically from the new page's YAML header.

## Conventions

- Prose uses hyphens, never em dashes.
- Titles and section headings in sentence case.
- Each project page opens with a `.project-summary` box (Problem, Approach,
  Result, Skills) and has a "What this means in practice" section linking the
  result to a decision.
- Each project page has an explicit "Assumptions and limitations" section near
  the end. This is a hard requirement, not optional - it is the main
  differentiator.
- Figure captions state the finding, not the chart type. "Cost per tonne
  diverged from budget from Q3, driven by rate not volume", not "Cost over time".
- Keep the body text column narrow (set by `grid` in `_quarto.yml`, not in
  `styles.scss`); let key figures break out wider using a `::: {.column-page}`
  fenced div.

## Employer-data caution

Some projects use the author's employer data (a meat company: freight cost and
budget variance work). Do NOT publish employer data or identifiable internal
detail. If asked to write up such a project, use synthetic or public data to
demonstrate the METHOD, and keep business context general. Flag this to the user
rather than deciding unilaterally.

## Build check before declaring done

After any change, run `quarto render` and confirm it completes without error and
that `_site/` is produced. If a render fails, read the error - it is almost
always a missing package for a live chunk or a bad path to a figure.
