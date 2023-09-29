dat <- read.table("f.txt")
plot(dat, type = "p", main = "Корреляционное поле", xlab = "X", ylab = "Y")
sr <- mean(dat[, 1])
sigma <- sd(dat[, 1])
rows <- paste0("(", round(sr - (1:3) * sigma, 2), ", ", round(sr + (1:3) * sigma, 2), ")")
tab <- rep(0, 3 * 4)
dim(tab) <- c(3, 4)
tab <- as.data.frame(tab)
sub1 <- subset (dat[, 1], ((sr - sigma) < dat[, 1]) & (dat[, 1] < (sr + sigma)))
sub2 <- subset (dat[, 1], ((sr - 2 * sigma) < dat[, 1]) & (dat[, 1] < (sr + 2 * sigma)))
sub3 <- subset (dat[, 1], ((sr - 3 * sigma) < dat[, 1]) & (dat[, 1] < (sr + 3 * sigma)))
colnames(tab) <- c("1", "2", "3", "4")
tab[1:3, 1] <- rows
tab[1:3, 2] <- c (length (sub1), length (sub2), length(sub3))
tab[1:3, 3] <- tab[1:3, 2] / length (dat[, 1]) * 100
tab[1:3, 4] <- c (68.3, 95.4, 99.7)
range <- max (dat[, 1]) - min (dat[, 1])
k <- 1 + floor (log (length (dat[, 1]), 2))
h <- range / k
sorted <- sort(dat[, 1])
tab2 <- rep(0, k * 4)
dim(tab2) <- c(k, 4)
tab2 <- as.data.frame(tab2)
colnames(tab2) <- c("1", "2", "3", "4")
for (i in 0:(k - 1)) {
  left <- sorted[1] + i * h
  right <- sorted[1] + (i + 1) * h
  part <- subset (dat[, 2], left <= dat[, 1] & (dat[, 1] < right | i == k - 1 & dat[, 1] <= right))
  rows <- paste0("(", left, ", ", right, ")")
  tab2[i + 1, 1] <- rows
  tab2[i + 1, 2:4] <- c(length (part), sum (part), mean (part))
}
tab
tab2
v <- length (dat[, 1]) - 2
corcoef <- cor (dat[, 1], dat[, 2])
t <- abs (corcoef) * sqrt (v / (1 - corcoef ^ 2))
corcoef
t
lm (dat[, 2] ~ dat[, 1])
cor.test(dat[, 1], dat[, 2])
abline(lm(dat[, 2] ~ dat[, 1]))