CREATE OR REPLACE FUNCTION DOMINIC.F_WORLD_CITYTIME
(   
    P_TYPE     IN VARCHAR2 -- A:YYYYMMDDHH24MISS / D:YYYYMMDD / T: HH24MISS 
  , P_VEWCITY  IN VARCHAR2 -- City Information
  , P_VEWDAT   IN VARCHAR2
  , P_VEWTIM   IN VARCHAR2
)
   RETURN VARCHAR2
/*******************************************************************************
  - FUNCTION NAME  : F_WORLD_CITYTIME
  - DESCRIPTION    : Get World Time by City
  - MADE BY        : Dominic
  - CREATION DATE  : 2019-01-01
  ------------------------------------------------------------------------------
  - MODIFICATION (DATE, WHO, MODIFIED CONTENTS)
*******************************************************************************/
IS
    -- ROW TYPE DATA
    V_WTCTI  WTCTI%ROWTYPE;
    -- SINGLE TYPE DATA
    V_RTNVAL VARCHAR2(20) := ' ';
    
BEGIN
   
    BEGIN
    
        SELECT *
          INTO V_WTCTI
          FROM WTCTI
         WHERE 1=1
           AND CITY = P_VEWCITY -- Get City Information
           AND ROWNUM = 1 ;
           
    EXCEPTION 
          -- Can't not Found .. Default City Time by US/Eastern.
          WHEN NO_DATA_FOUND THEN
               SELECT to_char(cast(sysdate as timestamp) at time zone 'US/Eastern','YYYYMMDDHH24MISS') AS YYYYMMDDHH24MISS
                 INTO V_RTNVAL
                 FROM DUAL;
          WHEN OTHERS THEN
               SELECT to_char(cast(sysdate as timestamp) at time zone 'US/Eastern','YYYYMMDDHH24MISS') AS YYYYMMDDHH24MISS
                 INTO V_RTNVAL
                 FROM DUAL;    
    END ;
    
    IF TRIM(P_VEWDAT||P_VEWTIM) IS NULL THEN
       V_RTNVAL := TO_CHAR(sysdate,'YYYYMMDDHH24MISS');
    ELSIF TRIM(P_VEWDAT) = '00000000' OR TRIM(P_VEWTIM) = '000000' THEN
       V_RTNVAL := TO_CHAR(sysdate,'YYYYMMDDHH24MISS');
    ELSE
       V_RTNVAL := P_VEWDAT||P_VEWTIM;
    END IF;
    
    IF TRIM(V_WTCTI.NATNKY) IS NULL THEN
       SELECT to_char(cast(sysdate as timestamp) at time zone 'US/Eastern','YYYYMMDDHH24MISS') AS YYYYMMDDHH24MISS
         INTO V_RTNVAL
         FROM DUAL; 
    ELSE
       
       V_WTCTI.NATNKY := REPLACE(V_WTCTI.NATNKY,'-','/');
       
	   -- Casting by City Time.
       SELECT to_char( from_tz(cast(to_date(V_RTNVAL,'YYYYMMDDHH24MISS') as timestamp),'US/Eastern' ) at time zone (V_WTCTI.NATNKY),'YYYYMMDDHH24MISS') AS YYYYMMDDHH24MISS
         INTO V_RTNVAL
         FROM DUAL; 
    
    END IF;

    IF P_TYPE = 'D' THEN
       V_RTNVAL :=  SUBSTR(V_RTNVAL,1,8) ;
    ELSIF P_TYPE = 'T' THEN
       V_RTNVAL :=  SUBSTR(V_RTNVAL,9,6) ;
    ELSIF P_TYPE = 'A' THEN
       V_RTNVAL := V_RTNVAL;
    END IF;

    RETURN V_RTNVAL;
    
END;
