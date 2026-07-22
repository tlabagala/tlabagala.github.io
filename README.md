# Analytics portfolio

A Quarto website showcasing data analytics and research projects in R, Python,
and SQL. Deployed to GitHub Pages. Each page is a written narrative that links
to its full code repo.

For the detailed build and maintenance conventions, see `CLAUDE.md`.

## Quickstart

```bash
# preview locally with live reload
quarto preview

# render the whole site into _site/
quarto render
```

The site publishes automatically on push to `main` via GitHub Actions.

## First-time deploy setup

1. Push to `main`. The Action renders and pushes to the `gh-pages` branch.
2. In the repo: Settings > Pages > set the source to the `gh-pages` branch.
3. The site goes live at your Pages URL in a few minutes.

## Adding a project

1. Copy `projects/_template.qmd` to `projects/<slug>.qmd`.
2. Fill the YAML header (title, description, date, categories, image).
3. Write the body in the fixed section order the template lays out.
4. `quarto render projects/<slug>.qmd` so `_freeze/` updates.
5. Commit the `.qmd`, any figures, and `_freeze/`. Push.

The landing-page grid updates itself - you do not edit `index.qmd`.

## Structure

```
_quarto.yml              site config
styles.scss              theme (fonts, colours, layout)
index.qmd                landing page (auto listing)
about.qmd                background + CV
theme/theme_portfolio.R  shared ggplot theme
projects/                one .qmd per project
assets/figures/          exported figures
_freeze/                 cached output - committed
```

## The one rule that matters

`_freeze/` is committed on purpose. It caches executed output so CI needs only
Quarto, not R or Python. A page re-runs only when its `.qmd` source changes - if
you refresh data but not the source, force it with
`quarto render <page> --no-cache`.
