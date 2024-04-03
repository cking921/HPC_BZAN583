Rprof()
  
system.time({
ntrials <- 3e4
counter <- 0
exam.results <- data.frame(matrix(ncol=10, nrow=0),row.names = NULL)

set.seed(583)
for (trial in 1:ntrials) {
  exam <- sample(1:50, 10, replace = FALSE)
  exam.results <- rbind(exam.results, exam)
}

counter <- sum(rowSums(exam.results <= 30) >= 7)
prob1 <- counter / ntrials

})

Rprof(NULL)
summaryRprof()



Rprof()

system.time({
set.seed(583)
ntrials <- 3e4

exam_results_rep <- do.call("rbind", 
                            replicate(ntrials, 
                                      {sample(1:50, 10, replace = FALSE)}, 
                                      simplify = FALSE))

counter <- sum(rowSums(exam_results_rep <= 30) >= 7)
prob2 <- counter / ntrials
})

Rprof(NULL)
summaryRprof()



all.equal(prob1, prob2)
