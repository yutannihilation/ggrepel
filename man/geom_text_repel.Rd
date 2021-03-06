% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/geom-label-repel.R, R/geom-text-repel.R
\name{geom_label_repel}
\alias{geom_label_repel}
\alias{geom_text_repel}
\title{Repulsive textual annotations.}
\usage{
geom_label_repel(mapping = NULL, data = NULL, stat = "identity",
  parse = FALSE, ..., box.padding = unit(0.25, "lines"),
  label.padding = unit(0.25, "lines"), label.r = unit(0.15, "lines"),
  label.size = 0.25, force = 1, max.iter = 2000, expand = TRUE,
  na.rm = FALSE, show.legend = NA, inherit.aes = TRUE)

geom_text_repel(mapping = NULL, data = NULL, stat = "identity",
  parse = FALSE, ..., box.padding = unit(0.25, "lines"),
  segment.color = "#666666", segment.size = 0.5, force = 1,
  max.iter = 2000, expand = TRUE, na.rm = FALSE, show.legend = NA,
  inherit.aes = TRUE)
}
\arguments{
\item{mapping}{Set of aesthetic mappings created by \code{\link[ggplot2]{aes}} or
\code{\link[ggplot2]{aes_}}. If specified and \code{inherit.aes = TRUE} (the
default), is combined with the default mapping at the top level of the
plot. You only need to supply \code{mapping} if there isn't a mapping
defined for the plot.}

\item{data}{A data frame. If specified, overrides the default data frame
defined at the top level of the plot.}

\item{stat}{The statistical transformation to use on the data for this
layer, as a string.}

\item{parse}{If TRUE, the labels will be parsed into expressions and
displayed as described in ?plotmath}

\item{...}{other arguments passed on to \code{\link[ggplot2]{layer}}. There are
  three types of arguments you can use here:

  \itemize{
  \item Aesthetics: to set an aesthetic to a fixed value, like
     \code{color = "red"} or \code{size = 3}.
  \item Other arguments to the layer, for example you override the
    default \code{stat} associated with the layer.
  \item Other arguments passed on to the stat.
  }}

\item{box.padding}{Amount of padding around bounding box. Defaults to 0.25
lines.}

\item{label.padding}{Amount of padding around label. Defaults to 0.25 lines.}

\item{label.r}{Radius of rounded corners. Defaults to 0.15 lines.}

\item{label.size}{Size of label border, in mm.}

\item{force}{Force of repulsion between overlapping text labels. Defaults
to 1.}

\item{max.iter}{Maximum number of iterations to try to resolve overlaps.
Defaults to 2000.}

\item{expand}{If \code{TRUE} (the default), allow text labels to be placed
in the expanded plot area. Otherwise, limit their positions to the range
of the data.}

\item{na.rm}{If \code{FALSE} (the default), removes missing values with
a warning.  If \code{TRUE} silently removes missing values.}

\item{show.legend}{logical. Should this layer be included in the legends?
\code{NA}, the default, includes if any aesthetics are mapped.
\code{FALSE} never includes, and \code{TRUE} always includes.}

\item{inherit.aes}{If \code{FALSE}, overrides the default aesthetics,
rather than combining with them. This is most useful for helper functions
that define both data and aesthetics and shouldn't inherit behaviour from
the default plot specification, e.g. \code{\link[ggplot2]{borders}}.}

\item{segment.color}{Color of the line segment connecting the data point to
the text labe. Defaults to \code{#666666}.}

\item{segment.size}{Width of segment, in mm.}
}
\description{
\code{geom_text_repel} adds text directly to the plot.
\code{geom_label_repel} draws a rectangle underneath the text, making it
easier to read. The text labels repel away from each other and away from
the data points.
}
\details{
These geoms are based on \code{\link[ggplot2]{geom_text}} and
\code{\link[ggplot2]{geom_label}}. See the documentation for those
functions for more details. Differences from those functions are noted
here.

Text labels have height and width, but they are physical units, not data
units. The amount of space they occupy on that plot is not constant in data
units: when you resize a plot, labels stay the same size, but the size of
the axes changes. Currently, the text labels will not be repositioned upon
resizing a plot. This may change in future releases.
}
\section{\code{geom_label_repel}}{

Currently \code{geom_label_repel} does not support the \code{rot} parameter
and is considerably slower than \code{geom_text_repel}. The \code{fill}
aesthetic controls the background colour of the label.
}

\section{Alignment}{

The repulsive geoms reposition text labels to avoid overlap, so the
following parameters are not supported:

\itemize{
  \item \code{hjust}
  \item \code{vjust}
  \item \code{nudge_x}
  \item \code{nudge_y}
  \item \code{position}
  \item \code{check_overlap}
}
}
\examples{

p <- ggplot(mtcars, aes(wt, mpg, label = rownames(mtcars)))

# Avoid overlaps by repelling text labels
p + geom_text_repel()
# Labels with background
p + geom_label_repel()

\dontrun{
p + geom_text_repel(family = "Times New Roman")

# Add aesthetic mappings
p + geom_text_repel(aes(colour = factor(cyl)))
p + geom_label_repel(aes(fill = factor(cyl)), colour = "white", fontface = "bold")

p + geom_text_repel(aes(size = wt))
# Scale height of text, rather than sqrt(height)
p + geom_text_repel(aes(size = wt)) + scale_radius(range = c(3,6))

# You can display expressions by setting parse = TRUE.  The
# details of the display are described in ?plotmath, but note that
# geom_text_repel uses strings, not expressions.
p + geom_text_repel(aes(label = paste(wt, "^(", cyl, ")", sep = "")),
  parse = TRUE)

# Add a text annotation
p +
  geom_text_repel() +
  annotate("text", label = "plot mpg vs. wt", x = 2, y = 15, size = 8, colour = "red")
}

}

