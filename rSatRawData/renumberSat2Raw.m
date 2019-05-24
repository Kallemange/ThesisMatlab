function no=renumberSat2Raw(system,prn)
no=0;
MINPRNGPS   = 1;                         %/* min satellite PRN number of GPS */
MAXPRNGPS   = 32;                        %/* max satellite PRN number of GPS */
NSATGPS     = (MAXPRNGPS-MINPRNGPS+1);   %/* number of GPS satellites */
NSYSGPS     = 1;

MINPRNGLO   = 1;                         %/* min satellite slot number of GLONASS */
MAXPRNGLO   = 27;                        %/* max satellite slot number of GLONASS */
NSATGLO     = (MAXPRNGLO-MINPRNGLO+1);   %/* number of GLONASS satellites */
NSYSGLO     = 1;

MINPRNGAL   = 1;                         %/* min satellite PRN number of Galileo */
MAXPRNGAL   = 30;                        %/* max satellite PRN number of Galileo */
NSATGAL     = (MAXPRNGAL-MINPRNGAL+1);   %/* number of Galileo satellites */
NSYSGAL     = 1;

MINPRNQZS   = 193;                       %/* min satellite PRN number of QZSS */
MAXPRNQZS   = 199;                       %/* max satellite PRN number of QZSS */
MINPRNQZS_S = 183;                       %/* min satellite PRN number of QZSS SAIF */
MAXPRNQZS_S = 189;                       %/* max satellite PRN number of QZSS SAIF */
NSATQZS     = (MAXPRNQZS-MINPRNQZS+1);   %/* number of QZSS satellites */
NSYSQZS     = 1;

MINPRNCMP   = 1;                         %/* min satellite sat number of BeiDou */
MAXPRNCMP   = 35;                        %/* max satellite sat number of BeiDou */
NSATCMP     = (MAXPRNCMP-MINPRNCMP+1);   %/* number of BeiDou satellites */
NSYSCMP     = 1;

MINPRNIRN   = 1;                         %/* min satellite sat number of IRNSS */
MAXPRNIRN   = 7;                         %/* max satellite sat number of IRNSS */
NSATIRN     = (MAXPRNIRN-MINPRNIRN+1);   %/* number of IRNSS satellites */
NSYSIRN     = 1;

MINPRNLEO   = 1;                         %/* min satellite sat number of LEO */
MAXPRNLEO   = 10;                        %/* max satellite sat number of LEO */
NSATLEO     = (MAXPRNLEO-MINPRNLEO+1);   %/* number of LEO satellites */
NSYSLEO     = 1;

NSYS        = (NSYSGPS+NSYSGLO+NSYSGAL+NSYSQZS+NSYSCMP+NSYSIRN+NSYSLEO); %/* number of systems */

MINPRNSBS   = 120;                       %/* min satellite PRN number of SBAS */
MAXPRNSBS   = 142;                       %/* max satellite PRN number of SBAS */
NSATSBS     = (MAXPRNSBS-MINPRNSBS+1);   %/* number of SBAS satellites */


sys=0;
switch (system)
        case 0 
            sys = 'SYS_GPS';
        case 1 
            sys = 'SYS_SBS';
        case 2 
            sys = 'SYS_GAL';
        case 3 
            sys = 'SYS_CMP';
        case 5 
            sys = 'SYS_QZS';
        case 6 
            sys = 'SYS_GLO';
end

switch (sys)
    case 'SYS_GPS'
        if (prn < MINPRNGPS || MAXPRNGPS < prn) 
            return;
        else
            no = prn - MINPRNGPS + 1;
        end
    case 'SYS_GLO'
        if (prn < MINPRNGLO || MAXPRNGLO < prn) 
            return;
        else
            no = NSATGPS + prn - MINPRNGLO + 1;
        end
    case 'SYS_GAL'
        if (prn < MINPRNGAL || MAXPRNGAL < prn) 
            return;
        else 
            no = NSATGPS + NSATGLO + prn - MINPRNGAL + 1;
        end
    case 'SYS_QZS'
        prnQZS=prn+192; %Only for QZS-satellites: add 192
        if (prnQZS < MINPRNQZS || MAXPRNQZS < prnQZS) 
            return;
        else
            no = NSATGPS + NSATGLO + NSATGAL + prnQZS - MINPRNQZS + 1;
        end
    case 'SYS_CMP'
        if (prn < MINPRNCMP || MAXPRNCMP < prn) 
            return;
        else
            no = NSATGPS + NSATGLO + NSATGAL + NSATQZS + prn - MINPRNCMP + 1;
        end
    case 'SYS_IRN'
        if (prn < MINPRNIRN || MAXPRNIRN < prn) 
            return;
        else
            no = NSATGPS + NSATGLO + NSATGAL + NSATQZS + NSATCMP + prn - MINPRNIRN + 1;
        end
    case 'SYS_LEO'
        if (prn < MINPRNLEO || MAXPRNLEO < prn) 
            return;
        else
            no = NSATGPS + NSATGLO + NSATGAL + NSATQZS + NSATCMP + NSATIRN + prn - MINPRNLEO + 1;
        end
    case 'SYS_SBS'
        if (prn < MINPRNSBS || MAXPRNSBS < prn) 
            return;
        else
            no = NSATGPS + NSATGLO + NSATGAL + NSATQZS + NSATCMP + NSATIRN + NSATLEO + prn - MINPRNSBS + 1;
        end
end


end


