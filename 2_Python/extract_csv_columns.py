import os
import csv

filepath01 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\01_avocado_prices\0_Raw\avocado.csv'))
filepath02 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\02_heart_failure_prediction_dataset\0_Raw\heart.csv'))
filepath03 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\03_data_science_salaries_2023\0_Raw\ds_salaries.csv'))
filepath04 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\04_vehicle_dataset\0_Raw\car details v4.csv')) 
filepath05a = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\05_ipl_complete_dataset_(2008-2024)\0_Raw\deliveries.csv'))
filepath05b = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\05_ipl_complete_dataset_(2008-2024)\0_Raw\matches.csv'))
filepath06 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\06_latest_covid-19_india_statewise_data\0_Raw\Latest Covid-19 India Status.csv'))
filepath07 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\07_emergency_-_911_calls\0_Raw\911.csv'))
filepath08 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\08_shop_customer_data\0_Raw\Customers.csv'))
filepath09 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\09_google_play_store_apps\0_Raw\Google-Playstore.csv'))
filepath10 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\10_the_human_freedom_index\0_Raw\hfi_cc_2022.csv'))
filepath11 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\11_jobs_and_salaries_in_data_science\0_Raw\jobs_in_data.csv'))
filepath12 = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', r'0_Data\12_airbnb_open_data\0_Raw\Airbnb_Open_Data.csv'))
path_list = [filepath01, filepath02, filepath03, filepath04,filepath05a, filepath05b, filepath06,
             filepath07, filepath08,filepath09, filepath10, filepath11, filepath12]
name_list = ['01', '02', '03', '04', '05a', '05b', '06', '07', '08', '09','10', '11', '12']

# Prints out the column names of each CSV file. Works even with 100+ columns, more efficient than pandas df.
for file, i in zip(path_list, name_list):
    with open(file, encoding="utf8") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        header = next(csv_reader)
    print(f"\nList of column names in Dataset {i}:\n", header)