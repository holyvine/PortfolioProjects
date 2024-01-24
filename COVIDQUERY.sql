SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total cases VS Total deaths 

SELECT location,date,total_cases,total_deaths
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2

---Total cases vs Population
---Show percantage of people who got covid

SELECT location,date,population,total_cases, (total_cases / population ) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2


--Countries with Highest infection rate as compared to population 
SELECT location,population,date,
MAX(total_cases) AS HighestCovidCases,
MAX((total_cases / population )) AS HighestCovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
GROUP BY location,population,date
ORDER BY HighestCovidPercentage DESC

--Showing countries with highest death rate

SELECT location,
MAX(total_deaths) AS HighestCoviddeath
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY HighestCoviddeath DESC

--Showing continents with highesh deaths

SELECT continent,
MAX(cast(total_deaths as int)) AS HighestCoviddeath
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestCoviddeath DESC


--total of new cases and new death with respect to location

SELECT location,SUM(new_cases) AS total_newcase,SUM(new_deaths) AS total_newdeath
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location
ORDER BY location DESC

--total of new cases and new death with respect to INDIA

SELECT location,SUM(new_cases) AS total_newcase,SUM(new_deaths) AS total_newdeath
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%India%'
GROUP BY location


--Total population Vs total vaccinations

SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (Partition by CD.location ORDER BY CD.location,CD.date) AS rollingpeoplevacinated
--(rollingpeoplevacinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths CD
JOIN PortfolioProject.dbo.CovidVaccinations CV
ON CD.date = CV.date
AND CD.location =CV.location
WHERE CD.continent is not null 
ORDER BY 2,3

--WITH CTE(Common Table Expression)

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevacinated)
AS 
(
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (Partition by CD.location ORDER BY CD.location,CD.date) AS rollingpeoplevacinated
--(rollingpeoplevacinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths CD
JOIN PortfolioProject.dbo.CovidVaccinations CV
ON CD.date = CV.date
AND CD.location =CV.location
WHERE CD.continent is not null 
)
SELECT *,
(rollingpeoplevacinated/population)*100
FROM popvsvac

--TEMP TABLE 

DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevacinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (Partition by CD.location ORDER BY CD.location,CD.date) AS rollingpeoplevacinated
--(rollingpeoplevacinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths CD
JOIN PortfolioProject.dbo.CovidVaccinations CV
ON CD.date = CV.date
AND CD.location =CV.location

SELECT *
FROM #PercentPopulationVaccinated

--Creating a view 

CREATE view indiadata 
AS SELECT location,SUM(new_cases) AS total_newcase,SUM(new_deaths) AS total_newdeath
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%India%'
GROUP BY location

SELECT * FROM indiadata
