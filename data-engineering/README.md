# Data Engineering Assignment D0

## This project implements an ETL data processing pipeline using Python. The script focuses on reading two input files, memberInfo.csv and memberPaidInfo.csv, and creates an output file, cleanData.csv, that contains information about member ID, member name, and paid amount.

## Important Prerequisites:
Before you begin, make sure the following is installed and ready:
- Python
- Python Libraries ('csv' and 'os')

## Project Structure
```text
data-engineering/
├── data/                  # Input data directory
│   ├── memberInfo.csv     # CSV file with list of members
│   └── memberPaidInfo.csv # CSV file with list of transactions
├── output/                # Created output directory for user
│   └── cleanData.csv      # Generated final CSV file with clean entries
├── script.py              # Main python script
└── README.md              # Project documentation
└── DESIGNCHOICE.md        # Design choices
```

## How to Run Locally
1. Clone the repository:
    ```
    git clone https://github.com/aks2107/tech-assessment.git
    cd data-engineering
    ```
2. Run the script
    ```
    python script.py
    ```
3. See results after running:
- Console: Summary of insights after the clean entries are produced
    - Number of clean entries.
    - Total Paid Amount
    - Information on Highest Payer
- Output File: A new file named `cleanData.csv` will be created with the clean entries in the output folder.

### Contact Information
- Email: abinswar7@gmail.com
- LinkedIn: https://www.linkedin.com/in/aveinn-swar/
