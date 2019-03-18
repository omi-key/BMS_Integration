using HTTP, JSON

function run()
    slst = Dict{String,Any}()

    rsl = String( HTTP.request("GET", "https://lite.stellabms.xyz/score.json").body )
    sl = JSON.parse(rsl)
    map(x -> slst[x["md5"]] = x, sl)
    rst = String( HTTP.request("GET", "https://stellabms.xyz/score.json").body )
    st = JSON.parse(rst)
    map(x -> slst[x["md5"]] = x, st)
    
    leveljson = HTTP.request("GET", "https://omi-key.github.io/BMS_Integration/levelmod.json").body |> String |> JSON.parse
    levelmod = Dict{String,Any}()

    map(x -> levelmod[x["md5"]] = x, leveljson)
    for (md5, s) in slst
        if !haskey(levelmod, md5)
            s["raw"] = "-"
            levelmod[md5] = s
        end
    end
    out_integ = levelmod |> values |> collect

    @show out_integ |> length, leveljson |> length
    
    (x -> x["level"] = string(x["level"])).(out_integ)

    output = open("integr.json", "w")
    outst = JSON.json(out_integ)
    write(output, outst)
end

run()