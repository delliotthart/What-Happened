import pandas as pd

def get_state_winner(table, path):
    data =  pd.DataFrame(pd.read_csv(table))
    data['dem_votes'] = data['predicted_votes'] * data['total_votes']
    data = data.drop(columns=['predicted_votes', 'county'])
    data = data.groupby(['state']).sum()
    data['dem_share'] = data['dem_votes'] / data['total_votes']
    data.to_csv(path)

if __name__ == "__main__":
    get_state_winner("../data/tree_predictions.csv", "../data/tree_winners.csv")
    get_state_winner("../data/forest_predictions.csv", "../data/forest_winners.csv")
