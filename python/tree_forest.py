import csv
from sklearn import tree
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import KBinsDiscretizer
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

num_trees = 10
tree_depth = 50

def find_best_depth(train_features, train_labels, test_features, test_labels):
    best_err = float('inf')
    best_depth = -1
    for depth in range(1, 20):
        print(depth)
        model = tree.DecisionTreeClassifier(max_depth = depth)
        model.fit(train_features, train_labels)
        prediction = np.asarray(model.predict(test_features), dtype = float)
        error = (np.absolute((np.asarray(prediction, dtype=float) - np.asarray(np.array(test_labels), dtype = float)))).mean()
        if error < best_err:
            best_err = error
            best_depth = depth
    return (best_depth, best_err)

def find_best_tree_num(train_features, train_labels, test_features, test_labels):
    best_err = float('inf')
    best_num = -1
    for trees in range(1, 100):
        print(trees)
        model = RandomForestClassifier(n_estimators = trees, max_depth = 4)
        model.fit(train_features, train_labels)
        prediction = np.asarray(model.predict(test_features), dtype = float)
        error = (np.absolute((np.asarray(prediction, dtype=float) - np.asarray(np.array(test_labels), dtype = float)))).mean()
        if error < best_err:
            best_err = error
            best_num = trees
    return (best_num, best_err)


def append_error(prediction, county_state, label):
    for i, row in enumerate(county_state):
        row[2] = prediction[i] - label[i]
        row[4] = prediction[i]

def visualize_error(county_state, title, file_name):
    error = [round(row[2], 3) for row in county_state]
    plt.hist(error, bins=20)
    plt.ylabel("count")
    plt.xlabel("predicted - actual dem vote share")
    plt.title(title)
    plt.savefig(file_name)
    plt.close()

def generate_results(county_state, file_name):
    table = []
    for i, row in enumerate(county_state):
        table.append([row[4], row[3], row[1], row[0]])
    with open(file_name, 'w') as f:
        csv_writer = csv.writer(f, delimiter = ',')
        for line in range(-1, len(county_state)):
            if line == -1:
                csv_writer.writerow(["predicted_votes", "total_votes", "state", "county"])
            else:
                csv_writer.writerow(table[line])

file_reader = open("../data/merged_final.csv", "rt")
csv_reader = csv.reader(file_reader)
attr = next(csv_reader)
not_features = ["county", "dem_share_total", "dem_two_party", "state", "fips", "year", "state_num"]
vote_index = attr.index("dem_share_total")
year_index = attr.index("year")
county_index = attr.index("county")
state_index = attr.index("state")
votes_index = attr.index("totalvotes")

train = []
test = []
train_votes = []
test_votes = []
county_state = []
for row in csv_reader:
    temp = []
    for j in range(len(row)):
        if attr[j] not in not_features:
            temp.append(row[j])
    if int(row[year_index]) != 2016:
        train.append(temp)
        train_votes.append(row[vote_index])
    else:
        test.append(temp)
        test_votes.append(row[vote_index])
        county_state.append([row[county_index], row[state_index], 0, row[votes_index], 0])

# print(find_best_depth(train, train_votes, test, test_votes))
# print(find_best_tree_num(train, train_votes, test, test_votes))

clf_tree = tree.DecisionTreeClassifier()
fitted_tree = clf_tree.fit(train, train_votes)
prediction_tree = np.asarray(fitted_tree.predict(test), dtype = float)
error_tree = (np.absolute((np.asarray(prediction_tree, dtype=float) - np.asarray(np.array(test_votes), dtype = float)))).mean()
append_error(np.asarray(prediction_tree, dtype = float), county_state, np.asarray(np.array(test_votes), dtype = float))
visualize_error(county_state, "prediction error with tree", "../output/tree_error.png")
generate_results(county_state, "../data/tree_predictions.csv")

feat = list(set(attr) - set(not_features))
outfile = tree.export_graphviz(fitted_tree, out_file='../output/tree.dot', feature_names=feat)

clf_forest = RandomForestClassifier(n_estimators = 50, max_depth = 10)
clf_forest.fit(train, train_votes)
prediction_forest = np.asarray(clf_forest.predict(test), dtype = float)
error_forest = (np.absolute((np.asarray(prediction_forest, dtype=float) - np.asarray(np.array(test_votes), dtype = float)))).mean()
append_error(np.asarray(prediction_forest, dtype = float), county_state, np.asarray(np.array(test_votes), dtype = float))
visualize_error(county_state, "prediction error with random forest", "../output/forest_error.png")
generate_results(county_state, "../data/forest_predictions.csv")
