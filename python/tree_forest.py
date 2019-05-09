import csv
from sklearn import tree
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import KBinsDiscretizer
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# from mpl_toolkits.basemap import Basemap as Basemap
# from matplotlib.colors import rgb2hex
# from matplotlib.patches import Polygon

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

# enc = KBinsDiscretizer(n_bins=10)
# train_disc = enc.fit_transform(np.asarray(np.array(train), dtype = float))
# test_disc = enc.fit_transform(np.asarray(np.array(test), dtype = float))

clf_tree = tree.DecisionTreeClassifier(max_depth = 10)
clf_tree.fit(train, train_votes)
prediction_tree = np.asarray(clf_tree.predict(test), dtype = float)
error_tree = (np.absolute((np.asarray(prediction_tree, dtype=float) - np.asarray(np.array(test_votes), dtype = float)))).mean()
append_error(np.asarray(prediction_tree, dtype = float), county_state, np.asarray(np.array(test_votes), dtype = float))
visualize_error(county_state, "prediction error with tree", "../output/tree_error.png")
generate_results(county_state, "../data/tree_predictions.csv")

clf_forest = RandomForestClassifier(n_estimators = 50, max_depth = 10)
clf_forest.fit(train, train_votes)
prediction_forest = np.asarray(clf_forest.predict(test), dtype = float)
error_forest = (np.absolute((np.asarray(prediction_forest, dtype=float) - np.asarray(np.array(test_votes), dtype = float)))).mean()
append_error(np.asarray(prediction_forest, dtype = float), county_state, np.asarray(np.array(test_votes), dtype = float))
visualize_error(county_state, "prediction error with random forest", "../output/forest_error.png")
generate_results(county_state, "../data/forest_predictions.csv")

# clf_tree.fit(train_disc, train_votes)
# prediction_tree_disc = clf_tree.predict(test_disc)
# error_tree_disc = (np.absolute((np.asarray(prediction_tree, dtype=float) - np.asarray(np.array(test_votes), dtype = float)))).mean()
# append_error(np.asarray(prediction_tree_disc, dtype = float), county_state, np.asarray(np.array(test_votes), dtype = float))
# visualize_error(county_state, "prediction error with tree (discrete features)")
#
# clf_forest.fit(train_disc, train_votes)
# prediction_forest_disc = clf_tree.predict(test_disc)
# error_forest_disc = (np.absolute((np.asarray(prediction_forest_disc, dtype=float) - np.asarray(np.array(test_votes), dtype = float)))).mean()
# append_error(np.asarray(prediction_forest_disc, dtype = float), county_state, np.asarray(np.array(test_votes), dtype = float))
# visualize_error(county_state, "prediction error with forest (discrete features)")
