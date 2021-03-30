--1
select v.tariff,
--       uniqExact(idhash_view) as u_views,
       count(idhash_view) as views,
       countIf(idhash_order, idhash_order > 0) as orders,
       countIf(da_dttm, da_dttm is not null) as driver_appointed,
       countIf(rfc_dttm, rfc_dttm is not null) as car_is_served,
       countIf(cc_dttm, cc_dttm is not null) as client_in_car,
       countIf(status, status = 'CP') as success_orders,
       views - orders as dif1,
       orders - driver_appointed as dif2,
       driver_appointed - car_is_served as dif3,
       car_is_served - client_in_car as dif4,
       client_in_car - success_orders as dif5
from data_analysis.views v
    left join data_analysis.orders o on o.idhash_order = v.idhash_order
group by v.tariff;
-- Видно, что большие потери идут на конверсии просмотра в заказ
-- и конверсии заказа в назначенного водителя

--2
--По каждому клиенту вывести топ используемых им
--тарифов по убыванию в массиве, а также подсчитать
--сколькими тарифами он пользуется.
select idhash_client,
       groupArray(tariff) as tariffs,
       groupArray(tariff_use) as tariff_uses,
       arrayReverseSort((x, y) -> y, tariffs, tariff_uses) as top_tariffs,
       length(tariffs) as number_of_used_tariffs
from
    (select
           idhash_client,
           tariff,
           count(idhash_order) as tariff_use
    from data_analysis.views v
        join data_analysis.orders o on o.idhash_order = v.idhash_order
    where status = 'CP'
    group by idhash_client, tariff)
group by idhash_client;

--3
--Вывести топ 10 гексагонов (размер 7) из которых уезжают
--с 7 до 10 утра и в которые едут с 18-00 до 20-00 в сумме
--по всем дням
select
       b.h3_from as h3,
       b.incomes_from + a.incomes_to as total_incomes
from (
    select if (toHour(cc_dttm) >=18 and toHour(cc_dttm) < 20, geoToH3(del_longitude, del_latitude, 7), null)
            h3_to,
           count(*) as incomes_to
    from data_analysis.views v
        join data_analysis.orders o on o.idhash_order = v.idhash_order
    where status = 'CP' and h3_to is not null
    group by h3_to
         ) a
join (
    select if (toHour(cc_dttm) >=8 and toHour(cc_dttm) < 10, geoToH3(longitude, latitude, 7), null) as h3_from,
           count(*) as incomes_from
    from data_analysis.views v
        join data_analysis.orders o on o.idhash_order = v.idhash_order
    where status = 'CP' and h3_from is not null
    group by h3_from
    ) b on b.h3_from = a.h3_to
order by total_incomes desc
limit 10;

--4
--Вывести медиану и 95 квантиль времени поиска водителя.
select
       median(dateDiff('second', order_dttm,  da_dttm)) as median_search_time,
       quantile(0.95)(dateDiff('second', order_dttm,  da_dttm)) as quantile_95_bill
from data_analysis.orders
where da_dttm is not null;