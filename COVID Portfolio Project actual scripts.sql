/* COVID-19 Data Exploration */

SELECT * 
FROM COVIDProject01..CovidDeaths
WHERE continent is not null
ORDER By 3, 4

--Select Starting Data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVIDProject01..CovidDeaths
WHERE continent is not null
ORDER By 1, 2

ALTER TABLE COVIDProject01..CovidDeaths
ALTER Column total_deaths BIGINT

ALTER TABLE COVIDProject01..CovidDeaths
ALTER Column total_cases BIGINT

ALTER TABLE COVIDProject01..CovidDeaths
ALTER Column new_deaths INT



--Total Cases vs. Total Deaths 
--Shows likelihood of dying from COVID by country

SELECT location, date, total_cases, total_deaths, (total_deaths*1.0)/(total_cases)*100 AS DeathPercentage
FROM COVIDProject01..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
ORDER By 1, 2


--Looking at Total Cases vs Population
--Shows the percentage of the population infected with COVID

SELECT location, date, total_cases, population, (total_cases)/(population)*100 AS InfectionRate
FROM COVIDProject01..CovidDeaths
WHERE location like '%states%'
ORDER By 1, 2


--Countries with Highest Infection Rate Compared to Population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases)/(population))*100 AS PercentofPopInfected
FROM COVIDProject01..CovidDeaths
GROUP By location, population
ORDER By PercentofPopInfected desc


--Countries with the Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM COVIDProject01..CovidDeaths
WHERE continent is not null
GROUP By location
ORDER By TotalDeathCount desc



--Breaking Data down by Continent

--Continents with the Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM COVIDProject01..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null 
and location not like '%income%'
and location not like '%world%'
GROUP By location
ORDER By TotalDeathCount desc

--Creating View to store data for later visualization

CREATE VIEW COVIDDeathsByContinent as
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM COVIDProject01..CovidDeaths
WHERE continent is null 
and location not like '%income%'
and location not like '%world%'
GROUP By location


--GLOBAL NUMBERS

--Totals By Date

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM COVIDProject01..CovidDeaths 
WHERE continent is not null
and new_cases > 0
and location not like '%income%'
and location not like '%world%'
GROUP By date
ORDER By 1, 2


--Totals To Date

SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM COVIDProject01..CovidDeaths 
WHERE continent is not null
and new_cases > 0
and location not like '%income%'
and location not like '%world%'
--GROUP By date
ORDER By 1, 2


--Total Population vs Vaccinations
--Shows the Percentage of Population that has recieved at least one COVID-19 Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVIDProject01..CovidDeaths dea
JOIN COVIDProject01..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER By 2,3


--Using CTE to Perform Calculation on Partition By in Previous Query

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVIDProject01..CovidDeaths dea
JOIN COVIDProject01..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER By 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 As PercentVaccinated
FROM PopvsVac



--Using Temp Table to Perform Calculation on Partition By in Previous Query

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVIDProject01..CovidDeaths dea
JOIN COVIDProject01..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER By 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 As PercentVaccinated
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVIDProject01..CovidDeaths dea
JOIN COVIDProject01..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null