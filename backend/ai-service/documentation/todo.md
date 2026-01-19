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
            - [X] Model-specific interpretation
            - [X] Internal evaluation metrics
            - [X] Interpretability
        - [ ] DBSCAN
            - [X] Model-specific interpretation
            - [X] Internal evaluation metrics
            - [X] Interpretability
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
    - [X] Write scalable algorithms at the start of the section to use with different models when needed. For fair comparissons
    **Next action:** update the interpretability score with a *dominance penalty* (e.g., penalize solutions where the largest cluster exceeds a target share such as 60–70%). After that, we will re-rank DBSCAN candidates and select a configuration that produces **multiple balanced, usable need profiles**.
    - [ ] Explain why the developed interpretability algorithm is a good idea. Write a code summary to explain better how does that works.
    - [ ] Added new penalty to the interpretability algorithm. Change explanation.
    - [ ] Use GMM model????
    - [-] Choose the best model configurations according to the defined metrics in the introduction
    - [ ] Explain better the choosen model output, and interpretation
    - [ ] Configure final model deployment
    - [ ] Fix / change final model's output system
- [ ] Documentation
    - [ ] Define and sort most important parameters that will be used for interpretation purposes. 