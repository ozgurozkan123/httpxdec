import os
import subprocess
from fastmcp import FastMCP
from typing import List, Optional

mcp = FastMCP("httpx-mcp")

@mcp.tool()
def httpx_scan(target: List[str], ports: Optional[List[int]] = None, probes: Optional[List[str]] = None) -> str:
    """
    Run ProjectDiscovery's httpx CLI to probe HTTP/HTTPS services.

    Args:
        target: List of domains/hosts to scan.
        ports: Optional list of ports. If omitted, httpx defaults.
        probes: Optional list of probe flags (e.g., "status-code", "title").
    """
    if not target:
        return "No targets provided."

    args = ["httpx", "-u", ",".join(target), "-silent"]

    if ports:
        args += ["-p", ",".join(str(p) for p in ports)]

    if probes:
        for probe in probes:
            # ensure we don't double-prefix
            probe_flag = probe if probe.startswith("-") else f"-{probe}"
            args.append(probe_flag)

    try:
        result = subprocess.run(
            args,
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        return "httpx binary not found in container."

    output = result.stdout.strip()
    if result.returncode != 0:
        return f"httpx exited with code {result.returncode}: {result.stderr.strip()}"

    return output if output else "No results returned by httpx."

if __name__ == "__main__":
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    # Use HTTP transport so clients can POST JSON-RPC to /mcp (SSE was causing 405)
    mcp.run(transport="http", host=host, port=port, path="/mcp")
