# Render publication entries from data/publications.yml.
pub_line <- function(p) {
  who <- if (nzchar(p$coauthors)) sprintf(" With %s.", p$coauthors) else ""
  cite <- if (nzchar(p$cite)) sprintf(" %s,", p$cite) else ""
  links <- c(
    if (nzchar(p$doi)) sprintf("[journal](https://doi.org/%s)", p$doi),
    if (nzchar(p$nber)) sprintf("[NBER](%s)", p$nber),
    if (nzchar(p$pdf)) sprintf("[pdf](%s)", p$pdf))
  lk <- if (length(links)) paste0(" ", paste(links, collapse = " · ")) else ""
  sprintf("**%s.**%s *%s*,%s %d.%s\n\n", p$title, who, p$venue, cite, p$year, lk)
}
pub_section <- function(pubs, section, by_year = FALSE) {
  ps <- Filter(function(p) p$section == section, pubs)
  ps <- ps[order(-sapply(ps, function(p) p$year))]
  if (!by_year) { for (p in ps) cat(pub_line(p)); return(invisible()) }
  for (y in unique(sapply(ps, function(p) p$year))) {
    cat(sprintf("### %d\n\n", y))
    for (p in Filter(function(p) p$year == y, ps)) cat(pub_line(p))
  }
}
