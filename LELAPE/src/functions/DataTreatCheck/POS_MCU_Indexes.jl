# Distributed under the 
#
#          European Union Public Licence v. 1.2
# 
# See 
#
#          https://github.com/fjfrancopelaez/LELAPE/blob/main/LICENSE.md 
# 
# for further details.
#
function POS_MCU_Indexes(   ADDRESS::Vector{UInt32}, 
                            CYCLES::Vector{UInt32}, 
                            POSDVMarkers::Vector{UInt32}, 
                            LimitMCUSize::Int=100)::Array{Int, 2}
    # This function looks for pairs of ADDRESSES that subtracted yield one of the
    # identified POSDVMarkers. In the case of success, a matrix is returned. The
    # matrix has as many rows as MCU candidates and as many columns as the size
    # of the largest identified MCU. This size can be limited by LimitMCUSize in
    # order to allow the program to escape from a neverending loop.
    #
    # Content in this matrix are the indexes of reñated addresses in the ADDRESS
    # vector, NEVER THE ADDRESSES THEMSELVES. To get the ADDRESSES, it is necessary
    # to use every elemtn as index for the ADDRESS vector.
    #
    # As in this matrix may appear events of different size but the matrix
    # has a defined number of columns, empty elements are filled with zeros.
    #
    # If no pair is found, a void matrix is returned.
    #
    # There is another dispatch of this function in whixh no CYCLES victor is
    # required. See below.
    #

    GroupsOfEventsDraft = zeros(UInt32, div(length(ADDRESS),2),LimitMCUSize)

    TrustWorthy = true

    TopMCUSize=[0];

    for k1 = 1:length(ADDRESS)-1, k2 = k1+1:length(ADDRESS)

        if CYCLES[k1]==CYCLES[k2]

             if PosSubst(ADDRESS[k1],ADDRESS[k2]) in POSDVMarkers

                if (k1 in GroupsOfEventsDraft) & !(k2 in GroupsOfEventsDraft)

                    EventIndex=findfirst(GroupsOfEventsDraft.==k1)[1];

                    NewAddressIndex = findfirst(GroupsOfEventsDraft[EventIndex,:].==0);

                    GroupsOfEventsDraft[EventIndex, NewAddressIndex] = k2;

                    if NewAddressIndex > TopMCUSize[1]
                        TopMCUSize[1] = NewAddressIndex;
                    end

                elseif !(k1 in GroupsOfEventsDraft) & (k2 in GroupsOfEventsDraft)

                    EventIndex=findfirst(GroupsOfEventsDraft.==k2)[1];

                    NewAddressIndex = findfirst(GroupsOfEventsDraft[EventIndex,:].==0);

                    GroupsOfEventsDraft[EventIndex, NewAddressIndex] = k1;

                    ## Clearly, the elements are not in aranged from lower to highe.
                    ## Let us rearange them with a simple instruction
                    GroupsOfEventsDraft[EventIndex, 1:NewAddressIndex]=sort(GroupsOfEventsDraft[EventIndex, 1:NewAddressIndex])

                    if NewAddressIndex > TopMCUSize[1]
                        TopMCUSize[1] = NewAddressIndex;
                    end

                elseif !(k1 in GroupsOfEventsDraft) & !(k2 in GroupsOfEventsDraft)

                    EventIndex =findfirst(GroupsOfEventsDraft[:,1].==0)

                    GroupsOfEventsDraft[EventIndex, 1:2]=[k1, k2]

                    if TopMCUSize[1] < 2
                        TopMCUSize[1] = 2;
                    end

                elseif (k1 in GroupsOfEventsDraft) & (k2 in GroupsOfEventsDraft)

                    EventIndex_k1 = findfirst(GroupsOfEventsDraft.==k1)[1]

                    EventIndex_k2 = findfirst(GroupsOfEventsDraft.==k2)[1]

                    if (EventIndex_k1 == EventIndex_k2)
                        #print(k1, " ", k2, "\n")
                    else
                        #print(k1, " ", k2, "\n")
                        # 2022/04/29: This print sentence was used during development to debug the system.
                        # Why do you need a debugger if you can just use print, vicious programmer?
                        # Commented for being useless at the present stage of design.
                        Elements_Group1=GroupsOfEventsDraft[EventIndex_k1,findall(GroupsOfEventsDraft[EventIndex_k1, :].!=0)]
                        Elements_Group2=GroupsOfEventsDraft[EventIndex_k2,findall(GroupsOfEventsDraft[EventIndex_k2, :].!=0)]
                        NewGroup = sort(union(Elements_Group1,Elements_Group2))
                        # Merging the groups
                        NewGroupSize=length(NewGroup)
                        if (NewGroupSize > LimitMCUSize)
                            TrustWorthy = false
                        else
                            GroupsOfEventsDraft[EventIndex_k1, 1:NewGroupSize]=NewGroup
                        end
                        ## Removing the second useless group.
                        GroupsOfEventsDraft[EventIndex_k2, :].=0
                        # Shifting rows upwards. Two options: The removed row was
                        # the last one so nothing is done, or inside the table.

                        if NewGroupSize > TopMCUSize[1]
                            TopMCUSize[1] = NewGroupSize;
                        end

                        LastEventIndex = findlast(GroupsOfEventsDraft[:,1].!=0)

                        if LastEventIndex+1==EventIndex_k2
                            ##Good Luck. k2 was in the last row. Escape.
                        else

                            GroupsOfEventsDraft[EventIndex_k2:LastEventIndex,:]=GroupsOfEventsDraft[EventIndex_k2+1:LastEventIndex+1,:]

                        end
                    end

                end
            end

        end

    end

    if (TrustWorthy) & (GroupsOfEventsDraft != zeros(Int32, div(length(ADDRESS),2),LimitMCUSize))

        GroupsOfEvents=GroupsOfEventsDraft[1:findlast(GroupsOfEventsDraft[:,1].!=0),1:TopMCUSize[1]]

    else

        GroupsOfEvents = []

    end

    return GroupsOfEvents

end

function POS_MCU_Indexes(ADDRESS::Vector{UInt32}, POSDVMarkers::Vector{UInt32}, LimitMCUSize::Int=1000)::Array{Int32, 2}

    return POS_MCU_Indexes(ADDRESS, ones(UInt32, length(ADDRESS)), POSDVMarkers, LimitMCUSize)

end
