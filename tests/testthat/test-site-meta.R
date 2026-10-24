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
site <- yaml::read_yaml(file.path(root, "_quarto.yml"))$website

# Width and height from a PNG's IHDR chunk.
png_size <- function(path) {
  b <- readBin(path, "raw", 24)
  stopifnot(identical(b[2:4], charToRaw("PNG")))
  as_int <- function(x) sum(as.integer(x) * 256^(3:0))
  c(as_int(b[17:20]), as_int(b[21:24]))
}

test_that("shared links get a preview: description, Open Graph and a large Twitter card", {
  expect_match(site$description, "Medicaid")
  expect_false(is.null(site[["open-graph"]]))
  expect_equal(site[["twitter-card"]][["card-style"]], "summary_large_image")
})

test_that("the preview image exists at 1200x630", {
  img <- file.path(root, site$image)
  expect_true(file.exists(img), info = site$image)
  expect_equal(png_size(img), c(1200, 630))
})

test_that("the site has a square tab icon", {
  ico <- file.path(root, site$favicon)
  expect_true(file.exists(ico), info = site$favicon)
  sz <- png_size(ico)
  expect_equal(sz[1], sz[2])
})

test_that("the homepage links row includes an email link", {
  idx <- readLines(file.path(root, "index.qmd"))
  links <- idx[grep("Google Scholar", idx)]
  expect_true(any(grepl("mailto:jacob.wallace@yale.edu", links, fixed = TRUE)))
})

front_matter <- function(page) {
  x <- readLines(file.path(root, page))
  yaml::yaml.load(paste(x[2:(which(x == "---")[2] - 1)], collapse = "\n"))
}

test_that("the homepage previews with the share card, not the first figure on the page", {
  expect_equal(front_matter("index.qmd")$image, site$image)
})

test_that("the research page has a preview description without one shown on the page", {
  fm <- front_matter("research.qmd")
  expect_null(fm$description)
  expect_match(fm[["open-graph"]]$description, "Medicaid")
  expect_match(fm[["twitter-card"]]$description, "Medicaid")
})
