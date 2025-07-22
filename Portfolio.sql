/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions,Aggregate functions, Creating Views, Converting Data Types
*/

select * FROM Portfolio.`coviddeaths(coviddeaths)`
Where continent is not null
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio.`coviddeaths(coviddeaths)`
Where continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from Portfolio.`coviddeaths(coviddeaths)`
where location like '%states%' and continent is not null
order by 1,2;

-- Looking at total cases vs population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases, population, (total_cases/population) *100 as DeathPercentage
from Portfolio.`coviddeaths(coviddeaths)`
where location like '%states%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio.`coviddeaths(coviddeaths)`
Group by Location, population
order by PercentPopulationinfected desc;

 -- Countries with Highest Death Count per Population
 
Select location, max(total_deaths) as TotalDeathCount
From Portfolio.`coviddeaths(coviddeaths)`
Where continent is not null
Group by location
order by TotalDeathCount desc;

-- Breaking things down by continent
-- Showing continents with the highest death count per population

 

Select continent, max(total_deaths) as TotalDeathCount
From Portfolio.`coviddeaths(coviddeaths)`
Where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Global numbers
Select  SUM(new_cases) as total_cases,SUM(new_deaths)as total_deaths, SUM(new_deaths/new_cases)*100 as DeathPercentage
From Portfolio.`coviddeaths(coviddeaths)`
where continent is not null 
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select*
From Portfolio.`coviddeaths(coviddeaths)`dea
Join Portfolio.`covidvaccinations(covidvaccinations)`vac
On dea.location=vac.location
and dea.date=vac.date;

Select dea.continent, dea.location, dea.date, dea.population, 
CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations
From Portfolio.`coviddeaths(coviddeaths)`as dea
Join Portfolio.`covidvaccinations(covidvaccinations)`as vac
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
order by 2,3;

Select dea.continent, dea.location, dea.date, dea.population,
CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date,dea.location
    ) AS RollingPeopleVaccinated
From Portfolio.`coviddeaths(coviddeaths)`AS dea
Join Portfolio.`covidvaccinations(covidvaccinations)` AS vac
On dea.location=vac.location
AND dea.date=vac.date
WHERE
dea.continent IS NOT NULL
order by 2,3;

Select dea.continent, dea.location, dea.date, dea.population,
CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date,dea.location
    ) AS RollingPeopleVaccinated
 --   ,(RollingPeopleVaccinated/population)*100
From Portfolio.`coviddeaths(coviddeaths)`AS dea
Join Portfolio.`covidvaccinations(covidvaccinations)` AS vac
On dea.location=vac.location
AND dea.date=vac.date
WHERE
dea.continent IS NOT NULL
order by 2,3;

-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,
CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date,dea.location
    ) AS RollingPeopleVaccinated
 --   ,(RollingPeopleVaccinated/population)*100
From Portfolio.`coviddeaths(coviddeaths)`AS dea
Join Portfolio.`covidvaccinations(covidvaccinations)` AS vac
On dea.location=vac.location
AND dea.date=vac.date
WHERE
dea.continent IS NOT NULL

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Temporary TABLE if EXISTS PercentPopulationVaccinated;

CREATE Temporary TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date DATE,
Population decimal(20,2),
New_vaccinations INT,
RollingPeopleVaccinated BIGINT
);

INSERT INTO PercentPopulationVaccinated
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population,
CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date,dea.location
    ) AS RollingPeopleVaccinated
 --   ,(RollingPeopleVaccinated/population)*100
From Portfolio.`coviddeaths(coviddeaths)`AS dea
Join Portfolio.`covidvaccinations(covidvaccinations)` AS vac
On dea.location=vac.location
AND dea.date=vac.date
WHERE
dea.continent IS NOT NULL;

Select 
*, 
CASE 
        WHEN Population IS NULL OR Population = 0 THEN NULL
        ELSE (RollingPeopleVaccinated / Population) * 100
    END AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,
CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date,dea.location
    ) AS RollingPeopleVaccinated
From Portfolio.`coviddeaths(coviddeaths)`AS dea
Join Portfolio.`covidvaccinations(covidvaccinations)` AS vac
On dea.location=vac.location
AND dea.date=vac.date
WHERE
dea.continent IS NOT NULL;

Select * 
From PercentPopulationVaccinated;


 
  
   












