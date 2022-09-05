SELECT *
FROM Portfolio_project..['COVID-DEATHS']
WHERE continent is not Null
ORDER BY 3,4

--SELECT *
--FROM Portfolio_project..['COVID-VACCINES$']
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project..['COVID-DEATHS']
WHERE continent is not Null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_project..['COVID-DEATHS']
WHERE location like '%states%'
and continent is not Null
ORDER BY 1,2


-- Looking at Total Cases vs Population

SELECT Location, date, population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM Portfolio_project..['COVID-DEATHS']
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countires with Highest Infection Rate vs Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolio_project..['COVID-DEATHS']
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Countries with the Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_project..['COVID-DEATHS']
--WHERE location like '%states%'
WHERE continent is not Null
GROUP BY Location
ORDER BY TotalDeathCount DESC


SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_project..['COVID-DEATHS']
--WHERE location like '%states%'
WHERE continent is not Null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_project..['COVID-DEATHS']
--WHERE location like '%states%'
WHERE continent is not Null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio_project..['COVID-DEATHS']
--WHERE location like '%states%'
WHERE continent is not Null
--GROUP BY date
ORDER BY 1,2


SELECT *
FROM Portfolio_project..['COVID-DEATHS'] AS dea
JOIN Portfolio_project..['COVID-VACCINES$'] AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date

  -- Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population) *100
FROM Portfolio_project..['COVID-DEATHS'] AS dea
JOIN Portfolio_project..['COVID-VACCINES$'] AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  Where dea.continent is not null
Order BY 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM Portfolio_project..['COVID-DEATHS'] AS dea
JOIN Portfolio_project..['COVID-VACCINES$'] AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  Where dea.continent is not null
--Order BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM Portfolio_project..['COVID-DEATHS'] AS dea
JOIN Portfolio_project..['COVID-VACCINES$'] AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
 -- Where dea.continent is not null
--Order BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM Portfolio_project..['COVID-DEATHS'] AS dea
JOIN Portfolio_project..['COVID-VACCINES$'] AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
 Where dea.continent is not null
 --Order BY 2,3


 SELECT*
 FROM PercentPopulationVaccinated