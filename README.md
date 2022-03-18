Many People are using PowerBI and they wanted to build Organization level dashboard to monitor snowflake environment in one centralized location using live query feature. 

To build Operational Dashboard we have leveraged Snowflake Task and Data sharing features. 

Currently in organization we have support for below two views:

WAREHOUSE_METERING_HISTORY 

STORAGE_DAILY_HISTORY

In this operational dashboard we are going to use below views data:

LOGIN_HISTORY

QUERY_HISTORY

WAREHOUSE_METERING_HISTORY

DATABASE_STORAGE_USAGE_HISTORY

We can add additional views as part of the process. It is all based on the customer requirements. 

Pre-requisites:

Decide the Consumer Account where the org level Dashboard will be hosted

List of accounts needs to be monitor using the centralized dashboard

Below are the steps involved sharing the usage history data to consumer account. 

Create database database ORGANIZATION and schema LOCAL_ACCOUNT_USAGE 

Build Local copy of the  above 4 views and refresh the views. By creating the copy of the views you can retain usage data to meet audit requirements (Snowflake  shared database has limit of maximum of 1 year) 

Create Task to refresh the views based on frequency you need to refresh the data

Share the views to consumer account where organization dashboard will be hosted.

In Consumer Account create database ORGANIZATION and schema CONSOLIDATED_ACCOUNT_USAGE

Create objects and procedures which needed to build the consolidated views

Create a role and grant necessary permission on organization database and organization_usage schema.

Build Dashboards in PowerBI using Live query

Security

<img width="1040" alt="image" src="https://user-images.githubusercontent.com/81976357/159076679-16ad0bce-414a-4808-b62c-46a8356a745f.png">

Consumption
<img width="1040" alt="image" src="https://user-images.githubusercontent.com/81976357/159076789-c68b8c9e-d23c-488b-b491-c7145f3d2608.png">

Performance
<img width="1040" alt="image" src="https://user-images.githubusercontent.com/81976357/159076821-445591d4-1aa1-494f-84bb-9fe3b3331d6b.png">


Storage Trends 

<img width="1040" alt="image" src="https://user-images.githubusercontent.com/81976357/159076882-4b88a091-b185-4a5e-925d-c2509659e87e.png">

To setup the snowflake environment, execute below two scripts. 
1. For each account execute LOCAL_ACCOUNT_USAGE_SETUP.SQL
2. For Centraolized Account CONSOLIDATED_ACCOUNT_USAGE_SETUP.SQL and LOCAL_ACCOUNT_USAGE_SETUP.SQL(to get local account informations)
