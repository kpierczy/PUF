-- bibioteka STD jest wlaczana automatycznie do projektu

entity SUM2_PARAM is				-- deklaracja sprzegu 'SUM2_PARAM'
  generic (N : integer := 6);			-- deklaracja parametru 'N'
  port (A : in  bit_vector(N-1 downto 0);	-- deklaracja portu wejsciowego 'A'
        B : in  bit_vector(N-1 downto 0);	-- deklaracja portu wejsciowego 'B'
        S : out bit_vector(N-1 downto 0);	-- deklaracja portu wyjsciowego 'S'
        P : out bit				-- deklaracja portu wyjsciowego 'P'
       ); 					-- zakonczenie deklaracji listy portow
end SUM2_PARAM; 				-- zakonczenie deklaracji sprzegu

architecture cialo of SUM2_PARAM is		-- deklaracja ciala 'cialo' architektury

  signal K :bit_vector(N-1 downto 0);		-- deklaracja sygnalu 'K'

begin						-- poczatek czesci wykonawczej

  lg: for i in 0 to N-1 generate		-- N-krotna petla powielania		
     signal KI :bit := '0';			-- deklaracja sygnalu w petli powielania
  begin						-- czesc wykowanwcza petli powielania
  
    i2: if (i>0) generate			-- generacja warunkowa gdy 'i>0'
      KI <= K(i-1);				-- przypisanie sygnalu przeniesienia
    end generate;				-- zakonczenie generacji warunkowej
    
    SUM3B_inst: entity work.SUM3B		-- dolaczenie projektu 'SUMB'
      port map (A(i), B(i), KI,  S(i), K(i));	-- podlaczenie wejsc i wyjsc projektu
      
  end generate;					-- zakonczenie petli powielania

  P <= K(N-1);					-- instrukcja przypisania sygnalu do portu

end architecture cialo;				-- zakonczenie deklaracji ciala 'cialo'
