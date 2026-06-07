# sjrdata 1.0.25

2026-06-06

Update to include 2025 data

Refactoring of the main download functions to account for the introduction of cloudflare scraping blocking screen that https://www.scimagojr.com introduced. 

There were also changes introduced in the list of variables available for the journals: 
 - `sgd` variable, that was available from 2018 and covered Number of documents related to the Sustainable Development Goals defined by the United Nations according to the [Elsevier 2023 Sustainable Development Goals (SDGs) Mapping](https://elsevier.digitalcommonsdata.com/datasets/y2zyy9vwzy/1), is no longer reported;
 - two new dummy variables `open_access` and `open_acess_diamond` appeared.


# sjrdata 1.0.24

2025-07-04

Update to include 2024 data

In this update I revert back to downloading all the data yearly. This came out of a productive discussion with [Mark Hanson](https://bsky.app/profile/hansonmark.bsky.social), in which he pointed out that SciMago group sometimes changes the data backwards in their update, and that it is better to have a fresh copy of the data every year. Starting from this year I will save a copy of the data for each year in a parquet format.

# sjrdata 1.0.23

2024-04-22

Update to include 2023 data 

# sjrdata 0.5.0

2023-12-06

Update to include 2022 data 

# sjrdata 0.4.0

2022-05-18

Update to include 2020 and 2021 data 

# sjrdata 0.3.0

2020-06-21

Update to include 2019 data (tnx @robjhyndman)

# sjrdata 0.2.0

2019-09-19

Update to include 2018 data 


# sjrdata 0.1.0

2018-09-23

first release



