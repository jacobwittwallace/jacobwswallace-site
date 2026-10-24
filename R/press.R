# Render the Press page from data/press.yml (requires R/html.R).
or_blank <- function(x) if (is.null(x)) "" else x

# Most prominent outlets first; "The New York Times" files under N.
press_sort <- function(items) {
  key <- function(f) vapply(items, f, "")
  outlet <- key(function(i) sub("^the ", "", tolower(i$outlet)))
  headline <- key(function(i) tolower(i$headline))
  items[order(vapply(items, function(i) as.integer(i$tier), 0L), outlet, headline)]
}

press_item_html <- function(item) {
  via <- or_blank(item$via)
  mark <- switch(or_blank(item$mark),
    quoted = ' <span class="press-mark" title="Quotes or interviews me">†</span>',
    authored = ' <span class="press-mark" title="Written by me">‡</span>',
    "")
  sprintf('<li><strong>%s</strong> — <a href="%s">%s</a>%s%s</li>',
          html_escape(item$outlet), html_escape(item$url), html_escape(item$headline),
          if (nzchar(via)) sprintf(" (via %s)", html_escape(via)) else "", mark)
}

press_page_html <- function(items) {
  paste0('<p class="press-key">† quotes or interviews me · ‡ written by me</p>\n<ul class="press-list">\n',
         paste0(vapply(press_sort(items), press_item_html, ""), "\n", collapse = ""),
         "</ul>\n")
}
