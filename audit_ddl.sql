create table etl_job (
job_id int identity(1,1) primary key,
job_name varchar(100))

create table etl_job_log (
job_log_id int identity(1,1) primary key,
job_id int,
start_time datetime,
end_time datetime,
job_run_time_in_seconds int,
rows_read_at_target int,
rows_inserted_in_target int,
status varchar(20),
foreign key(job_id) references etl_job(job_id) on delete cascade
)
