#!/usr/bin/env Rscript
# Network entrypoint: download both feeds, parse/filter/merge, write data/substack_posts.yml.
# Safe to run locally or in CI. Fails soft: if a feed is unreachable it is skipped.
source("R/substack.R")

cfg <- yaml::read_yaml("data/substack_config.yml")
tmp <- tempfile(fileext = ".xml")

try_feed <- function(url, source, author) {
  if (!nzchar(url) || grepl("REPLACE", url)) return(NULL)
  ok <- tryCatch({ download.file(url, tmp, quiet = TRUE); TRUE },
                 error = function(e) FALSE)
  if (!ok) { message("skip (unreachable): ", url); return(NULL) }
  tryCatch(parse_feed(tmp, source = source, author = author),
           error = function(e) { message("parse failed: ", url); NULL })
}

personal <- try_feed(cfg$personal_url, "personal", author = NULL)
scale    <- try_feed(cfg$scale_url,    "scale",    author = cfg$author_name)

feeds <- Filter(Negate(is.null), list(personal, scale))
if (length(feeds) == 0) {
  message("No feeds fetched; leaving existing data/substack_posts.yml unchanged.")
} else {
  posts <- merge_posts(feeds)
  write_posts_yaml(posts, "data/substack_posts.yml")
  message("Wrote ", nrow(posts), " posts.")
}
