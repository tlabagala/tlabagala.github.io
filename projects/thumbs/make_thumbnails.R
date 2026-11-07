# make_thumbnails.R
# Builds the listing-card thumbnails in projects/thumbs/. One headline number
# on the left, one simplified supporting visual on the right, large text so it
# stays readable at card size (~380px wide). Every number here already appears
# on the matching project page - do not add numbers that are not on the page.
#
# Run from the repo root:
#   Rscript projects/thumbs/make_thumbnails.R
# If Inter is not installed system-wide, point INTER_DIR at a folder holding
# Inter-Regular.ttf, Inter-SemiBold.ttf and Inter-Bold.ttf.

library(ggplot2)
source(here::here("theme/theme_portfolio.R"))

inter_dir <- Sys.getenv("INTER_DIR")
if (nzchar(inter_dir) &&
    !"Inter" %in% systemfonts::system_fonts()$family) {
  systemfonts::register_font(
    "Inter",
    plain      = file.path(inter_dir, "Inter-Regular.ttf"),
    bold       = file.path(inter_dir, "Inter-Bold.ttf"),
    italic     = file.path(inter_dir, "Inter-Regular.ttf"),
    bolditalic = file.path(inter_dir, "Inter-Bold.ttf")
  )
}

thumb_bg <- "#f3f6fa"   # same tint as the .project-summary box
ink_soft <- "#5f5e5a"   # muted text colour used in styles.scss

# Everything is drawn on one 1200 x 600 canvas in pixel coordinates, so text
# sizes and positions are exact. ggplot text size is in mm: at 150 dpi,
# size 1 = ~5.9 px of font size. Content stays inside y = 100..500 so a card
# that crops the image top and bottom still shows all of it.
W <- 1200; H <- 600
canvas <- function() {
  ggplot() +
    scale_x_continuous(limits = c(0, W), expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, H), expand = c(0, 0)) +
    coord_fixed(clip = "off") +
    theme_void() +
    theme(plot.background = element_rect(fill = thumb_bg, colour = NA),
          plot.margin = margin(0, 0, 0, 0))
}

# Left block: the headline number and a two-line label.
headline <- function(p, number, label) {
  p +
    annotate("text", x = 70, y = 375, label = number, hjust = 0, vjust = 0.5,
             family = "Inter", fontface = "bold", size = 25,
             colour = portfolio_accent) +
    annotate("text", x = 74, y = 200, label = label, hjust = 0, vjust = 0.5,
             family = "Inter", size = 7.6, colour = portfolio_ink,
             lineheight = 0.95)
}

# Right block: horizontal bars, accent on the result that matters, value
# labels only (no axes), so it reads as a shape rather than a chart to study.
# Bars are listed bottom to top.
mini_bars <- function(p, values, highlight, value_fmt, labels = NULL,
                      x0 = 760, x1 = 1060, y0 = 130, y1 = 470) {
  n <- length(values)
  lo <- min(0, values); hi <- max(0, values)
  sx <- function(v) x0 + (v - lo) / (hi - lo) * (x1 - x0)
  slot <- (y1 - y0) / n
  bar_h <- slot * if (is.null(labels)) 0.7 else 0.5
  df <- data.frame(
    v = values, hi = seq_len(n) == highlight,
    yc = y0 + slot * (seq_len(n) - 0.5) - if (is.null(labels)) 0 else slot * 0.12,
    txt = value_fmt(values)
  )
  df$xa <- pmin(sx(0), sx(df$v)); df$xb <- pmax(sx(0), sx(df$v))
  df$col <- ifelse(df$hi, portfolio_accent, portfolio_grey)
  df$tcol <- ifelse(df$hi, portfolio_accent, "grey45")
  p <- p +
    geom_rect(data = df, aes(xmin = xa, xmax = xb, ymin = yc - bar_h / 2,
                             ymax = yc + bar_h / 2, fill = I(col))) +
    annotate("segment", x = sx(0), xend = sx(0), y = y0 - 10, yend = y1 + 10,
             colour = "grey55", linewidth = 0.6) +
    geom_text(data = df, aes(x = ifelse(v >= 0, xb + 12, xa - 12), y = yc,
                             label = txt, hjust = ifelse(v >= 0, 0, 1),
                             colour = I(tcol)),
              family = "Inter", fontface = "bold", size = 6.4)
  if (!is.null(labels)) {
    df$lab <- labels
    p <- p + geom_text(data = df, aes(x = sx(0) + 2, y = yc + bar_h / 2 + 24,
                                      label = lab),
                       hjust = 0, family = "Inter", size = 5.6,
                       colour = ink_soft)
  }
  p
}

# Right block alternative: stacked supporting stats.
stat_stack <- function(p, stats, x0 = 760, y0 = 130, y1 = 470) {
  n <- length(stats)
  slot <- (y1 - y0) / n
  df <- data.frame(yc = y1 - slot * (seq_len(n) - 0.5),
                   num = names(stats), lab = unname(stats))
  p +
    annotate("segment", x = x0, xend = x0, y = y0, yend = y1,
             colour = portfolio_accent, linewidth = 1.6) +
    geom_text(data = df, aes(x = x0 + 28, y = yc + 18, label = num),
              hjust = 0, family = "Inter", fontface = "bold", size = 9,
              colour = portfolio_ink) +
    geom_text(data = df, aes(x = x0 + 28, y = yc - 30, label = lab),
              hjust = 0, family = "Inter", size = 5.6, colour = ink_soft)
}

save_thumb <- function(p, slug) {
  ggsave(here::here("projects/thumbs", paste0(slug, ".png")), p,
         device = ragg::agg_png, width = W / 150, height = H / 150, dpi = 150,
         bg = thumb_bg)
}

pct <- function(x) sprintf("%+.1f%%", x)

# NBA: strategy edge over the naive draft (Fig 1 on the page), worst to best.
canvas() |>
  headline("+14.6%", "starting-lineup points\nover the naive draft") |>
  mini_bars(c(-11.8, -1.4, 7.8, 14.6), highlight = 4, value_fmt = pct,
            x0 = 790, x1 = 1000) |>
  save_thumb("nba-fantasy-draft")

# ICU: kNN, MLP, random forest, logistic regression, then the final blend.
canvas() |>
  headline("0.942", "ROC-AUC ranking\nICU mortality risk") |>
  mini_bars(c(0.761, 0.771, 0.81, 0.829, 0.942), highlight = 5,
            value_fmt = function(x) sprintf("%.2f", x)) |>
  save_thumb("icu-mortality-prediction")

# Crime: elastic net test R2, with the panel's size alongside.
canvas() |>
  headline("0.777", "test R\u00b2 predicting\ncrime rates by LGA") |>
  stat_stack(c("78" = "Victorian LGAs", "14" = "years, 2011-2024",
               "1,092" = "LGA-years")) |>
  save_thumb("victorian-lga-crime")

# Text mining: clustering accuracy against the chance baseline.
canvas() |>
  headline("60%", "genre labels recovered\nfrom word counts alone") |>
  mini_bars(c(33, 60), highlight = 2, labels = c("Chance", "Clustering"),
            value_fmt = function(x) paste0(x, "%")) |>
  save_thumb("text-mining-news-genres")
