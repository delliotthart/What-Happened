from sklearn import datasets, linear_model
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
import numpy as np
import csv
import matplotlib.pyplot as plt
import pandas as pd

def mean_total_error(p1, p2):
	out = 0
	for i in range(len(p1)):
		out += p1[i] - p2[i]
	out /= len(p1)
	return(out)

fileReader = open("merged_final.csv", "rt", encoding="utf8")
csvReader  = csv.reader(fileReader)

header = next(csvReader)

numObs = len(list(csvReader))
fileReader.seek(0)
next(csvReader)

def average_win_error(realPerc, predPerc):
	total = 0
	for i in range(len(realPerc)):
		demWin = realPerc[i] > 0.5
		predWin = predPerc[i] > 0.5
		if demWin != predWin:
			total += 1
	return(total/len(realPerc))


trainX = []
trainDemShare = []
trainDemShare2Party = []
trainState = []
testX = []
testDemShare = []
testDemShare2Party = []
testState = []

for i, row in enumerate(list(csvReader)):
	rl = len(row)
	indeces = [0] + list(range(2, rl-6))
	npRow= np.array(row)
	if row[0] == '2016':
		testX.append(npRow[indeces])
		testDemShare.append(npRow[rl-3])
		testDemShare2Party.append(npRow[rl - 2])
		testState.append(npRow[rl-1])
	else:
		trainX.append(npRow[indeces])
		trainDemShare.append(npRow[rl-3])
		trainDemShare2Party.append(npRow[rl - 2])
		trainState.append(npRow[rl-1])

trainX = np.array(trainX).astype(float)
trainDemShare = np.array(trainDemShare).astype(float)
trainDemShare2Party = np.array(trainDemShare2Party).astype(float)
testX = np.array(testX).astype(float)
testDemShare = np.array(testDemShare).astype(float)
testDemShare2Party = np.array(testDemShare2Party).astype(float)

traits = header[2:rl-6]

#**********************************
#*****NORMAL REGRESSION************
#**********************************

reg = linear_model.LinearRegression()
reg.fit(trainX[:, 1:], trainDemShare)

traits = traits + ['intercept']
coefs = list(reg.coef_) + [reg.intercept_]

# sortedCoeffs, sortedTraits = zip(*sorted(zip(coefs, traits), key= lambda pair: 1/(abs(pair[0]))))
# plt.bar(range(len(sortedCoeffs)), sortedCoeffs, tick_label=sortedTraits)
# plt.xticks(rotation=90)
# plt.show()

sharePred = reg.predict(testX[:,1:])

print("Regular OLS: ", mean_absolute_error(sharePred, testDemShare))

reg2 = linear_model.LinearRegression()
reg2.fit(trainX[:, 1:], trainDemShare2Party)
sharePred2Party = reg2.predict(testX[:, 1:])
print("AWE OLS:", average_win_error(sharePred2Party, testDemShare2Party))

#******************************
#*****YEAR FIXED EFFECTS*******
#******************************

# trainDF = pd.DataFrame(trainX, columns=['year'] + traits[:len(traits) - 1])
# trainYear = pd.get_dummies(trainDF['year'])
# trainDF = trainDF.drop(['year'], axis=1)
# trainYear = trainYear.drop([2012], axis=1)
# trainDF = pd.concat([trainDF, trainYear], axis=1)

# regFE = linear_model.LinearRegression()
# regFE.fit(trainDF, trainDemShare)


#*******************************
#*****STATE FIXED EFFECTS*******
#*******************************

def fillOut(df):
	for code in np.array(list(range(50))).astype(str):
		if code not in df.columns:
			df[code] = np.zeros(len(df))

	return(df)

trainDF = pd.DataFrame(trainX[:, 1:], columns = traits[:len(traits) - 1])
trainDF['state'] = trainState
stateDummies = pd.get_dummies(trainDF['state'])
stateDummies = fillOut(stateDummies)
stateDummies = stateDummies.drop(['1'], axis = 1)

trainDF = pd.concat([trainDF, stateDummies], axis = 1)

regFE = linear_model.LinearRegression()
regFE.fit(trainDF, trainDemShare)

testDF = pd.DataFrame(testX[:, 1:], columns = traits[:len(traits) - 1])
testDF['state'] = testState
stateDummies = pd.get_dummies(testDF['state'])
stateDummies = fillOut(stateDummies)
stateDummies = stateDummies.drop(['1'], axis = 1)
testDF = pd.concat([testDF, stateDummies], axis = 1)

sharePredFE = regFE.predict(testDF)


print("OLS with State FE: ", mean_absolute_error(sharePredFE, testDemShare))

regFE2 = linear_model.LinearRegression()
regFE2.fit(trainDF, trainDemShare2Party)
sharePredFE2 = regFE2.predict(testDF)

print("AWE OLS with FE:", average_win_error(sharePredFE2, testDemShare2Party))



#***************************
#*****LASSO REGRESSION******
#***************************

x = np.array(range(1, 250))/10000
y = []
for alpha in x:
	regL = linear_model.Lasso(alpha=alpha, max_iter=100000)
	regL.fit(trainX[:, 1:], trainDemShare)
	sharePredL = regL.predict(testX[:,1:])
	y.append(mean_absolute_error(sharePredL, testDemShare))

# plt.plot(x, y)
# plt.show()

minLoss = sorted(zip(x, y), key= lambda pair: pair[1])[0][1]
minAlpha = sorted(zip(x, y), key= lambda pair: pair[1])[0][0]
print("Minimum Lasso Loss: ", minLoss, "with alpha =", minAlpha)



#For 2PARTY Share:

x = np.array(range(1, 250))/10000
y = []
for alpha in x:
	regL = linear_model.Lasso(alpha=alpha, max_iter=100000)
	regL.fit(trainX[:, 1:], trainDemShare2Party)
	sharePredL = regL.predict(testX[:,1:])
	y.append(average_win_error(sharePredL, testDemShare2Party))

minLoss = sorted(zip(x, y), key= lambda pair: pair[1])[0][1]
minAlpha = sorted(zip(x, y), key= lambda pair: pair[1])[0][0]
print("Minimum Lasso AWE: ", minLoss, "with alpha =", minAlpha)


















