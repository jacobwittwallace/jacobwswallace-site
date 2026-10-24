# Render the Press page from data/press.yml (requires R/html.R).
or_blank <- function(x) if (is.null(x)) "" else x

# date is "YYYY-MM-DD", "YYYY-MM" or "YYYY"; missing parts count as 0 so they sort after dated items.
date_parts <- function(date) {
  p <- as.integer(strsplit(as.character(date), "-", fixed = TRUE)[[1]])
  c(p, rep(0L, 3 - length(p)))
}

press_date_label <- function(date) {
  p <- date_parts(date)
  if (p[2] == 0) "" else if (p[3] == 0) month.abb[p[2]] else sprintf("%s %d", month.abb[p[2]], p[3])
}

# Newest first; same-day pieces by outlet, with "The New York Times" filed under N.
press_sort <- function(items) {
  key <- vapply(items, function(i) sum(date_parts(i$date) * c(10000L, 100L, 1L)), 0)
  outlet <- vapply(items, function(i) sub("^the ", "", tolower(i$outlet)), "")
  items[order(-key, outlet, method = "radix")]
}

press_item_html <- function(item) {
  via <- or_blank(item$via)
  mark <- switch(or_blank(item$mark),
    quoted = ' <span class="press-mark" title="Quotes or interviews me">†</span>',
    authored = ' <span class="press-mark" title="Written by me">‡</span>',
    "")
  sprintf('<li><span class="press-date">%s</span><span class="press-entry"><strong>%s</strong> — <a href="%s">%s</a>%s%s</span></li>',
          press_date_label(item$date), html_escape(item$outlet), html_escape(item$url), html_escape(item$headline),
          if (nzchar(via)) sprintf(" (via %s)", html_escape(via)) else "", mark)
}

# One plain heading and list per year, newest year first.
press_page_html <- function(items) {
  items <- press_sort(items)
  year <- vapply(items, function(i) date_parts(i$date)[1], 0L)
  blocks <- vapply(unique(year), function(y)
    sprintf('<h2 class="press-year">%d</h2>\n<ul class="press-list">\n%s</ul>\n', y,
            paste0(vapply(items[year == y], press_item_html, ""), "\n", collapse = "")), "")
  paste0('<p class="press-key">† quotes or interviews me · ‡ written by me</p>\n', paste(blocks, collapse = ""))
}
