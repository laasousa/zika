## this file contains housekeeping functions.

function get_age_group(age::Int64)
    ## this agegroup is a "condensed version" from the age distribution
    ## this is mainly used for sex frequency
    agegroup = -1
    if age >=0 && age < 15 
        agegroup = 0
    elseif age >= 15 && age < 25
        agegroup = 1
    elseif age >= 25 && age < 30
        agegroup = 2
    elseif age >= 30 && age < 40
        agegroup = 3
    elseif age >= 40 && age < 50 
        agegroup = 4 
    elseif age >= 50 && age < 60 
        agegroup = 5 
    elseif age >= 60 && age < 70        
        agegroup = 6 
    elseif age >= 70
        agegroup = 7
    end 
    return agegroup
end

## helper function to calculate an individauls' sex frequency 
function calculatesexfrequency(age::Int64, sex::GENDER)
    ## this function calculates sex frequency based on the distribution
    # first we need to get the age group  - this is a number between 1 and 8 -
    ag = get_age_group(age)     ## get the agegroup
    if ag == 0   # ie, age is between 1 - 15
        return 0
    end
    mfd, wfd = distribution_sexfrequency()  ## get the distributions
    rn = rand() ## roll a dice
    sexfreq = 0
    if sex == MALE 
        sexfreq = minimum(find(x -> rn <= x, mfd[ag])) - 1   #if male, use the male distribution
    else 
        sexfreq = minimum(find(x -> rn <= x, wfd[ag])) - 1   #if female, use the female distribution
    end
    return sexfreq
end

function prot(a) 
    ## this function is used 
    if a > 0 
        return 0
    else 
        return 1
    end
end

function get_preg_distribution(P)
    cnts = zeros(100) ## age 1 to 100
    for i in 1:1000
      humans = Array{Human}(P.grid_size_human)
      setup_humans(humans)                      ## initializes the empty array
      setup_human_demographics(humans)          ## setup age distribution, male/female 
      setup_preimmunity(humans , P)
      setup_pregnant_women(humans, P)
  
      a = [humans[i].age for i in find(x -> x.ispregnant == true, humans)]  
      for i in a
        cnts[i] += 1
      end
    end  
    return cnts
  end
  
  
## check if one array is embedded (subset) in a second array
function subset2(x,y)
    lenx = length(x)
    first = x[1]
    if lenx == 1
        return findnext(y, first, 1) != 0
    end
    leny = length(y)
    lim = length(y) - length(x) + 1
    cur = 1
    while (cur = findnext(y, first, cur)) != 0
        cur > lim && break
        beg = cur
        @inbounds for i = 2:lenx
            y[beg += 1] != x[i] && (beg = 0 ; break)
        end
        beg != 0 && return true
        cur += 1
    end
    false
end

function countries()
    a = JSON.parsefile("country_data.json", dicttype=Dict,  use_mmap=true)
    c = Array{String}(length(a))
    for (i, d) in enumerate(a)
        c[i] = d["name"]
    end
    return c
end

## returns beta values
function transmission_beta(keyname, cn)
    a = JSON.parsefile("country_data.json", dicttype=Dict,  use_mmap=true)    
    idx = find(x -> x["name"] == cn, a)
    length(idx) == 0 && error("Country dosn't exist")
    return a[idx[1]]["data"][keyname]
end

## returns beta values
function herdimmunity(cn)
    a = JSON.parsefile("country_data.json", dicttype=Dict,  use_mmap=true)    
    idx = find(x -> x["name"] == cn, a)
    length(idx) == 0 && error("Country dosn't exist")
    return a[idx[1]]["data"]["preimmunity"]
end
