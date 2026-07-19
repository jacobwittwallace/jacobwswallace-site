# Design Spec — jacobwswallace.com Academic Site Redesign

**Date:** 2026-07-19
**Owner:** Jacob Wallace (Associate Professor, Yale School of Public Health; Faculty Research Fellow, NBER)
**Author of spec:** Claude (brainstorming session)

## 1. Goal

Replace the current Google Sites site at jacobwswallace.com with a polished, modern academic
website that (a) looks genuinely nicer than a stock academic template and (b) features
interactive data visualizations built from Jacob's published research. Keep the existing
domain. Keep it free to host and maintainable by Jacob via a simple edit-commit workflow.

## 2. Platform & Workflow

- **Site generator:** [Quarto](https://quarto.org/) — markdown-based, native support for
  interactive figures authored in R, publishes to static HTML.
- **Hosting:** GitHub Pages, deployed via GitHub Actions on push to `main`.
- **Domain:** Point `jacobwswallace.com` (and `www`) at GitHub Pages via a `CNAME` file +
  DNS records at the current registrar. Preserve the existing CV PDF URL if feasible, or add
  a redirect.
- **Authoring language for viz:** R (Jacob's tool of choice). Charts render at build time;
  interactive ones use htmlwidgets / Observable JS embedded by Quarto.
- **Maintenance model:** Jacob edits markdown (`.qmd`) files and commits via GitHub. No
  server, no CMS.

### Data policy (important constraint)

All public-facing visualizations are built **only** from:
- **Published estimates** already public in Jacob's papers (point estimates, CIs, tables), and
- **Public datasets** (KFF, CMS, U.S. Census) for descriptive/context figures.

**No restricted Medicaid claims data** touches the repo or the site. Each interactive result
is driven by a small, hand-curated CSV of published numbers checked into the repo.

## 3. Visual System

An "editorial, but airy and white" hybrid:

- **Typography:** Serif headlines (editorial, scholarly); sans-serif for navigation, labels,
  and fine print (classic editorial pairing).
- **Sizing:** ~18px body, ~40–48px h1, generous line-height and whitespace throughout.
- **Color:**
  - Primary ink / headings: **Yale Blue `#00356B`**
  - Background: white, lots of whitespace
  - Accent (used sparingly, for emphasis in charts only): warm clay **`#b04a3f`**
  - Neutral hairlines/borders: light warm gray (`#ecebe7` / `#e3e6ea`)
- **Tone:** calm and readable everywhere except the homepage hero, where a single striking
  finding is allowed to lead.

The visual system is codified in a Quarto SCSS theme so it's consistent across every page.

## 4. Site Structure

Top nav: **Home · Research · Publications · Writing · CV · Contact**
(Contact may collapse into the footer; footer carries a persistent Substack "Subscribe" link.)

### Home
- Rotating **hero visualization** (see §5) up top.
- Short bio + photo, a plain-language one-liner about the research.
- 2–3 highlights (recent paper / award / media hit).
- Teaser of the **2–3 latest Substack posts** (see §6).
- Key links: Yale profile, CV, Google Scholar, NBER.

### Research
- 🧭 **Research at a glance** — a visual index of papers (theme, venue, year) each with a
  one-figure takeaway linking to the paper.
- 📈 **Interactive results** — explorable versions of flagship findings (see §5).

### Publications
- Full list, sortable/filterable by year and theme, with links to PDF / journal / replication
  materials. Built from a single structured source (BibTeX or a `.yml`/`.csv`) so it stays
  easy to update.

### Writing
- Auto-updated listing of Substack posts merged from two feeds by date (see §6).
- Prominent Subscribe button.

### CV
- Link to the maintained PDF; optionally a lightweight HTML version generated from the same
  publication source.

### Contact
- Email, office, Yale/NBER affiliations, Scholar/social links. May live in the footer.

## 5. Data Visualizations

All built collaboratively with Jacob from published estimates + public data.

### 5a. Rotating hero (Home)
- A **curated set of 2–4 hero visualizations** that Jacob can grow over time.
- Rotation is "occasional," not per-second flashy. **Mechanism:** on each site build, the hero
  is selected deterministically from the curated set (e.g., indexed by ISO week number) so it
  changes on a slow, predictable cadence without JS randomness that would hurt reproducibility.
  Jacob can also pin a specific hero when he wants.
- **Launch hero:** the AER 2026 finding — *managed care cut Medicaid costs 5.6%, but medical
  quality/satisfaction fell* — as a small interactive decomposition (savings by mechanism:
  pharmacy vs. outpatient vs. medical) with the quality caveat surfaced.

### 5b. Interactive results (Research)
Launch with **one** fully-built flagship, then repeat the pattern:
- **Flagship #1:** *The Private Provision of Public Services: Evidence from Random Assignment
  in Medicaid* (AER, 2026). Interactive coefficient/decomposition plot with a plain-language
  takeaway and link to the paper.
- **Next (repeatable pattern, added over time):** *What Difference Does a Health Plan Make?*
  (AEJ: Applied, 2023) and *What Does a Provider Network Do?* (AEJ: Policy, 2023).

Each interactive result = one `.qmd` partial + one curated CSV of published estimates + shared
R plotting helpers, so adding a new one is a well-worn path.

### 5c. Research at a glance (Research)
- A visual index (cards or a timeline) across all papers: theme, venue, year, a one-line
  takeaway, and a small takeaway figure where available.

## 6. Substack Integration

- **Feeds:** two — Jacob's **personal** Substack (all posts) and a **SCALE** Substack
  **filtered to only Jacob's posts**.
- **Mechanism:** a **scheduled GitHub Action** (daily cron) fetches each feed's RSS, parses
  it, writes a normalized data file (title, date, url, excerpt, source label), and triggers a
  site rebuild. Posts thus "flow in" automatically without manual copying; freshness = the
  cron cadence (daily), not real-time.
- **SCALE author filtering (best-effort):** filter SCALE feed items by author using the RSS
  `<dc:creator>`/author field when present.
  - **Fallback if the SCALE feed does not expose per-post authorship:** maintain a small
    manual allowlist of Jacob's SCALE post URLs (or, minimally, just link out to the SCALE
    publication without auto-listing its posts). This fallback is decided at implementation
    time once the actual feed is inspected.
- **Placement:** dedicated **Writing** page (both feeds merged by date, each tagged by
  source), **2–3 latest teased on Home**, persistent **Subscribe** link in footer + nav.
- **URLs:** the two Substack URLs are TBD from Jacob; spec/implementation uses config
  placeholders he fills in later.

## 7. Scope

### In scope for the first implementation
- Quarto project scaffold, SCSS theme (the §3 visual system), GitHub Pages deploy + custom
  domain.
- Home, Research, Publications, Writing, CV, Contact pages with real content migrated from the
  current site.
- **One** flagship interactive visualization (AER 2026) fully built.
- Rotating-hero mechanism with the launch hero wired in.
- Substack integration: scheduled Action + Writing page + Home teaser (with the SCALE-filter
  fallback path documented and implemented as needed).

### Deferred (repeatable patterns, added later)
- Interactive results for the two additional papers.
- Additional hero visualizations in the rotation.
- Optional HTML CV, teaching/blog pages.

### Explicitly out of scope
- Any use of restricted/claims data.
- A CMS or dynamic backend.
- Real-time (sub-daily) Substack syncing.

## 8. Component Boundaries

- **Theme** (`_theme.scss` + `_quarto.yml`): visual system only; pages don't hardcode styles.
- **Publication source** (single structured file): consumed by Publications page, "research at
  a glance," and optional HTML CV.
- **Viz module** (per-paper): `{one .qmd partial + one CSV + shared R helpers}`. Interface: a
  partial that can be included on Research and/or as a hero. Independently reviewable.
- **Hero selector**: pure function of (curated set, build date/pin) → chosen hero. No hidden
  state.
- **Substack ingester** (GitHub Action + small script): input = feed URLs + author filter;
  output = one normalized posts data file. The site reads only that file — the network fetch
  is isolated to the Action.

## 9. Open Questions / Risks

- **DNS/domain cutover** from Google Sites → GitHub Pages: needs registrar access; plan a
  low-risk cutover (verify build on a `*.github.io` URL first, then switch DNS).
- **SCALE RSS authorship** may not be exposed → fallback per §6.
- **CV PDF URL** continuity: preserve or redirect the existing link.
- Exact published numbers for each viz to be pulled from the papers with Jacob during build.

## 10. Success Criteria

- Site builds and deploys to jacobwswallace.com via GitHub Pages.
- Passes the "academic but genuinely nicer" bar: cohesive editorial-on-white Yale-blue system,
  readable type, generous whitespace.
- Homepage shows a working, interactive rotating hero (launch: AER 2026 finding).
- Research page has one fully interactive flagship result driven only by public/published data.
- Writing page and Home teaser populate automatically from the configured Substack feeds.
- Jacob can add a new publication, a new interactive result, or a new hero by following a
  documented, repeatable pattern.
