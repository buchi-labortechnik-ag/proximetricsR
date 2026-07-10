library(ggplot2)
library(hexSticker)
library(sysfonts)
library(showtext)
library(ggtext)
library(systemfonts)
library(prospectr)

#   Data  
data(NIRsoil)
mspc <- savitzkyGolay(NIRsoil$spc, m = 2, p = 2, w = 91)

nspc <- 350
set.seed(123)
some_spc <- mspc[sample(nrow(mspc), nspc), ]

wavs <- as.numeric(colnames(mspc))
df <- data.frame(
  wavelength = rep(wavs, times = nspc),
  absorbance = as.vector(t(some_spc)),
  sample = rep(paste0("S", 1:nspc), each = length(wavs))
)

#   Baseline ring  
baseline_df <- data.frame(
  wavelength = seq(min(wavs), max(wavs), length.out = 200),
  absorbance = 0
)

#   Fonts  
font_add(
  family = "helvetica_neue",
  regular = "/home/leo/.local/share/fonts/HelveticaNeue/HelveticaNeueLTStd-Lt.otf",
  bold = "/home/leo/.local/share/fonts/HelveticaNeue/HelveticaNeueLTStd-Bd.otf",
  italic = "/home/leo/.local/share/fonts/HelveticaNeue/HelveticaNeueLTStd-LtIt.otf",
  bolditalic = "/home/leo/.local/share/fonts/HelveticaNeue/HelveticaNeueLTStd-BdIt.otf"
)
font_add(
  family = "helvetica_neue_bdex",
  regular = "/home/leo/.local/share/fonts/HelveticaNeue/HelveticaNeueLTStd-BdEx.otf"
)
font_add(
  family = "helvetica_neue_ltex",
  regular = "/home/leo/.local/share/fonts/HelveticaNeue/HelveticaNeueLTStd-LtEx.otf"
)
showtext_auto()

#   Palette  
palette <- c(
  primary = "#64B445",
  secondary1 = "#289A93",
  secondary2 = "#4DB9D2",
  secondary3 = "#4F719A",
  accent1 = "#CF554E",
  accent2 = "#E08B55",
  accent3 = "#EAC473"
)

#   Polar plot: baseline ring + spectra  
p <- ggplot() +
  geom_path(
    data = baseline_df,
    aes(x = wavelength, y = absorbance),
    linewidth = 0.5,
    colour = "white",
    alpha = 0.6
  ) +
  geom_line(
    data = df,
    aes(x = wavelength, y = absorbance, group = sample),
    linewidth = 0.6,
    colour = "white",
    alpha = 0.015
  ) +
  coord_polar(theta = "x") +
  theme_void() +
  theme(legend.position = "none")

#   Sticker — spotlight OFF, will be added manually as centered subview  
s <- sticker(
  p,
  package = "",
  s_x = 1,
  s_y = 1,
  s_width = 2.5,
  s_height = 2.5,
  h_fill = palette["secondary3"],
  h_size = 1.4,
  h_color = "#3B82F6", ##64B445
  filename = "proximetricsr_hex.png",
  dpi = 300,
  url = "https://github.com/buchi-labortechnik-ag/proximetricsR",
  u_x = 0.94,
  u_y = 0.085,
  u_family = "helvetica_neue_ltex",
  u_color = "white",
  u_size = 2.6,
  spotlight = FALSE
)

#   Centered hexbin spotlight using hexSticker's internal function  

hexSticker_spotlight <- function(alpha) {
  vals_x <- rnorm(5e+05, sd = 2, mean = 0)
  vals_y <- rnorm(5e+05, sd = 2, mean = 0)
  hexbin::hexbinplot(vals_x ~ vals_y, colramp = hexSticker:::whiteTrans(alpha), 
             colorkey = FALSE, bty = "n", scales = list(draw = FALSE), 
             xlab = "", ylab = "", border = NA, par.settings = list(axis.line = list(col = NA)))
}

s <- s +
  geom_subview(
    subview = hexSticker_spotlight(alpha = 0.4),
    x = 1, y = 1,
    width = 3, height = 3
  )

#   Wordmark on top  
s <- s +
  geom_richtext(
    aes(x = 1, y = 1),
    label = "<span style='color:#FFFFFF;'>proximetrics</span><span style='color:#64B445;'>R</span>",
    family = "helvetica_neue_bdex",
    fontface = "plain",
    size = 13,
    fill = NA,
    label.color = NA
  )

s

ggsave("man/figures/logo.png", s, width = 43.94, height = 50.8, units = "mm", dpi = 300, bg = "transparent")

# s
