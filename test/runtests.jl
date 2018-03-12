using FeatherLib, Compat.Test, Missings
using Compat.Random

if Base.VERSION < v"0.7.0-DEV.2575"
    const Dates = Base.Dates
    using Compat.GC
    const GC = Compat.GC
else
    import Dates
end

testdir = joinpath(@__DIR__, "data")
files = map(x -> joinpath(testdir, x), readdir(testdir))

temps = []

@testset "ReadWrite" begin
    for f in files
        println("tesing $f...")
        columns, headers = featherread(f)

        ncols = length(columns)
        nrows = length(columns[1])

        temp = tempname()
        push!(temps, temp)

        featherwrite(temp, columns, headers)

        columns2, headers2 = featherread(temp)

        @test length(columns2) == ncols

        @test headers==headers2

        for (c1,c2) in zip(columns, columns2)
            @test length(c1)==nrows
            @test length(c2)==nrows
            for i = 1:nrows
                @test isequal(c1[i], c2[i])
            end
        end

    # @test source.ctable.description == sink.ctable.description
    # @test source.ctable.num_rows == sink.ctable.num_rows
    # @test source.ctable.metadata == sink.ctable.metadata
    # for (col1,col2) in zip(source.ctable.columns,sink.ctable.columns)
    #     @test col1.name == col2.name
    #     @test col1.metadata_type == col2.metadata_type
    #     @test typeof(col1.metadata) == typeof(col2.metadata)
    #     @test col1.user_metadata == col2.user_metadata

    #     v1 = col1.values; v2 = col2.values
    #     @test v1.dtype == v2.dtype
    #     @test v1.encoding == v2.encoding
    #     # @test v1.offset == v2.offset # currently not python/R compatible due to wesm/feather#182
    #     @test v1.length == v2.length
    #     @test v1.null_count == v2.null_count
    #     # @test v1.total_bytes == v2.total_bytes
    # end
    end
end

GC.gc(); GC.gc()
for t in temps
    rm(t)
end

# issue #34
# data = DataFrame(A=Union{Missing, String}[randstring(10) for i ∈ 1:100], B=rand(100))
# data[2, :A] = missing
# Feather.write("testfile.feather", data)
# dfo = Feather.read("testfile.feather")
# @test size(Data.schema(dfo)) == (100, 2)
# GC.gc();
# rm("testfile.feather")

# @testset "PythonRoundtrip" begin
# try
#     println("Generate a test.feather file from python...")
#     run(`docker cp runtests.py feathertest:/home/runtests.py`)
#     run(`docker exec feathertest python /home/runtests.py`)

#     println("Read test.feather into julia...")
#     run(`docker cp feathertest:/home/test.feather test.feather`)
#     df = Feather.read("test.feather")

#     dts = [Dates.DateTime(2016,1,1), Dates.DateTime(2016,1,2), Dates.DateTime(2016,1,3)]

#     @test df[:Autf8][:] == ["hey","there","sailor"]
#     @test df[:Abool][:] == [true, true, false]
#     @test df[:Acat][:] == categorical(["a","b","c"])  # these violate Arrow standard by using Int8!!
#     @test df[:Acatordered][:] == categorical(["d","e","f"])  # these violate Arrow standard by using Int8!!
#     @test convert(Vector{Dates.DateTime}, df[:Adatetime][:]) == dts
#     @test isequal(df[:Afloat32][:], [1.0, missing, 0.0])
#     @test df[:Afloat64][:] == [Inf,1.0,0.0]

#     df_ = Feather.read("test.feather"; use_mmap=false)

#     println("Writing test2.feather from julia...")
#     Feather.write("test2.feather", df)
#     df2 = Feather.read("test2.feather")

#     @test df2[:Autf8][:] == ["hey","there","sailor"]
#     @test df2[:Abool][:] == [true, true, false]
#     @test df2[:Acat][:] == categorical(["a","b","c"])  # these violate Arrow standard by using Int8!!
#     @test df2[:Acatordered][:] == categorical(["d","e","f"])  # these violate Arrow standard by using Int8!!
#     @test convert(Vector{Dates.DateTime}, df2[:Adatetime][:]) == dts
#     @test isequal(df2[:Afloat32][:], [1.0, missing, 0.0])
#     @test df2[:Afloat64][:] == [Inf,1.0,0.0]

#     println("Read test2.feather into python...")
#     @test (run(`docker cp test2.feather feathertest:/home/test2.feather`); true)
#     @test (run(`docker cp runtests2.py feathertest:/home/runtests2.py`); true)
#     @test (run(`docker exec feathertest python /home/runtests2.py`); true)
# finally
#     run(`docker stop feathertest`)
#     run(`docker rm feathertest`)
#     rm("test.feather")
#     rm("test2.feather")
# end

# end
