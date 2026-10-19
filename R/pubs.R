# Render paper entries for the Research page from data/publications.yml.
esc <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE); x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}
or_empty <- function(x) if (is.null(x)) "" else x

# Coauthor links: data/coauthors.yml maps a name (as written in publications.yml) to a URL.
coauthor_urls <- if (file.exists("data/coauthors.yml")) yaml::read_yaml("data/coauthors.yml") else list()
link_coauthors <- function(s) {
  s <- esc(s)
  nm <- names(coauthor_urls)
  nm <- nm[order(-nchar(nm))]                       # longest names first ("Chima D. Ndumele" before "Chima Ndumele")
  for (n in nm) {
    u <- coauthor_urls[[n]]
    if (!nzchar(or_empty(u))) next
    s <- gsub(sprintf("(?<![>\\w])%s(?![\\w<])", gsub("([.])", "\\\\\\1", esc(n))),
              sprintf('<a class="coauthor" href="%s">%s</a>', u, esc(n)), s, perl = TRUE)
  }
  s
}

press_html <- function(press) {
  if (!length(press)) return("")
  outlets <- unique(vapply(press, function(x) x$outlet, ""))
  items <- vapply(outlets, function(o) {
    us <- Filter(function(x) x$outlet == o, press)
    if (length(us) == 1) return(sprintf('<a href="%s">%s</a>', us[[1]]$url, esc(o)))
    nums <- paste(sprintf('<a href="%s">%d</a>', vapply(us, function(x) x$url, ""), seq_along(us)), collapse = " ")
    sprintf("%s %s", esc(o), nums)
  }, "")
  sprintf('<div class="press-text panel" hidden><p>%s</p></div>', paste(items, collapse = ' <span class="sep">&middot;</span> '))
}

paper_html <- function(p) {
  doi <- or_empty(p$doi); nber <- or_empty(p$nber); pdf <- or_empty(p$pdf); ab <- or_empty(p$abstract); url <- or_empty(p$url); rep <- or_empty(p$replication); code <- or_empty(p$code)
  press <- if (is.null(p$press)) list() else p$press
  main <- if (nzchar(doi)) paste0("https://doi.org/", doi) else if (nzchar(url)) url else if (nzchar(nber)) nber else ""
  title <- if (nzchar(main)) sprintf('<a href="%s">%s</a>', main, esc(p$title)) else esc(p$title)
  who <- if (nzchar(p$coauthors)) sprintf("with %s", link_coauthors(p$coauthors)) else ""
  if (p$section == "forthcoming") {
    venue <- sprintf("<em>%s</em>, %s", esc(p$venue), esc(p$cite))
  } else {
    cite <- if (nzchar(p$cite)) paste0(", ", esc(p$cite)) else ""
    venue <- sprintf("<em>%s</em>%s, %d", esc(p$venue), cite, p$year)
  }
  meta <- paste(Filter(nzchar, c(who, venue)), collapse = " &middot; ")
  btns <- c(
    if (nzchar(ab)) '<button type="button" class="toggle" data-panel="abs-text" aria-expanded="false">Abstract</button>',
    if (length(press)) sprintf('<button type="button" class="toggle" data-panel="press-text" aria-expanded="false">Press (%d)</button>', length(press)))
  links <- c(
    if (nzchar(doi)) sprintf('<a href="https://doi.org/%s">Journal</a>', doi),
    if (!nzchar(doi) && nzchar(url)) sprintf('<a href="%s">Article</a>', url),
    if (nzchar(nber)) sprintf('<a href="%s">NBER</a>', nber),
    if (nzchar(rep)) sprintf('<a href="%s">Replication</a>', rep),
    if (nzchar(code)) sprintf('<a href="%s">Code</a>', code),
    if (nzchar(pdf)) sprintf('<a href="%s">PDF</a>', pdf))
  row <- paste(c(btns, links), collapse = ' <span class="sep">&middot;</span> ')
  absdiv <- if (nzchar(ab)) sprintf('<div class="abs-text panel" hidden><p>%s</p></div>', esc(ab)) else ""
  sprintf('<div class="paper"><div class="paper-title">%s</div><div class="paper-meta">%s</div><div class="paper-links">%s</div>%s%s</div>\n',
          title, meta, row, absdiv, press_html(press))
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
