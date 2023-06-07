Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Alter Data type of total cases and total deaths

Alter Table PortfolioProject..CovidDeaths
Alter Column total_cases numeric


Alter Table PortfolioProject..CovidDeaths
Alter Column total_deaths numeric

-- Looking at Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%ind%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%ind%'
where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%ind%'
where continent is not null
Group by location, population
order by PercentagePopulationInfected desc


-- Looking at Countries with Highest Death Count per Population

Select location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%ind%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Select location, Max(total_deaths) as TotalDeathCount
--From PortfolioProject..CovidDeaths
----where location like '%ind%'
--where continent is null
--Group by location
--order by TotalDeathCount desc

-- Let's Break things down by Continent

-- Showing the Continents with Highest Death Count per Population

Select continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%ind%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

--Select date, Sum(total_cases) as totalcases, Sum(total_deaths) as totaldeaths, Sum(total_deaths)/Sum(total_cases)*100 as DeathPercentage 
--From PortfolioProject..CovidDeaths
----where location like '%ind%'
--where continent is not null
--Group by date
--order by 1,2

Select Sum(total_cases) as totalcases, Sum(total_deaths) as totaldeaths, Sum(total_deaths)/Sum(total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--where location like '%ind%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccination

--Select *
--From PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date

Alter Table PortfolioProject..CovidVaccinations
Alter Column new_vaccinations numeric

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Select *
From PercentPopulationVaccinated