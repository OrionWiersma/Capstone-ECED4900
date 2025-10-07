function savedata(fname,t,STATES,CURRENTS)

% Transform the arrays in arrays of structures for easier manipulation

V.V   = STATES(:,1);            % V
V.Cai = STATES(:,2);            % Cai
V.CaSR= STATES(:,3);            % CaSR        
V.g   = STATES(:,4);            % g   
V.Nai = STATES(:,5);            % Nai
V.Ki  = STATES(:,6);            % Ki
V.m   = STATES(:,7);            % m
V.h   = STATES(:,8);            % h
V.j   = STATES(:,9);            % j
V.xr1 = STATES(:,10);           % xr1       
V.xr2 = STATES(:,11);           % xr2
V.xs  = STATES(:,12);           % xs
V.dL  = STATES(:,13);           % dL
V.fL  = STATES(:,14);           % fL
V.fca = STATES(:,15);           % fca
V.dT  = STATES(:,16);           % dT
V.fT  = STATES(:,17);           % fT
																		   
cur.INa  = CURRENTS(:,1);
cur.ICaL = CURRENTS(:,2);
cur.ICaT = CURRENTS(:,3); 
cur.IpCa = CURRENTS(:,4); 
cur.INaK = CURRENTS(:,5);
cur.INaCa= CURRENTS(:,6);
cur.IKr  = CURRENTS(:,7); 
cur.IKs  = CURRENTS(:,8); 
cur.IK1  = CURRENTS(:,9); 
cur.IbNa = CURRENTS(:,10);
cur.IbCa = CURRENTS(:,11); 
cur.Irel = CURRENTS(:,12);
cur.Ileak= CURRENTS(:,13); 
cur.Iup  = CURRENTS(:,14);
							
save(fname,'t','V','cur');

end