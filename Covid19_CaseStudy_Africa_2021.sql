SELECT
	location,
	date,
	total_cases,
	new_cases,
	new_deaths,
	total_deaths,
	population
FROM 
	[PortfolioProjects].[dbo].[Covid19Death_AfricaData_2021]
ORDER BY
	1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in Egypt
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS Egypt_Death_Percentage
FROM 
	[PortfolioProjects].[dbo].[Covid19Death_AfricaData_2021]
WHERE
	location = 'Egypt'
ORDER BY
	1,2

--Total Cases vs Population
--Shows what percentage of population infected with Covid
SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS Infection_Percentage
FROM
	[PortfolioProjects].[dbo].[Covid19Death_AfricaData_2021]
WHERE
	location = 'Egypt'
ORDER BY
	1,2

--Countries in Africa with Highest Infection Rate compared to Population
SELECT
	location,
	population,
	MAX(total_cases) AS Highest_Infection_Number,
	Max((total_cases/population))*100 AS Infection_Percentage
FROM
	[PortfolioProjects].[dbo].[Covid19Death_AfricaData_2021]
GROUP BY
	location,
	population
ORDER BY
	Infection_Percentage DESC

--Countries with Highest Death Count per Population
SELECT
	location,
	population,
	MAX(total_deaths) AS Total_Death
FROM
	[PortfolioProjects].[dbo].[Covid19Death_AfricaData_2021]
GROUP BY
	location,
	population
ORDER BY
	Total_Death DESC,
	population DESC

--Africa total cases, total death, and death percentage in 2021
SELECT
	continent,
	SUM(new_cases) AS Africa_Total_Cases_2021,
	SUM(new_deaths) AS Africa_Total_Death_2021,
	(SUM(new_deaths)/SUM(new_cases))*100 AS Africa_Death_Percentage_2021
FROM
	[PortfolioProjects].[dbo].[Covid19Death_AfricaData_2021]
GROUP BY
	continent
--Vaccination table
SELECT *
FROM
	[PortfolioProjects].[dbo].[Covid19Vaccination_AfricaData_2021]

--Total Population vs Total Vaccinations
SELECT
	death.location,
	death.date,
	death.population,
	vacc.new_vaccinations,
	SUM(vacc.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS Counting_People_Vaccinated
FROM
	[PortfolioProjects].[dbo].[Covid19Death_AfricaData_2021] AS death
INNER JOIN 
	[PortfolioProjects].[dbo].[Covid19Vaccination_AfricaData_2021] AS vacc
ON death.location = vacc.location AND death.date = vacc.date
ORDER BY
	1,2

--Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists Population_Vaccinated_Percentage
Create Table Population_Vaccinated_Percentage
	(
	location nvarchar(100),
	date date,
	population numeric,
	new_vaccinations numeric,
	Counting_People_Vaccinated numeric
	)

INSERT INTO Population_Vaccinated_Percentage
SELECT
	death.location,
	death.date,
	death.population,
	vacc.new_vaccinations,
	SUM(vacc.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS Counting_People_Vaccinated
FROM
	[PortfolioProjects].[dbo].[Covid19Death_AfricaData_2021] AS death
INNER JOIN 
	[PortfolioProjects].[dbo].[Covid19Vaccination_AfricaData_2021] AS vacc
ON death.location = vacc.location AND death.date = vacc.date

Select *,
	(Counting_People_Vaccinated/population)*100 AS People_Vaccinated_Percentage
From Population_Vaccinated_Percentage