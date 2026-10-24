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

it <- function(outlet, headline, date, mark = "", via = "")
  list(outlet = outlet, headline = headline, url = "https://ex.org/a", mark = mark, via = via, date = date)

test_that("press_sort is reverse chronological; month-only and year-only dates fall after dated items", {
  s <- press_sort(list(it("A", "a", "2023-07-24"), it("B", "b", "2023"), it("C", "c", "2026-08-03"), it("D", "d", "2023-07"), it("E", "e", "2023-07-25")))
  expect_equal(vapply(s, `[[`, "", "outlet"), c("C", "E", "A", "D", "B"))
})

test_that("press_date_label shows month and day, month only, or nothing", {
  expect_equal(press_date_label("2023-07-04"), "Jul 4")
  expect_equal(press_date_label("2023-12"), "Dec")
  expect_equal(press_date_label("2013"), "")
})

test_that("press_item_html: date column, bold outlet, linked headline, no marks or parens", {
  h <- press_item_html(it("Vox", "Why & how", "2025-10-09"))
  expect_equal(h, '<li><span class="press-date">Oct 9</span><span class="press-entry"><strong>Vox</strong> — <a href="https://ex.org/a">Why &amp; how</a></span></li>')
})

test_that("press_item_html: quoted, authored and via render once", {
  expect_match(press_item_html(it("NBC News", "h", "2022-10-06", mark = "quoted")),
               '</a> <span class="press-mark" title="Quotes or interviews me">†</span></span></li>', fixed = TRUE)
  expect_match(press_item_html(it("NEJM", "h", "2022-05-12", mark = "authored")),
               '<span class="press-mark" title="Written by me">‡</span>', fixed = TRUE)
  expect_match(press_item_html(it("The Guardian", "h", "2026-05-29", via = "Yahoo News")),
               '</a> (via Yahoo News)</span></li>', fixed = TRUE)
})

test_that("press_page_html: key once, then one plain heading and list per year, newest year first", {
  h <- press_page_html(list(it("NPR", "h", "2023-07-25"), it("Vox", "v", "2025-10-09"), it("Axios", "x", "2023-07-27")))
  expect_match(h, '<p class="press-key">† quotes or interviews me · ‡ written by me</p>', fixed = TRUE)
  years <- regmatches(h, gregexpr('<h2 class="press-year">[0-9]{4}</h2>', h))[[1]]
  expect_equal(years, c('<h2 class="press-year">2025</h2>', '<h2 class="press-year">2023</h2>'))
  expect_equal(lengths(regmatches(h, gregexpr('<ul class="press-list">', h, fixed = TRUE))), 2L)
  expect_lt(regexpr("Axios", h, fixed = TRUE), regexpr("NPR", h, fixed = TRUE))
})

press_data <- yaml::read_yaml(file.path(root, "data/press.yml"))
host_of <- function(u) sub("^(www|news)\\.", "", tolower(sub("^https?://([^/]+).*$", "\\1", u)))

test_that("pieces read on a syndication or third-party site say where (via ...)", {
  copy_hosts <- c("yahoo.com", "msn.com", "orthoatlanta.com")
  copies <- Filter(function(i) host_of(i$url) %in% copy_hosts && !grepl("^(Yahoo|MSN)", i$outlet), press_data)
  expect_gt(length(copies), 0)
  for (i in copies) expect_true(nzchar(i$via), info = i$outlet)
})

test_that("outlet labels match the paper actually linked (Sentinel columns)", {
  sun <- Filter(function(i) host_of(i$url) == "sun-sentinel.com", press_data)
  expect_gt(length(sun), 0)
  for (i in sun) expect_equal(i$outlet, "South Florida Sun-Sentinel")
})

test_that("data/press.yml satisfies the spec", {
  p <- yaml::read_yaml(file.path(root, "data/press.yml"))
  expect_equal(length(p), 163)
  expect_true(all(vapply(p, function(i) nzchar(i$outlet) && nzchar(i$headline) && grepl("^https?://", i$url), TRUE)))
  expect_true(all(vapply(p, function(i) i$mark %in% c("", "quoted", "authored"), TRUE)))
  expect_true(all(grepl("^[0-9]{4}(-[0-9]{2}(-[0-9]{2})?)?$", vapply(p, function(i) as.character(i$date), ""))))
  expect_false(any(grepl("EurekAlert|Newswise", vapply(p, `[[`, "", "outlet"))))
  expect_false(any(startsWith(vapply(p, `[[`, "", "headline"), "(")))
})

test_that("critical, fringe and placeholder items Jacob cut stay cut", {
  outlets <- vapply(press_data, `[[`, "", "outlet")
  cut <- c("Zero Hedge", "Red Bluff Daily News", "Truth or Fiction", "Political Wire", "WhoWhatWhy", "Northwest Progressive Institute",
           "Alternet", "Florida Bulldog", "Edzard Ernst", "Washington Examiner", "Mediaite", "Volksverpetzer",
           "American Council on Science and Health", "Cardiovascular Business")
  expect_false(any(outlets %in% cut))
})
