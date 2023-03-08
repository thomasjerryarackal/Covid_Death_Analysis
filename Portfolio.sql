Select * from Covid..CovidVaccins
ORDER BY 3,4;

SELECT * FROM Covid..CovIdDeath
ORDER BY 3,4;

--Selecting the data columns for analysis

SELECT Location, date, total_cases,total_deaths,new_cases,population
FROM Covid..CovidDeath
WHERE continent is not null
ORDER BY 1,2;

--Note: in the data we have location like world,High income ,etc, it is due to continents= null 


--Realtionship total cases vs total death

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM Covid..CovidDeath
WHERE continent is not null
ORDER BY 1,2;

-- Now look at this relation in some countries
--India
SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM Covid..CovidDeath
Where Location = 'India'
ORDER BY 1,2;

--Mexico
SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM Covid..CovidDeath
Where Location = 'Mexico'
ORDER BY 1,2;

--Looking at total_cases vs popluations
--This will show how people got covid 
SELECT Location, date, total_cases,population,(total_cases/population)*100 as Infected_Percentage
FROM Covid..CovidDeath
WHERE continent is not null
ORDER BY 1,2;

-- in india
SELECT Location, date, total_cases,population,(total_cases/population)*100 as Infected_Percentage
FROM Covid..CovidDeath
Where Location = 'India'
ORDER BY 1,2;

--in Japan
SELECT Location, date, total_cases,population,(total_cases/population)*100 as Infected_Percentage
FROM Covid..CovidDeath
Where Location = 'Japan'
ORDER BY 1,2;

-- Checking which country has highest infection rate comparing to its population

SELECT Location,population, MAX(total_cases) as HighInfection_count , MAX((total_cases/population))*100 as Infected_Percentage
FROM Covid..CovidDeath
WHERE continent is not null
GROUP BY Location,population
ORDER BY Infected_Percentage desc;


--Checking which country has highest death count :

SELECT Location, MAX(cast(total_deaths as int)) as HighDeathcount 
FROM Covid..CovidDeath
WHERE continent is not null
GROUP BY Location
Order by HighDeathcount desc ;


--Check it by continent bases:
--Checking which continent has highest death count :
SELECT continent, MAX(cast(total_deaths as int)) as HighDeathcount 
FROM Covid..CovidDeath
WHERE continent is not null
GROUP BY continent
Order by HighDeathcount desc ;

--Now we wil check with continent is null
SELECT continent, MAX(cast(total_deaths as int)) as HighDeathcount 
FROM Covid..CovidDeath
WHERE continent is not null
GROUP BY continent
Order by HighDeathcount desc ;

--GLOBAL NUMBERS
--per day  cases and death cases and its percentage

SELECT  date,SUM(new_cases)AS total_case ,SUM(CAST(new_deaths as INT))as total_death ,
(SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as Death_Percentage
FROM Covid..CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--Summary of total case and total death 
SELECT  SUM(new_cases)AS total_case ,SUM(CAST(new_deaths as INT))as total_death ,
(SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as Death_Percentage
FROM Covid..CovidDeath
WHERE continent is not null
ORDER BY 1,2;

--Next stage 

--Combine with another table
-- this new table will have the data of vaccins

SELECT * 
FROM Covid..CovidDeath dea JOIN Covid..CovidVaccins vac
ON dea.location = vac.location 
and dea.date = vac.date;

--Checking total popluation each countries has vaccinations per day

SELECT dea.continent, dea.location ,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Vaccination_Count
FROM Covid..CovidDeath dea 
JOIN Covid..CovidVaccins vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- Looking total population vs total vaccinations
--with using temp tables
DROP TABLE if exists PopVac
CREATE TABLE PopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Vaccinations numeric,
Vaccination_Count numeric
)
INSERT INTO PopVac

SELECT dea.continent, dea.location ,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Vaccination_Count
FROM Covid..CovidDeath dea 
JOIN Covid..CovidVaccins vac
ON dea.location = vac.location 
and dea.date = vac.date
--WHERE dea.continent is not null

SELECT *,(Vaccination_Count/Population)*100 as Percetage_Vaccination
FROM PopVac;

--creating veiw to store data for later visualization

CREATE VIEW PopVac1 as
SELECT dea.continent, dea.location ,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Vaccination_Count
FROM Covid..CovidDeath dea 
JOIN Covid..CovidVaccins vac
ON dea.location = vac.location 
and dea.date = vac.date