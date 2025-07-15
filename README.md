# TravelTide-Project
Customers segmentation


## 📝 Project Description

This project analyzes user behavioral and transactional data to identify segments and assign perks, with the goal of increasing customer loyalty and revenue. The analysis is based on session, booking, and demographic data from TravelTide's platform.

## 📌 Project Summary

- Built a SQL pipeline (`Cohort_Usuarios`) that aggregates and enriches user-level data using a series of Common Table Expressions (CTEs).
- Segmented users based on key behavioral indicators: valid trip frequency, session duration, user age, and family status.
- Assigned personalized perks (e.g., free check bag, hotel meals, exclusive discounts) using logic embedded in the final CTE (`User_Perks`).
- Created visual user personas and a decision tree to clearly communicate segmentation strategy to stakeholders.
- Delivered final segmentation metrics and insights through interactive dashboards in Tableau Public.

### 🔗 Key Links

- [📊 Tableau Public Dashboard](https://public.tableau.com/app/profile/your_dashboard_link)
- [📃 Executive Summary (PDF)](./Executive_Summary.pdf)
- [📄 SQL Script - Cohort_Usuarios](./cohort_usuarios.sql)
- [📷 Persona Visuals](./personas/)
- [🔹 Canva Slides for Personas](https://www.canva.com/design/your_canva_link)

---

## 💻 Installation Instructions

> Only needed if you are running this project locally (PostgreSQL + Tableau Desktop environment)

1. Load the datasets: `sessions`, `users`, `flights`, and `hotels` into your PostgreSQL instance.
2. Execute the `cohort_usuarios.sql` script in your SQL editor to generate enriched and aggregated data.
3. Open Tableau Desktop and connect to the resulting `User_Perks` table to visualize insights.

---

## 🚀 Usage Instructions

- Run the SQL pipeline in `cohort_usuarios.sql` to create a fully enriched user segmentation table.
- Export the output table `User_Perks` to Tableau for visualization.
- Use the segmentation decision tree and user persona slides to guide campaign strategies.

---


## Project Structure

- `data/`: Contains the dataset used for analysis.
- `notebooks/`: Jupyter notebooks with the analysis code.
- `src/`: Source code for data preprocessing and modeling.
- `results/`: Output files and results.
- `README.md`: Project documentation.

## 📁 Directory Structure

```plaintext
📆 traveltide-segmentation/
├── cohort_usuarios.sql               # SQL logic for segmentation & perk assignment
├── README.md                         # Project documentation
├── Executive_Summary.pdf             # Stakeholder summary
├── /personas/                        # PNGs for each user segment
├── /assets/                          # Icons, visuals, and flowcharts
└── /dashboards/                      # Tableau Public snapshots or .twbx
```

---

## 🧰 Dependencies

These are optional Python libraries for users inspecting or analyzing SQL output locally:

```bash
pandas
sqlalchemy
matplotlib
streamlit
```
Install with:

```bash
pip install -r requirements.txt
```

---

## 📍 Example Usage

**From SQL:**
```sql
-- Query users eligible for a specific perk\SELECT *
FROM User_Perks
WHERE assigned_perk = 'free check bag';
```

**From Python:**
```python
import pandas as pd
from sqlalchemy import create_engine

# Set up SQL connection
engine = create_engine('postgresql://user:password@localhost/db')

# Load data into pandas DataFrame
df = pd.read_sql("SELECT * FROM User_Perks", engine)

# Analyze distribution of perks
print(df['assigned_perk'].value_counts())
```

---

## 📢 Contact

For questions or collaboration:
**Erik Strampfer**  
📧 erik@email.com  
🔗 [LinkedIn](https://www.linkedin.com/in/erikstrampfer/)

