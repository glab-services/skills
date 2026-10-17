import os, sys, time, signal, resource
lim = int(sys.argv[1]); resource.setrlimit(resource.RLIMIT_NPROC, (lim, lim))
kids = []
for i in range(lim + 50):
    try:
        p = os.fork()
    except OSError as e:
        print("fork failed after", len(kids), type(e).__name__, e.errno); break
    if p == 0:
        time.sleep(5); os._exit(0)
    kids.append(p)
else:
    print("all forks ok", len(kids))
for k in kids: os.kill(k, signal.SIGKILL)
for k in kids: os.waitpid(k, 0)
