# Substack RSS ingestion. Pure parsing/normalization — network fetch is done by the caller
# (the GitHub Action downloads feeds to disk, then calls parse_feed on the files).
suppressPackageStartupMessages({
  library(xml2)
})

# Minimal HTML escaping for RSS-derived text injected into pages as raw HTML.
# Escape & first so we don't double-escape the entities we introduce.
html_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;",  x, fixed = TRUE)
  x <- gsub(">", "&gt;",  x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x
}

# Parse one RSS file into a normalized data.frame.
# author: if non-NULL, keep only items whose <dc:creator> matches (case-insensitive).
parse_feed <- function(path, source, author = NULL) {
  doc <- read_xml(path)
  items <- xml_find_all(doc, ".//item")
  get <- function(node, tag) {
    v <- xml_text(xml_find_first(node, tag))
    if (is.na(v)) "" else trimws(v)
  }
  rows <- lapply(items, function(it) {
    data.frame(
      title   = get(it, "./title"),
      url     = get(it, "./link"),
      date    = as.Date(get(it, "./pubDate"), format = "%a, %d %b %Y %H:%M:%S", tz = "GMT"),
      excerpt = get(it, "./description"),
      author  = get(it, ".//dc:creator"),
      source  = source,
      stringsAsFactors = FALSE
    )
  })
  posts <- do.call(rbind, rows)
  if (is.null(posts)) {
    posts <- data.frame(title=character(), url=character(), date=as.Date(character()),
                        excerpt=character(), author=character(), source=character())
  }
  if (!is.null(author)) {
    posts <- posts[tolower(posts$author) == tolower(author), , drop = FALSE]
  }
  posts
}

# Merge a list of parsed data.frames, dedupe by url, sort newest first.
merge_posts <- function(feed_list) {
  posts <- do.call(rbind, feed_list)
  if (is.null(posts) || nrow(posts) == 0) return(posts)
  posts <- posts[!duplicated(posts$url), , drop = FALSE]
  posts[order(posts$date, decreasing = TRUE), , drop = FALSE]
}

# Write normalized posts to YAML consumed by the Writing page + Home teaser.
write_posts_yaml <- function(posts, path) {
  out <- lapply(seq_len(nrow(posts)), function(i) {
    list(title = posts$title[i], url = posts$url[i],
         date = if (is.na(posts$date[i])) "" else as.character(posts$date[i]),
         excerpt = posts$excerpt[i],
         source = posts$source[i])
  })
  yaml::write_yaml(out, path)
}
