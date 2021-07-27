
--CovidDeaths Data Exploration 
Select * 
From PortfolioProject..CovidDeaths 
Order by 3,4 

Select * 
From PortfolioProject..CovidVaccinations  
Order by 3,4 

-- Select the data for analysis 

Select Location, date, total_cases, new_cases, total_deaths,population 
From PortfolioProject..CovidDeaths 
Order by 1,2

-- Total cases vs Total Deaths 
-- Shows the likelihood of dying when contract covid in Ghana 

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--where  location like '%ghana%'
where continent is not null
Order by 1,2


--Total cases vs Population
-- Shows what percentage of population has got covid 

Select Location, date,population, total_cases, (total_cases /population )*100 as PopulationPercentageInfected 
From PortfolioProject..CovidDeaths 
where location like '%ghana%'
Order by 1,2


-- Countries with highest infection rate compared to the population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases /population ))*100 as 
PopulationPercentageInfected 
From PortfolioProject..CovidDeaths 
--where location like '%ghana%'
where continent is not null
Group by Location, Population 
Order by PopulationPercentageInfected desc



--By Countries with the highest death count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%ghana%'
where  continent is null
Group by location 
Order by TotalDeathCount  desc


-- By continents with the highest death count per population 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%ghana%'
where continent is NOT null
Group by continent
Order by TotalDeathCount  desc


--Global Numbers by Date
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--where  location like '%ghana%'
where continent is not null
Group by date
Order by 1,2

--Global Numbers 
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--where  location like '%ghana%'
where continent is not null
--Group by date
Order by 1,2



--CovidVaccinations Data Exploration 
Select * 
From PortfolioProject..CovidVaccinations

--Joining CovidDeaths and CovidVaccinations 
Select *
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location 
 and dea.date = vac.date 

 --Total Population vs Vaccinations 
 Select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
, 
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
   where dea.continent is not null
 order by 2,3

 --USE CTE

 With PopvsVac (continent, location, date,population, new_vaccinations,RollingPeopleVaccinated)
 as
 (
 Select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
   where dea.continent is not null
 --order by 2,3
 )

 Select * , (RollingPeopleVaccinated /population) * 100 as PercentageRollingPeopleVac
 From PopvsVac


 --Temp Table

 DROP Table if exists #PercentPopulationVaccinated 
 Create Table #PercentPopulationVaccinated 
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )


 Insert Into #PercentPopulationVaccinated
 Select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
   where dea.continent is not null
 order by 2,3

  Select * , (RollingPeopleVaccinated /population) * 100 as PercentageRollingPeopleVac
 From #PercentPopulationVaccinated


 --Creating View to Store Data for later Visualizations

 Create View PercentPopulationVaccinated as
  Select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
   where dea.continent is not null
 --order by 2,3

 Select * 
 From PercentPopulationVaccinated