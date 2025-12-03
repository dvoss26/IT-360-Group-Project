# Source Code (`src/`)

This folder contains all source code for the **Browser Forensics Collection Tool**, developed for the IT 360 Final Project.

## Files Included

### `collect_firefox_snap.sh`
This is the primary Bash script used to collect browser artifacts from **Firefox Snap** installations on Linux.  
It performs the following functions:

- Locates Firefox Snap profiles  
- Extracts key artifacts (history, cookies, cache, session data, form history, SQLite databases)  
- Parses SQLite data into readable CSV outputs  
- Calculates SHA-256 hashes for integrity verification  
- Generates a collection manifest  
- Creates a summary directory for quick review  
- Archives the entire evidence set into a `.tar.gz` file  

### `main.py` *(reserved for future feature expansion)*
This file exists as a placeholder for optional Python functionality (e.g., GUI wrapper, parsing utilities, or automation components).  
It is not required for the bash-based tool to function but remains in the repository for future enhancements.

---

All code in this folder is part of the core functionality used to run and demonstrate the project tool.
