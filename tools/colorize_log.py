import os
import sys
import re

# ANSI Color codes
RED = '\033[91m'
YELLOW = '\033[93m'
GREEN = '\033[92m'
RESET = '\033[0m'

def colorize_line(line):
    # Detect Stata error codes like r(199);
    if re.search(r'r\(\d+\);', line):
        return f"{RED}{line}{RESET}"
    
    # Detect words like "error" or "failed"
    if re.search(r'\berror\b', line, re.IGNORECASE) or re.search(r'\bfailing\b', line, re.IGNORECASE):
        return f"{RED}{line}{RESET}"
    
    # Detect warnings
    if re.search(r'\bwarning\b', line, re.IGNORECASE):
        return f"{YELLOW}{line}{RESET}"

    return line

def process_log(file_path):
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return

    colored_lines = []
    with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            colored_lines.append(colorize_line(line.rstrip()))

    # Write back to a .ansi file for viewing with colors
    ansi_file = file_path.replace('.log', '.ansi')
    with open(ansi_file, 'w', encoding='utf-8') as f:
        for line in colored_lines:
            f.write(line + '\n')
    
    print(f"Colored log created: {ansi_file}")
    print("You can view it with 'type' in a terminal that supports ANSI or any supporting editor.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python colorize_log.py <log_file>")
    else:
        process_log(sys.argv[1])
