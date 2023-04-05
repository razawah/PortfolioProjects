
Select * 
From PortfolioProject..CovidDeaths
where continent is not null
Order By 3,4

Select *
From PortfolioProject..CovidVaccinations

-- Select data that is going to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order by 1,2


-- Alter total_cases from navchar to float in CovidDeaths table
ALTER Table PortfolioProject.dbo.CovidDeaths
Alter Column total_cases float

-- Alter total_deaths from navchar to int in CovidDeaths table
ALTER Table PortfolioProject.dbo.CovidDeaths
Alter Column total_deaths int


-- Alter new_deaths from navchar to int in CovidDeaths table
ALTER Table PortfolioProject.dbo.CovidDeaths
Alter Column new_deaths int

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if one contracts Covid in a particular country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking at total case vs Population
-- Shows what percentage of Population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PopulationAffected
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
Order by 1,2

--Looking at countries with Highest infection rate compared to Population

Select location, Max(total_cases), population, Max((total_cases/population))*100 as PopulationAffectedCountWorlwide
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Group by population, location
Order by PopulationAffectedCountWorlwide desc

--Looking at countries with the highest death rate compared to population

Select location, Max(total_deaths) As HighestDeaths
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%states%'
Group by location
Order by HighestDeaths desc

-- Highest Death rate by Continent

Select continent, Max(total_deaths) As HighestDeathsByContinent
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%states%'
Group by continent
Order by HighestDeathsByContinent desc

-- Global Data

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS GlobalDeaths
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
Order by 1,2

-- Let's bring in CovidVaccinations table and join both tables

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Looking at Rolling Population Vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(float, vac.new_vaccinations)) over (Partition by  dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopVsVac (continet, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(float, vac.new_vaccinations)) over (Partition by  dea.location Order by dea.location, dea.date ) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVaccinated
From PopVsVac


-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(float, vac.new_vaccinations)) over (Partition by  dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVaccinated
From #PercentPopulationVaccinated

-- Create Views

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(float, vac.new_vaccinations)) over (Partition by  dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
