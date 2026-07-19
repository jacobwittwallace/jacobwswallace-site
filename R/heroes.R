# Deterministic hero rotation.
# Given an ordered vector of hero ids and an integer week, pick one id.
# Rotation cycles through the set by week so it changes on a slow, predictable cadence.
select_hero <- function(ids, week) {
  if (length(ids) == 0) stop("no heroes: id set is empty")
  idx <- (as.integer(week) %% length(ids)) + 1L
  ids[[idx]]
}

# Current ISO week number as an integer (used at build time).
current_iso_week <- function(today = Sys.Date()) {
  # Note: ISO week resets each January, so the rotation restarts at year boundaries (fine for a small set).
  as.integer(format(today, "%V"))
}
