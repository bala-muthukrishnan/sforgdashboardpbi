use role sysadmin;
create database if not exists organization;
create schema if not exists ORGANIZATION.LOCAL_ACCOUNT_USAGE;

-- Query History 
create table if not exists LOCAL_ACCOUNT_USAGE.query_history as select current_account() as account_name,* from snowflake.account_usage.query_history;

--insert into usage_history.query_history select current_account(),*  from snowflake.account_usage.query_history where start_time > (select max(start_time) from usage_history.query_history);

-- Login History 
create table if not exists LOCAL_ACCOUNT_USAGE.login_history as select current_account() as account_name,*  from snowflake.account_usage.login_history;

--insert into usage_history.login_history select current_account(),*  from snowflake.account_usage.login_history where EVENT_TIMESTAMP > (select max(EVENT_TIMESTAMP) from usage_history.login_history);

-- Warehouse Meetirng History
create table if not exists LOCAL_ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY as select current_account() as account_name,*  from snowflake.account_usage.WAREHOUSE_METERING_HISTORY;

--insert into usage_history.WAREHOUSE_METERING_HISTORY select * from snowflake.account_usage.WAREHOUSE_METERING_HISTORY where start_time > (select max(start_time) from usage_history.WAREHOUSE_METERING_HISTORY);

-- Database Usage History 

create table  if not exists LOCAL_ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY as select current_account() as account_name,*  from snowflake.account_usage.DATABASE_STORAGE_USAGE_HISTORY;

--insert into usage_history.DATABASE_STORAGE_USAGE_HISTORY select current_account(),*  from snowflake.account_usage.DATABASE_STORAGE_USAGE_HISTORY where usage_date > (select max(usage_date) from usage_history.DATABASE_STORAGE_USAGE_HISTORY);

-- Proc to update usage_history 

create or replace procedure LOCAL_ACCOUNT_USAGE.update_usage_history()
returns varchar()
language javascript
EXECUTE AS CALLER
as 
$$
var result="";
try 
{
      var sql_stmt1 = snowflake.createStatement(
      { sqlText: "insert into ORGANIZATION.LOCAL_ACCOUNT_USAGE.query_history select current_account(),*  from snowflake.account_usage.query_history where start_time > (select max(start_time) from usage_history.query_history)" } );
      var result_1 = sql_stmt1.execute();
      
      var sql_stmt2 = snowflake.createStatement(
      { sqlText: "insert into ORGANIZATION.LOCAL_ACCOUNT_USAGE.login_history select current_account(),*  from snowflake.account_usage.login_history where EVENT_TIMESTAMP > (select max(EVENT_TIMESTAMP) from usage_history.login_history)" } );
      var result_2 = sql_stmt2.execute();
      
      var sql_stmt3 = snowflake.createStatement(
      { sqlText: "insert into ORGANIZATION.LOCAL_ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY select current_account(),*  from snowflake.account_usage.WAREHOUSE_METERING_HISTORY where start_time > (select max(start_time) from usage_history.WAREHOUSE_METERING_HISTORY)" } );
      var result_3 = sql_stmt3.execute();
      
      var sql_stmt4 = snowflake.createStatement(
      { sqlText: "insert into ORGANIZATION.LOCAL_ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY select current_account(),*  from snowflake.account_usage.DATABASE_STORAGE_USAGE_HISTORY where usage_date > (select max(usage_date) from usage_history.DATABASE_STORAGE_USAGE_HISTORY)" } );
      var result_4 = sql_stmt4.execute();
      
      
      result="Proc Executed Successfully";
}     
      catch (err) 
      {
      result =  "Failed: Code: " + err.code + "  State: " + err.state;
      result += "  Message: " + err.message;
      result += "Stack Trace:" + err.stackTraceTxt; 
     }
return result;

$$
;

-- Execute the proc 
call ORGANIZATION.LOCAL_ACCOUNT_USAGE.update_usage_history();

-- Task to update usage_history schema given schedule 
CREATE TASK IF NOT EXISTS UPDATE_USAGE_HISTORY_TASK
SCHEDULE = 'USING CRON 0 9 * * * America/Los_Angeles'
  WAREHOUSE='SYSADMIN_WH'
AS
call ORGANIZATION.LOCAL_ACCOUNT_USAGE.update_usage_history();


-- Resume the Task 
ALTER TASK UPDATE_USAGE_HISTORY_TASK RESUME;


-- ALTER TASK UPDATE_USAGE_HISTORY_TASK SUSPEND;
-- Verify the Taks runs

select *
  from table(information_schema.task_history(scheduled_time_range_start=>dateadd('hour',-1,current_timestamp()),
    result_limit => 10,
    task_name=>'UPDATE_USAGE_HISTORY_TASK'))
order by scheduled_time DESC;


use role accountadmin;
CREATE SHARE LOCAL_ACCOUNT_USAGE_SHARE;
GRANT REFERENCE_USAGE ON DATABASE ORGANIZATION TO SHARE LOCAL_ACCOUNT_USAGE_SHARE;
GRANT USAGE ON SCHEMA ORGANIZATION.LOCAL_ACCOUNT_USAGE TO SHARE LOCAL_ACCOUNT_USAGE_SHARE;
GRANT SELECT ON ALL TABLES IN SCHEMA ORGANIZATION.LOCAL_ACCOUNT_USAGE TO SHARE LOCAL_ACCOUNT_USAGE_SHARE;
ALTER SHARE LOCAL_ACCOUNT_USAGE_SHARE ADD accounts=<centrailized_account>;

