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
