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
source(file.path(root, "R/html.R"))
source(file.path(root, "R/initiatives.R"))

li <- function(...) list(...)
test_that("link_item_html: external, empty source, hosted copy", {
  expect_equal(link_item_html(li(title = "A & B", url = "https://x.org", source = "Pub, 2026")),
               '<li><a href="https://x.org">A &amp; B</a> (Pub, 2026)</li>')
  expect_equal(link_item_html(li(title = "T", url = "https://x.org", source = "")), '<li><a href="https://x.org">T</a></li>')
  expect_equal(link_item_html(li(title = "Deck", url = "https://drive.google.com/x", source = "SCALE Lab, 2026", local = "assets/docs/snap/d.pdf")),
               '<li><a href="assets/docs/snap/d.pdf">Deck</a> (SCALE Lab, 2026; <a href="https://drive.google.com/x">original</a>)</li>')
})
test_that("link_item_html: a quote item shows the quote first, then a linked source line", {
  expect_equal(link_item_html(li(quote = "We want \"actionable\" intelligence & more", title = "Yale News story", url = "https://n.org/a", source = "Bill Halsey, 2024")),
               '<li class="init-quote-item"><p class="init-quote">\u201cWe want &quot;actionable&quot; intelligence &amp; more\u201d</p><p class="init-attrib">\u2014 <a href="https://n.org/a">Yale News story</a> (Bill Halsey, 2024)</p></li>')
})
test_that("link_item_html: an item without a url shows its title and note, unlinked", {
  expect_equal(link_item_html(li(title = "SCALE Lab website", note = "coming soon")),
               '<li>SCALE Lab website <span class="init-note">(coming soon)</span></li>')
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
test_that("initiative_html shows featured links, then a + dropdown naming every group", {
  links <- list(li(group = "About", items = list(li(title = "F1", url = "https://a.org", source = "", featured = TRUE), li(title = "A2", url = "https://b.org", source = ""))),
                li(group = "Website", items = list(li(title = "Site", note = "coming soon", featured = TRUE))))
  h <- initiative_html(li(id = "s", title = "T", meta = "", body = "", image = "x.jpg", alt = "A", links = links))
  expect_match(h, '<ul class="init-featured"><li><a href="https://a.org">F1</a></li><li>Site <span class="init-note">(coming soon)</span></li></ul>', fixed = TRUE)
  expect_match(h, '<details class="init-more"><summary>About \u00b7 Website</summary><div class="init-links">', fixed = TRUE)
  expect_match(h, '</div></details></div></section>', fixed = TRUE)
})

d <- yaml::read_yaml(file.path(root, "data/initiatives.yml"))
by_title <- setNames(d$initiatives, vapply(d$initiatives, `[[`, "", "title"))
all_items <- unlist(lapply(d$initiatives, function(i) unlist(lapply(i$links, `[[`, "items"), recursive = FALSE)), recursive = FALSE)
mll <- by_title[["Medicaid Learning Lab"]]
mll_text <- paste(unlist(mll), collapse = " ")

test_that("initiatives appear in the approved order", {
  expect_equal(names(by_title), c("The SCALE Lab", "Connecticut Medicaid Partnership", "Medicaid Learning Lab", "SNAP Payment Accuracy"))
})

test_that("every link has a title and an https url (or a note), and each url appears once on the page", {
  linked <- Filter(function(i) !is.null(i$url), all_items)
  unlinked <- Filter(function(i) is.null(i$url), all_items)
  urls <- vapply(linked, `[[`, "", "url")
  expect_true(all(vapply(all_items, function(i) nzchar(i$title), TRUE)))
  expect_true(all(grepl("^https://", urls)))
  expect_true(all(vapply(unlinked, function(i) nzchar(i$note), TRUE)))
  expect_equal(anyDuplicated(urls), 0L)
})

groups_of <- function(t) vapply(by_title[[t]]$links, `[[`, "", "group")
items_in <- function(t, g) Filter(function(x) x$group == g, by_title[[t]]$links)[[1]]$items

test_that("each initiative has exactly the groups Jacob asked for, in order", {
  expect_equal(groups_of("The SCALE Lab"), c("About", "News & features", "Website"))
  expect_equal(groups_of("Connecticut Medicaid Partnership"), c("Trials & registrations", "News & features", "In the state's words"))
  expect_equal(groups_of("Medicaid Learning Lab"), c("About", "News & features", "Related research"))
  expect_equal(groups_of("SNAP Payment Accuracy"), c("News & features", "Resources"))
})

featured_titles <- function(t) {
  its <- unlist(lapply(by_title[[t]]$links, `[[`, "items"), recursive = FALSE)
  vapply(Filter(function(x) isTRUE(x$featured), its), `[[`, "", "title")
}

test_that("above the fold: SCALE two links, Connecticut none, Learning Lab only the letter, SNAP only the CCF announcement", {
  expect_equal(length(featured_titles("The SCALE Lab")), 2L)
  expect_equal(length(featured_titles("Connecticut Medicaid Partnership")), 0L)
  expect_equal(featured_titles("Medicaid Learning Lab"), "Letter from the Scientific Advisor, Jacob Wallace")
  expect_equal(length(featured_titles("SNAP Payment Accuracy")), 1L)
  expect_match(featured_titles("SNAP Payment Accuracy"), "Center for Civic Futures", fixed = TRUE)
})

test_that("the page has an intro", {
  expect_true(is.character(d$intro) && nzchar(trimws(d$intro)))
})

test_that("every 'In the state's words' item carries its most relevant quote", {
  q <- items_in("Connecticut Medicaid Partnership", "In the state's words")
  expect_gt(length(q), 0)
  expect_true(all(vapply(q, function(x) !is.null(x$quote) && nchar(x$quote) > 40, TRUE)))
})

test_that("Connecticut lists the four pre-registered trials on OSF", {
  urls <- vapply(items_in("Connecticut Medicaid Partnership", "Trials & registrations"), `[[`, "", "url")
  expect_true(all(c("https://osf.io/epq5v", "https://osf.io/78znw", "https://osf.io/ypcjg", "https://osf.io/dsz6g") %in% urls))
})

test_that("the Learning Lab's About section opens with the Scientific Advisor's letter", {
  first <- items_in("Medicaid Learning Lab", "About")[[1]]
  expect_equal(first$title, "Letter from the Scientific Advisor, Jacob Wallace")
  expect_match(first$url, "Launching%20the%20Medicaid%20Learning%20Lab", fixed = TRUE)
})

test_that("the SCALE website is listed as coming soon, unlinked", {
  w <- items_in("The SCALE Lab", "Website")
  expect_equal(length(w), 1L)
  expect_null(w[[1]]$url)
})

test_that("SNAP resources are explicitly SCALE resources, not BGL-only", {
  r <- items_in("SNAP Payment Accuracy", "Resources")
  hosts <- vapply(r, function(x) x$url, "")
  expect_false(any(grepl("bettergovernmentlab|giannella|shinyapps|digitalgovernmenthub", hosts)))
  expect_true(any(grepl("safetynetresponse.org/blog/attribution/yale-scale-lab", hosts, fixed = TRUE)))
})

test_that("every hosted copy and every image exists in the repo", {
  locals <- unlist(lapply(all_items, function(i) i$local))
  images <- vapply(d$initiatives, `[[`, "", "image")
  expect_true(all(file.exists(file.path(root, c(locals, images)))))
})

test_that("meta lines name only the main funder, and only where there is one", {
  expect_true(grepl("Supported by Arnold Ventures", by_title[["Connecticut Medicaid Partnership"]]$meta))
  expect_true(grepl("Center for Civic Futures", by_title[["SNAP Payment Accuracy"]]$meta))
  expect_false(grepl("Supported by", by_title[["The SCALE Lab"]]$meta))
  expect_false(grepl("Supported by", mll$meta))
  expect_true(grepl("J-PAL North America", mll$meta))
})

test_that("Medicaid Learning Lab links RCT Palooza", {
  expect_match(mll_text, "RCT Palooza", fixed = TRUE)
})

test_that("leak guard: no forbidden terms in committed data (patterns kept outside the repo)", {
  fg <- file.path(root, ".superpowers/sources/2026-10-23/forbidden-global.txt")
  fm <- file.path(root, ".superpowers/sources/2026-10-23/forbidden-mll.txt")
  skip_if_not(file.exists(fg) && file.exists(fm))
  pat_global <- paste(readLines(fg), collapse = "|")
  pat_mll <- paste(readLines(fm), collapse = "|")
  blob <- paste(c(readLines(file.path(root, "data/initiatives.yml")), readLines(file.path(root, "data/press.yml"))), collapse = "\n")
  expect_false(grepl(pat_global, blob, ignore.case = TRUE, perl = TRUE))
  expect_false(grepl(pat_mll, mll_text, ignore.case = TRUE, perl = TRUE))
})

test_that("leak guard: committed design docs carry no internal-process details (patterns kept outside the repo)", {
  fd <- file.path(root, ".superpowers/sources/2026-10-23/forbidden-docs.txt")
  skip_if_not(file.exists(fd))
  pat_docs <- paste(readLines(fd), collapse = "|")
  docs <- list.files(file.path(root, "docs/superpowers"), pattern = "2026-10-2[34].*\\.md$", recursive = TRUE, full.names = TRUE)
  expect_gt(length(docs), 0)
  for (f in docs) expect_false(grepl(pat_docs, paste(readLines(f), collapse = "\n"), ignore.case = TRUE, perl = TRUE), info = basename(f))
})

test_that("advisory roles list New York and the California RSST work group", {
  expect_equal(length(d$advisory), 2L)
  expect_match(d$advisory[[2]]$text, "Academic Work Group member, Risk Stratification, Segmentation, and Tiering (RSST) project", fixed = TRUE)
})
