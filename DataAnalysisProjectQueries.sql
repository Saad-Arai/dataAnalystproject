Select * from DataAnalysisProject..CovidDeaths
where continent is not NULL
order by 3, 4

--Select * from DataAnalysisProject..Covidvacination
--order by 3, 4

-- Selecting data that we are using 

Select Location, date, total_cases, new_cases, total_deaths, population from DataAnalysisProject..CovidDeaths order by 1, 2

-- Distinguish b/w total cases and total deaths


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from DataAnalysisProject..CovidDeaths
where Location like '%Pakistan%'
order by 1, 2 

-- Looking at total cases vs total population

Select Location, date, population,total_cases, (total_cases/population)*100 as PositivePercentage
from DataAnalysisProject..CovidDeaths
where Location like '%Pakistan%'
order by 1, 2 

-- looking at countries with highest positive rate wrt population

Select Location, population, MAX(total_cases) as HighestCases, MAX((total_cases/population))*100 as PositivePercentage
from DataAnalysisProject..CovidDeaths
Group by location, population
order by PositivePercentage desc

-- Countries with highest death count 

Select location, MAX(cast(total_deaths as int)) as TotalDeaths from DataAnalysisProject..CovidDeaths 
where continent is not NULL
Group by location
order by TotalDeaths desc

-- Break down by continent



-- continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeaths from DataAnalysisProject..CovidDeaths 
where continent is not NULL
Group by continent
order by TotalDeaths desc

-- Global numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from DataAnalysisProject..CovidDeaths
-- where Location like '%Pakistan%'
where continent is not NULL
group by date
order by 1, 2 


-- New table
-- looking at total population vs total vacination

Select dea.location, dea.continent,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as PeopleVacinated
--(PeopleVacinated/population)*100
from DataAnalysisProject..CovidDeaths dea
join DataAnalysisProject..Covidvacination vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not NULL
order by 2,3

-- use CTE

with popvsvac (Continent,location,date,population,New_vaccinations,PeopleVacinated)
as 
(
Select dea.location, dea.continent,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as PeopleVacinated
--(PeopleVacinated/population)*100
from DataAnalysisProject..CovidDeaths dea
join DataAnalysisProject..Covidvacination vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not NULL
-- order by 2,3

)

Select * , (PeopleVacinated/population)*100 
from popvsvac 

-- temp table
drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
PeopleVacinated numeric
)
insert into #PercentPeopleVaccinated
Select dea.location, dea.continent,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as PeopleVacinated
--(PeopleVacinated/population)*100
from DataAnalysisProject..CovidDeaths dea
join DataAnalysisProject..Covidvacination vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.continent is not NULL
-- order by 2,3

Select * , (PeopleVacinated/population)*100 
from #PercentPeopleVaccinated 

--creating view to store data for future visualization
Create View PercentPeopleVaccinated  as 
Select dea.location, dea.continent,dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as PeopleVacinated
--(PeopleVacinated/population)*100
from DataAnalysisProject..CovidDeaths dea
join DataAnalysisProject..Covidvacination vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not NULL
--order by 2,3

select * from PercentPeopleVaccinated