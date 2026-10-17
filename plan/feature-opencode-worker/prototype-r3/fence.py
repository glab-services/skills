# fence.py <plan> <heading text> <n> — prints the n-th (1-based) ```` fence after the heading
import re, sys
t = open(sys.argv[1]).read(); i = t.index(sys.argv[2])
fs = re.findall(r'^````[^\n]*\n(.*?)^````$', t[i:], re.M | re.S)
sys.stdout.write(fs[int(sys.argv[3]) - 1])
