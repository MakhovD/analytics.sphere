-- Проведем аналитику по героям
-- Во-первых составим рейтинг героев в разрезе каждого матча и посмотрим, сколько
-- на нем заработали и убили
with rate_heroes_by_match as (select hn.localized_name as name,
       p.kills as kills,
       p.gold as gold,
       row_number() over (partition by m.match_id order by p.kills desc) as kills_rate,
       row_number() over (partition by m.match_id order by p.gold desc) as gold_rate
from players p
    join hero_names hn on p.hero_id = hn.hero_id
    join match m on m.match_id = p.match_id
where m.duration > (select avg(duration) from match))

select name,
       sum(case when kills_rate = 1 then 1 else 0 end) as all_top_kills,
       sum(case when gold_rate = 1 then 1 else 0 end)  as all_top_gold
from rate_heroes_by_match
where (kills_rate = 1) or (gold_rate = 1)
group by name
order by 2 desc, 3 desc
limit 5;
--(Windranger, Shadow Fiend, Queen of Pain, Invoker, Slark)

-- Здесь я взял, топ убийц и топов по зароботку из каждого матча и посмотрел сколько раз
-- они были лучшими в каждой категории.
-- Вывел топ 5 убийц, которые заработали больше золота, если в рейтинге убийц они делят одну позицию.

-- Теперь посмотрим на героев в разделе кластера
-- Может быть азиаты опять решили брать героев поддержки на основные позиции))
with stat_hero_by_region as (select distinct(hn.localized_name) as name,
                cr.region as region,
                avg(kills) over(partition by hn.localized_name, cr.region) as avg_kills,
                count(m.match_id) over(partition by hn.localized_name, cr.region) as all_match
from match m
    join cluster_regions cr on m.cluster = cr.cluster
    join players p on m.match_id = p.match_id
    join hero_names hn on p.hero_id = hn.hero_id
where m.duration > (select avg(duration) from match))


select *
from
     (select region,
             name,
             all_match,
             row_number() over (partition by region order by avg_kills desc) kills_rate
    from stat_hero_by_region) as rate_by_region
where name in ('Windranger', 'Shadow Fiend', 'Queen of Pain', 'Invoker', 'Slark')
and (kills_rate between 1 and 5)
and all_match > 10
-- Посмотрели, какие места занимают наши героя из предыдущего запроса в рейтинге регионов
-- и посмотрели какие из них попали в топ 5.

--Изменяя последние 2 строки запроса, получили такие выводы

-- Видно, что Slark популярен во всех регионах и занимают высокие строчки рейтинга
-- Можно, сделать вывод, что персонаж достаточно простой и на нем легко убивать.

-- Shadow Fiend занимает топы только в азиатском секторе (они задроты и герой сложный)

-- Queen of Pain заняла неплохую строчку в Австрии и там же на ней сыграно много матчей

-- Invoker тоже хороший убийца, как мы выяснили, но из-за того, что герой сложный,
-- его среднее просаживается на регионах из-за того, что его берут новички

-- Windranger персонаж средней сложности и популярности, поэтому она ниже топов

--Если бы мы взяли просто топ регионов и не смотрели на количество сыгранных матчей,
-- то мы бы получили очень странную статистику)
with stat_hero_by_region as (select distinct(hn.localized_name) as name,
                cr.region as region,
                avg(kills) over(partition by hn.localized_name, cr.region) as avg_kills,
                count(m.match_id) over(partition by hn.localized_name, cr.region) as all_match
from match m
    join cluster_regions cr on m.cluster = cr.cluster
    join players p on m.match_id = p.match_id
    join hero_names hn on p.hero_id = hn.hero_id
where m.duration > (select avg(duration) from match))


select *
from
     (select region,
             name,
             all_match,
             row_number() over (partition by region order by avg_kills desc) kills_rate
    from stat_hero_by_region) as rate_by_region
where (kills_rate = 1)
and all_match > 10
-- Но если взять героев с хорошим количеством сыгранных матчей, можем выделить еще таких героев, как
-- Рики, Урса и Темплар Асасин



