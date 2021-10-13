select *
from [Portfolio Projects]..[Covid-19 Deaths]
order by 3,4

--select *
--from [Portfolio Projects]..[Covid-19 Vaccination]
--order by 3,4

select location, date, total_cases,	new_cases, total_deaths, population
from [Portfolio Projects]..[Covid-19 Deaths]
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid-19 in India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from [Portfolio Projects]..[Covid-19 Deaths]
where location like '%India%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid in Australia

select location, date, total_cases, population, (total_cases/population)*100 as percentageOFcases
from [Portfolio Projects]..[Covid-19 Deaths]
where location like '%Australia%'
order by 1,2

--Looking at countries with highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectedRate, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Projects]..[Covid-19 Deaths]
--where location like '%Australia%'
GROUP BY location, population
Order by PercentPopulationInfected desc


--Showing countries with highest Death count per population

select location, Max(cast(total_deaths as int))as TotalDeathCount 
from [Portfolio Projects]..[Covid-19 Deaths]
where continent is not null
Group by location
order by TotalDeathCount desc

--Death count per continent
select location, Max(cast(total_deaths as int))as TotalDeathCount 
from [Portfolio Projects]..[Covid-19 Deaths]
where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers
Select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Projects]..[Covid-19 Deaths]
where continent is not null
Group by date
Order by 1,2

--Looking at Total Vaccination vs population by using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccination
from [Portfolio Projects]..[Covid-19 Deaths] dea
join [Portfolio Projects]..[Covid-19 Vaccination] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingVaccination/population)*100
from PopvsVac



--Looking at Total Vaccination vs population by using TEMP Table

Drop table if exists #VaccinatedPopulation

Create Table #VaccinatedPopulation
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccination numeric
)

Insert into  #VaccinatedPopulation
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccination
from [Portfolio Projects]..[Covid-19 Deaths] dea
join [Portfolio Projects]..[Covid-19 Vaccination] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingVaccination/population)*100
from #VaccinatedPopulation

--Creating a View for Visualisations

create view VaccinatedPopulation as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccination
from [Portfolio Projects]..[Covid-19 Deaths] dea
join [Portfolio Projects]..[Covid-19 Vaccination] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
