
library(stannis)
tag = "00000000-0000-0000-0000-000000000000"
o = stannis:::rewrite(source = 'output.csv', root = 'binary', tag = tag, comment = "Krump")
proportions = get_parameter('binary', 'proportions')





