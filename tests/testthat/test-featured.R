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
feat <- yaml::read_yaml(file.path(root, "data/featured.yml"))

test_that("homepage 'Recent research' shows REStat, then JEP, then the AER privatization paper", {
  titles <- vapply(feat, `[[`, "", "title")
  expect_equal(titles, c("The Great Equalizer: Medicare and the Geography of Consumer Financial Strain",
                         "Understanding Medicaid Managed Care: The Procured Competition Model",
                         "Private Provision of Public Services: Evidence from Random Assignment in Medicaid"))
})

test_that("every card has a finding, an existing image and a link", {
  for (f in feat) {
    expect_true(nzchar(f$finding), info = f$title)
    expect_true(file.exists(file.path(root, f$image)), info = f$image)
    expect_match(f$url, "^https://", info = f$title)
  }
})

test_that("the JEP card shows Figure 3 (effects of private managed care on spending)", {
  jep <- Filter(function(f) grepl("Procured Competition", f$title), feat)[[1]]
  expect_equal(jep$image, "assets/img/featured/jep-fig3-managed-care-spending-effects.png")
})
