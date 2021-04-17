-- bibioteka STD jest wlaczana automatycznie do projektu

entity SUM2X4B is			-- deklaracja sprzegu 'SUM2X4B'
 port (	A : in  bit_vector(3 downto 0);	-- deklaracja portu wejsciowego 'A'
        B : in  bit_vector(3 downto 0);	-- deklaracja portu wejsciowego 'B'
        S : out bit_vector(3 downto 0);	-- deklaracja portu wyjsciowego 'S'
        P : out bit			-- deklaracja portu wyjsciowego 'P'
      ); 				-- zakonczenie deklaracji listy portow
end SUM2X4B; 				-- zakonczenie deklaracji sprzegu

architecture cialo of SUM2X4B is	-- deklaracja ciala 'cialo' architektury

  signal K :bit_vector(3 downto 0);	-- deklaracja sygnalu 'K'

begin					-- poczatek czesci wykonawczej

 SUM3B_inst0: entity work.SUM3B		-- pierwsze dolaczenie projektu 'SUMB'
    port map (A(0), B(0), '0',  S(0), K(0)); -- podlaczenie wejsc i wyjsc projektu

 SUM3B_inst1: entity work.SUM3B		-- drugie dolaczenie projektu 'SUMB'
    port map (A(1), B(1), K(0), S(1), K(1)); -- podlaczenie wejsc i wyjsc projektu

 SUM3B_inst2: entity work.SUM3B		-- trzecie dolaczenie projektu 'SUMB'
    port map (A(2), B(2), K(1), S(2), K(2)); -- podlaczenie wejsc i wyjsc projektu

 SUM3B_inst3: entity work.SUM3B		-- czwarte dolaczenie projektu 'SUMB'
    port map (A(3), B(3), K(2), S(3), K(3)); -- podlaczenie wejsc i wyjsc projektu

 P <= K(3);				-- instrukcja przypisania sygnalu do portu

end architecture cialo;			-- zakonczenie deklaracji ciala 'cialo'
