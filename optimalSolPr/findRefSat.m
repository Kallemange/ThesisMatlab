function [sat_id, u_id]=findRefSat(refSatId, D, u, iD, iu)
sat_id  = find(D.sat(iD)==refSatId);
u_id    = find(u.sv(iu)==refSatId);
if isempty(sat_id)||isempty(u_id)
    keyboard
end