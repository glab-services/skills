# probe-conn.py host:port ... -> prints "<target> ok|<error>" for a TCP connect, 3 s each
import socket, sys
for t in sys.argv[1:]:
    h, p = t.rsplit(":", 1)
    try:
        s = socket.create_connection((h, int(p)), timeout=3); s.close(); r = "ok"
    except Exception as e:
        r = type(e).__name__ + ":" + str(e)[:60]
    print(t, r, flush=True)
