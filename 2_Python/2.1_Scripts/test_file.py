import pandas as pd
import numpy as np

df = pd.read_csv(r"E:\Work\DataSciencePortfolio\0_Data\0.1_Raw\0.1.01_avocado_prices\avocado.csv")

# Observe the file
print(df.head())  # First 5 rows
print(df.info())  # Column types and missing values
print(df.describe())  # Basic stats for numerical columns

# Practice Querying

# SQL: SELECT * FROM df WHERE region = 'West' AND AveragePrice > 2.0
df_filtered = df.query("region == 'West' and AveragePrice > 2.0")
print(df_filtered)

# National-level data
df_national = df[df['region'] == 'TotalUS'].copy()

# Regional data (exclude national)
df_regional = df[df['region'] != 'TotalUS'].copy()

# Compare sum of regional volumes to TotalUS entries for a given date/type
sample_date = '2017-01-01'
sample_type = 'conventional'

# Sum of all regions (excluding TotalUS)
regional_sum = df_regional.query("Date == @sample_date and type == @sample_type")['Total Volume'].sum()

# TotalUS value for the same date/type
totalus_value = df_national.query("Date == @sample_date and type == @sample_type")['Total Volume'].values[0]

print(f"Regional sum: {regional_sum}, TotalUS: {totalus_value}, Match: {np.isclose(regional_sum, totalus_value)}")

sample_regions = df_regional.query("Date == @sample_date and type == @sample_type")['region'].unique()
print(sample_regions)