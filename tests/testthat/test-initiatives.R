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

d <- yaml::read_yaml(file.path(root, "data/initiatives.yml"))
by_title <- setNames(d$initiatives, vapply(d$initiatives, `[[`, "", "title"))
all_items <- unlist(lapply(d$initiatives, function(i) unlist(lapply(i$links, `[[`, "items"), recursive = FALSE)), recursive = FALSE)
mll <- by_title[["Medicaid Learning Lab"]]
mll_text <- paste(unlist(mll), collapse = " ")

test_that("initiatives appear in the approved order", {
  expect_equal(names(by_title), c("The SCALE Lab", "Connecticut Medicaid Partnership", "Medicaid Learning Lab", "SNAP Payment Accuracy"))
})

test_that("every link has a title and an https url, and each url appears once on the page", {
  urls <- vapply(all_items, `[[`, "", "url")
  expect_true(all(vapply(all_items, function(i) nzchar(i$title), TRUE)))
  expect_true(all(grepl("^https://", urls)))
  expect_equal(anyDuplicated(urls), 0L)
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
