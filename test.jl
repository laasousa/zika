
include("main.jl")
using Base.Test 

@testset "Protection Level" begin
    P = ZikaParameters(preimmunity = 0, country="Colombia", transmission = 1.0, coverage_pregnant=1.0, coverage_general=0.0, preg_percentage=0.0)
    humans = Array{Human}(P.grid_size_human)
    setup_humans(humans)                      ## initializes the empty array
    setup_human_demographics(humans)          ## setup age distribution, male/female 
    setup_preimmunity(humans , P)
    setup_pregnant_women(humans, P)
    g, p = setup_vaccination(humans, P)       ## setup initial vaccination if coverage is more than 0. (g, p) are the number of people vaccinated (general and pregnant women)
    
    trslts = main(x->1, 1, P)


    a = find(x -> x.protectionlvl > 0, humans)
    h = humans[a[1]]
    make_human_latent(h, P)
    h.timeinstate = h.statetime 
    increase_timestate(h, P)
    @test h.swap == ASYMP


    ## scenario 2: preexisting immunity
    P = ZikaParameters(preimmunity = 0.08)
    humans = Array{Human}(P.grid_size_human)
    setup_humans(humans)                      ## initializes the empty array
    setup_preimmunity(humans , P)
    @test length(find(x -> x.protectionlvl == 1.0, humans)) > 0
end

mosqs  = Array{Mosq}(P.grid_size_mosq)

## current season
current_season = SUMMER   #current season


setup_sexualinteractionthree(humans)      ## setup sexual frequency, and partners
setup_mosquitos(mosqs, current_season)    ## setup the mosquito array, including bite distribution
setup_mosquito_random_age(mosqs, P)  ## assign age and age of death to mosquitos
setup_rand_initial_latent(humans, P) ## introduce initial latent person


for t=1:P.sim_time
    if mod(t, 182) == 0
        current_season = SEASON(Int(current_season) * -1)
    end 
    increase_mosquito_age(mosqs, current_season)
    bite_interaction(humans, mosqs, P)
    sexual_interaction(humans, mosqs, P)
    timeinstate_plusplus(humans, mosqs, t, P)
    baby_born(humans, P)
    cb(1) ## increase the progress metre by 1.. callback function
end ##end of time 

a = find(x-> x.gender == FEMALE && x.age >= 15 && x.age <= 49, humans)

humans[10].timeinpregnancy = 268
baby_born(humans, P)
print(humans[10].timeinpregnancy)



find(x-> x.gender == FEMALE && x.age <= 49 && x.age >= 15 && x.ispregnant== true && x.isvaccinated==true, humans)

find(x -> x.isvaccinated == true, humans)


P = ZikaParameters(preimmunity = 0, transmission = 1.0, coverage_pregnant=0.05, coverage_general=0.0, preg_percentage=1.0)
    humans = Array{Human}(P.grid_size_human)

    setup_humans(humans)                      ## initializes the empty array
    setup_human_demographics(humans)          ## setup age distribution, male/female 
    setup_preimmunity(humans , P)
    setup_pregnant_women(humans, P)
    g, p = setup_vaccination(humans, P)       ## setup initial vaccination if coverage is more than 0. (g, p) are the number of people vaccinated (general and pregnant women)


    a = find(x-> x.gender == FEMALE && x.age >= 15 && x.age <= 49 && x.ispregnant == true , humans)
    find(x -> x.ispregnant == true, humans)

rand(find(x->  x.age == 32, humans))

## print out setup_human_demographics
dump(humans[1])



Pkg.add("JSON")
using JSON


include("main.jl")
a = JSON.parsefile("country_data.json", dicttype=Dict,  use_mmap=true)
countries = Array{String}(length(a))
for (i, d) in enumerate(a)
    countries[i]= d["name"]
end

using Plots

include("main.jl")
 ## the grids for humans and mosquitos

cn = countries() 
#male/female dataframes
dfm = DataFrame()
dff = DataFrame()

#df[:countries] = cn
for (i, c) in enumerate(cn)
    P = ZikaParameters(preimmunity = 0, transmission = 1.0, coverage_pregnant=0.05, coverage_general=0.0, preg_percentage=1.0, country=c)
    !(P.country in countries()) && error("Country not defined for model");   

    sm = zeros(Int64, 15, 100)
    sf = zeros(Int64, 15, 100)
    for sim in 1:100
        humans = Array{Human}(P.grid_size_human)
        mosqs  = Array{Mosq}(P.grid_size_mosq)
        # simulation setup functions
        setup_humans(humans)                      ## initializes the empty array
        setup_human_demographics(humans, P)          ## setup age distribution, male/female 
        setup_preimmunity(humans, P)
        setup_pregnant_women(humans, P)           ## setup pregant women according to distribution 
        
        ## 17 age brackets
        m_tmparr = zeros(Int64, 15)
        f_tmparr = zeros(Int64, 15)
    
        malecnt = find(x -> x.gender == MALE, humans)
        femalecnt = find(x -> x.gender == FEMALE, humans)
        
        for (j, m) in enumerate(malecnt)
            m_tmparr[humans[m].agegroup] += 1
        end
        
        for (j, m) in enumerate(femalecnt)
            f_tmparr[humans[m].agegroup] += 1        
        end    
        sm[:, sim] = m_tmparr
        sf[:, sim] = f_tmparr
    end
    tmp = Array{Float64}(15)    
    dfm[Symbol(c)] = reshape(sum(sm, 2)/100, (15, ))
    dff[Symbol(c)] = reshape(sum(sm, 2)/100, (15, ))
end

dfp[Symbol(P.country)] = length(find(x-> x.gender == FEMALE && x.age >= 15 && x.age <= 49 && x.ispregnant == true , humans))
P = ZikaParameters(preimmunity = 0, transmission = 1.0, coverage_pregnant=0.05, coverage_general=0.0, preg_percentage=1.0, country="Colombia")
!(P.country in countries()) && error("Country not defined for model");
humans = Array{Human}(P.grid_size_human)
mosqs  = Array{Mosq}(P.grid_size_mosq)
# simulation setup functions
setup_humans(humans)                      ## initializes the empty array
setup_human_demographics(humans, P)          ## setup age distribution, male/female 
setup_preimmunity(humans, P)
setup_pregnant_women(humans, P)           ## setup pregant women according to distribution 

for i in 1:length(humans)
    println(humans[i].age)
end


using VegaLite, VegaDatasets

dataset("cars") 
@vlplot(
    :point,
    x=:Horsepower,
    y=:Miles_per_Gallon,
    color=:Origin,
    width=400,
    height=400
)

using DataFrames
using CSV

df = CSV.read("transmissions.csv", )

