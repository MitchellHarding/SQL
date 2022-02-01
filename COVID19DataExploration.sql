SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL

--Selecting the Data
SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases VS Total Deaths By Country
--The liklihood of dying from COVID-19, after testing positive, inside any Country. (Isolated Estonia)

SELECT Location, Date, Total_Cases, Total_Deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Estonia%'
ORDER BY 1,2

--Looking at Total Cases VS Population By Country
--What percentage of the population contracted COVID-19 inside any Country. (Isolated Estonia)

SELECT Location, Date, Total_Cases, Population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Estonia%'
ORDER BY 1,2


--Infection Rates, Highest Countries, compared to Population
SELECT Location, MAX(Total_Cases) AS InfectionCount, Population, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%Estonia%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC




--Countries with Highest Death count, By Population
SELECT Location, MAX(cast(Total_Deaths AS INT)) AS DeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%Estonia%'
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY DeathCount DESC


--Data by Continent
--Total Deaths by continent

SELECT location, MAX(cast(Total_Deaths AS INT)) AS DeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%Estonia%'
WHERE Continent IS NULL
GROUP BY location
ORDER BY DeathCount DESC


--Global Statistics
SELECT SUM(New_Cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%Estonia%'
WHERE continent IS NOT NULL

ORDER BY 1,2

 

 --Vaccinations daily across Total Population
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations AS DailyNewVacc
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY da.location ORDER BY da.location, da.Date) AS RunningTotVacc,
--(RunningTotVacc/da.population) * 100
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVaccinations vac
	ON da.Location = vac.location AND
	da.date = vac.date 
	WHERE da.continent IS NOT NULL
	order by 2,3
	

--Using CTE to create variable from creation

WITH  PopaccVac (Continent, Location, Date, Population, New_vaccinations, RunningTotVacc)
AS
(
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations AS DailyNewVacc
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY da.location ORDER BY da.location, da.Date) AS RunningTotVacc
--(RunningTotVacc/da.population) * 100
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVaccinations vac
	ON da.Location = vac.location AND
	da.date = vac.date 
	WHERE da.continent IS NOT NULL
	--order by 2,3
)

SELECT *, (RunningTotVacc/Population)*100 AS Percpplvaccinated
FROM PopaccVac


--Using TEMP TABLE to create variable from creation
DROP TABLE if exists #PercPopulationVaccinated
CREATE TABLE #PercPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RunningTotVacc numeric
)

INSERT INTO #PercPopulationVaccinated
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations AS DailyNewVacc
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY da.location ORDER BY da.location, da.Date) AS RunningTotVacc
--(RunningTotVacc/da.population) * 100
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVaccinations vac
	ON da.Location = vac.location AND
	da.date = vac.date 
 	WHERE da.continent IS NOT NULL
	--order by 2,3

	SELECT *, (RunningTotVacc/Population)*100 AS Percpplvaccinated
FROM #PercPopulationVaccinated


--Creating views for visualisations

CREATE VIEW PopulationVaccViewNEW AS
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations AS DailyNewVacc
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY da.location ORDER BY da.location, da.Date) AS RunningTotVacc
--(RunningTotVacc/da.population) * 100
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVaccinations vac
	ON da.Location = vac.location AND
	da.date = vac.date 
 	WHERE da.continent IS NOT NULL
	--order by 2,3

Select *
FROM PopulationVaccViewNEW



--What percentage of the population contracted COVID-19 inside any Country. (Isolated Estonia)
CREATE VIEW EstoniaContraction AS
SELECT Location, Date, Total_Cases, Population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Estonia%'

Select *
FROM EstoniaContraction