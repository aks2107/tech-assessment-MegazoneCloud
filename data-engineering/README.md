# Data Engineering Assignment D0

## This project implements an ETL data processing pipeline using Python. The script focuses on reading two input files, memberInfo.csv and memberPaidInfo.csv, and creates an output file, cleanData.csv, that contains information about member ID, member name, and amount paid.

## How to Run Locally

1. Make sure Python 3 is installed on your computer.
2. Clone the repo with the following command:
    ```text
    git clone https://github.com/aks2107/tech-assessment.git
    ```
3. Go to the correct project directory:
   ```text
    cd technical-assessment-2025/data-engineering
    ```
5. Make sure the data directory contains the following:
   - memberInfo.csv 
   - memberPaidInfo.csv
6. Run the script with the following command:
    ```text
    python script.py
    ```

## Project Structure
```text
data-engineering/
├── data/                  # Input directory
│   ├── memberInfo.csv     # CSV file with list of members
│   └── memberPaidInfo.csv # CSV file with list of transactions from members
├── output/                # Output directory
│   └── cleanData.csv      # Processed and cleaned data
├── script.py              # Main script
└── README.md              # Project documentation
```

### Contact Information
- Email: abinswar7@gmail.com
- LinkedIn: https://www.linkedin.com/in/aveinn-swar/
