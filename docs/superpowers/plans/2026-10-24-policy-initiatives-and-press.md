# Policy Initiatives and Press Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Policy Initiatives" page (four image-left rows with abstracts and grouped public links, plus advisory roles) and a "Press" page (one long undated list with † / ‡ marks) to jacobwswallace.com.

**Architecture:** This follows the site's existing pattern. Content lives in `data/*.yml`, and small R helpers in `R/` turn it into HTML strings. Thin `.qmd` pages `cat()` that HTML through `output: asis` chunks. All content decisions (which links, copy, outlet names, tiers) were made at planning time and are staged as finished files under `.superpowers/sources/2026-10-23/`. The build copies them in and renders them; it does not re-curate.

**Tech Stack:** Quarto website, R (`yaml`, `testthat`), SCSS theme (`assets/css/theme.scss`), GitHub Pages via `.github/workflows/publish.yml`.

**Spec:** `docs/superpowers/specs/2026-10-23-policy-initiatives-and-press-design.md`

## Global Constraints

- **This repo is PUBLIC and `publish.yml` deploys every push to `main`.**
  - Work only on branch `policy-initiatives-and-press`.
  - Never push `main`, and never push the branch, until Jacob approves the local preview (Task 5).
- Never commit anything under `.superpowers/`. It is gitignored once Task 1 commits the `.gitignore` change.
  - `materials.md` there holds internal material.
  - Copy into the repo only the staged files this plan names.
- Never publish:
  - Medicaid Learning Lab cohort states or agencies;
  - the PBIF award amount;
  - internal proposal titles;
  - any internal results or counts.
  This applies to pages, data, tests, commit messages and code comments.
- The forbidden terms themselves must never appear in committed files either, because naming them would leak them. They live only in two gitignored pattern files, one case-insensitive extended regex per line:
  - `.superpowers/sources/2026-10-23/forbidden-global.txt`: for all committed content.
  - `.superpowers/sources/2026-10-23/forbidden-mll.txt`: for the Medicaid Learning Lab entry only.
  Tests and scans read these files. Never copy their contents into the repo.
- Nav order: `Research · Policy Initiatives · Press · Writing · CV · Contact`.
- Page titles: **"Policy Initiatives"** (`initiatives.qmd`) and **"Press"** (`press.qmd`).
- Initiative order: `The SCALE Lab`, `Connecticut Medicaid Partnership`, `Medicaid Learning Lab`, `SNAP Payment Accuracy`.
- Look: old-school, hand-built.
  - Use: serif headings, thin hairline rules, underlined links.
  - Don't use: cards, chips or tag pills, shaded boxes, icons, `box-shadow`, `border-radius`, gradients, or alternating image sides.
  - The image is always on the left, about 260px wide, 3:2, with a 1px hairline border.
  - Rows stack (image above text) at `max-width: 760px`, the breakpoint `theme.scss` already uses.
- Press marks key, verbatim: `† quotes or interviews me · ‡ written by me`. The year is never displayed.
- Use the existing theme variables (`$yale-blue`, `$sub-gray`, `$hairline`, `$ink`, `$font-family-serif`, `$font-family-sans-serif`). Add no fonts and no CSS framework.
- Every commit message ends with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Tests: from the repo root, run `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")'`. The baseline (heroes and substack) is green.

## Review Focus

1. **Phone width (about 390px).** Rows stack with the image on top. The link groups wrap. Nothing scrolls horizontally. Long URLs and long titles wrap. This is checked by the screenshot in Task 4, Step 7.
2. **Punctuation-heavy titles.** Items with `&`, `<`, curly quotes, `$400,000`, accents (El País) or a `—` dash render escaped exactly once. There must be no double escaping (`&amp;amp;`) and no broken HTML. This is checked by the escaping tests in Task 1 and Task 3.
3. **Missing optional fields.** An empty `via`, `mark`, `source` or `local` produces no stray `()`, `;` or empty `<span>`. This is checked by the optional-field tests in Task 1 and Task 3.
4. **Hosted files actually ship.** The PDFs and initiative images are referenced from raw HTML, which Quarto doesn't scan, so they must reach `_site/`. This is checked by the `_site` file checks in Task 4, Step 6.
5. **Dead or changed external links.** Some publishers return 403 to scripts but work in browsers. Anything else that isn't 2xx or 3xx is a real problem. This is checked by the link check in Task 5, Step 2.

---

### Task 1: Branch, shared HTML helper, and Press renderer with data

**Files:**
- Create: `R/html.R`, `R/press.R`, `tests/testthat/test-press.R`, `data/press.yml`
- Commit as-is: `.gitignore` (already modified to ignore `.superpowers/`), `docs/superpowers/specs/2026-10-23-policy-initiatives-and-press-design.md`, `docs/superpowers/plans/2026-10-24-policy-initiatives-and-press.md`

**Interfaces:**
- Produces: `html_escape(x: chr) -> chr`, which escapes `& < > "` with `&` first (same semantics as in `R/substack.R`; that file stays untouched).
- Produces: `md_links(x: chr) -> chr`. It escapes `x` with `html_escape`, then turns each `[text](url)` into `<a href="url">text</a>`.
- Produces: `press_sort(items: list) -> list`. The order is `tier` ascending, then the outlet sort key (lowercase, with a leading `"the "` removed), then the lowercased headline.
- Produces: `press_item_html(item: list) -> chr`, which returns one `<li>`.
- Produces: `press_page_html(items: list) -> chr`, which returns the key paragraph plus one sorted `<ul class="press-list">`.
- The data schema of `data/press.yml` is a list of `{outlet, headline, url, mark ∈ {"", "quoted", "authored"}, via, tier ∈ 1:6, topic, year}`.

- [ ] **Step 1: Create the branch and commit the docs and the gitignore**

```bash
cd ~/Library/CloudStorage/Dropbox/repos/jacobwswallace-site
git switch -c policy-initiatives-and-press
git add .gitignore docs/superpowers/specs/2026-10-23-policy-initiatives-and-press-design.md docs/superpowers/plans/2026-10-24-policy-initiatives-and-press.md
git status --short   # must show NOTHING under .superpowers/
git commit -m "docs: design and plan for Policy Initiatives and Press pages; ignore .superpowers/

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 2: Copy the staged press data**

```bash
cp .superpowers/sources/2026-10-23/press/press.curated.yml data/press.yml
```

The file holds 178 items with a header comment explaining the fields. It is the output of `.superpowers/sources/2026-10-23/scripts/curate_press.py`. That script makes these decisions:
- display names and tiers per outlet;
- marks: 21 quoted, 8 authored;
- wire press releases dropped;
- syndicated duplicates dropped;
- one `via: "Yahoo News"` row (The Guardian).

- [ ] **Step 3: Write the failing tests in `tests/testthat/test-press.R`**

Use the same `find_root()` preamble as `test-heroes.R`, then `source()` `R/html.R` and `R/press.R` from `root`. The tests:

```r
test_that("md_links escapes text and converts markdown links once", {
  expect_equal(md_links("A & B <c>"), "A &amp; B &lt;c&gt;")
  expect_equal(md_links("with [Chima Ndumele](https://ysph.yale.edu/profile/chima-ndumele/)"),
               'with <a href="https://ysph.yale.edu/profile/chima-ndumele/">Chima Ndumele</a>')
  expect_equal(md_links("[x](https://a.org/?p=1&q=2)"), '<a href="https://a.org/?p=1&amp;q=2">x</a>')
  expect_equal(md_links("up to $400,000."), "up to $400,000.")
})

it <- function(outlet, headline, tier, mark = "", via = "")
  list(outlet = outlet, headline = headline, url = "https://ex.org/a", mark = mark, via = via, tier = tier)

test_that("press_sort orders by tier, then outlet ignoring 'The', then headline", {
  s <- press_sort(list(it("NPR", "c", 2), it("USA Today", "b", 1), it("The New York Times", "z", 1), it("The New York Times", "a", 1)))
  expect_equal(vapply(s, function(i) paste(i$outlet, i$headline), ""),
               c("The New York Times a", "The New York Times z", "USA Today b", "NPR c"))
})

test_that("press_item_html: plain coverage item has bold outlet, linked headline, no marks or parens", {
  h <- press_item_html(it("Vox", "Why & how", 3))
  expect_equal(h, '<li><strong>Vox</strong> — <a href="https://ex.org/a">Why &amp; how</a></li>')
})

test_that("press_item_html: quoted, authored and via render once", {
  expect_match(press_item_html(it("NBC News", "h", 2, mark = "quoted")),
               '</a> <span class="press-mark" title="Quotes or interviews me">†</span></li>', fixed = TRUE)
  expect_match(press_item_html(it("NEJM", "h", 3, mark = "authored")),
               '<span class="press-mark" title="Written by me">‡</span>', fixed = TRUE)
  expect_match(press_item_html(it("The Guardian", "h", 1, via = "Yahoo News")),
               '</a> (via Yahoo News)</li>', fixed = TRUE)
})

test_that("press_page_html has the key once and never shows a year", {
  h <- press_page_html(list(it("NPR", "h", 2)))
  expect_match(h, '<p class="press-key">† quotes or interviews me · ‡ written by me</p>', fixed = TRUE)
  expect_equal(lengths(regmatches(h, gregexpr('<ul class="press-list">', h, fixed = TRUE))), 1L)
  expect_false(grepl("20[0-9]{2}", h))
})

test_that("data/press.yml satisfies the spec", {
  p <- yaml::read_yaml(file.path(root, "data/press.yml"))
  expect_equal(length(p), 178)
  expect_true(all(vapply(p, function(i) nzchar(i$outlet) && nzchar(i$headline) && grepl("^https?://", i$url), TRUE)))
  expect_true(all(vapply(p, function(i) i$tier %in% 1:6 && i$mark %in% c("", "quoted", "authored"), TRUE)))
  expect_false(any(grepl("EurekAlert|Newswise", vapply(p, `[[`, "", "outlet"))))
  expect_false(any(startsWith(vapply(p, `[[`, "", "headline"), "(")))
})
```

- [ ] **Step 4: Run the tests and confirm they fail**

Run: `Rscript -e 'testthat::test_file("tests/testthat/test-press.R")'`
Expected: FAIL. The error is "cannot open file …R/html.R" or "could not find function".

- [ ] **Step 5: Implement `R/html.R` (`html_escape`, `md_links`) and `R/press.R` (`press_sort`, `press_item_html`, `press_page_html`)**

- `md_links` escapes first, then applies `gsub("\\[([^]]+)\\]\\(([^)[:space:]]+)\\)", '<a href="\\2">\\1</a>', x)`. The URL is already escaped by that point, so `&` becomes `&amp;`.
- `press_item_html` builds `<li><strong>{outlet}</strong> — <a href="{url}">{headline}</a>` and then appends:
  - ` (via {via})` if `via` is non-empty;
  - ` <span class="press-mark" title="…">†/‡</span>` for a mark;
  - `</li>`.
  All text goes through `html_escape`.
- `press_page_html` returns `paste0('<p class="press-key">…</p>\n<ul class="press-list">\n', items…, '</ul>\n')`.
- Every function tolerates a `NULL` or missing `via` or `mark` (treat it as `""`).

- [ ] **Step 6: Run the tests and confirm they pass**

Run: `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")'`
Expected: all of heroes, substack and press pass.

- [ ] **Step 7: Commit**

```bash
git add R/html.R R/press.R tests/testthat/test-press.R data/press.yml
git commit -m "feat: press list data and renderer

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: Press page, nav entry and press styles

**Files:**
- Create: `press.qmd`
- Modify: `_quarto.yml` (navbar `right:` list), `assets/css/theme.scss` (append a `// Press page` block)

**Interfaces:**
- Consumes: `press_page_html(items)` from Task 1 (with `R/html.R` sourced first).

- [ ] **Step 1: Create `press.qmd`**

The front matter is `title: "Press"`. Add one `#| echo: false` / `#| output: asis` chunk that sources `R/html.R` and `R/press.R` and runs `cat(press_page_html(yaml::read_yaml("data/press.yml")))`. Add no intro text; the key line is enough.

- [ ] **Step 2: Add nav items in `_quarto.yml`**

The navbar `right:` list becomes, in order: Research (`research.qmd`), `text: "Policy Initiatives"` with `href: initiatives.qmd`, `text: "Press"` with `href: press.qmd`, Writing, CV (unchanged, `target: _blank`), Contact. `initiatives.qmd` arrives in Task 4. Until then the link is dead on this branch, which is acceptable because nothing is deployed.

- [ ] **Step 3: Append press styles to `assets/css/theme.scss`**

Use these values:
- `.press-key`: `$sub-gray`, `.95rem`.
- `.press-list`: `list-style: none; padding: 0`.
- `.press-list li`: `padding: .45rem 0; border-bottom: 1px solid $hairline; line-height: 1.45`.
- `.press-list a`: `text-decoration: underline; text-underline-offset: 2px`.
- `.press-mark`: `$yale-blue`, bold, `margin-left: .15rem`.

Do not use `border-radius`, `box-shadow` or background fills.

- [ ] **Step 4: Render and check**

Run: `quarto render press.qmd && grep -o '<li><strong>' _site/press.html | wc -l && grep -o 'class="press-mark"' _site/press.html | wc -l`
Expected: render succeeds, `178` list items, and at least 29 marks.

Run: `grep -o 'href="press.html"' _site/press.html | head -1`
Expected: the nav link is present.

- [ ] **Step 5: Commit**

```bash
git add press.qmd _quarto.yml assets/css/theme.scss
git commit -m "feat: Press page and nav entries

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Initiatives renderer and data

**Files:**
- Create: `R/initiatives.R`, `tests/testthat/test-initiatives.R`, `data/initiatives.yml`
- Copy (needed so the data tests can check that files exist): `assets/img/initiatives/{scale-lab.jpg,connecticut.png,learning-lab.jpg,snap-accuracy.png}` and `assets/docs/snap/{qc-data-workshop-summary-2026-03.pdf,evaluation-discussion-slides-2026-06.pdf,implementing-predictive-model-connecticut-2026-05.pdf}`

**Interfaces:**
- Consumes: `html_escape`, `md_links` from `R/html.R` (Task 1).
- Produces: `link_item_html(item: list) -> chr`, where `item` is `{title, url, source, local?}`.
  - Without `local`: `<li><a href="{url}">{title}</a> ({source})</li>`. Omit ` (…)` when `source` is empty.
  - With `local`: `<li><a href="{local}">{title}</a> ({source}; <a href="{url}">original</a>)</li>`. When `source` is empty, the parenthesis is ` (<a href="{url}">original</a>)`.
- Produces: `link_groups_html(groups: list) -> chr`, where each group is `{group, items}`. It returns `<div class="init-links">` containing, per group, `<div class="init-group"><h3 class="init-label">{group}</h3><ul>…</ul></div>`, then `</div>`. Groups with zero items are skipped.
- Produces: `initiative_html(x: list) -> chr`. It returns `<section class="initiative" id="{id}">` containing `<div class="init-image"><img src="{image}" alt="{alt}" loading="lazy"></div>`. When `x$fit == "contain"`, the div's class is `"init-image fit-contain"`. A missing `fit` means the default crop-to-fill and `<div class="init-text">`. Inside the text div: `<h2>{title}</h2>`, `<p class="init-meta">{md_links(meta)}</p>`, `<p>{md_links(body)}</p>`, the link groups, then `</div></section>`.
- Produces: `advisory_html(roles: list) -> chr`. It returns `<section class="advisory"><h2>Advisory roles</h2><ul>` with `<li><a href="{url}">{text}</a></li>` per role, then `</ul></section>`.
- Produces: `initiatives_page_html(d: list) -> chr`. It returns `<p class="init-intro">{md_links(d$intro)}</p>`, then every initiative, then `advisory_html(d$advisory)`.

- [ ] **Step 1: Copy the staged data and assets**

```bash
S=.superpowers/sources/2026-10-23
cp $S/initiatives/initiatives.curated.yml data/initiatives.yml
mkdir -p assets/img/initiatives assets/docs/snap
cp $S/assets-staging/img/initiatives/* assets/img/initiatives/
cp $S/assets-staging/docs/snap/* assets/docs/snap/
```

`data/initiatives.yml` has 52 links and was produced by `scripts/curate_initiatives.py`. Its copy, link selection, "In the state's words" items, RCT Palooza entry, hosted-file entries and advisory wording are all final; do not re-curate them.

- [ ] **Step 2: Write the failing tests in `tests/testthat/test-initiatives.R`**

Use the same preamble, sourcing `R/html.R` and `R/initiatives.R`. Renderer tests:

```r
li <- function(...) list(...)
test_that("link_item_html: external, empty source, hosted copy", {
  expect_equal(link_item_html(li(title = "A & B", url = "https://x.org", source = "Pub, 2026")),
               '<li><a href="https://x.org">A &amp; B</a> (Pub, 2026)</li>')
  expect_equal(link_item_html(li(title = "T", url = "https://x.org", source = "")), '<li><a href="https://x.org">T</a></li>')
  expect_equal(link_item_html(li(title = "Deck", url = "https://drive.google.com/x", source = "SCALE Lab, 2026", local = "assets/docs/snap/d.pdf")),
               '<li><a href="assets/docs/snap/d.pdf">Deck</a> (SCALE Lab, 2026; <a href="https://drive.google.com/x">original</a>)</li>')
})
test_that("link_groups_html skips empty groups and labels the rest", {
  h <- link_groups_html(list(li(group = "About", items = list(li(title = "T", url = "https://x.org", source = ""))),
                             li(group = "Empty", items = list())))
  expect_match(h, '<h3 class="init-label">About</h3>', fixed = TRUE)
  expect_false(grepl("Empty", h))
})
test_that("initiative_html renders image-left row with linked meta", {
  h <- initiative_html(li(id = "scale-lab", title = "The SCALE Lab", meta = "with [C](https://c.org)", body = "B",
                          image = "assets/img/initiatives/scale-lab.jpg", alt = "Alt", links = list()))
  expect_match(h, '^<section class="initiative" id="scale-lab"><div class="init-image"><img src="assets/img/initiatives/scale-lab.jpg" alt="Alt" loading="lazy"></div>')
  expect_match(h, '<p class="init-meta">with <a href="https://c.org">C</a></p>', fixed = TRUE)
  h2 <- initiative_html(li(id = "c", title = "T", meta = "", body = "", image = "x.png", alt = "A", fit = "contain", links = list()))
  expect_match(h2, '<div class="init-image fit-contain">', fixed = TRUE)
})
```

Data tests on `d <- yaml::read_yaml(file.path(root, "data/initiatives.yml"))`. Let `all_items` be every link item across all initiatives:
- `vapply(d$initiatives, `[[`, "", "title")` equals `c("The SCALE Lab", "Connecticut Medicaid Partnership", "Medicaid Learning Lab", "SNAP Payment Accuracy")`.
- Every item has a non-empty `title` and a `url` matching `^https://`.
- Every `url` in `all_items` is unique (`anyDuplicated == 0`).
- Every `local` and every `image` exists: `file.exists(file.path(root, …))`.
- Meta lines:
  - `grepl("Supported by Arnold Ventures", ct$meta)` is TRUE;
  - `grepl("Center for Civic Futures", snap$meta)` is TRUE;
  - `grepl("Supported by", scale$meta)` and `grepl("Supported by", mll$meta)` are both FALSE;
  - `grepl("J-PAL North America", mll$meta)` is TRUE.
- `mll_text <- paste(unlist(mll), collapse = " ")` matches `"RCT Palooza"`.
- Leak guard. This is one `test_that`, and it starts with `skip_if_not(file.exists(fg))`, where `fg <- file.path(root, ".superpowers/sources/2026-10-23/forbidden-global.txt")` and `fm` is the sibling `forbidden-mll.txt`. The skip keeps CI and other clones green. Then:
  - read each file with `readLines`;
  - collapse its lines into one pattern with `paste(..., collapse = "|")`;
  - assert `!grepl(pat_global, blob, ignore.case = TRUE, perl = TRUE)`, where `blob` is the text of `data/initiatives.yml` and `data/press.yml`;
  - assert `!grepl(pat_mll, mll_text, ignore.case = TRUE, perl = TRUE)`.
  Write no literal forbidden term in the test file.
- `length(d$advisory) == 2`, and `d$advisory[[2]]$text` contains `"Academic Work Group member, Risk Stratification, Segmentation, and Tiering (RSST) project"`.

- [ ] **Step 3: Run the tests and confirm they fail**

Run: `Rscript -e 'testthat::test_file("tests/testthat/test-initiatives.R")'`
Expected: FAIL, because `R/initiatives.R` is not found.

- [ ] **Step 4: Implement the five functions in `R/initiatives.R` per the Interfaces block**

Escape every text field with `html_escape`. Pass `meta`, `body` and `intro` through `md_links`. Treat a missing `local` or `source` as `""`.

- [ ] **Step 5: Run the tests and confirm they pass**

Run: `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")'`
Expected: all files pass.

- [ ] **Step 6: Commit**

```bash
git add R/initiatives.R tests/testthat/test-initiatives.R data/initiatives.yml assets/img/initiatives assets/docs/snap
git commit -m "feat: Policy Initiatives data, images, hosted SNAP resources and renderer

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Policy Initiatives page, resources and styles

**Files:**
- Create: `initiatives.qmd`
- Modify: `_quarto.yml` (`project.resources`), `assets/css/theme.scss` (append a `// Policy Initiatives page` block)

**Interfaces:**
- Consumes: `initiatives_page_html(d)` from Task 3.

- [ ] **Step 1: Create `initiatives.qmd`**

The front matter is `title: "Policy Initiatives"`. Add one asis chunk that sources `R/html.R` and `R/initiatives.R` and runs `cat(initiatives_page_html(yaml::read_yaml("data/initiatives.yml")))`.

- [ ] **Step 2: Ship raw-HTML assets**

Extend `project.resources` in `_quarto.yml` with `assets/img/initiatives/*` and `assets/docs/snap/*.pdf`. Keep `assets/Jacob_Wallace_CV.pdf`.

- [ ] **Step 3: Append the initiative styles to `assets/css/theme.scss`**

Use these values:
- `.init-intro`: `max-width: 46rem`.
- `.initiative`: `display: grid; grid-template-columns: 260px minmax(0, 1fr); gap: 2rem; border-top: 1px solid $hairline; padding: 2rem 0`.
- `.initiative h2`: `border: 0; margin: 0 0 .2rem; padding: 0; font-size: 1.45rem`. This overrides the global `h2` rule.
- `.init-image img`: `width: 100%; aspect-ratio: 3 / 2; object-fit: cover; border: 1px solid $hairline; display: block`.
- `.init-image.fit-contain img`: `object-fit: contain; background: #fff; padding: .4rem`. This is for the Connecticut diagram and the SNAP chart.
- `.init-meta`: `$sub-gray`, `.95rem`, `margin: 0 0 .8rem`.
- `.init-links`: `display: grid; grid-template-columns: repeat(auto-fill, minmax(16rem, 1fr)); gap: .2rem 2rem; font-size: .95rem`.
- `.init-label`: `$font-family-sans-serif`, `.74rem`, `letter-spacing: 1.4px`, uppercase, `$sub-gray`, `margin: .9rem 0 .3rem`, `border: 0`.
- `.init-links ul, .advisory ul`: `list-style: none; padding: 0; margin: 0`.
- `.init-links li`: `margin: 0 0 .35rem; line-height: 1.45; overflow-wrap: anywhere`.
- `.initiative a, .advisory a`: underline, `text-underline-offset: 2px`.
- `.advisory`: `border-top: 1px solid $hairline; padding-top: 1.5rem`, with `.advisory h2 { border: 0; }`.
- `@media (max-width: 760px) { .initiative { grid-template-columns: 1fr; gap: 1rem; } }`.

Do not use `border-radius`, `box-shadow`, background fills, icons or alternating sides.

- [ ] **Step 4: Render the whole site**

Run: `quarto render`
Expected: it succeeds with no R errors.

- [ ] **Step 5: Check the rendered structure**

Run: `grep -o '<section class="initiative"' _site/initiatives.html | wc -l`
Expected: `4`.

Run: `grep -o 'id="[a-z-]*"' _site/initiatives.html | grep -E 'scale-lab|connecticut|learning-lab|snap-accuracy'`
Expected: the four ids, in that order.

- [ ] **Step 6: Check that the hosted files shipped**

Run: `for f in assets/img/initiatives/{scale-lab.jpg,connecticut.png,learning-lab.jpg,snap-accuracy.png} assets/docs/snap/{qc-data-workshop-summary-2026-03,evaluation-discussion-slides-2026-06,implementing-predictive-model-connecticut-2026-05}.pdf; do test -f "_site/$f" && echo ok || echo "MISSING $f"; done`
Expected: seven `ok` lines and no `MISSING`.

- [ ] **Step 7: Check phone and desktop layout with screenshots**

Run:
```bash
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CH" --headless --disable-gpu --hide-scrollbars --window-size=390,3200 --screenshot=/tmp/init-390.png "file://$PWD/_site/initiatives.html"
"$CH" --headless --disable-gpu --hide-scrollbars --window-size=1280,3200 --screenshot=/tmp/init-1280.png "file://$PWD/_site/initiatives.html"
"$CH" --headless --disable-gpu --hide-scrollbars --window-size=390,2400 --screenshot=/tmp/press-390.png "file://$PWD/_site/press.html"
```

Open the three PNGs and confirm:
- at 390px, each image sits above its text, nothing is cut off at the right edge, and long titles wrap;
- at 1280px, images are on the left at about 260px, rows are separated by thin rules, and there are no boxes or shadows;
- the press list is readable at 390px.

- [ ] **Step 8: Commit**

```bash
git add initiatives.qmd _quarto.yml assets/css/theme.scss
git commit -m "feat: Policy Initiatives page

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Pre-publication checks and preview for Jacob

**Files:**
- None created. These are checks only, plus fixes if a check fails.

- [ ] **Step 1: Full test suite and render**

Run: `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")' && quarto render`
Expected: all tests pass and the render succeeds.

- [ ] **Step 2: Link check**

For every `url` in `data/initiatives.yml` and `data/press.yml`, run `curl -s -o /dev/null -L --max-time 20 -A "Mozilla/5.0" -w "%{http_code}"`.

Report every result that is not 2xx or 3xx. A 403 or 429 from these hosts is expected and acceptable:
- `healthaffairs.org`, `nejm.org`, `jamanetwork.com`, `doi.org` (to JAMA/OUP);
- `tobin.yale.edu/opportunities`, `washingtonpost.com`, `nytimes.com`;
- `ft.com`, `thehill.com`, `medpagetoday.com`, `medscape.com`, `yaledailynews.com`.

Any other 404, 410 or 5xx goes into the handoff note for Jacob. Do not silently drop rows.

- [ ] **Step 3: Leak scan of everything on the branch**

Run: `git diff main | grep -niE -f .superpowers/sources/2026-10-23/forbidden-global.txt`
Expected: no output.

Run: `git diff main -- data/ R/ tests/ '*.qmd' _quarto.yml assets/ | grep -ni 'scratchpad\|\.superpowers/sources'`
Expected: no output. The spec and plan under `docs/` may cite `.superpowers/sources` paths, which is fine.

Run: `git ls-files | grep -c '^\.superpowers/'`
Expected: `0`.

- [ ] **Step 4: Start the preview and hand it to Jacob**

Run: `quarto preview --no-browser --port 4321` in the background.

Give Jacob `http://localhost:4321/initiatives.html` and `http://localhost:4321/press.html`, the link-check exceptions from Step 2, and the screenshots from Task 4.

Do **not** merge or push. When Jacob approves: `git switch main && git merge --ff-only policy-initiatives-and-press && git push`. Pushing deploys the site, so do it only on his explicit go-ahead.
