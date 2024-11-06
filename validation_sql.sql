--sql validation queries for PBI and Tableau

--how many accidents occurred in nyc, austin and chicago
	select isnull(b.city,'TOTAL') as City, count(crash_sk) accident_count from crash_fct a join address_dim b on a.address_sk = b.address_sk 
	group by grouping sets((b.city),())

--which areas in the 3 cities had the greatest number of accidents
	-- by street name 
	with cte1 as (
	select b.city, b.street_name, count(a.crash_sk) accident_count from crash_fct a join address_dim b on a.address_sk = b.address_sk 
	where b.street_name!='UNKNOWN'
	group by b.city,b.street_name), cte2 as (
	select cte1.*, dense_rank() over(partition by cte1.city order by cte1.accident_count desc) as rnk  from cte1)
	select cte2.* from cte2 where cte2.rnk<=3

	-- by lot long location
	with cte1 as (
	select b.city, b.latitude,b.longitude, count(a.crash_sk) accident_count from crash_fct a join address_dim b on a.address_sk = b.address_sk 
	where b.latitude!='0' and b.longitude!='0'
	group by b.city,b.latitude,b.longitude), cte2 as (
	select cte1.*, dense_rank() over(partition by cte1.city order by cte1.accident_count desc) as rnk  from cte1)
	select cte2.* from cte2 where cte2.rnk<=3

--how many accidents resulted in just injuries --verified
	-- by city and overall
		select isnull(b.city, 'TOTAL') as City ,count(crash_sk) ACCIDENT_COUNT from crash_fct a join
		address_dim b on a.address_sk = b.address_sk 
		where tot_injry_cnt>0
		group by grouping sets((b.city),())

--how often are pedestrians involved in accidents --verified
	-- by city and overall
		select isnull(b.city, 'TOTAL') as City, count(crash_sk) accident_count from crash_fct a join address_dim b on a.address_sk = b.address_sk
		where pedestrian_fl=1
		group by grouping sets((b.city),())

--when do most accidents happen --verified
	-- season (fall/spring/summer/winter)
		select isnull(b.season, 'TOTAL ACCIDENTS') SEASON, count(crash_sk) ACCIDENT_COUNT from crash_fct a 
		join date_dim b on a.crash_date_sk = b.date_sk 
		group by grouping sets(( b.season ) ,())

--how many motorists are injured or killed in accidents --verified
	-- by city and overall
		select isnull(b.city, 'TOTAL') as City, sum(motorist_injry_or_killed_cnt) accident_count from crash_fct a 
		join address_dim b on a.address_sk = b.address_sk
		group by grouping sets((b.city),())

--which top 5 areas in 3 cities have the most fatal number of accidents --verified
	--street name wise
		with cte as(
		select b.city, b.street_name, sum(tot_fatal_cnt) accident_count from crash_fct a
		join address_dim b on a.address_sk = b.address_sk
		group by b.city, b.street_name),
		cte1 as (
		select cte.*, DENSE_RANK() over(partition by cte.city order by cte.accident_count desc) rnk from cte), cte2 as
		(select top 5 * from cte1 where cte1.city='AUSTIN' and cte1.rnk<=5 order by cte1.city, cte1.rnk, cte1.street_name
		union all
		select top 5 * from cte1 where cte1.city='CHICAGO' and cte1.rnk<=5 order by cte1.city, cte1.rnk, cte1.street_name
		union all
		select top 5 * from cte1 where cte1.city='NEW YORK' and cte1.rnk<=5 order by cte1.city, cte1.rnk, cte1.street_name)
		select * from cte2;

		-- lat long wise
		with cte as(
		select b.city, b.latitude, b.longitude, sum(tot_fatal_cnt) accident_count from crash_fct a
		join address_dim b on a.address_sk = b.address_sk
		where b.latitude!='0' and b.longitude!='0'
		group by b.city, b.latitude, b.longitude),
		cte1 as (
		select cte.*, DENSE_RANK() over(partition by cte.city order by cte.accident_count desc) rnk from cte), cte2 as
		(select top 5 * from cte1 where cte1.city='AUSTIN' and cte1.rnk<=5 order by cte1.city, cte1.rnk, cte1.latitude, cte1.longitude
		union all
		select top 5 * from cte1 where cte1.city='CHICAGO' and cte1.rnk<=5 order by cte1.city, cte1.rnk, cte1.latitude, cte1.longitude
		union all
		select top 5 * from cte1 where cte1.city='NEW YORK' and cte1.rnk<=5 order by cte1.city, cte1.rnk, cte1.latitude, cte1.longitude)
		select * from cte2;

--time based analysis for accidents --verified
		-- time (morning/afternoon/evening/night)
			select b.time_category, count(a.crash_sk) accident_count from crash_fct a 
			join time_dim b on a.time_sk = b.time_sk group by b.time_category

		-- time + date(day wise accidents + night(optional))
			select isnull(b.calendar_day_in_words, 'TOTAL ACCIDENTS') 'DAY', count(crash_sk) ACCIDENT_COUNT from crash_fct a join date_dim b on a.crash_date_sk = b.date_sk 
			group by grouping sets((b.calendar_day_in_words),())

			select isnull(b.calendar_day_in_words, 'TOTAL ACCIDENTS') 'DAY', isnull(c.time_category, 'NIGHT') 'TIME',count(crash_sk) ACCIDENT_COUNT from crash_fct a 
			join date_dim b on a.crash_date_sk = b.date_sk 
			join time_dim c on a.time_sk = c.time_sk
			where c.time_category='NIGHT'
			group by grouping sets((b.calendar_day_in_words, c.time_category),())

		-- time (am/pm)
			select isnull(cast(b.am_or_pm as varchar(20)), 'TOTAL_ACCIDENTS') 'AM/PM', count(crash_sk) ACCIDENT_COUNT from crash_fct a 
			join time_dim b on a.time_sk = b.time_sk
			group by grouping sets((b.am_or_pm),())

		-- time + date(weekend vs weekday accidents + night(optional))
			select isnull(cast(b.weekend_indicator_in_words as varchar(20)), 'TOTAL_ACCIDENTS') 'WEEKEND / WEEKDAY', count(crash_sk) ACCIDENT_COUNT from crash_fct a 
			join date_dim b on a.crash_date_sk = b.date_sk
			group by grouping sets((weekend_indicator_in_words),())

			select isnull(cast(b.weekend_indicator_in_words as varchar(20)), 'TOTAL_ACCIDENTS') 'WEEKEND / WEEKDAY',isnull(c.time_category, 'NIGHT') 'TIME',  count(crash_sk) ACCIDENT_COUNT from crash_fct a 
			join date_dim b on a.crash_date_sk = b.date_sk
			join time_dim c on a.time_sk = c.time_sk
			where c.time_category='NIGHT'
			group by grouping sets((weekend_indicator_in_words,c.time_category),())

--are pedestrians killed more often than road users --verified
		select sum(pedestrian_falal_cnt) pedestrial_fatal_cnt, sum(motorist_fatal_cnt) road_user_fatal_cnt from crash_fct

--what are the common factors involved in accidents --verified
		select b.contrib_factor, count(a.contrib_factor_sk) contrib_factor_cnt from most_common_factor_bdg a  
		join contrib_factor_dim b on a.contrib_factor_sk = b.contrib_factor_sk
		where contrib_factor != 'UNABLE TO DETERMINE' and contrib_factor != 'OTHER'
		group by b.contrib_factor order by contrib_factor_cnt desc

-- number of accidents that involved more than two vehicles (comparision between nyc and austin) --verified
		with cte as (
		select d.city, a.crash_sk, count(a.vehicle_involved_sk) vehicle_involved from vehicle_involved_bdg a 
		join vehicle_type_dim b on a.vehicle_sk = b.vehicle_sk
		join crash_fct c on a.crash_sk = c.crash_sk
		join address_dim d on c.address_sk = d.address_sk
		group by d.city, a.crash_sk
		having count(a.vehicle_involved_sk)>2)
		select city, count(crash_sk) ACCIDENT_COUNT from cte group by city


-- row count verification
select  isnull(a.tbl,'Total Rows') as tbl, sum(a.rowcnt) Row_Count from (
select 'stg_autin' as tbl ,count(crash_id) rowcnt from stg_austin
union all
select 'stg_chicago' , count(CRASH_RECORD_ID) from stg_chicago
union all
select 'stg_ny', count(COLLISION_ID) from stg_ny
union all
select 'stg_austin_v2', count(crash_id) from stg_austin_v2
union all
select 'stg_chicago_v2',count(CRASH_RECORD_ID) from stg_chicago_v2
union all
select 'stg_ny_v2', count(COLLISION_ID) from stg_ny_v2
union all
select 'stg_ny_austin_vehicle_type', count(crash_id) from stg_ny_austin_vehicle_type
union all
select 'date_dim',count(date_sk) from date_dim
union all
select 'time_dim',count(time_sk) from time_dim
union all
select 'address_dim',count(address_sk) from address_dim
union all
select 'soruce_dim', count(source_id) from source_dim
union all
select 'vehicle_type_dim', count(vehicle_sk) from vehicle_type_dim
union all
select 'contrib_factor_dim', count(contrib_factor_sk) from contrib_factor_dim
union all
select 'crash_fct', count(crash_sk) from crash_fct
union all
select 'most_common_factor_bdg', count(most_com_factor_sk) from most_common_factor_bdg
union all
select 'vehicle_involved_bdg', count(vehicle_involved_sk) from vehicle_involved_bdg
) a group by grouping sets(a.tbl,());
