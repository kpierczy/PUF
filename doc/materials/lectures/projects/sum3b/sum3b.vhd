-- bibioteka STD jest wlaczana automatycznie do projektu

entity SUM3B is				-- deklaracja sprzegu 'SUM3B'
 port (	A : in  bit;			-- deklaracja portu wejsciowego 'A'
        B : in  bit;			-- deklaracja portu wejsciowego 'B'
        C : in  bit;			-- deklaracja portu wejsciowego 'C'
        S : out bit;			-- deklaracja portu wyjsciowego 'Y'
        P : out bit			-- deklaracja portu wyjsciowego 'P'
      ); 				-- zakonczenie deklaracji listy portow
end SUM3B; 				-- zakonczenie deklaracji sprzegu

architecture cialo of SUM3B is		-- deklaracja ciala 'cialo' architektury

  signal S1, P1, P2 :bit;		-- deklaracja sygnalow 'S1', 'P1', 'P2'

begin					-- poczatek czesci wykonawczej

 SUM2B_inst1: entity work.SUM2B		-- pierwsze dolaczenie projektu 'SUM1'
    port map (	A => A,  B => B,	-- podlaczenie wejsc 'A' i 'B' projektu
		S => S1, P => P1);	-- podlaczenie wyjsc 'S' i 'P' projektu

 SUM2B_inst2: entity work.SUM2B		-- drugie dolaczenie projektu 'SUM1'
    port map (	A => C, B => S1,	-- podlaczenie wejsc 'A' i 'B' projektu
		S => S, P => P2);	-- podlaczenie wyjsc 'S' i 'P' projektu

 P <= P1 or P2;				-- wyznaczenie sygna³u przeniesienia 'P'

end architecture cialo;			-- zakonczenie deklaracji ciala 'cialo'
