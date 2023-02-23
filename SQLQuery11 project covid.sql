select *
from ['coivdDeaths $'] 
where continent is not null 
order by 3,4

--select * 
--from CovidVaccinations$
--order by 3,4

select continent, date, total_cases, new_cases, total_deaths, population
from ['coivdDeaths $']
order by 1,2



--looking at total cases vs total deaths
--shows liklihood of dying if you contact covid in your country

select continent, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as percentpopulationinfected
from ['coivdDeaths $']
where continent like '%states%'
order by 1,2

--looking at totals vs population
--Shows what percentage of population got covid

select continent, date, total_cases, population, (total_cases/population)*100 as deathpercentage 
from ['coivdDeaths $']
where continent like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population 

select continent, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentepopulationinfected 
from ['coivdDeaths $']
--where location like '%states%'
group by continent, population 
order by percentepopulationinfected desc

--showing countries with highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathscount
from ['coivdDeaths $']
--where location like '%states%'
where continent is not null 
group by continent
order by totaldeathscount desc

--lets break things down by continent

select continent, max(cast(total_deaths as int)) as totaldeathscount
from ['coivdDeaths $']
--where location like '%states%'
where continent is not null 
group by continent
order by totaldeathscount desc

--showing continents with highest death count per population 

select continent, max(cast(total_deaths as int)) as totaldeathscount
from ['coivdDeaths $']
--where location like '%states%'
where continent is not null 
group by continent
order by totaldeathscount desc

--global number

select sum(new_cases) as tota_Cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_Cases)*100 as deathpercentage
from ['coivdDeaths $']
--where location '%state%'
where continent is not null
--group by date
order by 1,2 




--looking at total population vs vaccinations 

--watch where you are pulling from if it is not in the table it will not work!!

--use cte

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from CovidVaccinations$ vac
join ['coivdDeaths $'] dea
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from CovidVaccinations$ vac
join ['coivdDeaths $'] dea
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3

	select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated




--creating view to store date for later visual

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from CovidVaccinations$ vac
join ['coivdDeaths $'] dea
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3

	select *
	from percentpopulationvaccinated