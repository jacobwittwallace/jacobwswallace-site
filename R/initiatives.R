# Render the Policy Initiatives page from data/initiatives.yml (requires R/html.R).
blank <- function(x) if (is.null(x)) "" else x

# One link: "Title (Source)". A hosted copy links first, with the original alongside.
link_item_html <- function(item) {
  src <- html_escape(blank(item$source))
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

initiative_html <- function(x) {
  img_class <- if (identical(x$fit, "contain")) "init-image fit-contain" else "init-image"
  sprintf(paste0('<section class="initiative" id="%s"><div class="%s"><img src="%s" alt="%s" loading="lazy"></div>',
                 '<div class="init-text"><h2>%s</h2><p class="init-meta">%s</p><p>%s</p>%s</div></section>\n'),
          html_escape(x$id), img_class, html_escape(x$image), html_escape(x$alt), html_escape(x$title),
          md_links(blank(x$meta)), md_links(blank(x$body)), link_groups_html(x$links))
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
