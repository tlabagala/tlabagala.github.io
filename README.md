# Analytics portfolio

A Quarto website showcasing data analytics and research projects in R, Python,
and SQL. Live at <https://tlabagala.github.io>. Each page is a written narrative
that links out to its full code repo.

For build and maintenance conventions, see `CLAUDE.md`.

## Quickstart

Live-reloading local preview. Edits to `.qmd` and `.scss` files refresh in the
browser as you save:

```bash
quarto preview
```

Render the whole site into `_site/` once, without a server:

```bash
quarto render
```

Neither command publishes anything. Both are local only. See the next section.

## Publishing to GitHub Pages

`quarto preview` runs a server on your own machine that nobody else can reach.
The public site changes only when you push to `main`.

### How the pipeline works

1. You push to `main`.
2. The `Publish site` workflow (`.github/workflows/publish.yml`) starts.
3. It installs Quarto, renders the site, and pushes the result to the
   `gh-pages` branch.
4. GitHub Pages serves `gh-pages` at <https://tlabagala.github.io>.

You never edit `gh-pages` by hand, and you never run `quarto publish` locally.
The runner installs Quarto only, with no R and no packages, which is why the
freeze cache below matters.

### The everyday loop

Edit and preview as much as you like without committing. When you want the
change to go live:

```bash
quarto render
```

```bash
git add -A
```

```bash
git commit -m "Describe what changed"
```

```bash
git push origin main
```

The Action takes about 30 seconds, then Pages needs a minute or two to
propagate. A hard refresh clears a stale cached copy.

`git add -A` is the safe habit because it sweeps up `_freeze/` alongside the
`.qmd` that produced it. See the freeze rule at the bottom.

### Checking a deploy

Watch the run that is in flight:

```bash
gh run watch --exit-status
```

List recent runs and their status:

```bash
gh run list --workflow "Publish site" --limit 5
```

Read the logs of the most recent failure:

```bash
gh run view --log-failed
```

The same information is on the Actions tab of the repo.

### When the deploy does not show up

- **Action failed.** Check `gh run list`. A failure means `gh-pages` was never
  updated, so the old site stays up.
- **Action passed but the page looks old.** Pages caches hard. Hard refresh, or
  open the URL in a private window.
- **`gh-pages` does not exist.** The publish action pushes into that branch but
  will not create it from nothing. It exists in this repo already; if it is ever
  deleted, recreate an empty one and re-run the workflow.
- **Numbers on a page are stale.** That is the freeze cache, not the deploy. See
  the bottom section.

## Customising the look

Almost all visual choices live in one file, `styles.scss`. It has two parts, and
putting a rule in the wrong one is the most common mistake:

- `/*-- scss:defaults --*/` sets Bootstrap variables. These must be defined
  before Bootstrap loads, so this is where fonts, brand colours, and anything
  starting with `$` belongs.
- `/*-- scss:rules --*/` holds ordinary CSS that layers on top afterwards.

The site builds on the `cosmo` Bootstrap theme, set in `_quarto.yml`. Anything
you do not override comes from there.

### Colour

The current palette is deliberately restrained: a warm off-white page, near
black text, and one blue accent.

| Variable | Current | Role |
| --- | --- | --- |
| `$body-bg` | `#fdfdfc` | page background, warm rather than pure white |
| `$body-color` | `#24211f` | body text |
| `$link-color` | `#185fa5` | links and the blockquote rule |
| `$link-hover-color` | `#0c447c` | link hover |

Setting `$primary` in `scss:defaults` is the highest-leverage single change,
because Bootstrap derives buttons, badges, focus rings, and active states from
it:

```scss
$primary: #185fa5;
```

Greys are currently hardcoded in `scss:rules` in several places (`#5f5e5a` for
muted text, `#e6e4dd` and `#d3d1c7` for borders). If you start changing them,
lift them into named variables in `scss:defaults` first and reference the
variable everywhere, so a future change is one edit rather than six.

Whatever you pick, keep body text near a 4.5:1 contrast ratio against the
background. Coloured text on a tinted background is where portfolio sites
usually fail accessibility.

### Fonts

Two families, Inter and JetBrains Mono, are declared in `scss:defaults` and
loaded from Google Fonts via the `include-in-header` block in `_quarto.yml`. Both places have to agree: if you
add a family to the SCSS without adding it to the font URL, it silently falls
back.

```scss
$font-family-sans-serif: "Inter", system-ui, -apple-system, sans-serif;
$headings-font-family:   "Inter", system-ui, -apple-system, sans-serif;
$font-family-monospace:  "JetBrains Mono", ui-monospace, monospace;
```

Two things worth knowing about fallback lists. A generic family such as `serif`
or `sans-serif` always resolves, so anything listed after it is dead. And the
fallbacks should match the character of the first font, or a failed load flips
the page to a different style of typeface entirely.

`$headings-font-weight` controls heading weight. With a single typeface across
headings and body, weight and size are what create hierarchy.

### Layout and reading measure

The width of the prose column is set by the grid in `_quarto.yml`, not in
`styles.scss`:

```yaml
grid:
  body-width: 900px
  margin-width: 220px
```

Keep it there. Capping `main.content` in `styles.scss` instead squeezes Quarto's
whole layout grid, so `.column-page` figures end up narrower than the text they
are meant to break out past. That is why `styles.scss` sets
`main.content { max-width: none; }`.

To let one figure break out past that column, wrap it in a fenced div in the
`.qmd`:

```markdown
::: {.column-page}
![Caption stating the finding](../assets/figures/name.png)
:::
```

### Project summary box

Each project page opens with a `.project-summary` fenced div: four one-line
bullets (Problem, Approach, Result, Skills) for a reader who stops there. Its
styling is the `.project-summary` block in `scss:rules`, and the template has a
skeleton to copy.

### Link previews and favicon

`open-graph` and `twitter-card` in `_quarto.yml` give each page a preview card
when its link is shared on LinkedIn or Slack. A project page uses its own
`image:`, and every other page falls back to the headshot. The browser-tab icon
is `assets/favicon.png`.

### Listing cards and title blocks

The landing page grid is generated from each project's YAML header, so you never
edit `index.qmd` to add a card. The card styling is `.quarto-grid-item` in
`scss:rules`: border colour, corner radius, and the hover transition.

The uppercase category pills are `.quarto-category` and `.listing-category`.
Colouring these by tool is an easy way to add colour that carries meaning
instead of decoration.

For a coloured banner behind page titles, set this in `index.qmd` or a project
header:

```yaml
title-block-banner: "#185fa5"
title-block-banner-color: white
```

### Figures

R figures are themed separately, in `theme/theme_portfolio.R`, because ggplot2
knows nothing about your CSS. The accent colour is defined there a second time:

```r
portfolio_accent <- "#185fa5"
portfolio_grey   <- "grey75"
```

If you change the site accent in `styles.scss`, change it here too or your
charts will drift out of step with the page. This duplication is the easiest
thing in the project to forget.

The house style is one accent colour against grey: colour the series that
matters, leave everything else neutral.

### Seeing your changes

Run `quarto preview` and save. SCSS recompiles and the browser refreshes on its
own, so there is no need to re-render manually while you are iterating. Nothing
you see there is public until you push.

## Adding a project

1. Copy `projects/_template.qmd` to `projects/<slug>.qmd`.
2. Fill the YAML header (title, description, date, categories, image).
3. Write the body in the fixed section order the template lays out.
4. `quarto render projects/<slug>.qmd` so `_freeze/` updates.
5. Commit the `.qmd`, any figures, and `_freeze/`. Push.

The landing-page grid updates itself. You do not edit `index.qmd`.

## Structure

```
_quarto.yml              site config, navbar, fonts, theme
styles.scss              theme (fonts, colours, layout)
index.qmd                landing page (auto listing)
about.qmd                background and links
theme/theme_portfolio.R  shared ggplot theme
projects/                one .qmd per project
assets/figures/          exported figures
_freeze/                 cached output - committed
```

## The one rule that matters

`_freeze/` is committed on purpose. It caches executed output so CI needs only
Quarto, not R or Python.

Each cache entry is keyed by a hash of the page source. Change a `.qmd` that
contains code chunks and the hash no longer matches, so Quarto decides the page
needs re-executing. That is fine locally, where R is installed. On the runner
there is no R, so the build fails.

The practical consequence: when you commit a `.qmd` with code chunks, the
updated `_freeze/` has to be in the same commit. Render first, then
`git add -A`.

The reverse case is quieter and worse. If the underlying data changed but the
source did not, the hash still matches, Quarto skips execution, and the site
ships stale numbers without complaint. Force a refresh:

```bash
quarto render projects/<slug>.qmd --no-cache
```

Pages with no code chunks, such as `about.qmd`, have no cache entry and none of
this applies to them.
