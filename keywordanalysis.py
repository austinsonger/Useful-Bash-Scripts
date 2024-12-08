"""
Keyword Analysis on specified columns in a spreadsheet

This script performs keyword analysis on specified columns of a spreadsheet.  
It adds a new column listing the top unique keywords for each row based on the content of the specified columns.
"""

import pandas as pd
from collections import Counter
import string

def clean_and_split(text, stopwords):
    """
    Clean and split the text into words, removing punctuation and stopwords.

    Parameters:
    text (str): The text to be processed.
    stopwords (set): A set of stopwords to be removed.

    Returns:
    list: A list of words after cleaning and splitting.
    """
    text = text.translate(str.maketrans('', '', string.punctuation))
    words = text.lower().split()
    return [word for word in words if word not in stopwords]

def extract_top_keywords(row, columns, stopwords, top_n=8):
    """
    Extract the top N keywords from the specified columns of a row.

    Parameters:
    row (pd.Series): The row of the dataframe.
    columns (list): List of column names to analyze.
    stopwords (set): A set of stopwords to be removed.
    top_n (int): Number of top keywords to extract.

    Returns:
    str: A string of the top N keywords separated by commas.
    """
    combined_text = ' '.join(row[col] for col in columns if col in row and not pd.isna(row[col]))
    words = clean_and_split(combined_text, stopwords)
    word_count = Counter(words)
    top_keywords = [word for word, count in word_count.most_common(top_n)]
    return ', '.join(top_keywords)

def main():
    # Load the dataset
    file_path = 'path_to_your_dataset.csv'
    df = pd.read_csv(file_path)

    # Define the columns to analyze and the list of stopwords
    columns_to_analyze = ['Control', 'Expected Evidence', 'Extra Guidance']
    manual_stop_words = set([
        "i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", 
        "yourself", "yourselves", "he", "him", "his", "himself", "she", "her", "hers", 
        "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themselves", 
        "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", 
        "was", "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", 
        "did", "doing", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until", 
        "while", "of", "at", "by", "for", "with", "about", "against", "between", "into", 
        "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", 
        "in", "out", "on", "off", "over", "under", "again", "further", "then", "once", "here", 
        "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", 
        "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", 
        "than", "too", "very", "s", "t", "can", "will", "just", "don", "should", "now"
    ])

    # Create a new column 'Keywords' and apply the keyword extraction function to each row
    df['Keywords'] = df.apply(lambda row: extract_top_keywords(row, columns_to_analyze, manual_stop_words), axis=1)

    # Save the modified dataframe with the new 'Keywords' column
    output_file_path = 'path_to_your_output_dataset.csv'
    df.to_csv(output_file_path, index=False)

if __name__ == "__main__":
    main()
