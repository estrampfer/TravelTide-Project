# TravelTide-Project
Customers Segmentation


## 📝 Project Description

This project analyzes user behavioral and transactional data to identify segments and assign perks, with the goal of increasing customer loyalty and revenue. The analysis is based on session, booking, and demographic data from TravelTide's platform.

## 📌 Project Summary

- Built a SQL pipeline (`Users_Segmentation_fv`) that aggregates and enriches user-level data using a series of Common Table Expressions (CTEs).
- Segmented users based on key behavioral indicators: valid trip frequency, session duration, user age, and family status.
- Assigned personalized perks (e.g., free check bag, hotel meals, exclusive discounts) using logic embedded in the final CTE.
- Created visuals through interactive workbooks in Tableau Public
- Created a PDF presentation with a decision tree and customers profiles to clearly communicate segmentation strategy to stakeholders

## 🚀 Usage Instructions

- Run the SQL pipeline in `Users_Segmentation_fv` to create a fully enriched user segmentation table.
- Export the output table to Tableau for visualization.
- Use the segmentation decision tree and customers profiles to guide campaign strategies.

---

## 📁 Repository Structure

```plaintext
Traveltide-Project/
├── data_source/                     # Dataset access and documentation
├── sql_scripts/                     # SQL code: CTEs, metrics, segmentation logic
├── documentation/                   # Visualizations, reports, spreadsheets
├── Users_Based_TravelTide_v7.csv    # Final user list with assigned perks
└── README.md                        # Project overview (this file)
```

---

## 🧠 Key Technologies

- SQL (BigQuery-compatible syntax)
- DBeaver for query development
- Markdown for documentation
- Tableau Public for visualization
- Excel for business rule testing

---

## 🧱 Workflow Summary

1. Connect to the Traveltide dataset (see `/data_source`).
2. Run the main SQL script (`Users_Segmentation_fv` in `/sql_scripts`) to generate the user-level segmentation table.
3. Export and review the final results in `Users_Based_TravelTide_v7.csv`.
4. Explore insights and visualizations in `/documentation`.

---

## 🎯 Output Example

| user_id | age | total_trips | total_revenue | segment        | assigned_perk        |
|---------|-----|-------------|----------------|----------------|-----------------------|
| 102938  | 27  | 5           | 800.00         | Young Traveler | Free hotel meal       |
| 384756  | 64  | 7           | 1200.00        | Senior Voyager | Free checked bag      |
| 928374  | 35  | 1           | 60.00          | Just Looking   | No perk               |

---

## 📄 License

This project is part of the Masterschool Data Analytics Mastery Program. It is shared for educational purposes only.

## 📢 Contact

For questions or collaboration:
**Erik Strampfer**  
📧 estrampfer@hotmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/erick-strampfer-monje)

