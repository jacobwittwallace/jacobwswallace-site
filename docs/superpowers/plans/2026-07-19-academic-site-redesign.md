# Academic Site Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a polished Quarto academic website for Jacob Wallace, deployed to GitHub Pages at jacobwswallace.com, with interactive research visualizations, a rotating homepage hero, and auto-updating Substack integration.

**Architecture:** A Quarto static site. Content lives in `.qmd` markdown files. A shared SCSS theme codifies the "editorial-on-white, Yale-blue" visual system. Interactive charts are authored in R (plotly / ggplotly) from small curated CSVs of *published* estimates and *public* datasets only — no restricted data. Two small, unit-tested R modules carry the real logic: a deterministic **hero selector** (ISO-week → hero id) and a **Substack RSS ingester** (feeds → normalized posts data). GitHub Actions render the site with R and deploy to Pages; a daily schedule refreshes Substack posts first.

**Tech Stack:** Quarto, R 4.4 (ggplot2, plotly, xml2, dplyr, yaml, testthat), GitHub Actions, GitHub Pages.

**Spec:** `docs/superpowers/specs/2026-07-19-academic-site-redesign-design.md`

---

## Conventions used throughout this plan

- **Repo root:** `/Users/JWW48/Library/CloudStorage/Dropbox/repos/jacobwswallace-site` (already `git init`'d on branch `main`, contains README + the spec/plan docs).
- **Data files** (single sources of truth, read by multiple pages):
  - `data/publications.yml` — publication list.
  - `data/heroes.yml` — ordered list of hero ids in the rotation.
  - `data/substack_config.yml` — feed URLs + author name to filter SCALE.
  - `data/substack_posts.yml` — generated cache of normalized posts.
- **R modules** (pure logic, unit-tested with testthat): `R/heroes.R`, `R/substack.R`.
- **Tests:** `tests/testthat/` run via `Rscript -e 'testthat::test_dir("tests/testthat")'`.
- **Colors:** Yale Blue `#00356B`; accent clay `#b04a3f`; hairline `#ecebe7`; body ink `#3a4453`.
- Commit after every task. Never commit restricted data.

---

## Phase 0 — Prerequisites & project skeleton

### Task 0.1: Install the missing toolchain

**Files:** none (environment setup)

- [ ] **Step 1: Install Quarto and gh via Homebrew**

Run:
```bash
brew install --cask quarto
brew install gh
```

- [ ] **Step 2: Install the plotly R package (and yaml, used later)**

Run:
```bash
Rscript -e 'install.packages(c("plotly","yaml"), repos="https://cloud.r-project.org")'
```

- [ ] **Step 3: Verify everything is available**

Run:
```bash
quarto --version && gh --version | head -1 && \
Rscript -e 'stopifnot(all(sapply(c("ggplot2","plotly","xml2","dplyr","yaml","testthat","htmlwidgets"), requireNamespace, quietly=TRUE))); cat("R deps OK\n")'
```
Expected: a Quarto version (≥1.4), a `gh version ...` line, and `R deps OK`.

### Task 0.2: Create the project skeleton and .gitignore

**Files:**
- Create: `.gitignore`, `DESCRIPTION`, directory stubs

- [ ] **Step 1: Create directories**

Run:
```bash
cd /Users/JWW48/Library/CloudStorage/Dropbox/repos/jacobwswallace-site
mkdir -p R data heroes viz tests/testthat/fixtures assets/css assets/img .github/workflows
```

- [ ] **Step 2: Create `.gitignore`**

```gitignore
# Quarto
/.quarto/
/_site/
/_freeze/

# R
.Rproj.user
.Rhistory
.RData
.Ruserdata

# OS
.DS_Store
```

- [ ] **Step 3: Create `DESCRIPTION`** (declares R deps for CI via r-lib/actions)

```
Package: jacobwswallace.site
Title: Personal academic website build dependencies
Version: 0.0.1
Description: Package manifest used only to install R dependencies for the Quarto site build.
Encoding: UTF-8
Imports:
    ggplot2,
    plotly,
    dplyr,
    xml2,
    yaml,
    htmlwidgets,
    knitr,
    rmarkdown
Suggests:
    testthat (>= 3.0.0)
```

- [ ] **Step 4: Commit**

```bash
git add .gitignore DESCRIPTION
git commit -m "chore: project skeleton and R dependency manifest"
```

---

## Phase 1 — Quarto scaffold & visual system

### Task 1: Site config `_quarto.yml`

**Files:**
- Create: `_quarto.yml`

- [ ] **Step 1: Create `_quarto.yml`**

```yaml
project:
  type: website
  output-dir: _site
  render:
    - "*.qmd"

website:
  title: "Jacob Wallace"
  description: "Health economist studying health insurance markets and managed care in public programs."
  site-url: "https://www.jacobwswallace.com"
  navbar:
    logo: ""
    title: "Jacob Wallace"
    left:
      - text: "Research"
        href: research.qmd
      - text: "Publications"
        href: publications.qmd
      - text: "Writing"
        href: writing.qmd
      - text: "CV"
        href: cv.qmd
      - text: "Contact"
        href: contact.qmd
  page-footer:
    left: "© 2026 Jacob Wallace"
    right:
      - text: "Subscribe on Substack"
        href: "https://example.substack.com"   # replace in Task 13 with real URL
      - text: "Google Scholar"
        href: "https://scholar.google.com/citations?user=fEv_2Z0AAAAJ"
      - text: "Yale profile"
        href: "https://ysph.yale.edu/profile/jacob-wallace/"

format:
  html:
    theme:
      - cosmo
      - assets/css/theme.scss
    toc: false
    page-layout: full
    grid:
      body-width: 900px
    include-in-header:
      - text: |
          <link rel="preconnect" href="https://fonts.googleapis.com">

execute:
  freeze: false
```

- [ ] **Step 2: Verify config parses (render will fail until pages exist — that's expected next task)**

Run: `quarto check`
Expected: Quarto reports environment OK (no YAML parse error for `_quarto.yml`).

- [ ] **Step 3: Commit**

```bash
git add _quarto.yml
git commit -m "feat: quarto site config with navbar and footer"
```

### Task 2: Visual system theme `assets/css/theme.scss`

**Files:**
- Create: `assets/css/theme.scss`

- [ ] **Step 1: Create `assets/css/theme.scss`** (editorial-on-white, Yale-blue system)

```scss
/*-- scss:defaults --*/
$yale-blue:  #00356B;
$yale-light: #286dc0;
$clay:       #b04a3f;
$ink:        #3a4453;
$hairline:   #ecebe7;
$bg:         #ffffff;

$primary:      $yale-blue;
$body-color:   $ink;
$body-bg:      $bg;
$link-color:   $yale-blue;
$navbar-bg:    $bg;
$navbar-fg:    $yale-blue;

// Editorial pairing: serif headings, sans body/nav/fine-print.
$font-family-serif: Georgia, "Times New Roman", Cambria, serif;
$font-family-sans-serif: "Helvetica Neue", Arial, system-ui, sans-serif;
$headings-font-family: #{$font-family-serif};
$font-family-base: #{$font-family-sans-serif};
$font-size-base: 1.125rem;   // ~18px body
$headings-font-weight: 600;
$line-height-base: 1.65;

/*-- scss:rules --*/
body { color: $ink; }

h1, h2, h3, h4 { color: $yale-blue; line-height: 1.2; }
h1 { font-size: 2.6rem; margin-bottom: 1rem; }
h2 { font-size: 1.9rem; margin-top: 2.5rem; }

.navbar { border-bottom: 1px solid $hairline; }
.navbar .navbar-title { font-family: $font-family-serif; font-weight: 600; }
.navbar .nav-link { font-family: $font-family-sans-serif; letter-spacing: .3px; }

a { text-decoration: none; }
a:hover { text-decoration: underline; }

// Small uppercase eyebrow label used above headings.
.eyebrow {
  font-family: $font-family-sans-serif;
  text-transform: uppercase;
  letter-spacing: 1.6px;
  font-size: .8rem;
  color: $yale-light;
  margin-bottom: .75rem;
}

// Bordered card used for hero, featured finding, research-at-a-glance.
.card-lite {
  border: 1px solid $hairline;
  border-radius: 8px;
  padding: 1.75rem;
  margin: 1.5rem 0;
}

// Accent, used sparingly for emphasis.
.accent { color: $clay; }

// Substack "Subscribe" button.
.btn-substack {
  display: inline-block;
  background: $yale-blue;
  color: #fff !important;
  font-family: $font-family-sans-serif;
  font-size: .95rem;
  padding: .5rem .9rem;
  border-radius: 5px;
}
.btn-substack:hover { text-decoration: none; background: darken($yale-blue, 6%); }

// Post list (Writing page + Home teaser).
.post { padding: 1rem 0; border-bottom: 1px solid #f1f0ec; }
.post .meta { font-family: $font-family-sans-serif; font-size: .8rem; letter-spacing: .5px; color: #93745a; text-transform: uppercase; }
.post .headline { font-size: 1.15rem; font-weight: 600; margin: .25rem 0; }
.post .excerpt { font-family: $font-family-sans-serif; font-size: .95rem; color: #5b6472; }

.hero-figure { margin: 1rem 0 .5rem; }
```

- [ ] **Step 2: Commit**

```bash
git add assets/css/theme.scss
git commit -m "feat: editorial Yale-blue visual system (scss theme)"
```

---

## Phase 2 — Content pages

Bio and affiliation text below are migrated from the current site + public Yale/NBER profiles. Replace the photo file when available.

### Task 3: Home page `index.qmd` (static shell; hero + teaser wired in later tasks)

**Files:**
- Create: `index.qmd`
- Create (placeholder image): `assets/img/README.md`

- [ ] **Step 1: Create `assets/img/README.md`** so the dir is tracked

```markdown
Put `headshot.jpg` here (square, ≥400px). Until then pages reference it but Quarto renders fine without it.
```

- [ ] **Step 2: Create `index.qmd`**

````markdown
---
title: ""
pagetitle: "Jacob Wallace"
---

::: {.eyebrow}
Health Economist · Yale School of Public Health
:::

# Rigorous evidence on how health insurance markets shape care for vulnerable populations.

Associate Professor of Public Health (Health Policy) at the Yale School of Public Health
and a Faculty Research Fellow at the National Bureau of Economic Research. My research studies
the economics of health insurance markets, with a focus on managed care in public insurance
programs such as Medicaid.

Before academia I served as a Medicaid policy expert for New York State, worked as a data
scientist in Silicon Valley, and co-founded the advocacy organization Young Invincibles.
I hold degrees from Swarthmore College and Harvard University.

[Yale profile](https://ysph.yale.edu/profile/jacob-wallace/){.btn-substack}
[CV (PDF)](cv.qmd)
[Google Scholar](https://scholar.google.com/citations?user=fEv_2Z0AAAAJ)

<!-- HERO PLACEHOLDER: replaced in Task 9 -->

<!-- LATEST WRITING PLACEHOLDER: replaced in Task 13 -->
````

- [ ] **Step 3: Render the site and confirm the home page builds**

Run: `quarto render index.qmd`
Expected: renders to `_site/index.html` with no error. (Other nav links 404 until their pages exist — fine.)

- [ ] **Step 4: Commit**

```bash
git add index.qmd assets/img/README.md
git commit -m "feat: home page shell"
```

### Task 4: Contact page `contact.qmd`

**Files:**
- Create: `contact.qmd`

- [ ] **Step 1: Create `contact.qmd`**

```markdown
---
title: "Contact"
---

**Jacob Wallace, PhD**
Associate Professor of Public Health (Health Policy)
Yale School of Public Health

- Email: [jacob.wallace@yale.edu](mailto:jacob.wallace@yale.edu)
- [Yale School of Public Health profile](https://ysph.yale.edu/profile/jacob-wallace/)
- [Yale Department of Economics](https://economics.yale.edu/people/jacob-wallace)
- [NBER](https://www.nber.org/)
- [Google Scholar](https://scholar.google.com/citations?user=fEv_2Z0AAAAJ)
```

- [ ] **Step 2: Render and commit**

```bash
quarto render contact.qmd && git add contact.qmd && git commit -m "feat: contact page"
```

### Task 5: CV page `cv.qmd`

**Files:**
- Create: `cv.qmd`
- Add: `assets/cv.pdf` (Jacob supplies the current PDF)

- [ ] **Step 1: Copy the current CV PDF into the repo**

Run (Jacob provides the path to the latest CV):
```bash
cp /path/to/jacob-wallace-cv.pdf assets/cv.pdf   # replace with the real path
```
If the PDF is not available yet, create a stub so the page renders: `printf '' > assets/cv.pdf` and replace later.

- [ ] **Step 2: Create `cv.qmd`**

```markdown
---
title: "CV"
---

My full curriculum vitae is available as a PDF.

[Download CV (PDF)](assets/cv.pdf){.btn-substack}
```

- [ ] **Step 3: Render and commit**

```bash
quarto render cv.qmd && git add cv.qmd assets/cv.pdf && git commit -m "feat: cv page"
```

---

## Phase 3 — Publications (single structured source)

### Task 6: Publications data + page

**Files:**
- Create: `data/publications.yml`
- Create: `publications.qmd`

- [ ] **Step 1: Create `data/publications.yml`** (seeded with known papers; Jacob adds the rest)

```yaml
- title: "The Private Provision of Public Services: Evidence from Random Assignment in Medicaid"
  authors: "Danil Agafiev Macambira, Michael Geruso, Anthony Lollo, Chima D. Ndumele, Jacob Wallace"
  year: 2026
  venue: "American Economic Review"
  theme: "Managed care & privatization"
  url: "https://www.aeaweb.org/articles?id=10.1257/aer.20230541"
  pdf: ""
- title: "Adverse selection and network design under regulated plan prices: Evidence from Medicaid"
  authors: "Jacob Wallace, et al."
  year: 2024
  venue: "Journal of Health Economics"
  theme: "Plan & network design"
  url: ""
  pdf: ""
- title: "What Difference Does a Health Plan Make? Evidence from Random Plan Assignment in Medicaid"
  authors: "Jacob Wallace, Anthony Lollo, Chima D. Ndumele"
  year: 2023
  venue: "American Economic Journal: Applied Economics"
  theme: "Health plan effects"
  url: ""
  pdf: ""
- title: "What Does a Provider Network Do? Evidence from Random Assignment in Medicaid Managed Care"
  authors: "Jacob Wallace, et al."
  year: 2023
  venue: "American Economic Journal: Economic Policy"
  theme: "Plan & network design"
  url: ""
  pdf: ""
```

- [ ] **Step 2: Create `publications.qmd`** (renders the YAML, newest first, grouped by year)

````markdown
---
title: "Publications"
---

```{r}
#| echo: false
#| output: asis
pubs <- yaml::read_yaml("data/publications.yml")
# newest first
pubs <- pubs[order(-sapply(pubs, function(p) p$year))]
for (p in pubs) {
  link <- if (nzchar(p$url)) sprintf(" [[journal](%s)]", p$url) else ""
  pdf  <- if (nzchar(p$pdf)) sprintf(" [[pdf](%s)]", p$pdf) else ""
  cat(sprintf("**%s** (%d). *%s.* %s.%s%s\n\n",
              p$title, p$year, p$venue, p$authors, link, pdf))
}
```
````

- [ ] **Step 3: Render and confirm all four publications appear newest-first**

Run: `quarto render publications.qmd`
Expected: `_site/publications.html` lists the 2026 AER paper first, then 2024, then the two 2023 papers.

- [ ] **Step 4: Commit**

```bash
git add data/publications.yml publications.qmd
git commit -m "feat: publications page from structured yaml source"
```

---

## Phase 4 — Hero selector (unit-tested logic) + launch hero

### Task 7: Deterministic hero selector `R/heroes.R` (TDD)

**Files:**
- Create: `R/heroes.R`
- Test: `tests/testthat/test-heroes.R`

- [ ] **Step 1: Write the failing test** `tests/testthat/test-heroes.R`

```r
# Robustly locate the repo root regardless of testthat's working directory.
find_root <- function() {
  d <- getwd()
  while (!file.exists(file.path(d, "DESCRIPTION"))) {
    parent <- dirname(d)
    if (parent == d) stop("repo root (DESCRIPTION) not found")
    d <- parent
  }
  d
}
root <- find_root()
source(file.path(root, "R/heroes.R"))

test_that("select_hero returns a member of the id set", {
  ids <- c("a", "b", "c")
  expect_true(select_hero(ids, week = 1) %in% ids)
})

test_that("select_hero is deterministic for a given week", {
  ids <- c("a", "b", "c")
  expect_equal(select_hero(ids, week = 7), select_hero(ids, week = 7))
})

test_that("select_hero rotates across weeks (cycles through the set)", {
  ids <- c("a", "b", "c")
  expect_equal(select_hero(ids, week = 0), "a")
  expect_equal(select_hero(ids, week = 1), "b")
  expect_equal(select_hero(ids, week = 2), "c")
  expect_equal(select_hero(ids, week = 3), "a")
})

test_that("select_hero errors on an empty set", {
  expect_error(select_hero(character(0), week = 1), "no heroes")
})
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `Rscript -e 'testthat::test_dir("tests/testthat")'`
Expected: FAIL — `could not find function "select_hero"`.

- [ ] **Step 3: Write minimal implementation** `R/heroes.R`

```r
# Deterministic hero rotation.
# Given an ordered vector of hero ids and an integer week, pick one id.
# Rotation cycles through the set by week so it changes on a slow, predictable cadence.
select_hero <- function(ids, week) {
  if (length(ids) == 0) stop("no heroes: id set is empty")
  idx <- (as.integer(week) %% length(ids)) + 1L
  ids[[idx]]
}

# Current ISO week number as an integer (used at build time).
current_iso_week <- function(today = Sys.Date()) {
  as.integer(format(today, "%V"))
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `Rscript -e 'testthat::test_dir("tests/testthat")'`
Expected: PASS (4 passing tests in test-heroes.R).

- [ ] **Step 5: Commit**

```bash
git add R/heroes.R tests/testthat/test-heroes.R
git commit -m "feat: deterministic hero selector with tests"
```

### Task 8: Launch hero visualization (AER 2026 finding)

**Files:**
- Create: `data/hero_aer2026.csv`
- Create: `heroes/hero-aer2026.qmd` (knitr child rendered into Home)
- Create: `data/heroes.yml`

- [ ] **Step 1: Create `data/hero_aer2026.csv`**

The one confirmed, citable headline is the **overall −5.6% cost reduction**. The component
magnitudes below are directional placeholders **to be replaced with the exact values from the
paper's results tables** (see AER 2026, Table of cost effects by category). The visualization
code works regardless of the exact numbers — this is a data-entry step, not a code change.

```csv
category,pct_change,note
Pharmacy,-9.0,"Utilization management; switches to cheaper drugs — REPLACE with paper value"
Outpatient,-4.0,"Lower prices — REPLACE with paper value"
Medical (other),-1.5,"Modest savings — REPLACE with paper value"
Overall,-5.6,"Confirmed headline: managed care cut total costs 5.6%"
```

- [ ] **Step 2: Create `heroes/hero-aer2026.qmd`** (a child doc; interactive plotly bar)

````markdown
::: {.card-lite}
::: {.eyebrow}
Featured finding · [The Private Provision of Public Services (AER, 2026)](https://www.aeaweb.org/articles?id=10.1257/aer.20230541)
:::

### Managed care cut Medicaid costs [5.6%]{.accent} — but medical quality fell.

```{r}
#| echo: false
#| warning: false
#| message: false
library(plotly)
d <- read.csv("data/hero_aer2026.csv", stringsAsFactors = FALSE)
d$category <- factor(d$category, levels = d$category)
d$fill <- ifelse(d$category == "Overall", "#b04a3f", "#00356B")
plot_ly(
  d, x = ~category, y = ~pct_change, type = "bar",
  marker = list(color = ~fill),
  hovertemplate = ~paste0(category, ": ", pct_change, "%<extra></extra>")
) |>
  layout(
    yaxis = list(title = "Cost change (%)", zeroline = TRUE),
    xaxis = list(title = ""),
    margin = list(t = 10),
    showlegend = FALSE
  ) |>
  config(displayModeBar = FALSE)
```

Savings came mostly from **pharmacy** management; privatizing **medical** benefits produced
only modest savings and was associated with **lower quality and satisfaction**.
:::
````

- [ ] **Step 3: Create `data/heroes.yml`** (rotation set — one entry for launch)

```yaml
- id: aer2026
  child: heroes/hero-aer2026.qmd
```

- [ ] **Step 4: Wire the hero into `index.qmd`** — replace the `<!-- HERO PLACEHOLDER -->` line with:

````markdown
```{r}
#| echo: false
#| output: asis
source("R/heroes.R")
heroes <- yaml::read_yaml("data/heroes.yml")
ids <- vapply(heroes, function(h) h$id, character(1))
chosen <- select_hero(ids, current_iso_week())
child <- heroes[[which(ids == chosen)]]$child
cat(knitr::knit_child(child, quiet = TRUE))
```
````

- [ ] **Step 5: Render Home and confirm the interactive hero appears**

Run: `quarto render index.qmd`
Expected: `_site/index.html` contains an interactive plotly bar chart inside a `.card-lite`
with the "Managed care cut Medicaid costs 5.6%" headline. Open it: `open _site/index.html`.

- [ ] **Step 6: Commit**

```bash
git add data/hero_aer2026.csv heroes/hero-aer2026.qmd data/heroes.yml index.qmd
git commit -m "feat: launch hero visualization (AER 2026) with rotation wiring"
```

---

## Phase 5 — Flagship interactive result on Research

### Task 9: Interactive result partial + Research page

**Files:**
- Create: `data/result_aer2026.csv`
- Create: `viz/result-aer2026.qmd`
- Create: `research.qmd`

- [ ] **Step 1: Create `data/result_aer2026.csv`** (published point estimates + CIs)

Seed with the confirmed overall effect; **replace the component estimates and CIs with exact
values from the paper's tables** during the build (data-entry step; code is complete).

```csv
outcome,estimate,ci_low,ci_high
Total cost,-5.6,-7.0,-4.2
Pharmacy spending,-9.0,-11.0,-7.0
Outpatient spending,-4.0,-6.0,-2.0
Quality/satisfaction,-3.0,-5.0,-1.0
```

- [ ] **Step 2: Create `viz/result-aer2026.qmd`** (interactive coefficient plot)

````markdown
::: {.card-lite}
::: {.eyebrow}
Interactive result
:::

### The Private Provision of Public Services (AER, 2026)

Nearly 100,000 Medicaid enrollees were **randomly assigned** between a publicly operated
fee-for-service system and private managed care. Hover each estimate for its confidence interval.

```{r}
#| echo: false
#| warning: false
#| message: false
library(plotly)
d <- read.csv("data/result_aer2026.csv", stringsAsFactors = FALSE)
d$outcome <- factor(d$outcome, levels = rev(d$outcome))
plot_ly(d, y = ~outcome, x = ~estimate, type = "scatter", mode = "markers",
        marker = list(color = "#00356B", size = 9),
        error_x = list(type = "data", symmetric = FALSE,
                       array = ~(ci_high - estimate),
                       arrayminus = ~(estimate - ci_low),
                       color = "#00356B"),
        hovertemplate = ~paste0(outcome, ": ", estimate,
                                "% [", ci_low, ", ", ci_high, "]<extra></extra>")) |>
  layout(xaxis = list(title = "Effect of managed care (%)", zeroline = TRUE),
         yaxis = list(title = ""), margin = list(l = 10)) |>
  config(displayModeBar = FALSE)
```

**Takeaway:** managed care lowered total costs (−5.6%), driven by pharmacy management, but
reduced measured quality/satisfaction — privatization's benefits concentrated in pharmacy, not
broader medical care.
[Read the paper →](https://www.aeaweb.org/articles?id=10.1257/aer.20230541)
:::
````

- [ ] **Step 3: Create `research.qmd`** (includes the result; research-at-a-glance added next task)

````markdown
---
title: "Research"
---

I study the economics of health insurance markets, with a focus on managed care in public
insurance programs. Below is an interactive look at a flagship result; a full list is on the
[Publications](publications.qmd) page.

{{< include viz/result-aer2026.qmd >}}

<!-- RESEARCH-AT-A-GLANCE PLACEHOLDER: replaced in Task 10 -->
````

- [ ] **Step 4: Render Research and confirm the interactive coefficient plot appears**

Run: `quarto render research.qmd`
Expected: `_site/research.html` shows an interactive dot-and-error-bar plot with four outcomes.

- [ ] **Step 5: Commit**

```bash
git add data/result_aer2026.csv viz/result-aer2026.qmd research.qmd
git commit -m "feat: interactive flagship result (AER 2026) on research page"
```

---

## Phase 6 — Research at a glance

### Task 10: Visual index of papers

**Files:**
- Modify: `research.qmd` (replace the research-at-a-glance placeholder)

- [ ] **Step 1: Replace the `<!-- RESEARCH-AT-A-GLANCE PLACEHOLDER -->` line in `research.qmd` with:**

````markdown
## Research at a glance

```{r}
#| echo: false
#| output: asis
pubs <- yaml::read_yaml("data/publications.yml")
pubs <- pubs[order(-sapply(pubs, function(p) p$year))]
cat('<div>\n')
for (p in pubs) {
  href <- if (nzchar(p$url)) p$url else "publications.qmd"
  cat(sprintf(
    '<div class="card-lite"><div class="eyebrow">%s · %d</div><div class="headline"><a href="%s">%s</a></div><div class="excerpt">%s</div></div>\n',
    p$theme, p$year, href, p$title, p$venue))
}
cat('</div>\n')
```
````

- [ ] **Step 2: Render and confirm one card per publication, grouped visually by theme/year**

Run: `quarto render research.qmd`
Expected: below the interactive result, four `.card-lite` entries, newest first, each linking out.

- [ ] **Step 3: Commit**

```bash
git add research.qmd
git commit -m "feat: research-at-a-glance visual index"
```

---

## Phase 7 — Substack integration

### Task 11: RSS ingester `R/substack.R` (TDD)

**Files:**
- Create: `tests/testthat/fixtures/feed.xml`
- Create: `R/substack.R`
- Test: `tests/testthat/test-substack.R`

- [ ] **Step 1: Create the fixture `tests/testthat/fixtures/feed.xml`** (minimal Substack-style RSS with two authors)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>SCALE</title>
    <item>
      <title>Random assignment and Medicaid plans</title>
      <link>https://scale.substack.com/p/random-assignment</link>
      <pubDate>Fri, 10 Jul 2026 12:00:00 GMT</pubDate>
      <dc:creator>Jacob Wallace</dc:creator>
      <description>A short take on the new AER paper.</description>
    </item>
    <item>
      <title>Someone else's post</title>
      <link>https://scale.substack.com/p/other</link>
      <pubDate>Thu, 09 Jul 2026 12:00:00 GMT</pubDate>
      <dc:creator>Another Author</dc:creator>
      <description>Not by Jacob.</description>
    </item>
  </channel>
</rss>
```

- [ ] **Step 2: Write the failing test** `tests/testthat/test-substack.R`

```r
find_root <- function() {
  d <- getwd()
  while (!file.exists(file.path(d, "DESCRIPTION"))) {
    parent <- dirname(d)
    if (parent == d) stop("repo root (DESCRIPTION) not found")
    d <- parent
  }
  d
}
root <- find_root()
source(file.path(root, "R/substack.R"))
fx <- file.path(root, "tests/testthat/fixtures/feed.xml")

test_that("parse_feed returns one row per item with expected fields", {
  posts <- parse_feed(fx, source = "scale")
  expect_equal(nrow(posts), 2)
  expect_setequal(names(posts), c("title","url","date","excerpt","author","source"))
  expect_equal(posts$source[1], "scale")
})

test_that("author filter keeps only matching posts", {
  posts <- parse_feed(fx, source = "scale", author = "Jacob Wallace")
  expect_equal(nrow(posts), 1)
  expect_equal(posts$title, "Random assignment and Medicaid plans")
})

test_that("no author filter keeps all posts", {
  posts <- parse_feed(fx, source = "personal", author = NULL)
  expect_equal(nrow(posts), 2)
})

test_that("merge_posts sorts newest first", {
  a <- parse_feed(fx, source = "scale")
  merged <- merge_posts(list(a))
  expect_true(merged$date[1] >= merged$date[2])
})
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `Rscript -e 'testthat::test_dir("tests/testthat")'`
Expected: FAIL — `could not find function "parse_feed"`.

- [ ] **Step 4: Write implementation** `R/substack.R`

```r
# Substack RSS ingestion. Pure parsing/normalization — network fetch is done by the caller
# (the GitHub Action downloads feeds to disk, then calls parse_feed on the files).
suppressPackageStartupMessages({
  library(xml2)
})

# Parse one RSS file into a normalized data.frame.
# author: if non-NULL, keep only items whose <dc:creator> matches (case-insensitive).
parse_feed <- function(path, source, author = NULL) {
  doc <- read_xml(path)
  items <- xml_find_all(doc, ".//item")
  get <- function(node, tag) {
    v <- xml_text(xml_find_first(node, tag))
    if (is.na(v)) "" else trimws(v)
  }
  rows <- lapply(items, function(it) {
    data.frame(
      title   = get(it, "./title"),
      url     = get(it, "./link"),
      date    = as.Date(get(it, "./pubDate"), format = "%a, %d %b %Y %H:%M:%S", tz = "GMT"),
      excerpt = get(it, "./description"),
      author  = get(it, ".//dc:creator"),
      source  = source,
      stringsAsFactors = FALSE
    )
  })
  posts <- do.call(rbind, rows)
  if (is.null(posts)) {
    posts <- data.frame(title=character(), url=character(), date=as.Date(character()),
                        excerpt=character(), author=character(), source=character())
  }
  if (!is.null(author)) {
    posts <- posts[tolower(posts$author) == tolower(author), , drop = FALSE]
  }
  posts
}

# Merge a list of parsed data.frames, dedupe by url, sort newest first.
merge_posts <- function(feed_list) {
  posts <- do.call(rbind, feed_list)
  if (is.null(posts) || nrow(posts) == 0) return(posts)
  posts <- posts[!duplicated(posts$url), , drop = FALSE]
  posts[order(posts$date, decreasing = TRUE), , drop = FALSE]
}

# Write normalized posts to YAML consumed by the Writing page + Home teaser.
write_posts_yaml <- function(posts, path) {
  out <- lapply(seq_len(nrow(posts)), function(i) {
    list(title = posts$title[i], url = posts$url[i],
         date = as.character(posts$date[i]), excerpt = posts$excerpt[i],
         source = posts$source[i])
  })
  yaml::write_yaml(out, path)
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `Rscript -e 'testthat::test_dir("tests/testthat")'`
Expected: PASS (all test-substack.R + test-heroes.R tests green).

- [ ] **Step 6: Commit**

```bash
git add R/substack.R tests/testthat/test-substack.R tests/testthat/fixtures/feed.xml
git commit -m "feat: substack RSS ingester with author filtering and tests"
```

### Task 12: Fetch script + config + Writing page + Home teaser

**Files:**
- Create: `data/substack_config.yml`
- Create: `data/substack_posts.yml` (initial empty cache)
- Create: `R/fetch_substack.R` (network entrypoint used by CI + local)
- Create: `writing.qmd`
- Modify: `index.qmd` (replace latest-writing placeholder)
- Modify: `_quarto.yml` (real Substack footer URL)

- [ ] **Step 1: Create `data/substack_config.yml`** (Jacob fills the two URLs + author name)

```yaml
personal_url: "https://REPLACE-personal.substack.com/feed"
scale_url: "https://REPLACE-scale.substack.com/feed"
author_name: "Jacob Wallace"
```

- [ ] **Step 2: Create an initial `data/substack_posts.yml`** so pages render before first fetch

```yaml
[]
```

- [ ] **Step 3: Create `R/fetch_substack.R`** (downloads feeds, calls the tested parser, writes YAML)

```r
#!/usr/bin/env Rscript
# Network entrypoint: download both feeds, parse/filter/merge, write data/substack_posts.yml.
# Safe to run locally or in CI. Fails soft: if a feed is unreachable it is skipped.
source("R/substack.R")

cfg <- yaml::read_yaml("data/substack_config.yml")
tmp <- tempfile(fileext = ".xml")

try_feed <- function(url, source, author) {
  if (!nzchar(url) || grepl("REPLACE", url)) return(NULL)
  ok <- tryCatch({ download.file(url, tmp, quiet = TRUE); TRUE },
                 error = function(e) FALSE)
  if (!ok) { message("skip (unreachable): ", url); return(NULL) }
  tryCatch(parse_feed(tmp, source = source, author = author),
           error = function(e) { message("parse failed: ", url); NULL })
}

personal <- try_feed(cfg$personal_url, "personal", author = NULL)
scale    <- try_feed(cfg$scale_url,    "scale",    author = cfg$author_name)

feeds <- Filter(Negate(is.null), list(personal, scale))
if (length(feeds) == 0) {
  message("No feeds fetched; leaving existing data/substack_posts.yml unchanged.")
} else {
  posts <- merge_posts(feeds)
  write_posts_yaml(posts, "data/substack_posts.yml")
  message("Wrote ", nrow(posts), " posts.")
}
```

- [ ] **Step 4: Create `writing.qmd`**

````markdown
---
title: "Writing"
---

[Subscribe on Substack](https://REPLACE-personal.substack.com){.btn-substack}

```{r}
#| echo: false
#| output: asis
posts <- yaml::read_yaml("data/substack_posts.yml")
if (length(posts) == 0) {
  cat("*Posts will appear here once the Substack feeds are configured.*\n")
} else {
  for (p in posts) {
    cat(sprintf(
      '<div class="post"><div class="meta">%s · %s</div><div class="headline"><a href="%s">%s</a></div><div class="excerpt">%s</div></div>\n',
      p$date, toupper(p$source), p$url, p$title, p$excerpt))
  }
}
```
````

- [ ] **Step 5: Replace the `<!-- LATEST WRITING PLACEHOLDER -->` line in `index.qmd` with:**

````markdown
```{r}
#| echo: false
#| output: asis
posts <- yaml::read_yaml("data/substack_posts.yml")
if (length(posts) > 0) {
  cat("## Latest writing\n\n")
  for (p in head(posts, 3)) {
    cat(sprintf(
      '<div class="post"><div class="meta">%s · %s</div><div class="headline"><a href="%s">%s</a></div></div>\n',
      p$date, toupper(p$source), p$url, p$title))
  }
  cat('\n[All writing →](writing.qmd)\n')
}
```
````

- [ ] **Step 6: Update the footer Substack URL in `_quarto.yml`** — replace the `page-footer` Substack `href` `"https://example.substack.com"` with the real personal URL (or leave until Jacob provides it).

- [ ] **Step 7: Render the whole site and confirm Writing renders and Home teaser is conditional**

Run: `quarto render`
Expected: full site builds; `writing.html` shows the "Posts will appear here…" message (empty cache); `index.html` has no "Latest writing" section yet (empty cache). No errors.

- [ ] **Step 8: (Optional local smoke test once real URLs are in config)** run the fetcher

Run: `Rscript R/fetch_substack.R && quarto render writing.qmd && open _site/writing.html`
Expected: real posts listed newest-first; SCALE items limited to Jacob's posts.

- [ ] **Step 9: Commit**

```bash
git add data/substack_config.yml data/substack_posts.yml R/fetch_substack.R writing.qmd index.qmd _quarto.yml
git commit -m "feat: substack fetch script, writing page, and home teaser"
```

> **SCALE author-filter fallback (from spec §6):** if, once the real SCALE feed is inspected,
> `<dc:creator>` is absent, switch `scale` ingestion to a manual allowlist: add
> `scale_post_urls:` to `data/substack_config.yml` and filter `parse_feed` output by
> `posts$url %in% cfg$scale_post_urls` instead of by author. This is a small, localized change
> to `R/fetch_substack.R` only.

---

## Phase 8 — Deploy to GitHub Pages + custom domain

### Task 13: Render+deploy workflow with daily Substack refresh

**Files:**
- Create: `.github/workflows/publish.yml`
- Create: `CNAME`

- [ ] **Step 1: Create `CNAME`** (custom domain for Pages)

```
www.jacobwswallace.com
```

- [ ] **Step 2: Create `.github/workflows/publish.yml`**

```yaml
name: Publish site
on:
  push:
    branches: [main]
  schedule:
    - cron: "0 9 * * *"   # daily 09:00 UTC: refresh Substack, rotate hero, redeploy
  workflow_dispatch:

permissions:
  contents: write
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::yaml

      - name: Refresh Substack posts (scheduled/manual only)
        if: github.event_name != 'push'
        run: Rscript R/fetch_substack.R

      - name: Commit refreshed posts if changed
        if: github.event_name != 'push'
        run: |
          if ! git diff --quiet data/substack_posts.yml; then
            git config user.name "github-actions"
            git config user.email "actions@github.com"
            git add data/substack_posts.yml
            git commit -m "chore: refresh substack posts [skip ci]"
            git push
          fi

      - uses: quarto-dev/quarto-actions/setup@v2

      - name: Render site
        run: quarto render

      - uses: actions/upload-pages-artifact@v3
        with:
          path: _site

  deploy:
    needs: build-deploy
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    permissions:
      pages: write
      id-token: write
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/publish.yml CNAME
git commit -m "ci: render+deploy to github pages with daily substack refresh"
```

### Task 14: Create the GitHub repo, push, enable Pages

**Files:** none (remote setup — requires Jacob's GitHub auth)

- [ ] **Step 1: Authenticate gh (Jacob runs this interactively)**

In the Claude Code prompt, type: `! gh auth login`
Follow the browser prompts. Verify: `gh auth status`.

- [ ] **Step 2: Create the remote repo and push**

Run:
```bash
gh repo create jacobwswallace-site --public --source=. --remote=origin --push
```

- [ ] **Step 3: Enable Pages via GitHub Actions**

Run:
```bash
gh api -X POST repos/:owner/jacobwswallace-site/pages -f build_type=workflow || true
gh workflow run "Publish site"
```
Then watch: `gh run watch`
Expected: the workflow renders and deploys; `gh run view --web` shows a green run with a Pages URL (`https://<user>.github.io/jacobwswallace-site` initially, then the custom domain).

- [ ] **Step 4: Verify the deployed site loads on the github.io URL before touching DNS**

Open the Pages URL from the run summary. Confirm home hero, research plot, and nav all work.

### Task 15: Point jacobwswallace.com at GitHub Pages (DNS cutover)

**Files:** none (registrar DNS — requires Jacob's registrar access)

- [ ] **Step 1: At the domain registrar, set DNS records**

- `www` CNAME → `<github-username>.github.io`
- Apex `@` A records → GitHub Pages IPs: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
- (Optional) Apex AAAA records for IPv6 per GitHub Pages docs.

- [ ] **Step 2: Set the custom domain + enforce HTTPS in the repo**

Run:
```bash
gh api -X PUT repos/:owner/jacobwswallace-site/pages -f cname=www.jacobwswallace.com
```
Then in the repo Settings → Pages, wait for the DNS check to pass and tick **Enforce HTTPS**.

- [ ] **Step 3: Verify**

After DNS propagates (minutes to a few hours):
```bash
curl -sI https://www.jacobwswallace.com | head -1
```
Expected: `HTTP/2 200`. Open the site and confirm it is the new Quarto site over HTTPS.

- [ ] **Step 4: Decommission the old Google Site** once the new site is confirmed live (unpublish it so it no longer competes for the domain).

---

## Self-review notes (author checklist run against the spec)

- **Spec §2 platform/workflow** → Tasks 0–1, 13–15 (Quarto, GitHub Pages, domain). ✓
- **Spec §2 data policy (public/published only)** → enforced in Tasks 8/9 CSVs + notes; no restricted data anywhere. ✓
- **Spec §3 visual system** → Task 2 (theme.scss: Yale blue, serif headings, 18px, clay accent). ✓
- **Spec §4 structure (Home/Research/Publications/Writing/CV/Contact + footer subscribe)** → Tasks 1,3–6,9–12. ✓
- **Spec §5a rotating hero** → Tasks 7–8 (tested selector + launch hero + wiring). ✓
- **Spec §5b interactive results (flagship AER 2026)** → Task 9. ✓
- **Spec §5c research at a glance** → Task 10. ✓
- **Spec §6 Substack (two feeds, SCALE author filter + fallback, Writing page + Home teaser, scheduled refresh)** → Tasks 11–13. ✓
- **Spec §7 scope (one flagship viz; others deferred)** → only AER 2026 built; §7 deferred items intentionally excluded. ✓
- **Spec §9 risks (DNS cutover, SCALE authorship, CV URL)** → Tasks 5, 12 (fallback note), 15. ✓

**Deferred to future plans (per spec §7):** interactive results for *What Difference Does a
Health Plan Make?* and *What Does a Provider Network Do?*; additional heroes in the rotation;
optional HTML CV. Each follows the established pattern: add a CSV + a `viz/*.qmd` or
`heroes/*.qmd` partial + (for heroes) an entry in `data/heroes.yml`.
