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

test_that("merge_posts sorts newest first even when input is out of order", {
  older <- data.frame(title="old", url="u1", date=as.Date("2020-01-01"),
                      excerpt="", author="", source="personal", stringsAsFactors=FALSE)
  newer <- data.frame(title="new", url="u2", date=as.Date("2026-01-01"),
                      excerpt="", author="", source="personal", stringsAsFactors=FALSE)
  merged <- merge_posts(list(older, newer))  # deliberately oldest-first input
  expect_equal(merged$title, c("new", "old"))
})

test_that("merge_posts dedupes by url", {
  a <- parse_feed(fx, source = "scale")
  merged <- merge_posts(list(a, a))
  expect_equal(nrow(merged), 2)
})

test_that("html_escape neutralizes angle brackets and ampersands", {
  expect_equal(html_escape("a < b & c > d"), "a &lt; b &amp; c &gt; d")
})
