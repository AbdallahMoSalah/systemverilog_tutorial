#!/usr/bin/env python3
import sys
import re

LRM_PATH = "/media/abdallah-salah/eng/Verification/Svstandard.txt"

def search_lrm(query, max_matches=5, context=4):
    with open(LRM_PATH, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    pages = content.split('\x0c')
    pattern = re.compile(query, re.IGNORECASE)
    
    matches_found = 0
    for page_idx, page_text in enumerate(pages, start=1):
        lines = page_text.splitlines()
        for line_idx, line in enumerate(lines):
            if pattern.search(line):
                matches_found += 1
                start = max(0, line_idx - context)
                end = min(len(lines), line_idx + context + 1)
                print(f"=== [Page {page_idx}, Line {line_idx+1}] ===")
                for i in range(start, end):
                    prefix = ">> " if i == line_idx else "   "
                    print(f"{prefix}{lines[i]}")
                print()
                if matches_found >= max_matches:
                    return

if __name__ == "__main__":
    if len(sys.argv) > 1:
        search_lrm(sys.argv[1])
    else:
        print("Usage: lrm_search.py <pattern>")
