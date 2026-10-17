# Fake OpenAI-compatible chat-completions server for offline OpenCode probing.
# No model is called: every reply is scripted. Step = number of tool results seen.
import json, sys, http.server, os
PORT = int(sys.argv[1]); SCEN = json.load(open(sys.argv[2])); LOG = sys.argv[3]
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        self.send_response(404); self.end_headers()
    def do_POST(self):
        n = int(self.headers.get('content-length', 0)); body = json.loads(self.rfile.read(n) or b'{}')
        with open(LOG, 'a') as f: f.write(json.dumps({"path": self.path, "tools": [t["function"]["name"] for t in body.get("tools", [])], "msgs": body.get("messages", [])})+"\n")
        msgs = body.get("messages", [])
        if not body.get("tools"):
            step = None; reply = {"text": "title"}
        else:
            step = sum(1 for m in msgs if m.get("role") == "tool"); reply = SCEN[min(step, len(SCEN)-1)]
        self.send_response(200); self.send_header("content-type", "text/event-stream"); self.end_headers()
        def ev(d): self.wfile.write(b"data: " + json.dumps(d).encode() + b"\n\n"); self.wfile.flush()
        base = {"id": "c1", "object": "chat.completion.chunk", "created": 0, "model": "m"}
        if "tool" in reply:
            ev({**base, "choices": [{"index": 0, "delta": {"role": "assistant", "tool_calls": [{"index": 0, "id": "call_%s" % step, "type": "function", "function": {"name": reply["tool"], "arguments": json.dumps(reply["args"])}}]}, "finish_reason": None}]})
            ev({**base, "choices": [{"index": 0, "delta": {}, "finish_reason": "tool_calls"}], "usage": {"prompt_tokens": 1, "completion_tokens": 1, "total_tokens": 2}})
        elif "error" in reply:
            pass
        else:
            ev({**base, "choices": [{"index": 0, "delta": {"role": "assistant", "content": reply["text"]}, "finish_reason": None}]})
            ev({**base, "choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}], "usage": {"prompt_tokens": 1, "completion_tokens": 1, "total_tokens": 2}})
        self.wfile.write(b"data: [DONE]\n\n")
http.server.HTTPServer(("127.0.0.1", PORT), H).serve_forever()
