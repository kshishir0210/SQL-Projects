select * from PortfolioProject..CovidDeaths order by 3,4
select * from PortfolioProject..CovidVaccinations order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths order by 1,2

-- Total case vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths where location like 'In%' order by 1,2

-- Total cases vs population

Select location, date, total_cases, population, (total_cases / population)*100
as InfectedPercentage 
from PortfolioProject..CovidDeaths where location like 'India' order by 1,2

-- country with highest infected rate in comparison to population

Select location, population, max(total_cases) as HigInfCount, max((total_cases / population)*100)
as MaxInfectedPercentage from PortfolioProject..CovidDeaths group by location, population 
order by MaxInfectedPercentage desc

-- Countries with highest death rate

Select location, max(cast(total_deaths as int)) as HigDeathCount 
from PortfolioProject..CovidDeaths group by location 
order by HigDeathCount desc

--   global no's cases per day

Select date, SUM(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths ,  SUM(new_cases) /sum(cast(new_deaths as int))*100 
as DeathPercentage From PortfolioProject..CovidDeaths
where continent is not NULL
group by date
order by 1,2 

-- covid vaccinations
Select * from PortfolioProject..CovidVaccinations dv
join
PortfolioProject..CovidDeaths de
on
dv.location = de.location
and
dv.date = de.date

-- total population vs vaccinations

Select de.continent, de.location, de.date, dv.new_vaccinations
from PortfolioProject..CovidVaccinations dv
join
PortfolioProject..CovidDeaths de 
on
dv.location = de.location
and
dv.date = de.date
where de.location is not null
order by 1,2,3  

-- population which have new vaccinations

Select de.continent, de.location, de.date, dv.new_vaccinations
from PortfolioProject..CovidVaccinations dv
join
PortfolioProject..CovidDeaths de 
on
dv.location = de.location
and
dv.date = de.date
where de.continent is not null
and dv.new_vaccinations is not null
order by cast(new_vaccinations as int) desc 

--partition by location and date

Select de.continent, de.location, de.date, de.population, dv.new_vaccinations, SUM(convert(bigint, dv.new_vaccinations))
OVER (Partition by de.location order by de.location, de.date) as Total_vaccinated
from PortfolioProject..CovidVaccinations dv
join
PortfolioProject..CovidDeaths de 
on
dv.location = de.location
and
dv.date = de.date
where de.continent is not null
and dv.new_vaccinations is not null
order by 2,3 

-- Total People vaccinated by population after partition using CTE
With PopVsVacc(Continent, location, date, population, new_vaccinations, Total_vaccinated)
as
(
Select de.continent, de.location, de.date, de.population, dv.new_vaccinations, SUM(convert(bigint, dv.new_vaccinations))
OVER (Partition by de.location order by de.location, de.date) as Total_vaccinated
from PortfolioProject..CovidVaccinations dv
join
PortfolioProject..CovidDeaths de 
on
dv.location = de.location
and
dv.date = de.date
where de.continent is not null
--and dv.new_vaccinations is not null
)
Select *, (Total_vaccinated/Population)*100 as Per_Vaccinated from PopVsVacc


-- Temp Table
drop table if exists #PerPeopleVacc 
Create table #PerPeopleVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),

)

 
Select de.continent, de.location, de.date, de.population, dv.new_vaccinations
from PortfolioProject..CovidVaccinations dv
join
PortfolioProject..CovidDeaths de 
on
dv.location = de.location
and
dv.date = de.date
where de.continent is not null
Select *, (new_vaccinations/population)*100 from #PerPeopleVacc

-- View
Create View PerPopVacci as
Select de.continent, de.location, de.date, de.population, dv.new_vaccinations, SUM(convert(bigint, dv.new_vaccinations))
OVER (Partition by de.location order by de.location, de.date) as Total_vaccinated
from PortfolioProject..CovidVaccinations dv
join
PortfolioProject..CovidDeaths de 
on
dv.location = de.location
and
dv.date = de.date
where de.continent is not null
and dv.new_vaccinations is not null
Select * from PerPopVacci