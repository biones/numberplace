using JuMP
using GLPK


function strtobord(str)
    k=1
    bord=zeros(Int,9,9,9)
    initial_bord=zeros(Int,9,9)
    for i in 1:9
        for j in 1:9
            if str[k]!='0'
                n=parse(Int,str[k])
                bord[i,j,parse(Int,str[k])]=1
                initial_bord[i,j]=n
            end
            k+=1
        end
    end
    bord,initial_bord
end


#https://www.kaggle.com/bryanpark/sudoku

prob="004300209005009001070060043006002087190007400050083000600000105003508690042910300"
sol="864371259325849761971265843436192587198657432257483916689734125713528694542916378"


bord,initial_bord=strtobord(prob)

m= Model(with_optimizer(GLPK.Optimizer))
@variable(m, bord[1:9, 1:9, 1:9], Bin)

@constraints(m,begin
    cc[i in 1:9 ,j in 1:9],sum(bord[i,j,:])==1
    row[i in 1:9, k in 1:9], sum(bord[i, :, k]) == 1
    col[j in 1:9, k in 1:9], sum(bord[:, j, k]) == 1
    subgrid[i=1:3:7, j=1:3:7, val=1:9], sum(bord[i:i + 2, j:j + 2, val]) == 1
end)

for row in 1:9, col in 1:9
    if initial_bord[row, col] != 0
        @constraint(m, bord[row, col, initial_bord[row, col]] == 1)
    end
end

JuMP.optimize!(m)


mip_solution = JuMP.value.(bord)
res = zeros(Int, 9, 9)
for row in 1:9, col in 1:9, val in 1:9
    if mip_solution[row, col, val] >= 0.9
        res[row, col] = val
    end
end


b,bb=strtobord(sol)

for i in 1:9
    println(bb[i,:])
end
#Base.showarray(STDOUT,bb,false)




