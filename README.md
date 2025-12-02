# Browser Forensics Collection Tool  
### IT 360 – Final Project  
**Authors:** Dylan Voss & Grant Gollinger  

---

## 📌 Project Overview
The Browser Forensics Collection Tool is a Linux-based forensic acquisition utility designed to extract and preserve browser artifacts from Firefox (Snap) and Chromium-based browsers. This tool automates the collection of browsing history, cookies, Firefox cache2 contents, session data, form history, raw SQLite databases, SHA-256 integrity hashes, and a consolidated summary directory for fast review. The goal is to provide a reliable, repeatable, and integrity-focused method for gathering browser artifacts in a digital forensics setting.

---

## 🚀 Features

### ✔ Firefox (Snap) Support  
Automatically detects Firefox Snap profiles located at:
~/snap/firefox/common/.mozilla/firefox/

### ✔ Extracts Key Browser Evidence
- Browsing history (CSV + SQLite)
- Cookies (CSV + SQLite)
- Full Firefox cache2 directory
- Session data (sessionstore.jsonlz4)
- Form history (formhistory.sqlite)
- Raw SQLite databases

### ✔ Human-Readable Timestamp Conversion
- Firefox timestamps (microseconds since Unix epoch 1970)
- Chromium timestamps (WebKit epoch 1601 converted to readable)

### ✔ Summary Directory
Creates a folder containing:
- History CSV  
- Cookies CSV   
- Form history CSV  
- Session data  

### ✔ Evidence Integrity
All files are hashed with SHA-256 and recorded in:
manifest_<timestamp>.csv

### ✔ Automatic Archiving
A tar.gz archive of the entire evidence directory is automatically created.

---

## 📁 Repository Structure

browser-forensics-tool/
├── src/
│   └── collect_firefox_snap.sh
├── data/
│   └── sample_output/
│       ├── history_sample.csv
│       ├── cookies_sample.csv
│       └── evidence_tree_sample.txt
├── docs/
│   └── final_report.docx
└── README.md

---

## 🛠 Requirements

Your system must have:
- Ubuntu Linux  
- Firefox Snap  
- sqlite3  
- sha256sum  
- tree (optional)

Install missing packages:
sudo apt update  
sudo apt install sqlite3 tree -y

---

📘 How to Run the Tool

1. Clone the Repository - 
Clone the project and move into the repository directory:
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>

2. Make the Script Executable - 
Give the collection script permission to run:
chmod +x collect_firefox_snap.sh

3. Create an Output Directory - 
This directory will store all browser artifacts collected by the tool:
mkdir ~/browser_evidence

4. Run the Tool - 
Provide the output directory you just created:
./collect_firefox_snap.sh ~/browser_evidence

5. View Your Results - 
Navigate into the evidence directory and inspect the output:
cd ~/browser_evidence
ls
tree .

You will see a directory named:
firefox_snap_artifacts_<timestamp>/

Inside that folder, you will find:

- collection_info.txt — metadata about the collection (timestamp, user, hostname)
- manifest_<timestamp>.csv — SHA-256 hashes for every copied/exported artifact
- firefox_profiles/ — extracted Firefox profile data
- firefox_snap_artifacts_<timestamp>.tar.gz — compressed archive of the full evidence set

---

## 📦 Example Output Structure
## 📦 Example Output Structure

```text
browser_evidence/
└── firefox_snap_artifacts_<timestamp>/
    ├── collection_info.txt
    ├── manifest_<timestamp>.csv
    └── firefox_profiles/
        └── <profile>/                         # ex: 4w5y56z.default
            ├── cache2/
            │   └── entries/                   # ⚠ ~2000+ files
            │       # These are Firefox Cache2 entry files.
            │       # Each file represents cached web content such as images,
            │       # HTML fragments, scripts, JSON responses, and media.
            │       # Filenames look like hashes, but they are internal cache keys.
            │       # The tool hashes each file for integrity in the manifest.
            │
            ├── history_<profile>.csv          # Parsed browsing history (readable)
            ├── cookies_<profile>.csv          # Parsed cookies (readable)
            │
            ├── places.sqlite                  # Raw Firefox history database
            ├── cookies.sqlite                 # Raw cookie database
            ├── formhistory.sqlite
            ├── logins.json                    # Encrypted saved login data
            ├── key4.db                        # Encryption key database
            ├── sessionstore.jsonlz4           # Session/tab recovery data
            └── (other Firefox profile files)
```



---

## ⚠️ Forensic Safety Notes
- Only collect browser data on systems you have permission to analyze.  
- Do NOT upload sensitive raw databases such as:
  cookies.sqlite, logins.json, key4.db, sessionstore.jsonlz4  
- Only sanitized CSV exports from test browsing should be uploaded.

---

## 👥 Authors
- Dylan Voss  
- Grant Gollinger  
IT 360 – Illinois State University
