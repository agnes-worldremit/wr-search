-- combined SEO (gsc) and PPC (Google Ads) query level data

-- GSC search query data
create or replace view personal_space_db.abungsy_stg.v_onesearch_queries_monhtly as
with
 combined  as
  (select  Yrmonth, country_name, region_name, sub_region_name,device, keyword, is_tracked, category
         ,0 as seo_clicks, 0 as seo_impressions, 0 as seo_position_total
          , ppc_impressions ,  ppc_clicks,  ppc_cost
         from personal_space_db.abungsy_stg.v_ppc_queries
         where  datediff(month, date, CURRENT_DATE()) > 0   -- exclude current month
                and datediff(day, date, CURRENT_DATE()) > 3  -- pull data up to 3 days ago only (gsc data usually is available 3 days late)
        UNION ALL
  select Yrmonth, country_name, region_name, sub_region_name,device, keyword, is_tracked, category
         , seo_clicks, seo_impressions, seo_position_total
          , 0 as ppc_impressions, 0 as ppc_clicks, 0 as ppc_cost
         from personal_space_db.abungsy_stg.v_gsc_queries
           where  datediff(month, date, CURRENT_DATE()) > 0   -- exclude current month
                and datediff(day, date, CURRENT_DATE()) > 3  -- pull data up to 3 days ago only (gsc data usually is available 3 days late)
        )

select  -- date
--, Yrmonth
  (CASE WHEN (NOT (CAST(TO_TIMESTAMP(Yrmonth, 'YYYY-MM') AS DATE) IS NULL)) THEN CAST(TO_TIMESTAMP(Yrmonth, 'YYYY-MM') AS DATE) WHEN (NOT (TRY_CAST(Yrmonth AS DATE) IS NULL)) THEN TRY_CAST(Yrmonth AS DATE) ELSE NULL END) AS "YRMONTH"

--,week_start
--, week_ending
--  ,(CASE WHEN (NOT (CAST(TO_TIMESTAMP(week_ending, 'YYYY-MM-DD') AS DATE) IS NULL)) THEN CAST(TO_TIMESTAMP(week_ending, 'YYYY-MM-DD') AS DATE) WHEN (NOT (TRY_CAST(week_ending AS DATE) IS NULL)) THEN TRY_CAST(week_ending AS DATE) ELSE NULL END) AS "WEEK_ENDING"

, country_name, region_name, sub_region_name,device, keyword, is_tracked, category
   ,sum(seo_clicks) seo_clicks, sum(seo_impressions) seo_impressions, sum(seo_position_total) seo_position_total
   ,sum(ppc_impressions) ppc_impressions ,  sum(ppc_clicks) ppc_clicks,  sum(ppc_cost) ppc_cost
   ,sum(seo_clicks+ppc_clicks) as combined_clicks
from combined
group by Yrmonth, country_name, region_name, sub_region_name,device, keyword, is_tracked, category ;

/*

-- USEFUL CODE

-- preview the data
select * from  personal_space_db.abungsy_stg.v_onesearch_queries_monhtly limit 100;

-- show all data for a country
select *
from personal_space_db.abungsy_stg.v_onesearch_queries_monhtly
where country_name = 'United Kingdom'
order by combined_clicks desc nulls last

*/
