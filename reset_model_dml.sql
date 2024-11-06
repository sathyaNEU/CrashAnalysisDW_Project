delete from most_common_factor_bdg;
delete from vehicle_involved_bdg;
delete from crash_fct;
delete from time_dim;
delete from date_dim;
delete from source_dim;
delete from address_dim;
delete from contrib_factor_dim;
delete from vehicle_type_dim;

dbcc checkident('most_common_factor_bdg',reseed, 0)
dbcc checkident('vehicle_involved_bdg',reseed, 0)
dbcc checkident('crash_fct',reseed, 0)
dbcc checkident('source_dim',reseed, 0)
dbcc checkident('address_dim',reseed, 0)
dbcc checkident('contrib_factor_dim',reseed, 0)
dbcc checkident('vehicle_type_dim',reseed, 0)

--ALTER INDEX <INDEX_NAME> ON <TABLE_NAME> <REBUILD/DISABLE>


