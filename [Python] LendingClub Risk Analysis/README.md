# LendingClub Risk Analysis
- **Language**: Python
- **Overview**: Analysed the data of over 42,000 Lending Club customers and developed classification models to predict whether borrowers would default on their loans
- **Primary skills**: data pre-processing, data visualisation, machine learning, model selection
- **Completed in:** 2019
- **Grade Received**: A

------

LendingClub is one of the leading P2P lending companies in the United States. With a rise in credit demand, there have been more instances of default on loans which will potentially squeeze LendingClub’s profit margin.

This project uses machine learning to classify whether a potential borrower will default on his loan or not.

The following methods are used:

1. Random Forest Classifier
2. Support Vector Machine (SVM)
3. Logistic Regression

K-Fold cross validation was used to validate the models and for model selection as well.

For model evaluation, 3 metrics: (1) Precision, (2) Recall, and (3) F5 score were used. F5 is a composite metric score that accounts for both precision and recall, but weighs recall 5x as much as precision. This was used because in the context of default prediction, a false negative prediction (i.e wrongly predicting a default as non-default) is likely to be significantly more costly than a false positive one (which may only result in a premature selloff and lost potential interests).

Ultimately, a model with over 70% recall rate was achieved.

The source code and project report have been included in the folder.