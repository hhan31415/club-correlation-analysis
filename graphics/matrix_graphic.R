library(ggplot2)

# Edit these four cell texts and colors as needed
quadrant_data <- data.frame(
  row = c("High underlying value", "High underlying value",
          "Low underlying value", "Low underlying value"),
  col = c("Strong correlation", "Weak correlation",
          "Strong correlation", "Weak correlation"),
  label = c(
    "Team is good at something that\nproduces well. No major\nchanges needed.",
    "Team is good at something that\nproduces little result. Needs to\nconvert this metric into output.",
    "Team is bad at something that\nproduces well. Needs to find\nplayers who can increase this metric.",
    "Team is bad at something that\nproduces little. Low priority."
  ),
  fill_group = c("good", "mixed", "mixed", "low")
)

# Order factors so "High" is on top and "Strong" is on the left
quadrant_data$row <- factor(quadrant_data$row,
                             levels = c("Low underlying value", "High underlying value"))
quadrant_data$col <- factor(quadrant_data$col,
                             levels = c("Strong correlation", "Weak correlation"))

fill_colors <- c(good = "#9FE1CB", mixed = "#FAC775", low = "#D3D1C7")

ggplot(quadrant_data, aes(x = col, y = row, fill = fill_group)) +
  geom_tile(color = "black", linewidth = 0.6) +
  geom_text(aes(label = label), size = 5, lineheight = 1) +
  scale_fill_manual(values = fill_colors) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 16) +
  theme(
    legend.position = "none",
    axis.text = element_text(face = "bold", size = 14),
    panel.grid = element_blank()
  )

# Save for README (larger canvas keeps text from feeling cramped)
ggsave("quadrant_matrix.png", width = 10, height = 7.5, dpi = 200)