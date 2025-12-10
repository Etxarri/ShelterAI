# Using Clustering for Shelter Prioritization

## Why Clustering?

In our project, the goal is to support humanitarian decision-making for allocating people to shelters based on their needs and vulnerabilities. Using a clustering approach offers several advantages:

- **Ethical Decision-Making**: Clustering does not assign shelters directly. Instead, it identifies groups of individuals with similar profiles, allowing human decision-makers to interpret and act responsibly.
- **Data-Driven Insights**: It leverages patterns in the data to reveal hidden structures, such as groups of highly vulnerable individuals, without imposing arbitrary rules.
- **Explainability**: Each cluster can be characterized by its key features (e.g., age, pregnancy status, health conditions, access to resources), making it transparent why individuals are grouped together.
- **Independence from Predefined Labels**: We do not rely on subjective labels like "priority" or "urgency" for training; the clustering finds patterns solely based on the features in the dataset.

---

## How Clustering Works in Our Project

1. **Data Preprocessing**
   - Convert categorical variables (e.g., gender, status, district) into numerical codes or embeddings.
   - Handle missing values and normalize numeric variables to ensure fair clustering.
   - Select relevant features related to vulnerability and needs, such as:
     - Demographics (age, gender, marital status)
     - Family situation (household size, children, dependents)
     - Health and accessibility indicators
     - Exposure to risk or displacement history

2. **Clustering Algorithm**
   - Apply an unsupervised learning algorithm (e.g., K-Prototypes, K-Means, or HDBSCAN) to group individuals into clusters with similar vulnerability profiles.
   - Determine the optimal number of clusters based on metrics like silhouette score or cluster stability.

3. **Cluster Interpretation**
   - Analyze each cluster to identify key characteristics and levels of vulnerability.
   - Assign human-readable labels to clusters for easier interpretation (e.g., "highly vulnerable", "moderately vulnerable", "low vulnerability").

4. **Supporting Human Decision-Making**
   - Use the cluster profiles to guide shelter allocation decisions.
   - Human operators can prioritize resources based on the identified vulnerability patterns, while the clustering ensures a fair, data-driven foundation.

---

## Benefits for the Project

- Provides a **scalable and automated way** to analyze large datasets.
- Ensures **ethical compliance** since decisions are reviewed by humans.
- Improves **transparency and accountability** in the allocation process.
- Avoids reliance on subjective or arbitrary priority labels.

In summary, clustering allows us to uncover patterns in vulnerability data, supporting informed, ethical, and explainable decisions without replacing human judgment.