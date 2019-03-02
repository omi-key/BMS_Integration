using HTTP, JSON

const convertlist = [0, 1.5, 3, 5, 7, 9, 10.7, 12.3, 14, 15.2, 16.4, 17.6, 18.8, 20, 21, 22, 22.6, 23.2, 23.6, 24, 24.4, 24.8, 25.4, 26]
geno_to_stsl(x::Float64) = searchsortedfirst(convertlist, x) - 1

function run(convertlist)
    slst = Dict{String,Any}()

    rsl = String( HTTP.request("GET", "https://lite.stellabms.xyz/score.json").body )
    sl = JSON.parse(rsl)
    map(x -> slst[x["md5"]] = Dict("level" => parse(Int,x["level"]), "title" => x["title"]), sl)
    rst = String( HTTP.request("GET", "https://stellabms.xyz/score.json").body )
    st = JSON.parse(rst)
    map(x -> slst[x["md5"]] = Dict("level" => parse(Int,x["level"])+13, "title" => x["title"]), st)

    geno = Dict{String,Any}()

    genr = String( HTTP.request("GET", "http://walkure.net/hakkyou/for_glassist/bms/data_json.cgi?lamp=easy&min=-2.0&max=28.0&step_count=300").body )
    genjson = JSON.parse(genr)
    for ar in genjson
        if ar["level"] == "-"
            continue
        end
        geno[ar["md5"]] = Dict("level" => parse(Float64, split(ar["level"],"...")[1]), "title" => ar["title"])
    end

    geno_conv = Dict{String,Any}()
    for (md5,v) in geno
        if haskey(slst, md5)
            continue
        end
        v["level"] = (v["level"] |> geno_to_stsl)
        geno_conv[md5] = v
    end
    out_integ = [merge(Dict("md5" => md5), v) for (md5,v) in merge(slst, geno_conv)]
    
    (x -> x["level"] = string(x["level"])).(out_integ)

    output = open("integr.json", "w")
    outst = JSON.json(out_integ)
    write(output, outst)
end

run(convertlist)