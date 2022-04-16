Select *
From PortfolioProject..CovidDeaths
where location not like '%income%'
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at the total cases vs total deaths
--Shows the likelihood of dying after getting affected by Covid
Select location, date, total_cases, new_cases, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India'
order by 1,2

--Looking at Total Cases vs Population.
--Shows the percentage of cases with respect to population.
Select location, date, total_cases, population, (total_cases/population)*100 as CovidCasesPercentage
From PortfolioProject..CovidDeaths
Where location = 'India'
order by 1,2

--Looking at countries with highest infection rate wrt population.

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidCasesPercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by CovidCasesPercentage desc

--Showing the countries with death rate per population.

Select location, MAX(cast(total_deaths as int)) as totalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by totalDeathCount desc

-- selecting by continent

-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as totalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null and continent not like '%income%'
Group by continent
order by totalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'India'
where continent is not null
--Group by date
order by 1,2


--Looking at total vaccination vs population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Calculating all the total vaccinations done in a country by date and location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CET

With PopulationvsVaccination (continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population) * 100 as PercentageVaccinated
From PopulationvsVaccination


-- TEMP TABLE

DROP Table if exists #PopulationVaccinated
Create Table #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population) * 100 as PercentageVaccinated
From #PopulationVaccinated


--Creating View to store data for later visualizations

Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PopulationVaccinated



