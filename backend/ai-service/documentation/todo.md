# ToDo

This is a ToDo where i will be writting down what does our project's ai service still need.

# List
- [ ] Better introduction
- [ ] Better data analisys
- [ ] Preprocessing
    - [ ] More advanced preprocessing?
- [ ] Modeling
    - [X] Introduction
        - [ ] Change PRACTICAL CONSTRAINTS according to the final answer
    - [ ] Explain each model
        - [ ] K-Means
            - [X] Model-specific interpretation
            - [X] Internal evaluation metrics
            - [X] Interpretability
        - [ ] Hierarchical
            - [ ] Model-specific interpretation
            - [ ] Internal evaluation metrics
            - [ ] Interpretability
        - [ ] DBSCAN
            - [ ] Model-specific interpretation
            - [ ] Internal evaluation metrics
            - [ ] Interpretability
        - [ ] HDBSCAN
            - [ ] Model-specific interpretation
            - [ ] Internal evaluation metrics
            - [ ] Interpretability
        - [ ] GMM
            - [ ] Model-specific interpretation
            - [ ] Internal evaluation metrics
            - [ ] Interpretability
    - [ ] Explain (and argue why the output is correct) specific algorithms for each model
    - [ ] Explain (and argue why the output is correct) used techniques and algorithms (same in all the models)
    - [ ] Writte scalable algorithms at the start of the section to use with different models when needed. For fair comparissons
    - [ ] Use GMM model????
    - [ ] Choose the best model configurations according to the defines metrics in the introduction
    - [ ] Explain better the choosen model output, and interpretation
    - [ ] Configure final model deployment
    - [ ] Fix / change final model's output system
- [ ] Documentation
    - [ ] Define and sort most important parameters that will be used for interpretation purposes. 

---
DBSCAN
from sklearn.cluster import DBSCAN
candidates = [
    {"name": "DBSCAN eps=0.6 ms=10", "estimator": DBSCAN(eps=0.6, min_samples=10)},
    {"name": "DBSCAN eps=0.7 ms=10", "estimator": DBSCAN(eps=0.7, min_samples=10)},
]
---
Hierarchical (Agglomerative)
from sklearn.cluster import AgglomerativeClustering
candidates = [
    {"name": "Agglo ward k=10", "estimator": AgglomerativeClustering(n_clusters=10, linkage="ward")},
    {"name": "Agglo ward k=15", "estimator": AgglomerativeClustering(n_clusters=15, linkage="ward")},
]
---
GMM
from sklearn.mixture import GaussianMixture
candidates = [
    {"name": "GMM comp=10", "estimator": GaussianMixture(n_components=10, covariance_type="full", random_state=42)},
]
