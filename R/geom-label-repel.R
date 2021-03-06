#' @rdname geom_text_repel
#' @param label.padding Amount of padding around label. Defaults to 0.25 lines.
#' @param label.r Radius of rounded corners. Defaults to 0.15 lines.
#' @param label.size Size of label border, in mm.
#' @export
geom_label_repel <- function(
  mapping = NULL, data = NULL, stat = "identity",
  parse = FALSE,
  ...,
  box.padding = unit(0.25, "lines"),
  label.padding = unit(0.25, "lines"),
  label.r = unit(0.15, "lines"),
  label.size = 0.25,
  force = 1,
  max.iter = 2000,
  expand = TRUE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomLabelRepel,
    position = "identity",
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      parse = parse,
      box.padding  = box.padding,
      label.padding = label.padding,
      label.r = label.r,
      label.size = label.size,
      na.rm = na.rm,
      force = force,
      max.iter = max.iter,
      expand = expand,
      ...
    )
  )
}

#' GeomLabelRepel
#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomLabelRepel <- ggproto(
  "GeomLabelRepel", Geom,
  required_aes = c("x", "y", "label"),

  default_aes = aes(
    colour = "black", fill = "white", size = 3.88, angle = 0,
    alpha = NA, family = "", fontface = 1, lineheight = 1.2
  ),

  draw_panel = function(
    self, data, panel_scales, coord,
    parse = FALSE,
    na.rm = FALSE,
    box.padding = unit(0.25, "lines"),
    label.padding = unit(0.25, "lines"),
    label.r = unit(0.15, "lines"),
    label.size = 0.25,
    segment.color = "#666666",
    segment.size = 0.5,
    force = 1,
    max.iter = 2000,
    expand = TRUE
  ) {
    lab <- data$label
    if (parse) {
      lab <- parse(text = as.character(lab))
    }

    data <- coord$transform(data, panel_scales)

    pad.x <- convertWidth(box.padding, "npc", valueOnly = TRUE)
    pad.y <- convertHeight(box.padding, "npc", valueOnly = TRUE)

    # Create a dataframe with x y width height
    boxes <- lapply(1:nrow(data), function(i) {
      row <- data[i, , drop = FALSE]
      t <- textGrob(
        lab[i],
        unit(row$x, "native") + label.padding,
        unit(row$y, "native") + label.padding,
        gp = gpar(
          col = row$colour,
          fontsize = row$size * .pt,
          fontfamily = row$family,
          fontface = row$fontface,
          lineheight = row$lineheight
        ),
        name = "text"
      )
      r <- roundrectGrob(
        row$x, row$y, default.units = "native",
        width = grobWidth(t) + 2 * label.padding,
        height = grobHeight(t) + 2 * label.padding,
        r = label.r,
        gp = gpar(
        col = row$colour,
        fill = alpha(row$fill, row$alpha),
          lwd = label.size * .pt
        ),
        name = "box"
      )
      c(
        "x1" = row$x + convertWidth(grobX(r, "west"), "npc", TRUE) - pad.x,
        "y1" = row$y - convertHeight(grobHeight(r), "npc", TRUE) / 2 - pad.y,
        "x2" = row$x + convertWidth(grobX(r, "east"), "npc", TRUE) + pad.x,
        "y2" = row$y + convertHeight(grobHeight(r), "npc", TRUE) / 2 + pad.y
      )
    })

    # Fudge factor to make each box slightly wider. This is useful when the
    # user adds a legend to the plot, causing all the labels to squeeze
    # together.
    fudge.width <- abs(max(data$x) - min(data$x)) / 50
    boxes <- lapply(boxes, function(b) {
      # fudge.width <- abs(b['x2'] - b['x1']) / 10
      b['x1'] <- b['x1'] - fudge.width
      b['x2'] <- b['x2'] + fudge.width
      b
    })

    # By default, fit the text labels in the expanded plot area.
    expanded.range <- function(xs, amount = 0.05) {
      xs <- range(xs)
      d <- abs(xs[2] - xs[1])
      c(xs[1] - amount * d - pad.x, xs[2] + amount * d + pad.x)
    }

    if (expand) {
      xlims <- expanded.range(data$x)
      ylims <- expanded.range(data$y)
    } else {
      xlims <- range(data$x)
      ylims <- range(data$y)
    }

    ws <- repel_boxes(
      do.call(rbind, boxes),
      xlim = xlims,
      ylim = ylims,
      force = force * 1e-6,
      maxiter = max.iter
    )

#     cat("data$x", range(data$x), "\n")
#     cat("ws$x", range(ws$x), "\n")
#     cat("data$y", range(data$y), "\n")
#     cat("ws$y", range(ws$y), "\n")
#     print("data")
#     print(data[,c("x","y")])
#     print("ws")
#     print(ws)

    grobs <- lapply(1:nrow(data), function(i) {
      row <- data[i, , drop = FALSE]
      labelRepelGrob(
        lab[i],
        x = unit(ws$x[i], "native"),
        y = unit(ws$y[i], "native"),
        x.orig = unit(data$x[i], "native"),
        y.orig = unit(data$y[i], "native"),
        box.padding = box.padding,
        label.padding = label.padding,
        r = label.r,
        text.gp = gpar(
          col = row$colour,
          fontsize = row$size * .pt,
          fontfamily = row$family,
          fontface = row$fontface,
          lineheight = row$lineheight
        ),
        rect.gp = gpar(
          col = row$colour,
          fill = alpha(row$fill, row$alpha),
          lwd = label.size * .pt
        ),
        segment.gp = gpar(
          col = segment.color,
          lwd = segment.size * .pt
        )
      )
    })
    class(grobs) <- "gList"

    ggname("geom_label_repel", grobTree(children = grobs))
  },
  draw_key = draw_key_label
)

labelRepelGrob <- function(
  label,
  x = unit(0.5, "npc"),
  y = unit(0.5, "npc"),
  x.orig = unit(0.5, "npc"),
  y.orig = unit(0.5, "npc"),
  default.units = "npc",
  just = "center",
  box.padding = unit(0.25, "lines"),
  label.padding = unit(0.25, "lines"),
  name = NULL,
  text.gp = gpar(),
  rect.gp = gpar(fill = "white"),
  r = unit(0.1, "snpc"),
  segment.gp = gpar(),
  vp = NULL
) {
  stopifnot(length(label) == 1)

  if (!is.unit(x))
    x <- unit(x, default.units)
  if (!is.unit(y))
    y <- unit(y, default.units)

  gTree(
    label = label,
    x = x,
    y = y,
    x.orig = x.orig,
    y.orig = y.orig,
    just = just,
    box.padding = box.padding,
    label.padding = label.padding,
    r = r,
    name = name,
    text.gp = text.gp,
    rect.gp = rect.gp,
    segment.gp = segment.gp,
    vp = vp,
    cl = "labelrepelgrob"
  )
}

#' grid::makeContent function for labelRepelGrob.
#'
#' @param x A grid grob.
#' @export
makeContent.labelrepelgrob <- function(x) {
  hj <- resolveHJust(x$just, NULL)
  vj <- resolveVJust(x$just, NULL)

  t <- textGrob(
    x$label,
    x$x + 2 * (0.5 - hj) * x$box.padding,
    x$y + 2 * (0.5 - vj) * x$box.padding,
    just = c(hj, vj),
    gp = x$text.gp,
    name = "text"
  )

  r <- roundrectGrob(
    x$x + 2 * (0.5 - hj) * x$box.padding,
    x$y + 2 * (0.5 - vj) * x$box.padding,
    default.units = "native",
    width = grobWidth(t) + 2 * x$label.padding,
    height = grobHeight(t) + 2 * x$label.padding,
    just = c(hj, vj),
    r = x$r,
    gp = x$rect.gp,
    name = "box"
  )

  x1 <- convertWidth(x$x - 0.5 * grobWidth(r), "native", TRUE)
  x2 <- convertWidth(x$x + 0.5 * grobWidth(r), "native", TRUE)
  y1 <- convertHeight(x$y - 0.5 * grobHeight(r), "native", TRUE)
  y2 <- convertHeight(x$y + 0.5 * grobHeight(r), "native", TRUE)
  xo <- convertWidth(x$x.orig, "native", TRUE)
  yo <- convertHeight(x$y.orig, "native", TRUE)

  center <- centroid(c(x1, y1, x2, y2))

  # Get the coordinates of the intersection between the line from the original
  # data point to the centroid and the rectangle's edges.
  int <- intersect_line_rectangle(c(xo, yo), center, c(x1, y1, x2, y2))

  s <- segmentsGrob(
    x0 = int[1],
    y0 = int[2],
    x1 = x$x.orig,
    y1 = x$y.orig,
    default.units = "native",
    gp = x$segment.gp,
    name = "segment"
  )

  setChildren(x, gList(s, r, t))
}
