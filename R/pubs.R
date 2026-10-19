# Render paper entries for the Research page from data/publications.yml.
esc <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE); x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}
or_empty <- function(x) if (is.null(x)) "" else x

paper_html <- function(p) {
  doi <- or_empty(p$doi); nber <- or_empty(p$nber); pdf <- or_empty(p$pdf); ab <- or_empty(p$abstract)
  main <- if (nzchar(doi)) paste0("https://doi.org/", doi) else if (nzchar(nber)) nber else ""
  title <- if (nzchar(main)) sprintf('<a href="%s">%s</a>', main, esc(p$title)) else esc(p$title)
  who <- if (nzchar(p$coauthors)) sprintf("with %s", esc(p$coauthors)) else ""
  cite <- if (nzchar(p$cite)) paste0(", ", esc(p$cite)) else ""
  venue <- sprintf("<em>%s</em>%s, %d", esc(p$venue), cite, p$year)
  if (p$section == "forthcoming") venue <- sprintf("<em>%s</em>, %s", esc(p$venue), tolower(esc(p$cite)))
  meta <- paste(Filter(nzchar, c(who, venue)), collapse = " &middot; ")
  links <- c(
    if (nzchar(doi)) sprintf('<a href="https://doi.org/%s">Journal</a>', doi),
    if (nzchar(nber)) sprintf('<a href="%s">NBER</a>', nber),
    if (nzchar(pdf)) sprintf('<a href="%s">PDF</a>', pdf))
  btn <- if (nzchar(ab)) '<button type="button" class="abs-toggle" aria-expanded="false">Abstract</button>' else NULL
  row <- paste(c(btn, links), collapse = ' <span class="sep">&middot;</span> ')
  absdiv <- if (nzchar(ab)) sprintf('<div class="abs-text" hidden><p>%s</p></div>', esc(ab)) else ""
  sprintf('<div class="paper"><div class="paper-title">%s</div><div class="paper-meta">%s</div><div class="paper-links">%s</div>%s</div>\n',
          title, meta, row, absdiv)
}

paper_section <- function(pubs, section, by_year = FALSE) {
  ps <- Filter(function(p) p$section == section, pubs)
  ps <- ps[order(-sapply(ps, function(p) p$year))]
  if (!by_year) { cat(paste(vapply(ps, paper_html, ""), collapse = "")); return(invisible()) }
  for (y in unique(sapply(ps, function(p) p$year))) {
    cat(sprintf('\n### %d {.year}\n\n', y))
    cat(paste(vapply(Filter(function(p) p$year == y, ps), paper_html, ""), collapse = ""))
  }
}
