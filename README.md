# Browser Forensics Collection Tool  
### IT 360 – Final Project  
**Authors:** Dylan Voss & Grant Gollinger  

---

## 📌 Project Overview
The Browser Forensics Collection Tool is a Linux-based forensic acquisition utility designed to extract and preserve browser artifacts from Firefox (Snap) and Chromium-based browsers. This tool automates the collection of browsing history, cookies, download history, Firefox cache2 contents, session data, form history, raw SQLite databases, SHA-256 integrity hashes, and a consolidated summary directory for fast review. The goal is to provide a reliable, repeatable, and integrity-focused method for gathering browser artifacts in a digital forensics setting.

---

## 🚀 Features

### ✔ Firefox (Snap) Support  
Automatically detects Firefox Snap profiles located at:
~/snap/firefox/common/.mozilla/firefox/

### ✔ Extracts Key Browser Evidence
- Browsing history (CSV + SQLite)
- Cookies (CSV + SQLite)
- Download history (CSV)
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
- Downloads CSV  
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
│       ├── downloads_sample.csv
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

## ▶️ How to Run the Tool

1. Clone the Repository  
git clone https://github.com/<your-username>/<repo-name>.git  
cd <repo-name>

2. Make the script executable  
chmod +x src/collect_firefox_snap.sh

3. Create an output directory  
mkdir ~/browser_evidence

4. Run the tool  
./src/collect_firefox_snap.sh ~/browser_evidence

5. View your results  
cd ~/browser_evidence  
ls  
tree .

You will see a directory like:
firefox_snap_artifacts_<timestamp>/

Inside will be:
- firefox_profiles/  
- summary/  
- manifest_<timestamp>.csv  
- collection_info.txt  
- timestamp.tar.gz archive  

---

## 📦 Example Output Structure

firefox_snap_artifacts_2025.../
├── collection_info.txt
├── manifest_2025...csv
├── summary/
│   ├── firefox_history_<profile>.csv
│   ├── firefox_cookies_<profile>.csv
│   └── firefox_downloads_<profile>.csv
└── firefox_profiles/
    └── <profile>/
        ├── places.sqlite
        ├── cookies.sqlite
        ├── downloads.sqlite
        ├── history_<profile>.csv
        ├── cookies_<profile>.csv
        ├── downloads_<profile>.csv
        ├── cache2/
        └── sessionstore.jsonlz4

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
