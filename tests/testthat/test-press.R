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
source(file.path(root, "R/press.R"))

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
