###############################################################################
#                             Collective Variables                            #
###############################################################################

# =============
# CG nativeness
# =============

function compute_nativeness(t::GenTopology, c::Conformation, args::Dict{String, <:Any}=Dict{String, Any}())
    verbose = get(args, "verbose", false)
    q_type  = get(args, "type", 1)
    cutoff  = get(args, "cutoff", 1.2)
    beta    = get(args, "beta", 5.0)

    # count number of native contacts
    num_native_contacts = 0
    for p in t.top_pairs
        if p.function_type == 1 || p.function_type == 2
            num_native_contacts += 1
        end
    end

    # loop over all the native contacts
    num_correct_contact = 0
    num_contact_type_2  = 0.0
    for p in t.top_pairs
        if p.function_type == 1 || p.function_type == 2
            r0 = p.r0
            i  = p.i
            j  = p.j
            r  = compute_distance(c.coors[:, i], c.coors[:, j])
            if q_type == 1      # simple type
                if r <= r0 * cutoff
                    num_correct_contact += 1
                end
            elseif q_type == 2  # complex type
                num_contact_type_2 += 1 / (1 + exp( beta * (r - cutoff * r0)))
            end
        end
    end

    if q_type == 1      # simple type
        return num_correct_contact / num_native_contacts
    elseif q_type == 2  # complex type
        return num_contact_type_2 / num_native_contacts
    end
end
