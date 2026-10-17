# Fake OpenAI-compatible chat-completions server for offline OpenCode probing.
# No model is called: every reply is scripted. Step = tool results seen since the last user message.
import json, sys, http.server
PORT = int(sys.argv[1]); SCEN = json.load(open(sys.argv[2])); LOG = sys.argv[3]
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        self.send_response(404); self.end_headers()
    def do_POST(self):
        n = int(self.headers.get('content-length', 0)); body = json.loads(self.rfile.read(n) or b'{}')
        msgs = body.get("messages", [])
        users = [m for m in msgs if m.get("role") == "user"]
        with open(LOG, 'a') as f: f.write(json.dumps({"path": self.path, "tools": [t["function"]["name"] for t in body.get("tools", [])], "schemas": {t["function"]["name"]: t["function"].get("parameters") for t in body.get("tools", [])}, "nuser": len(users), "msgs": msgs})+"\n")
        if not body.get("tools"):
            step = None; reply = {"text": "title"}
        else:
            last_user = max(i for i, m in enumerate(msgs) if m.get("role") == "user")
            step = sum(1 for m in msgs[last_user:] if m.get("role") == "tool")
            turn = SCEN[min(len(users), len(SCEN)) - 1]
            reply = turn[min(step, len(turn) - 1)]
        self.send_response(200); self.send_header("content-type", "text/event-stream"); self.end_headers()
        def ev(d): self.wfile.write(b"data: " + json.dumps(d).encode() + b"\n\n"); self.wfile.flush()
        base = {"id": "c1", "object": "chat.completion.chunk", "created": 0, "model": "m"}
        if "tool" in reply:
            ev({**base, "choices": [{"index": 0, "delta": {"role": "assistant", "tool_calls": [{"index": 0, "id": "call_%s_%d" % (step, len(users)), "type": "function", "function": {"name": reply["tool"], "arguments": json.dumps(reply["args"])}}]}, "finish_reason": None}]})
            ev({**base, "choices": [{"index": 0, "delta": {}, "finish_reason": "tool_calls"}], "usage": {"prompt_tokens": 1, "completion_tokens": 1, "total_tokens": 2}})
        else:
            t = reply["text"].replace("{nuser}", str(len(users)))
            if "think" in reply:
                ev({**base, "choices": [{"index": 0, "delta": {"role": "assistant", "reasoning_content": reply["think"]}, "finish_reason": None}]})
            ev({**base, "choices": [{"index": 0, "delta": {"role": "assistant", "content": t}, "finish_reason": None}]})
            ev({**base, "choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}], "usage": {"prompt_tokens": 1, "completion_tokens": 1, "total_tokens": 2}})
        self.wfile.write(b"data: [DONE]\n\n")
http.server.HTTPServer(("127.0.0.1", PORT), H).serve_forever()
