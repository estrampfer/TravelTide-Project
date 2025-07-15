# 🧠 SQL Scripts – CTEs & User Segmentation

This folder contains the SQL scripts used to build the user-level table and cohort segmentation for the Traveltide project.

## 📂 Contents

- `Users_Segmentation_fv`: Main script including all CTEs and final user segmentation.

## 📌 Highlights

- Filtering active sessions and valid trips.
- Joining tables with demographic and transactional data.
- Calculating user-level KPIs: total trips, revenue, cancellations, etc.
- Assigning user segments such as "Just Looking", "Young Traveler", "Explorer".
- Final column `assigned_perk` with personalized perks (e.g., free hotel meal).
