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
