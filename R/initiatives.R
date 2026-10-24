# Render the Policy Initiatives page from data/initiatives.yml (requires R/html.R).
blank <- function(x) if (is.null(x)) "" else x

# One link: "Title (Source)". A hosted copy links first, with the original alongside.
# A quote item leads with the quote; an item with no url (e.g. a site not yet live) shows its note.
link_item_html <- function(item) {
  src <- html_escape(blank(item$source))
  if (is.null(item$url))
    return(sprintf('<li>%s <span class="init-note">(%s)</span></li>', html_escape(item$title), html_escape(blank(item$note))))
  if (!is.null(item$quote))
    return(sprintf('<li class="init-quote-item"><p class="init-quote">\u201c%s\u201d</p><p class="init-attrib">\u2014 <a href="%s">%s</a>%s</p></li>',
                   html_escape(item$quote), html_escape(item$url), html_escape(item$title), if (nzchar(src)) sprintf(" (%s)", src) else ""))
  local <- blank(item$local)
  href <- if (nzchar(local)) local else item$url
  note <- if (nzchar(local)) {
    orig <- sprintf('<a href="%s">original</a>', html_escape(item$url))
    sprintf(" (%s)", if (nzchar(src)) paste0(src, "; ", orig) else orig)
  } else if (nzchar(src)) sprintf(" (%s)", src) else ""
  sprintf('<li><a href="%s">%s</a>%s</li>', html_escape(href), html_escape(item$title), note)
}

link_groups_html <- function(groups) {
  groups <- Filter(function(g) length(g$items) > 0, groups)
  parts <- vapply(groups, function(g) sprintf('<div class="init-group"><h3 class="init-label">%s</h3><ul>%s</ul></div>',
                                              html_escape(g$group), paste(vapply(g$items, link_item_html, ""), collapse = "")), "")
  paste0('<div class="init-links">', paste(parts, collapse = ""), "</div>")
}

# Two featured links stay visible; a "More" dropdown holds every group.
featured_html <- function(links) {
  items <- Filter(function(i) isTRUE(i$featured), unlist(lapply(links, `[[`, "items"), recursive = FALSE))
  if (!length(items)) return("")
  paste0('<ul class="init-featured">', paste(vapply(items, link_item_html, ""), collapse = ""), "</ul>")
}

more_html <- function(links) {
  groups <- Filter(function(g) length(g$items) > 0, links)
  if (!length(groups)) return("")
  sprintf('<details class="init-more"><summary>More: %s</summary>%s</details>',
          paste(vapply(groups, function(g) html_escape(g$group), ""), collapse = " \u00b7 "), link_groups_html(groups))
}

initiative_html <- function(x) {
  img_class <- if (identical(x$fit, "contain")) "init-image fit-contain" else "init-image"
  sprintf(paste0('<section class="initiative" id="%s"><div class="%s"><img src="%s" alt="%s" loading="lazy"></div>',
                 '<div class="init-text"><h2>%s</h2><p class="init-meta">%s</p><p>%s</p>%s%s</div></section>\n'),
          html_escape(x$id), img_class, html_escape(x$image), html_escape(x$alt), html_escape(x$title),
          md_links(blank(x$meta)), md_links(blank(x$body)), featured_html(x$links), more_html(x$links))
}

advisory_html <- function(roles) {
  items <- vapply(roles, function(r) sprintf('<li><a href="%s">%s</a></li>', html_escape(r$url), html_escape(r$text)), "")
  paste0('<section class="advisory"><h2>Advisory roles</h2><ul>', paste(items, collapse = ""), "</ul></section>\n")
}

initiatives_page_html <- function(d) {
  paste0('<p class="init-intro">', md_links(d$intro), "</p>\n",
         paste(vapply(d$initiatives, initiative_html, ""), collapse = ""),
         advisory_html(d$advisory))
}
