import csv
import io
import itertools
from contextlib import redirect_stdout

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.kernel_ridge import KernelRidge
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neighbors import KNeighborsRegressor as KNNReg


def load_data(split=False):
    fileReader = open("data/merged_final.csv", "rt", encoding="utf8")
    csvReader = csv.reader(fileReader)

    cHeader = next(csvReader)
    data = []
    counties_2016 = []

    for row in csvReader:
        attributes = {}
        row_index = 0

        for i in range(0, len(row) - 2):
            key = cHeader[i]
            value = row[i]
            attributes[key] = value

        dem_share = float(row[len(row) - 1])
        dem_share_all_parties = float(row[len(row) - 2])

        row_index += 1

        if attributes['year'] == '2016' and split:
            counties_2016.append((attributes, dem_share_all_parties))
        else:
            data.append((attributes, dem_share_all_parties))

    if split:
        print(
            F'{len(data)} counties in 2008 and 2012, used to predict {len(counties_2016)} in 2016')
        return(data, counties_2016)
    else:
        return data


def bootstrap(inputs, pct, include_test=True):  # returns tuple (training,test)
    length = int(len(inputs) * pct)
    training = [int(random.random() * len(inputs))
                for i in range(length)]
    all_ind = set(range(len(inputs)))
    train_ind = set(training)
    test = all_ind - train_ind
    # test = [j not in training for j in range(len(inputs))]
    # print(len(inputs), "total obs.", len(training), " obs in training set: ", len(train_ind),
    #       " are unique.", len(test), " are in test set")
    if include_test:
        return ([inputs[i] for i in training], [inputs[i] for i in test])
    else:
        return ([inputs[i] for i in training], "No test set produced")


def get_MSE(election_data, predictions):
    error = 0
    abs_error = 0
    pop_sum = 0
    for i in range(len(predictions)):

        ob = election_data[i]
        weight = int(ob[0]['totalvotes'])

        error += weight * (ob[1] - predictions[i])
        abs_error += abs(weight * (ob[1] - predictions[i]))
        pop_sum += weight

    return (float(abs_error / pop_sum), float(error / pop_sum))


def prep_data(data_set, features, split=False):
    X = []
    Y = []
    X_2016 = []
    data_16 = []
    for ob in data_set:
        x = []
        for var in features:
            # print(ob[0])
            x.append(float(ob[0][var]))

        if ob[0]['year'] == '2016' and split:
            X_2016.append(x)
            data_16.append(ob)
        else:
            X.append(x)
            Y.append(float(ob[1]))
    if split:
        return(X, Y, X_2016, data_16)
    else:
        return (X, Y)


def leave_one_out(data, features, K):  # return MSE
    predictions = []
    for i in range(len(data)):
        if(i % 500) != 0:
            continue
        (X, Y) = prep_data(data, features)
        X_i = X.pop(i)
        Y_i = Y.pop(i)

        model = KNNReg(n_neighbors=K, weights='distance')
        model.fit(X, Y)
        predictions.append(model.predict([X_i]))

    return (features, get_MSE(data, predictions))


def find_best_features(data, attributes, n_features, K, mode, features=[]):
    # takes mode = KNN or Kernel
    if mode == 'test_all':
        prediction_function = leave_one_out
    elif mode == 'predict_16':
        prediction_function = sim_2016

    trials = []
    for var in attributes:
        if n_features == 1:
            local_features = list(features)
            local_features.append(var)

            trials.append(prediction_function(
                data=data, features=local_features, K=K))
        else:
            local_features = list(features)
            local_attributes = list(attributes)

            local_features.append(var)
            local_attributes.remove(var)

            next = n_features - 1
            trials.extend(find_best_features(data=data,
                                             attributes=local_attributes,
                                             n_features=next, features=local_features, K=K, mode=mode))
    # return(trials)

    return(trials)


# def run_KNN(data, features, K=10):
#     (X, Y, wt) = prep_data(data, features)
#     model = KNNReg(n_neighbors=K, weights='distance')
#
#     model.fit(X, Y)
#     predictions = model.predict(X)
#
#     return (features, get_MSE(data, predictions))


def print_results(trials, K, mode):
    labels = ['MSE']
    for i in range(1, len(trials[0][0]) + 1):
        labels.append(F'Feature {i}')

    filename = F'all_models_{K}NN_{mode}.csv'
    with open(filename, 'w') as myfile:
        wr = csv.writer(myfile)
        wr.writerow(labels)
        for trial in trials:
            # print(trial)
            line = [trial[1]]
            line.extend(trial[0])
            wr.writerow(line)

    print(F'Wrote CSV with info on {len(trials)} groupings')


def get_best_model(K, mode):
    fields = []
    rows = []
    filename = F'all_models_{K}NN_{mode}.csv'
    with open(filename, 'r') as file:
        csvreader = csv.reader(file)
        fields = next(csvreader)
        # print(fields)
        min = 1
        best_model = -1
        for i, row in enumerate(csvreader):
            # print(row)
            if float(row[0][1:-1]) < min:
                min = float(row[0][1:-1])
                best_model = i
            rows.append(row)
    features = [ft for ft in rows[i]]
    features = features[1:]
    print(
        F'Best model for {K}NN {mode} is in row {best_model}.  Average Abs. Error={rows[best_model][0]}: Features are {[ft for ft in features]}')


def main(k, mode):
    election_set = load_data()

    attributes = ['naturalized', 'non_citizen', 'female', 'foodstamp',
                  'age', 'white', 'black', 'asian_pac_islander', 'multi_racial',
                  'indig', 'hispanic', 'married', 'single', 'foreign_born',
                  'student', 'veteran', 'moved_last_year', 'col_degree',
                  'less_than_hs', 'grad', 'indig_land', 'farm',
                  'med_hhinc', 'med_age', 'med_hh_val']

    trials = find_best_features(
        election_set, attributes, 1, K=k, mode=mode)
    trials_2 = find_best_features(election_set, attributes, 2, K=k, mode=mode)
    trials_3 = find_best_features(election_set, attributes, 3, K=k, mode=mode)
    #
    trials.extend(trials_2)
    trials.extend(trials_3)

    print_results(trials, k, mode)
    get_best_model(k, mode)


def sim_2016(data, features, K=10):
    (Training_X, Training_Y, Predict_X, eval_data) = prep_data(
        data, features, split=True)

    model = KNNReg(n_neighbors=K, weights='distance')
    model.fit(Training_X, Training_Y)
    predictions = model.predict(Predict_X)

    error = get_MSE(eval_data, predictions)
    print(
        F'MSE is {error}, when grouping on {[f for f in features]} with {K} neighbors')
    return(features, error)


def display_NN(features, K, county_FIPS):
    data = load_data()
    features.append('fips')

    (X, Y, X_2016, full_eval) = prep_data(
        data, features=features, split=True)

    trimmed_X = [x[:-1] for x in X]
    # print(trimmed_X)

    classifier = KNNReg(n_neighbors=K, weights='distance')
    main_county = [x for x in X_2016 if x[-1] == county_FIPS]
    main_county = main_county[0][:-1]

    # print(F'found county with these attributes: {main_county}')

    classifier.fit(trimmed_X, Y)
    # print(main_county[0])
    neighbors = classifier.kneighbors(
        [main_county], return_distance=False)
    print(neighbors[0])

    trimmed_X = np.asarray(trimmed_X)

    KNN_obs = trimmed_X[neighbors[0]]
    KKN_votes = Y[neighbors[0]]

    for i, ft_name in enumerate(features):
        feature = KNN_obs[:, i]

        plt.plot(feature, KNN_votes)

        plt.title(F'Most Similar Counties Based on {ft_name}')
        plt.ylabel('Two-Party Democratic Vote Share')
        plt.xlabel('K clusters')
    plt.savefig('graphs/Within Scatter - 2D.png', bbox_inches='tight')
    plt.gcf().clear()

    # print(KNN_obs)
    # print(f'found some neighbors at indexes: {neighbors}')


# display_NN(['med_hh_val', 'med_age', 'med_hhinc'], 20, 1003)


# main(20, 'predict_16')
# get_best_model(2)
# for k in [5, 10, 20, 50, 100]:
#     main(k, 'predict_16')
# #     sim_2016(data, ['med_hh_val', 'med_age'], K=k)
data = load_data()
sim_2016(data, ['naturalized', 'non_citizen', 'female', 'foodstamp',
                'age', 'white', 'black', 'asian_pac_islander', 'multi_racial',
                'indig', 'hispanic', 'married', 'single', 'foreign_born',
                'student', 'veteran', 'moved_last_year', 'col_degree',
                'less_than_hs', 'grad', 'indig_land', 'farm',
                'med_hhinc', 'med_age', 'med_hh_val'], 20)
sim_2016(data, ['med_hh_val', 'med_age', 'med_hhinc'], 20)
sim_2016(data, ['med_hh_val', 'med_age', 'med_hhinc'], 5)
sim_2016(data, ['med_hh_val', 'med_age', 'med_hhinc'], 100)


# TODO: bootstrap and then test out of sample
# TODO: see how adding params one at a time does

# election_set
