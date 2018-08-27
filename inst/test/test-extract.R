
library(stannis)
tag = "00000000-0000-0000-0000-000000000000"
o = stannis:::rewrite(source = 'output.csv', root = 'binary', tag = tag, comment = "Krump")
proportions = stannis:::get_parameter('binary', 'proportions')

mp = proportions[1001:1050,,]
mp[425720]
mp[20,1:4,2129]





