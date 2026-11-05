import pathlib, re, sys

ROOT = pathlib.Path("/home/z/my-project/download/dunia-akiomida")

def strip_comments(src: str) -> str:
    out = []
    i, n = 0, len(src)
    line_has_code = False
    def long_level(j):
        if j >= n or src[j] != "[":
            return -1
        k = j + 1
        while k < n and src[k] == "=":
            k += 1
        if k < n and src[k] == "[":
            return k - j - 1
        return -1
    while i < n:
        c = src[i]
        nxt = src[i + 1] if i + 1 < n else ""
        if c in ('"', "'"):
            q = c
            out.append(c)
            i += 1
            while i < n:
                out.append(src[i])
                if src[i] == "\\" and i + 1 < n:
                    out.append(src[i + 1])
                    i += 2
                    continue
                if src[i] == q:
                    i += 1
                    break
                i += 1
            line_has_code = True
            continue
        if c == "[":
            lvl = long_level(i)
            if lvl >= 0:
                end_pat = "]" + "=" * lvl + "]"
                end = src.find(end_pat, i + lvl + 2)
                if end < 0:
                    end = n
                    chunk = src[i:]
                else:
                    end += len(end_pat)
                    chunk = src[i:end]
                out.append(chunk)
                line_has_code = True
                i = end
                continue
        if c == "-" and nxt == "-":
            lvl = long_level(i + 2)
            if lvl >= 0:
                end_pat = "]" + "=" * lvl + "]"
                end = src.find(end_pat, i + lvl + 3)
                end = n if end < 0 else end + len(end_pat)
                i = end
                if not line_has_code:
                    while i < n and src[i] in "\r\n":
                        i += 1
                continue
            else:
                while i < n and src[i] != "\n":
                    i += 1
                if not line_has_code:
                    i += 1
                else:
                    out.append("\n") if i < n else None
                    i += 1
                line_has_code = False
                continue
        if c == "\n":
            line_has_code = False
        if c not in " \t":
            line_has_code = True
        out.append(c)
        i += 1
    return "".join(out)

def clean_text(s: str) -> str:
    s = re.sub(r"[ \t]+$", "", s, flags=re.M)
    s = re.sub(r"\n{3,}", "\n\n", s)
    return s

changed = 0
for path in sorted(ROOT.rglob("*.luau")):
    src = path.read_text()
    stripped = clean_text(strip_comments(src))
    if stripped != src:
        path.write_text(stripped)
        changed += 1
    leftover = re.search(r"(?m)^\s*--", stripped)
    print(("STRIPPED " if stripped != src else "clean    ") + str(path.relative_to(ROOT)) + ("  LEFTOVER!" if leftover else ""))
print("files changed:", changed)
