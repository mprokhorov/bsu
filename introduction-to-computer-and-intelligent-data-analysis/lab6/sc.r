library(MASS)
x1 <- rnorm(20, 0, 8 / 3)
y1 <- rnorm(20, 0, 8 / 3)
x2 <- rnorm(10, 8, 8 / 3)
y2 <- rnorm(10, 8, 8 / 3)
xy <- cbind(c(x1, x2), c(y1, y2))
xy
n <- 30
n.train <- floor(n * 0.7)
n.test <- n - n.train
idx.train <- sample(1:n, n.train)
data.train <- xy[idx.train, ] 
idx.test <- setdiff(1:n, idx.train)
data.test <- xy[idx.test, ]

cl <- kmeans(xy, 2)
cl.cluster <- cl$cluster
plot(xy, xlab="x", ylab="y", col = c("blue", "green")[cl$cluster])
legend("bottomleft", legend = c("1", "2"), fill = c("blue", "green"))

cl.train <- cl.cluster[idx.train]
cl.test <- cl.cluster[idx.test]
mod <- qda(data.train, cl.train)
cl.test_est <- predict(mod, data.test)$class
sum(cl.test_est != cl.test) / n.test
idx.wrong <- idx.test[cl.test_est != cl.test] # оценка ошибки классификации
plot(xy, type = "n", xlab = "x", ylab = "y")
points(xy[idx.train,], pch = 2, col = c("blue", "green")[cl.train])
points(xy[idx.test,], col = c("blue", "green")[cl.test])
points(xy[idx.wrong, 1], xy[idx.wrong, 2], pch = 4, col = "red")

idx.new <- sample(1:n.train, n.train * 0.2)
for (i in idx.new) cl.train[i] = ifelse(cl.train[i] == 1, 2, 1)

mod.new <- qda(data.train, cl.train)
cl.test_est.new <- predict(mod.new, data.test)$class
sum(cl.test_est.new != cl.test) / n.test
idx.wrong.new <-  idx.test[cl.test_est.new != cl.test]

plot(xy, type = "n", xlab = "x", ylab = "y")
points(xy[idx.train,], pch = 2, col = c("blue", "green")[cl.train])
points(xy[idx.test,], col = c("blue", "green")[cl.test])
points(xy[idx.wrong.new, 1], xy[idx.wrong.new, 2], pch = 4, col = "red")