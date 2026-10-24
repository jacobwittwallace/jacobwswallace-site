# Small HTML helpers shared by the Press and Policy Initiatives pages.

# Escape & first so we don't double-escape the entities we introduce.
html_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;",  x, fixed = TRUE)
  x <- gsub(">", "&gt;",  x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x
}

# Escape text, then turn [text](url) into a link (lets data files carry inline links).
md_links <- function(x) {
  gsub("\\[([^]]+)\\]\\(([^)[:space:]]+)\\)", '<a href="\\2">\\1</a>', html_escape(x))
}
