-- 1
select count(*)
from match
where first_blood_time > 60 and first_blood_time < 180;

-- 2
select p.account_id
from players p
        join match m on m.match_id = p.match_id
where m.radiant_win = 'True'
  and p.account_id != 0
  and m.negative_votes < m.positive_votes;

-- 3
select p.account_id, avg(m.duration)
from players p
        left join match m on m.match_id = p.match_id
group by p.account_id;

-- 4
select sum(p.gold_spent), count(distinct p.hero_id), avg(m.duration)
from players p
        join match m on m.match_id = p.match_id
where p.account_id = 0;

--5
select h.localized_name,
       count(m.match_id) all_match,
       avg(p.kills) avg_kills,
       min(p.deaths) min_deaths,
       max(p.gold_spent) max_gold_spent,
       sum(m.positive_votes) sum_pos,
       sum(m.negative_votes) sum_neg
from players p
    join match m on m.match_id = p.match_id
    right join hero_names h on p.hero_id = h.hero_id
group by h.localized_name;

--6
select distinct(match_id)
from purchase_log
where item_id = 42 and time > 100;

--7
select *
from purchase_log
limit 20;
select *
from match
limit 20;


