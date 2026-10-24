# Policy Initiatives and Press pages: design

Date: 2026-10-23. Status: ready for Jacob's review.

## Why

jacobwswallace.com shows Jacob's papers well but says little about the other half of his work: running initiatives with state agencies. It also doesn't show how much press his research has drawn. Two new pages fix that.

- **Policy Initiatives.** Readers are researchers, state officials and funders, in roughly equal measure. They should come away seeing three things:
  - how broad the work is;
  - that it matters directly for policy;
  - that Jacob engages in several ways: running initiatives, doing research, and serving on advisory workgroups.
- **Press.** A long, undated list of every piece that covered his research. Volume is the point: the impression should be "a lot of serious outlets."

## Goals

- Add a **Policy Initiatives** page with four initiatives, each shown once as a row: a visual, a title, an abstract-length paragraph, then grouped links to as many public documents as exist. A short "Advisory roles" list closes the page.
- Add a **Press** page: one undated list of every public piece covering his research. Pieces that quote or interview him, and pieces he wrote, are marked subtly.
- Add both pages to the navbar.

## Non-goals

- **No Research page changes.** We tried "Selected areas of research" and a filterable list. Jacob decided to keep the current paper list exactly as it is.
- **No separate page per initiative yet.** Everything is on one page. Later, the SCALE row can link out to the SCALE website once it launches.
- **No map.** The map concept was dropped because the Medicaid Learning Lab states can't be named.
- **No Medicaid managed care initiative.** It was considered and dropped "for now." That work stays on the Research page.

## Anti-goals (failure even if it "works")

- **Looks AI-generated or templated.** No cards, chips or tag pills, shaded boxes, icons, drop shadows, gradients, or alternating left/right image rows. Jacob wants it to feel old-school: a hand-built faculty page.
- **Leaks non-public information.** The participating Learning Lab states or agencies must never appear, on this page or in linked documents. Also off limits:
  - anything sourced only from internal files: grant amounts, internal trial counts or results, unreleased announcements, internal proposal titles, personnel material.
- **Press page that reads as one story.** Excess-deaths coverage is about 60% of the list. It should sit inside the long list, not get its own headline section.

## Constraints

- **Stack.** Quarto website (`_quarto.yml`), built with R helpers in `R/` reading YAML in `data/`. Deployed by GitHub Pages via `.github/` (CNAME `jacobwswallace.com`). Follow the existing pattern: content in `data/*.yml`, rendering in an R helper, a thin `.qmd` page.
- **Style.** Use the existing theme in `assets/css/theme.scss`:
  - Yale blue `#00356B`, light `#286dc0`;
  - Source Serif 4 for headings, Source Sans 3 for body;
  - hairline `#e9ecf0`.
  Add new rules to `theme.scss`; do not add new fonts or a CSS framework.
- **Mobile.** Must work on phones. Image-left rows stack to image-above.
- **Facts.** Every fact and link must be public. The source materials label each fact; the builder publishes only items labeled PUBLIC (see "Sources"). This repo is public, so nothing non-public goes in committed files either, including this document and commit messages.

## Decided: Policy Initiatives page

- **File and name.** `initiatives.qmd`, title and nav label **"Policy Initiatives"**.
- **Navbar order.** Research · Policy Initiatives · Press · Writing · CV · Contact.
- **Intro.** One or two sentences at the top. (Superseded; see the Revision section.)
- **Initiatives**, in this exact order:
  1. **The SCALE Lab**
  2. **Connecticut Medicaid Partnership**
  3. **Medicaid Learning Lab**
  4. **SNAP Payment Accuracy**
- **Row format.** Each initiative is one row:
  - an image on the left, about 260px wide, 3:2, with a thin border; the image is always on the left;
  - on the right: the title (serif, Yale blue), a one-line meta line (partners, role), an abstract-length paragraph (60–100 words), then grouped link lists.
  - Rows are separated by a thin rule. There is no picture-tile row at the top; Jacob removed it.
- **Link groups.** Small uppercase labels such as About, Papers, News & features, Events & presentations, Announcements, Trials & registrations, Related writing. Show only the groups an initiative has. Links are underlined text in "Title (Publisher, Year)" form.
- **Advisory roles.** A short plain list after the four rows:
  - Health economist, New York State Medicaid Evidence-Based Benefit Review Advisory Committee (appointed 2024, term to 2027). Public on the NY DOH roster.
  - "Academic Work Group member, Risk Stratification, Segmentation, and Tiering (RSST) project, California Department of Health Care Services". Jacob gave this wording. It is public: link it to the DHCS RSST Transparency Document (July 2025), https://www.dhcs.ca.gov/wp-content/uploads/2025/10/RSST-Transparency-Document-July-2025.pdf
- **Funders: name only the main one, and only where there is one.** Jacob decided:
  - **The SCALE Lab:** no funder list. SCALE has no dedicated funder.
  - **Connecticut Medicaid Partnership:** Arnold Ventures.
  - **Medicaid Learning Lab:** no funder; just note the partnership with J-PAL North America.
  - **SNAP Payment Accuracy:** Center for Civic Futures (Public Benefit Innovation Fund).
  Put the funder in the meta line, e.g. "With CT DSS · Supported by Arnold Ventures".
- **Content per initiative** (draft copy is in the mockup; Jacob can edit wording):
  - **The SCALE Lab.**
    - Meta line: "State Collaborations to Advance LEarning · Yale School of Public Health · co-directed with Chima Ndumele". Chima's name links to https://ysph.yale.edu/profile/chima-ndumele/.
    - Paragraph covers: a research and policy institute; hands-on partnerships with state policymakers; embedded data scientists with state credentials; test-and-learn; team of "about a dozen". No funder list.
    - Until the SCALE site launches, the "About" link is the YSPH magazine feature.
    - Use the name "The SCALE Lab" for the heading and first mention. "SCALE" alone is fine elsewhere.
  - **Connecticut Medicaid Partnership.**
    - **Public statements from DSS.** Include links to public instances of DSS officials crediting or praising the work, in their own group. Use only public URLs. Verified candidates, all in `.superpowers/sources/2026-10-23/initiatives/ct-praise-and-visuals.md`:
      - Deputy Commissioner Hadler at MAPOC, May 8 2026. This is the strongest: the slide and the meeting summary both name "Yale University's SCALE Lab".
      - DSS and Halsey at MAPOC, Mar 14 2025: "DSS and the Tobin Center… are modeling". Covered by CT News Junkie.
      - Halsey in Yale News, Dec 20 2024: "actionable intelligence".
      - Woolston in Yale News, June 1 2023.
      - Commissioner Barton Reeves' testimony, Feb 27 2025, p.10, on the Test & Learn initiative. It does not name Yale.
      - Excluded: a radio segment and leads with no public source. Jacob decided this.
      - Label the group neutrally, e.g. "In the state's words" or "Presentations by DSS", because most of these items credit the work rather than praise it. That's the builder's call.
    - **Story to tell:** Spring 2023 Lamont administration–Yale collaboration (with the Tobin Center and J-PAL North America). Team embedded at DSS (HUSKY Health and SNAP). Co-designed randomized evaluations of care management, outreach and take-up. Rapid-cycle analysis.
  - **Medicaid Learning Lab.**
    - Meta line: "With J-PAL North America · Scientific Advisor".
    - Paragraph covers: developed by J-PAL North America with SCALE; builds agencies' test-and-learn capacity; curriculum, peer learning and technical assistance; evaluation awards up to $400,000; launched June 2026, convened at MIT in September 2026.
    - **No states named.**
    - **RCT Palooza.** Mention and link it here, by that name. Jacob decided this. Link the June 1 2023 Yale News story "At Yale, scholars and policymakers unite to improve state Medicaid program". The name is used publicly for the first time on this site.
  - **SNAP Payment Accuracy.** From 2027 states' cost share depends on payment error rates. With Georgetown's Better Government Lab, working with five states (not named) on predictive models that flag error-prone cases without adding burden for families. Selected in round 2 of the Public Benefit Innovation Fund. (Jacob later added the award amount himself; see the Revision section.)
- **SNAP Payment Accuracy resources.** Jacob wants the team's publicly posted SNAP PER resources made available from the site. The inventory is `.superpowers/sources/2026-10-23/snap-resources/inventory.csv`: 20 items, with files in `.superpowers/sources/2026-10-23/snap-resources/files/`.
  - **Rehost on the site.** This is the builder's call; Jacob can override. Rehost only the items credited to SCALE/Yale, in `assets/docs/snap/`, each with a "Originally posted by…" link next to it:
    - QC Data Workshop Summary (Mar 2 2026)
    - Evaluation discussion slides (June 2026)
    - "Is This Working?" (link the SNRN original; it's a web post, not a file)
    - "SNAP PER Analytics Workgroup: Implementing a predictive model within Connecticut" (Lollo, May 11 2026). Jacob approved rehosting it.
  - **Link to the original, don't rehost:**
    - BGL-only work: the feature-engineering summary, the buffers brief, the Promising Practices posts, the state workbooks (333 MB), the `giannella/snap_qc` repo, the QC Error Viewer and the Cost Share tool. None of it credits SCALE, and none of it states a license except the repo.
    - The preauthorization checklist, which is a state agency's form.
  - **Risk Assessment Tools video (May 21 2026):** not included. Jacob decided this.
  - **Group label:** "Resources" in the SNAP row, with the BGL hub page (https://www.bettergovernmentlab.org/resources/snap) as the lead link.
- **Links.** Jacob wants **as many public documents as possible** in each initiative: papers, YSPH write-ups, J-PAL pages, CCF, RCT Palooza, anything written about the Connecticut model. The verified list is `links.csv` (see Sources). Include every verified link; only partially verified ones go in after the builder confirms they resolve.

## Decided: Press page

- **File and name.** `press.qmd`, title and nav label **"Press"**.
- **Scope.** Everything that covered his research, including pieces that don't name him. Jacob chose this. Also included: pieces that quote or interview him, pieces he wrote (Health Affairs Forefront, NEJM Perspective, blogs), and audio/video.
- **Undated.** Store the year in the data, but don't display it.
- **Format.** One long list, not split into sections by paper or by type. Each entry is the outlet in bold, then the linked headline.
- **Marks.** A one-line key at the top: "† quotes or interviews me · ‡ written by me".
- **Already on the site.** The 16 press links on the Research page (per-paper "Press" toggles) stay as they are, and are also in the Press list.

## Builder's calls (Jacob can override)

- **Press order:** by outlet prominence, then alphabetically:
  1. national papers and wires
  2. national broadcast and audio
  3. national magazines and digital outlets
  4. health and policy trade press
  5. regional and local
  6. institutional (Yale, Tobin, J-PAL, NY Fed)
- **Press scope:** pieces checked only through a search snippet, a reprint or Altmetric are included. The 3 rows with verified = "no" are excluded.
- **Syndicated copies:** keep the original only.
- **Wire press releases** (EurekAlert!, Newswise) are not press coverage and are left off. This was a planning-time call.
- **Images (all chosen by Jacob on 2026-10-24):**
  - **The SCALE Lab:** the public Yale News photo of Jacob and Chima at the lectern opening the 2024 Northeast Medicaid Research Symposium (`ChimaJacobRoomView`, Yale News, Dec 20 2024). It is cropped 3:2 toward the lectern and the screen.
  - **Connecticut Medicaid Partnership:** Jacob's screenshot of the team's "THE MODEL: A rapid-cycle learning model" (Plan–Do–Study–Act) diagram. Show it whole, uncropped (`fit: contain`).
  - **Medicaid Learning Lab:** the J-PAL North America photo of Jacob on a panel at the Learning Lab launch, with "Connecticut's test-and-learn model" on screen.
  - **SNAP Payment Accuracy:** Jacob's screenshot of the chart that combines the state and federal models' predictions into one risk score. Show it whole (`fit: contain`).
  - The earlier drawn-SVG and symposium-discussion options are dropped. Staged files are in `.superpowers/sources/2026-10-23/assets-staging/img/initiatives/`, and the originals are in `initiatives/new-image-originals/`.
- **Data files:**
  - `data/initiatives.yml`: per initiative, `title`, `meta`, `image`, `alt`, `body`, and `links` grouped by label.
  - `data/press.yml`: per item, `outlet`, `headline`, `url`, `type`, `topic`, `year`, `mark`.
  - A small R helper renders each, matching `R/pubs.R` style.
- **Advisory roles:** live at the bottom of Policy Initiatives, since there is no separate policy page.
- **Nothing goes live without Jacob's approval.** `publish.yml` deploys on every push to `main`, so all work happens on a feature branch. Jacob reviews a local preview (`quarto preview`) and approves before anything is merged. Anything still pending at that point (for example, an unconfirmed advisory role or photo) is left out and added in a later change.
- **Syndicated-only press rows:** if the only working link is a copy, list the piece under the original outlet's name, link the copy, and add "(via Yahoo News)" or similar. Rows whose headline is a guess (shown in parentheses in the CSV) are left out until a real headline is confirmed.
- **Link selection from `links.csv`:**
  - Include all "yes" rows and the DOI-confirmed "partial" rows.
  - Where the CSV notes say "use one" (the same piece posted in two places), keep the original publisher's copy.
  - Leave out:
    - Tobin job postings (they get taken down);
    - pieces that don't credit Yale or SCALE (StateScoop, the BGL technical brief);
    - the Risk Assessment Tools video. The other two SNRN Drive files (the workshop summary and the Connecticut deck) are rehosted under SNAP resources.
  - Maine items under the Learning Lab are framed as example evidence and must not read as cohort participation.
  - Fix the 2022 Forefront title: "…Can Minimize Churn".
- **SCALE row has no "Current work" group.** The other three initiatives are directly below it on the same page.

## Excluded by Jacob

- The Risk Assessment Tools video and the CT Public "Wheelhouse" segment.
- DSS leads that have no public source.
- Four press items whose publication could not be confirmed.

Nothing is pending. Everything the build needs is decided.

## Sources

- **Approved mockup:** `.superpowers/brainstorm/32002-1792784975/content/policy-initiatives-v3.html` (gitignored; local only). The images it uses are in the same folder.
- **Initiative facts,** each labeled PUBLIC / PUBLIC-PENDING / INTERNAL / DO-NOT-PUBLISH: `.superpowers/sources/2026-10-23/initiatives/materials.md`
- **Initiative links:** `.superpowers/sources/2026-10-23/initiatives/links.csv`: 70 rows across the four initiatives, every URL checked on 2026-10-23 (58 "yes", 12 "partial"). Partial rows are journal DOIs confirmed via Crossref, which are fine to use, and Tobin job postings.
- **Press list:** `.superpowers/sources/2026-10-23/press/press.csv` (190 rows) and `press-notes.md`
- **Candidate images:** `.superpowers/sources/2026-10-23/initiatives/img/`. Use only the four images chosen above; the folder also holds internal or not-yet-released images that must not be published.
- **SNAP resources:** `.superpowers/sources/2026-10-23/snap-resources/` (`inventory.csv`, `README.md`, `files/`). The 333 MB BGL state workbooks were not kept; they are linked, not rehosted.

Everything under `.superpowers/` is gitignored and lives only in Jacob's Dropbox copy. `materials.md` in particular contains internal and do-not-publish material and must never be committed. Move only public, needed content into `data/` and `assets/` as part of the build.

## Revision, 2026-10-24 (after Jacob reviewed the first build)

Jacob found the link lists too long. The changes below replace the earlier link rules wherever they conflict.

- **Fewer links up front.**
  - Featured links sit above the dropdown, set per initiative by Jacob:
    - The SCALE Lab: the YSPH feature and "SCALE Lab website (coming soon)".
    - Connecticut: none.
    - Learning Lab: only "Letter from the Scientific Advisor, Jacob Wallace".
    - SNAP: only the Center for Civic Futures announcement.
  - A "+" dropdown (a native `<details>` element) lists every group. Its summary is just the group names, e.g. "+ About · News & features · Website", with no "More".
- **Intro and body copy:** Jacob now edits these directly in `data/initiatives.yml`. On 2026-10-24 he cleared the PBIF award amount for publication.
- **Groups per initiative**, in this order:
  - **The SCALE Lab:** About · News & features · Website. Website reads "SCALE Lab website (coming soon)", unlinked. No research papers, because SCALE is the umbrella for most of Jacob's work.
  - **Connecticut Medicaid Partnership:** Trials & registrations · News & features · In the state's words. Each "In the state's words" item shows its most relevant quote, verified word for word against the source, before the link.
  - **Medicaid Learning Lab:** About · News & features · Related research.
    - About opens with "Letter from the Scientific Advisor", linked to the June 2026 J-PAL North America newsletter PDF, followed by J-PAL's own mentions of the launch (the program page and the February 2026 newsletter).
    - News & features holds the affiliate spotlight, RCT Palooza and the MIT convening.
  - **SNAP Payment Accuracy:** News & features (the Center for Civic Futures announcement) · Resources. Resources holds only items that explicitly credit SCALE: SCALE's Safety Net Response Network page, the three hosted files and "Is This Working?". Better Government Lab-only resources are removed.
- **Images.**
  - The image column is 520px, double the earlier width. Images are re-exported at about 1,400px so they stay sharp.
  - Rows stack below 1,000px, because two 520px-plus columns no longer fit there.

## Revision, 2026-10-24: Press page (after Jacob's review)

These changes replace the earlier Press rules ("Undated", ordering by prominence tier, rules between items).

- **Cut:**
  - critical or hostile coverage;
  - fringe, partisan and very small outlets (Red Bluff Daily News, Truth or Fiction, Political Wire, WhoWhatWhy, Northwest Progressive Institute, Alternet, Florida Bulldog, Edzard Ernst, Washington Examiner, Mediaite, Volksverpetzer, American Council on Science and Health);
  - one item whose headline was a placeholder (Cardiovascular Business).
- **Kept** (Jacob decided):
  - TV links that open a whole episode;
  - pieces that cover the work without naming him;
  - Yale and partner items.
- **Dated, newest first.** Pieces sit under plain year headings, each with a narrow gray date column ("Jul 24", or the month alone when the day is unknown). Dates come from the research notes and, where those had none, from the live pages.
- **Look:** no horizontal rules, only spacing. Same outlet-and-headline line, with the † / ‡ marks.
